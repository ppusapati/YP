package pipeline

import (
	"context"
	"testing"
	"time"
)

func TestNullCheck_MissingField(t *testing.T) {
	rule := NewNullCheck([]string{"name", "value"}, SeverityError)

	err := rule.Check(map[string]interface{}{"name": "ok"})
	if err == nil {
		t.Fatal("expected error for missing 'value' field")
	}
}

func TestNullCheck_NilField(t *testing.T) {
	rule := NewNullCheck([]string{"name"}, SeverityError)

	err := rule.Check(map[string]interface{}{"name": nil})
	if err == nil {
		t.Fatal("expected error for nil field")
	}
}

func TestNullCheck_AllPresent(t *testing.T) {
	rule := NewNullCheck([]string{"name", "value"}, SeverityError)

	err := rule.Check(map[string]interface{}{"name": "ok", "value": 42})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
}

func TestRangeCheck_InRange(t *testing.T) {
	rule := NewRangeCheck("ph", 0, 14, SeverityWarning)

	err := rule.Check(map[string]interface{}{"ph": 7.0})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
}

func TestRangeCheck_BelowMin(t *testing.T) {
	rule := NewRangeCheck("ph", 0, 14, SeverityWarning)

	err := rule.Check(map[string]interface{}{"ph": -1.0})
	if err == nil {
		t.Fatal("expected error for value below min")
	}
}

func TestRangeCheck_AboveMax(t *testing.T) {
	rule := NewRangeCheck("ph", 0, 14, SeverityWarning)

	err := rule.Check(map[string]interface{}{"ph": 15.0})
	if err == nil {
		t.Fatal("expected error for value above max")
	}
}

func TestRangeCheck_MissingField(t *testing.T) {
	rule := NewRangeCheck("ph", 0, 14, SeverityWarning)

	// Missing field should not error (let NullCheck handle it).
	err := rule.Check(map[string]interface{}{})
	if err != nil {
		t.Fatalf("unexpected error for missing field: %v", err)
	}
}

func TestRangeCheck_IntField(t *testing.T) {
	rule := NewRangeCheck("count", 0, 100, SeverityWarning)

	err := rule.Check(map[string]interface{}{"count": 50})
	if err != nil {
		t.Fatalf("unexpected error for int field: %v", err)
	}

	err = rule.Check(map[string]interface{}{"count": int64(75)})
	if err != nil {
		t.Fatalf("unexpected error for int64 field: %v", err)
	}
}

func TestRangeCheck_NonNumeric(t *testing.T) {
	rule := NewRangeCheck("ph", 0, 14, SeverityWarning)

	err := rule.Check(map[string]interface{}{"ph": "not a number"})
	if err == nil {
		t.Fatal("expected error for non-numeric field")
	}
}

func TestFreshnessCheck_Fresh(t *testing.T) {
	rule := NewFreshnessCheck("timestamp", 1*time.Hour, SeverityError)

	record := map[string]interface{}{
		"timestamp": time.Now().Add(-30 * time.Minute),
	}
	err := rule.Check(record)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
}

func TestFreshnessCheck_Stale(t *testing.T) {
	rule := NewFreshnessCheck("timestamp", 1*time.Hour, SeverityError)

	record := map[string]interface{}{
		"timestamp": time.Now().Add(-2 * time.Hour),
	}
	err := rule.Check(record)
	if err == nil {
		t.Fatal("expected error for stale data")
	}
}

func TestFreshnessCheck_StringTimestamp(t *testing.T) {
	rule := NewFreshnessCheck("timestamp", 1*time.Hour, SeverityError)
	rule.nowFn = func() time.Time {
		return time.Date(2024, 6, 15, 12, 0, 0, 0, time.UTC)
	}

	record := map[string]interface{}{
		"timestamp": "2024-06-15T11:30:00Z",
	}
	err := rule.Check(record)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
}

func TestFreshnessCheck_InvalidString(t *testing.T) {
	rule := NewFreshnessCheck("timestamp", 1*time.Hour, SeverityError)

	record := map[string]interface{}{
		"timestamp": "not-a-timestamp",
	}
	err := rule.Check(record)
	if err == nil {
		t.Fatal("expected error for invalid timestamp string")
	}
}

func TestFreshnessCheck_MissingField(t *testing.T) {
	rule := NewFreshnessCheck("timestamp", 1*time.Hour, SeverityError)
	err := rule.Check(map[string]interface{}{})
	if err != nil {
		t.Fatalf("unexpected error for missing field: %v", err)
	}
}

func TestUniquenessCheck_UniqueValues(t *testing.T) {
	rule := NewUniquenessCheck("id", SeverityError)

	if err := rule.Check(map[string]interface{}{"id": "a"}); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if err := rule.Check(map[string]interface{}{"id": "b"}); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
}

func TestUniquenessCheck_DuplicateValues(t *testing.T) {
	rule := NewUniquenessCheck("id", SeverityError)

	if err := rule.Check(map[string]interface{}{"id": "a"}); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if err := rule.Check(map[string]interface{}{"id": "a"}); err == nil {
		t.Fatal("expected error for duplicate value")
	}
}

func TestUniquenessCheck_Reset(t *testing.T) {
	rule := NewUniquenessCheck("id", SeverityError)

	_ = rule.Check(map[string]interface{}{"id": "a"})
	rule.Reset()

	// After reset, "a" should be accepted again.
	if err := rule.Check(map[string]interface{}{"id": "a"}); err != nil {
		t.Fatalf("unexpected error after reset: %v", err)
	}
}

func TestQualityMonitor_Validate(t *testing.T) {
	monitor := NewQualityMonitor(nil, nil,
		NewNullCheck([]string{"name"}, SeverityError),
		NewRangeCheck("value", 0, 100, SeverityWarning),
	)

	records := []map[string]interface{}{
		{"id": "1", "name": "sensor-a", "value": 50.0},       // pass
		{"id": "2", "value": 50.0},                           // fail: missing name
		{"id": "3", "name": "sensor-c", "value": 150.0},      // fail: out of range
		{"id": "4", "name": "sensor-d", "value": 75.0},       // pass
	}

	report := monitor.Validate(context.Background(), "test-job", records)

	if report.TotalRecords != 4 {
		t.Errorf("expected 4 total, got %d", report.TotalRecords)
	}
	if report.Passed != 2 {
		t.Errorf("expected 2 passed, got %d", report.Passed)
	}
	if report.Failed != 2 {
		t.Errorf("expected 2 failed, got %d", report.Failed)
	}
	if len(report.Violations) != 2 {
		t.Errorf("expected 2 violations, got %d", len(report.Violations))
	}
	if report.JobName != "test-job" {
		t.Errorf("expected job_name=test-job, got %s", report.JobName)
	}
}

func TestQualityMonitor_ValidateAllPass(t *testing.T) {
	monitor := NewQualityMonitor(nil, nil,
		NewNullCheck([]string{"name"}, SeverityError),
	)

	records := []map[string]interface{}{
		{"name": "a"},
		{"name": "b"},
	}

	report := monitor.Validate(context.Background(), "all-pass", records)
	if report.Failed != 0 {
		t.Errorf("expected 0 failures, got %d", report.Failed)
	}
	if report.Passed != 2 {
		t.Errorf("expected 2 passed, got %d", report.Passed)
	}
}

func TestQualityMonitor_ValidateEmpty(t *testing.T) {
	monitor := NewQualityMonitor(nil, nil)
	report := monitor.Validate(context.Background(), "empty", nil)
	if report.TotalRecords != 0 {
		t.Errorf("expected 0 total, got %d", report.TotalRecords)
	}
}

func TestQualityMonitor_AddRule(t *testing.T) {
	monitor := NewQualityMonitor(nil, nil)
	monitor.AddRule(NewNullCheck([]string{"x"}, SeverityInfo))

	records := []map[string]interface{}{
		{"y": 1},
	}
	report := monitor.Validate(context.Background(), "added-rule", records)
	if report.Failed != 1 {
		t.Errorf("expected 1 failure after adding rule, got %d", report.Failed)
	}
}

func TestSeverity_String(t *testing.T) {
	tests := []struct {
		s    Severity
		want string
	}{
		{SeverityInfo, "info"},
		{SeverityWarning, "warning"},
		{SeverityError, "error"},
		{SeverityCritical, "critical"},
		{Severity(99), "unknown"},
	}
	for _, tt := range tests {
		if got := tt.s.String(); got != tt.want {
			t.Errorf("Severity(%d).String() = %q, want %q", tt.s, got, tt.want)
		}
	}
}

func TestQualityReport_RecordIDFallback(t *testing.T) {
	monitor := NewQualityMonitor(nil, nil,
		NewNullCheck([]string{"required"}, SeverityError),
	)

	records := []map[string]interface{}{
		{"other": "value"}, // no "id" field, no "required" field
	}

	report := monitor.Validate(context.Background(), "fallback-id", records)
	if len(report.Violations) == 0 {
		t.Fatal("expected violations")
	}
	if report.Violations[0].RecordID != "record-0" {
		t.Errorf("expected record ID fallback 'record-0', got %q", report.Violations[0].RecordID)
	}
}

func TestRangeCheck_Boundary(t *testing.T) {
	rule := NewRangeCheck("v", 0, 100, SeverityWarning)

	// Boundary values should pass.
	if err := rule.Check(map[string]interface{}{"v": 0.0}); err != nil {
		t.Errorf("min boundary should pass: %v", err)
	}
	if err := rule.Check(map[string]interface{}{"v": 100.0}); err != nil {
		t.Errorf("max boundary should pass: %v", err)
	}
}
