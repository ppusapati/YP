package pipeline

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/IBM/sarama"
	"github.com/jackc/pgx/v5/pgxpool"
	"google.golang.org/protobuf/proto"

	msgp "p9e.in/samavaya/packages/api/v1/message"
	"p9e.in/samavaya/packages/p9log"
)

// Severity indicates how critical a quality rule violation is.
type Severity int

const (
	SeverityInfo Severity = iota
	SeverityWarning
	SeverityError
	SeverityCritical
)

func (s Severity) String() string {
	switch s {
	case SeverityInfo:
		return "info"
	case SeverityWarning:
		return "warning"
	case SeverityError:
		return "error"
	case SeverityCritical:
		return "critical"
	default:
		return "unknown"
	}
}

// QualityRule defines a single data quality check.
type QualityRule interface {
	// Name returns the rule identifier.
	Name() string
	// Check validates a single record and returns nil if valid.
	Check(record map[string]interface{}) error
	// Severity returns how critical violations are.
	RuleSeverity() Severity
}

// RuleViolation captures a single rule check failure.
type RuleViolation struct {
	RuleName string `json:"rule_name"`
	Severity string `json:"severity"`
	Message  string `json:"message"`
	RecordID string `json:"record_id,omitempty"`
}

// QualityReport summarizes the outcome of quality checks against a data batch.
type QualityReport struct {
	JobName      string          `json:"job_name"`
	RunAt        time.Time       `json:"run_at"`
	TotalRecords int             `json:"total_records"`
	Passed       int             `json:"passed"`
	Failed       int             `json:"failed"`
	Violations   []RuleViolation `json:"violations"`
}

// QualityMonitor runs a set of quality rules against data batches.
type QualityMonitor struct {
	rules []QualityRule
	pool  *pgxpool.Pool
	log   p9log.Logger
}

// NewQualityMonitor creates a monitor with the provided rules.
func NewQualityMonitor(pool *pgxpool.Pool, log p9log.Logger, rules ...QualityRule) *QualityMonitor {
	return &QualityMonitor{rules: rules, pool: pool, log: log}
}

// AddRule appends a quality rule.
func (qm *QualityMonitor) AddRule(rule QualityRule) {
	qm.rules = append(qm.rules, rule)
}

// Validate runs all rules against each record and returns a report.
func (qm *QualityMonitor) Validate(ctx context.Context, jobName string, records []map[string]interface{}) *QualityReport {
	report := &QualityReport{
		JobName:      jobName,
		RunAt:        time.Now(),
		TotalRecords: len(records),
	}

	for i, record := range records {
		recordFailed := false
		recordID := ""
		if id, ok := record["id"]; ok {
			recordID = fmt.Sprintf("%v", id)
		} else {
			recordID = fmt.Sprintf("record-%d", i)
		}

		for _, rule := range qm.rules {
			if err := rule.Check(record); err != nil {
				recordFailed = true
				report.Violations = append(report.Violations, RuleViolation{
					RuleName: rule.Name(),
					Severity: rule.RuleSeverity().String(),
					Message:  err.Error(),
					RecordID: recordID,
				})
			}
		}

		if recordFailed {
			report.Failed++
		} else {
			report.Passed++
		}
	}

	return report
}

// PersistReport stores the quality report in the data_quality_reports table.
func (qm *QualityMonitor) PersistReport(ctx context.Context, tenantID string, report *QualityReport) error {
	if qm.pool == nil {
		return nil
	}

	details, err := json.Marshal(report.Violations)
	if err != nil {
		return fmt.Errorf("quality: marshal violations: %w", err)
	}

	_, err = qm.pool.Exec(ctx, `
		INSERT INTO data_quality_reports
			(tenant_id, job_name, run_at, total_records, passed, failed, details)
		VALUES ($1, $2, $3, $4, $5, $6, $7)`,
		tenantID, report.JobName, report.RunAt,
		report.TotalRecords, report.Passed, report.Failed, details)
	if err != nil {
		return fmt.Errorf("quality: persist report: %w", err)
	}
	return nil
}

// --------------------------------------------------------------------------
// Pre-built quality rules
// --------------------------------------------------------------------------

// NullCheck verifies that required fields are present and non-nil.
type NullCheck struct {
	Fields   []string
	severity Severity
}

func NewNullCheck(fields []string, severity Severity) *NullCheck {
	return &NullCheck{Fields: fields, severity: severity}
}

func (n *NullCheck) Name() string           { return "null_check" }
func (n *NullCheck) RuleSeverity() Severity { return n.severity }

func (n *NullCheck) Check(record map[string]interface{}) error {
	for _, f := range n.Fields {
		v, ok := record[f]
		if !ok || v == nil {
			return fmt.Errorf("field %q is null or missing", f)
		}
	}
	return nil
}

// RangeCheck validates that a numeric field falls within [Min, Max].
type RangeCheck struct {
	Field    string
	Min      float64
	Max      float64
	severity Severity
}

func NewRangeCheck(field string, min, max float64, severity Severity) *RangeCheck {
	return &RangeCheck{Field: field, Min: min, Max: max, severity: severity}
}

func (r *RangeCheck) Name() string           { return "range_check" }
func (r *RangeCheck) RuleSeverity() Severity { return r.severity }

func (r *RangeCheck) Check(record map[string]interface{}) error {
	v, ok := record[r.Field]
	if !ok {
		return nil // let NullCheck handle missing fields
	}
	var val float64
	switch n := v.(type) {
	case float64:
		val = n
	case int:
		val = float64(n)
	case int64:
		val = float64(n)
	default:
		return fmt.Errorf("field %q is not numeric", r.Field)
	}
	if val < r.Min || val > r.Max {
		return fmt.Errorf("field %q value %.2f out of range [%.2f, %.2f]", r.Field, val, r.Min, r.Max)
	}
	return nil
}

// FreshnessCheck ensures a timestamp field is not older than MaxAge.
type FreshnessCheck struct {
	Field    string
	MaxAge   time.Duration
	severity Severity
	nowFn    func() time.Time // injectable for testing
}

func NewFreshnessCheck(field string, maxAge time.Duration, severity Severity) *FreshnessCheck {
	return &FreshnessCheck{Field: field, MaxAge: maxAge, severity: severity}
}

func (f *FreshnessCheck) Name() string           { return "freshness_check" }
func (f *FreshnessCheck) RuleSeverity() Severity { return f.severity }

func (f *FreshnessCheck) Check(record map[string]interface{}) error {
	v, ok := record[f.Field]
	if !ok {
		return nil
	}
	var ts time.Time
	switch t := v.(type) {
	case time.Time:
		ts = t
	case string:
		var err error
		ts, err = time.Parse(time.RFC3339, t)
		if err != nil {
			return fmt.Errorf("field %q is not a valid RFC3339 timestamp", f.Field)
		}
	default:
		return fmt.Errorf("field %q is not a timestamp", f.Field)
	}

	now := time.Now()
	if f.nowFn != nil {
		now = f.nowFn()
	}
	if now.Sub(ts) > f.MaxAge {
		return fmt.Errorf("field %q is stale: age %v exceeds max %v", f.Field, now.Sub(ts).Truncate(time.Second), f.MaxAge)
	}
	return nil
}

// UniquenessCheck validates that a field value has not been seen before in the batch.
// Note: this check is stateful within a single Validate call because it tracks
// seen values. Create a new instance for each batch.
type UniquenessCheck struct {
	Field    string
	severity Severity
	seen     map[interface{}]bool
}

func NewUniquenessCheck(field string, severity Severity) *UniquenessCheck {
	return &UniquenessCheck{Field: field, severity: severity, seen: make(map[interface{}]bool)}
}

func (u *UniquenessCheck) Name() string           { return "uniqueness_check" }
func (u *UniquenessCheck) RuleSeverity() Severity { return u.severity }

func (u *UniquenessCheck) Check(record map[string]interface{}) error {
	v, ok := record[u.Field]
	if !ok {
		return nil
	}
	if u.seen[v] {
		return fmt.Errorf("field %q has duplicate value: %v", u.Field, v)
	}
	u.seen[v] = true
	return nil
}

// Reset clears the seen values for reuse across batches.
func (u *UniquenessCheck) Reset() {
	u.seen = make(map[interface{}]bool)
}

// --------------------------------------------------------------------------
// Kafka consumer with quality validation
// --------------------------------------------------------------------------

// ValidatingConsumer wraps a Kafka consumer that validates messages against
// quality rules before forwarding them to a downstream channel.
type ValidatingConsumer struct {
	consumer      sarama.ConsumerGroup
	monitor       *QualityMonitor
	log           p9log.Logger
	validTopic    string
	invalidTopic  string
	producer      sarama.SyncProducer
	extractFields func([]byte) (map[string]interface{}, error)
}

// ValidatingConsumerConfig holds configuration for the validating consumer.
type ValidatingConsumerConfig struct {
	ConsumerGroup sarama.ConsumerGroup
	Monitor       *QualityMonitor
	Log           p9log.Logger
	ValidTopic    string // topic to forward valid messages
	InvalidTopic  string // topic for rejected messages (dead letter)
	Producer      sarama.SyncProducer
	ExtractFields func([]byte) (map[string]interface{}, error)
}

// NewValidatingConsumer creates a consumer that validates before forwarding.
func NewValidatingConsumer(cfg ValidatingConsumerConfig) *ValidatingConsumer {
	extract := cfg.ExtractFields
	if extract == nil {
		extract = defaultExtractFields
	}
	return &ValidatingConsumer{
		consumer:      cfg.ConsumerGroup,
		monitor:       cfg.Monitor,
		log:           cfg.Log,
		validTopic:    cfg.ValidTopic,
		invalidTopic:  cfg.InvalidTopic,
		producer:      cfg.Producer,
		extractFields: extract,
	}
}

func defaultExtractFields(data []byte) (map[string]interface{}, error) {
	var m map[string]interface{}
	if err := json.Unmarshal(data, &m); err != nil {
		return nil, fmt.Errorf("quality: unmarshal message: %w", err)
	}
	return m, nil
}

// ValidateMessage checks a single message against quality rules and routes
// it to the valid or invalid topic.
func (vc *ValidatingConsumer) ValidateMessage(ctx context.Context, msg *msgp.EventMessage) error {
	data := msg.GetValue().GetValue()
	fields, err := vc.extractFields(data)
	if err != nil {
		return vc.routeInvalid(ctx, msg, fmt.Sprintf("parse error: %v", err))
	}

	report := vc.monitor.Validate(ctx, "kafka_validation", []map[string]interface{}{fields})
	if report.Failed > 0 {
		reason := "validation failed"
		if len(report.Violations) > 0 {
			reason = report.Violations[0].Message
		}
		return vc.routeInvalid(ctx, msg, reason)
	}

	return vc.routeValid(ctx, msg)
}

func (vc *ValidatingConsumer) routeValid(ctx context.Context, msg *msgp.EventMessage) error {
	if vc.producer == nil || vc.validTopic == "" {
		return nil
	}
	data, err := proto.Marshal(msg)
	if err != nil {
		return fmt.Errorf("quality: marshal valid message: %w", err)
	}
	_, _, err = vc.producer.SendMessage(&sarama.ProducerMessage{
		Topic: vc.validTopic,
		Key:   sarama.ByteEncoder(msg.Key),
		Value: sarama.ByteEncoder(data),
	})
	return err
}

func (vc *ValidatingConsumer) routeInvalid(ctx context.Context, msg *msgp.EventMessage, reason string) error {
	if vc.producer == nil || vc.invalidTopic == "" {
		vc.log.Warn("quality", "msg", "invalid message dropped", "reason", reason)
		return nil
	}
	// Attach rejection reason to headers or log it.
	vc.log.Warn("quality", "msg", "routing to dead letter", "reason", reason, "topic", vc.invalidTopic)
	data, err := proto.Marshal(msg)
	if err != nil {
		return fmt.Errorf("quality: marshal invalid message: %w", err)
	}
	_, _, err = vc.producer.SendMessage(&sarama.ProducerMessage{
		Topic: vc.invalidTopic,
		Key:   sarama.ByteEncoder(msg.Key),
		Value: sarama.ByteEncoder(data),
		Headers: []sarama.RecordHeader{
			{Key: []byte("rejection_reason"), Value: []byte(reason)},
		},
	})
	return err
}
