// Package featureflags provides a feature flag system with support for boolean flags,
// percentage-based rollouts, multivariate flags, and targeting rules. It is designed
// to integrate with the p9e.in/samavaya platform's ConnectRPC microservices via
// interceptors and context-based evaluation.
package featureflags

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"sync"
	"time"
)

// Attributes holds key-value pairs used for targeting and consistent hashing
// during flag evaluation. Common keys include "tenant_id", "user_id", "user_role",
// and "region".
type Attributes map[string]string

// TargetingRule defines a condition that must match for a flag to be enabled
// for a specific set of users/tenants.
type TargetingRule struct {
	// Attribute is the key to match against (e.g., "tenant_id", "user_role", "region").
	Attribute string `json:"attribute" yaml:"attribute"`
	// Operator is the comparison operator: "eq", "neq", "in", "not_in".
	Operator string `json:"operator" yaml:"operator"`
	// Values is the set of values to compare against.
	Values []string `json:"values" yaml:"values"`
}

// Variant represents one possible value for a multivariate flag.
type Variant struct {
	// Key is the unique identifier for this variant (e.g., "control", "treatment_a").
	Key string `json:"key" yaml:"key"`
	// Description provides a human-readable explanation of the variant.
	Description string `json:"description,omitempty" yaml:"description,omitempty"`
	// Weight determines the relative probability of this variant being selected
	// during percentage-based evaluation. Weights across all variants are summed
	// and each variant receives weight/totalWeight proportion.
	Weight int `json:"weight" yaml:"weight"`
	// Payload is optional arbitrary data attached to the variant.
	Payload map[string]interface{} `json:"payload,omitempty" yaml:"payload,omitempty"`
}

// FlagType categorizes the flag behavior.
type FlagType string

const (
	// FlagTypeBoolean is a simple on/off flag.
	FlagTypeBoolean FlagType = "boolean"
	// FlagTypePercentage is a percentage-based rollout flag.
	FlagTypePercentage FlagType = "percentage"
	// FlagTypeMultivariate is a flag with multiple possible variants.
	FlagTypeMultivariate FlagType = "multivariate"
	// FlagTypeKillSwitch is a flag that gates external API access.
	FlagTypeKillSwitch FlagType = "killswitch"
)

// Flag represents a single feature flag definition.
type Flag struct {
	// Name is the unique identifier for the flag.
	Name string `json:"name" yaml:"name"`
	// Description is a human-readable explanation of the flag's purpose.
	Description string `json:"description,omitempty" yaml:"description,omitempty"`
	// Type categorizes the flag behavior.
	Type FlagType `json:"type" yaml:"type"`
	// Enabled controls whether the flag is active. When false, the flag always
	// evaluates to its default value regardless of other settings.
	Enabled bool `json:"enabled" yaml:"enabled"`
	// RolloutPercentage is the percentage of users/tenants that should receive
	// the enabled value (0-100). Only used for FlagTypePercentage flags.
	RolloutPercentage int `json:"rollout_percentage" yaml:"rollout_percentage"`
	// Variants defines the possible values for multivariate flags.
	Variants []Variant `json:"variants,omitempty" yaml:"variants,omitempty"`
	// TargetingRules defines conditions that override the default evaluation.
	// If any rule matches, the flag is enabled regardless of rollout percentage.
	TargetingRules []TargetingRule `json:"targeting_rules,omitempty" yaml:"targeting_rules,omitempty"`
	// DefaultVariant is the variant key returned when the flag is disabled or
	// when evaluation does not select any variant.
	DefaultVariant string `json:"default_variant,omitempty" yaml:"default_variant,omitempty"`
	// Tags provides optional metadata for organizing and filtering flags.
	Tags []string `json:"tags,omitempty" yaml:"tags,omitempty"`
	// UpdatedAt records when the flag was last modified.
	UpdatedAt time.Time `json:"updated_at,omitempty" yaml:"updated_at,omitempty"`
}

// EvaluationResult holds the outcome of a flag evaluation.
type EvaluationResult struct {
	// FlagName is the name of the evaluated flag.
	FlagName string
	// Enabled indicates whether the flag is on for the given attributes.
	Enabled bool
	// VariantKey is the selected variant key for multivariate flags.
	VariantKey string
	// Payload is the optional data from the selected variant.
	Payload map[string]interface{}
	// Reason explains why this result was produced.
	Reason string
}

// FlagService defines the interface for interacting with feature flags.
type FlagService interface {
	// IsEnabled checks whether a boolean or percentage flag is enabled for the
	// given attributes.
	IsEnabled(ctx context.Context, flagName string, attributes Attributes) bool
	// GetVariant evaluates a flag and returns the full evaluation result, including
	// the selected variant for multivariate flags.
	GetVariant(ctx context.Context, flagName string, attributes Attributes) EvaluationResult
	// ListFlags returns all configured flags.
	ListFlags(ctx context.Context) []Flag
}

// EvaluationLogger is called after each flag evaluation to record the result
// for experiment tracking and analytics.
type EvaluationLogger interface {
	LogEvaluation(ctx context.Context, result EvaluationResult, attributes Attributes)
}

// InMemoryFlagService is a thread-safe in-memory implementation of FlagService
// that supports loading flags from JSON files.
type InMemoryFlagService struct {
	mu        sync.RWMutex
	flags     map[string]*Flag
	evaluator *Evaluator
	logger    EvaluationLogger
}

// InMemoryOption configures the InMemoryFlagService.
type InMemoryOption func(*InMemoryFlagService)

// WithEvaluationLogger sets an evaluation logger on the flag service.
func WithEvaluationLogger(logger EvaluationLogger) InMemoryOption {
	return func(s *InMemoryFlagService) {
		s.logger = logger
	}
}

// NewInMemoryFlagService creates a new InMemoryFlagService.
func NewInMemoryFlagService(opts ...InMemoryOption) *InMemoryFlagService {
	s := &InMemoryFlagService{
		flags:     make(map[string]*Flag),
		evaluator: NewEvaluator(),
	}
	for _, opt := range opts {
		opt(s)
	}
	return s
}

// IsEnabled checks whether a flag is enabled for the given attributes.
// Returns false if the flag does not exist.
func (s *InMemoryFlagService) IsEnabled(ctx context.Context, flagName string, attributes Attributes) bool {
	result := s.GetVariant(ctx, flagName, attributes)
	return result.Enabled
}

// GetVariant evaluates a flag and returns the full result.
func (s *InMemoryFlagService) GetVariant(ctx context.Context, flagName string, attributes Attributes) EvaluationResult {
	s.mu.RLock()
	flag, exists := s.flags[flagName]
	if !exists {
		s.mu.RUnlock()
		result := EvaluationResult{
			FlagName: flagName,
			Enabled:  false,
			Reason:   "flag_not_found",
		}
		if s.logger != nil {
			s.logger.LogEvaluation(ctx, result, attributes)
		}
		return result
	}
	// Copy the flag under read lock so evaluation proceeds without holding the lock.
	flagCopy := *flag
	s.mu.RUnlock()

	result := s.evaluator.Evaluate(&flagCopy, attributes)

	if s.logger != nil {
		s.logger.LogEvaluation(ctx, result, attributes)
	}

	return result
}

// ListFlags returns all configured flags.
func (s *InMemoryFlagService) ListFlags(_ context.Context) []Flag {
	s.mu.RLock()
	defer s.mu.RUnlock()

	flags := make([]Flag, 0, len(s.flags))
	for _, f := range s.flags {
		flags = append(flags, *f)
	}
	return flags
}

// SetFlag adds or updates a flag in the service. This is thread-safe.
func (s *InMemoryFlagService) SetFlag(flag Flag) {
	s.mu.Lock()
	defer s.mu.Unlock()
	flag.UpdatedAt = time.Now()
	s.flags[flag.Name] = &flag
}

// RemoveFlag removes a flag from the service. This is thread-safe.
func (s *InMemoryFlagService) RemoveFlag(name string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	delete(s.flags, name)
}

// GetFlag returns a copy of the named flag, or nil if not found.
func (s *InMemoryFlagService) GetFlag(name string) *Flag {
	s.mu.RLock()
	defer s.mu.RUnlock()
	f, ok := s.flags[name]
	if !ok {
		return nil
	}
	copy := *f
	return &copy
}

// ReplaceAll atomically replaces all flags with the provided set.
func (s *InMemoryFlagService) ReplaceAll(flags []Flag) {
	newMap := make(map[string]*Flag, len(flags))
	for i := range flags {
		f := flags[i]
		newMap[f.Name] = &f
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	s.flags = newMap
}

// LoadFromJSON loads flags from a JSON file, replacing all current flags.
func (s *InMemoryFlagService) LoadFromJSON(path string) error {
	data, err := os.ReadFile(path)
	if err != nil {
		return fmt.Errorf("featureflags: read file %s: %w", path, err)
	}

	var config struct {
		Flags []Flag `json:"flags"`
	}
	if err := json.Unmarshal(data, &config); err != nil {
		return fmt.Errorf("featureflags: parse JSON from %s: %w", path, err)
	}

	s.ReplaceAll(config.Flags)
	return nil
}

// FlagCount returns the number of flags currently loaded.
func (s *InMemoryFlagService) FlagCount() int {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return len(s.flags)
}
