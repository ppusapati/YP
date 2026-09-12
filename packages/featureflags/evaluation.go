package featureflags

import (
	"context"
	"fmt"
	"hash/crc32"
	"sort"
	"strings"
	"time"
)

// Evaluator performs flag evaluation with consistent hashing for percentage-based
// rollouts and rule-based targeting.
type Evaluator struct{}

// NewEvaluator creates a new flag evaluator.
func NewEvaluator() *Evaluator {
	return &Evaluator{}
}

// Evaluate determines the result for a given flag and attributes.
func (e *Evaluator) Evaluate(flag *Flag, attrs Attributes) EvaluationResult {
	result := EvaluationResult{
		FlagName: flag.Name,
	}

	// If the flag is globally disabled, return the default.
	if !flag.Enabled {
		result.Enabled = false
		result.Reason = "flag_disabled"
		result.VariantKey = flag.DefaultVariant
		result.Payload = e.variantPayload(flag, flag.DefaultVariant)
		return result
	}

	// Check targeting rules first; if any rule matches, the flag is enabled.
	if len(flag.TargetingRules) > 0 {
		if matched, rule := e.matchesTargetingRules(flag.TargetingRules, attrs); matched {
			result.Enabled = true
			result.Reason = fmt.Sprintf("targeting_rule_match:%s=%s", rule.Attribute, rule.Operator)

			if flag.Type == FlagTypeMultivariate && len(flag.Variants) > 0 {
				variant := e.selectVariant(flag, attrs)
				result.VariantKey = variant.Key
				result.Payload = variant.Payload
			}
			return result
		}
	}

	// Evaluate based on flag type.
	switch flag.Type {
	case FlagTypeBoolean, FlagTypeKillSwitch:
		result.Enabled = true
		result.Reason = "flag_enabled"

	case FlagTypePercentage:
		hashKey := e.buildHashKey(flag.Name, attrs)
		bucket := consistentHash(hashKey, 100)
		result.Enabled = bucket < flag.RolloutPercentage
		if result.Enabled {
			result.Reason = fmt.Sprintf("percentage_rollout:%d%%", flag.RolloutPercentage)
		} else {
			result.Reason = fmt.Sprintf("percentage_excluded:%d%%", flag.RolloutPercentage)
			result.VariantKey = flag.DefaultVariant
			result.Payload = e.variantPayload(flag, flag.DefaultVariant)
		}

	case FlagTypeMultivariate:
		result.Enabled = true
		variant := e.selectVariant(flag, attrs)
		result.VariantKey = variant.Key
		result.Payload = variant.Payload
		result.Reason = fmt.Sprintf("multivariate:%s", variant.Key)

	default:
		result.Enabled = false
		result.Reason = "unknown_flag_type"
	}

	return result
}

// matchesTargetingRules checks whether the given attributes satisfy any of the
// targeting rules. Returns true and the first matching rule, or false.
func (e *Evaluator) matchesTargetingRules(rules []TargetingRule, attrs Attributes) (bool, TargetingRule) {
	for _, rule := range rules {
		attrValue, exists := attrs[rule.Attribute]
		if !exists {
			continue
		}
		if e.evaluateRule(rule, attrValue) {
			return true, rule
		}
	}
	return false, TargetingRule{}
}

// evaluateRule checks a single targeting rule against an attribute value.
func (e *Evaluator) evaluateRule(rule TargetingRule, attrValue string) bool {
	switch rule.Operator {
	case "eq":
		return len(rule.Values) > 0 && rule.Values[0] == attrValue
	case "neq":
		return len(rule.Values) > 0 && rule.Values[0] != attrValue
	case "in":
		for _, v := range rule.Values {
			if v == attrValue {
				return true
			}
		}
		return false
	case "not_in":
		for _, v := range rule.Values {
			if v == attrValue {
				return false
			}
		}
		return true
	case "contains":
		return len(rule.Values) > 0 && strings.Contains(attrValue, rule.Values[0])
	default:
		return false
	}
}

// selectVariant picks a variant using consistent hashing based on weights.
func (e *Evaluator) selectVariant(flag *Flag, attrs Attributes) Variant {
	if len(flag.Variants) == 0 {
		return Variant{Key: flag.DefaultVariant}
	}

	totalWeight := 0
	for _, v := range flag.Variants {
		totalWeight += v.Weight
	}
	if totalWeight == 0 {
		// Equal distribution when no weights are configured.
		totalWeight = len(flag.Variants)
		for i := range flag.Variants {
			flag.Variants[i].Weight = 1
		}
	}

	hashKey := e.buildHashKey(flag.Name, attrs)
	bucket := consistentHash(hashKey, totalWeight)

	cumulative := 0
	for _, v := range flag.Variants {
		cumulative += v.Weight
		if bucket < cumulative {
			return v
		}
	}

	// Fallback to last variant (should not happen with valid weights).
	return flag.Variants[len(flag.Variants)-1]
}

// buildHashKey constructs a deterministic key for consistent hashing from the
// flag name and user/tenant attributes. The key is stable across evaluations
// for the same user, ensuring consistent rollout assignment.
func (e *Evaluator) buildHashKey(flagName string, attrs Attributes) string {
	var b strings.Builder
	b.WriteString(flagName)

	// Use tenant_id and user_id if available for consistent assignment.
	if tid, ok := attrs["tenant_id"]; ok {
		b.WriteString(":")
		b.WriteString(tid)
	}
	if uid, ok := attrs["user_id"]; ok {
		b.WriteString(":")
		b.WriteString(uid)
	}

	// If neither is present, use a sorted concatenation of all attributes
	// so the hash is still deterministic.
	if _, hasTenant := attrs["tenant_id"]; !hasTenant {
		if _, hasUser := attrs["user_id"]; !hasUser {
			keys := make([]string, 0, len(attrs))
			for k := range attrs {
				keys = append(keys, k)
			}
			sort.Strings(keys)
			for _, k := range keys {
				b.WriteString(":")
				b.WriteString(k)
				b.WriteString("=")
				b.WriteString(attrs[k])
			}
		}
	}

	return b.String()
}

// consistentHash returns a deterministic bucket in [0, buckets) for the given key.
// It uses CRC32 for speed and good distribution.
func consistentHash(key string, buckets int) int {
	if buckets <= 0 {
		return 0
	}
	h := crc32.ChecksumIEEE([]byte(key))
	return int(h % uint32(buckets))
}

// LogEntry represents a recorded flag evaluation for experiment tracking.
type LogEntry struct {
	Timestamp  time.Time         `json:"timestamp"`
	FlagName   string            `json:"flag_name"`
	Enabled    bool              `json:"enabled"`
	VariantKey string            `json:"variant_key,omitempty"`
	Reason     string            `json:"reason"`
	Attributes map[string]string `json:"attributes,omitempty"`
}

// InMemoryEvaluationLogger captures evaluation results in memory for testing
// and local experiment tracking.
type InMemoryEvaluationLogger struct {
	mu      sync.Mutex
	entries []LogEntry
}

// NewInMemoryEvaluationLogger creates a new in-memory evaluation logger.
func NewInMemoryEvaluationLogger() *InMemoryEvaluationLogger {
	return &InMemoryEvaluationLogger{}
}

// LogEvaluation records a flag evaluation result.
func (l *InMemoryEvaluationLogger) LogEvaluation(_ context.Context, result EvaluationResult, attributes Attributes) {
	l.mu.Lock()
	defer l.mu.Unlock()

	entry := LogEntry{
		Timestamp:  time.Now(),
		FlagName:   result.FlagName,
		Enabled:    result.Enabled,
		VariantKey: result.VariantKey,
		Reason:     result.Reason,
	}
	if len(attributes) > 0 {
		entry.Attributes = make(map[string]string, len(attributes))
		for k, v := range attributes {
			entry.Attributes[k] = v
		}
	}
	l.entries = append(l.entries, entry)
}

// Entries returns a copy of all recorded log entries.
func (l *InMemoryEvaluationLogger) Entries() []LogEntry {
	l.mu.Lock()
	defer l.mu.Unlock()

	out := make([]LogEntry, len(l.entries))
	copy(out, l.entries)
	return out
}

// Clear removes all recorded entries.
func (l *InMemoryEvaluationLogger) Clear() {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.entries = l.entries[:0]
}

// NopEvaluationLogger discards all evaluation logs. Use in production when
// evaluation logging is not needed.
type NopEvaluationLogger struct{}

// LogEvaluation is a no-op.
func (NopEvaluationLogger) LogEvaluation(_ context.Context, _ EvaluationResult, _ Attributes) {}
