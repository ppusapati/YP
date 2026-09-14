package services

import (
	"testing"

	pb "p9e.in/samavaya/agriculture/alert-service/api/v1"
	"p9e.in/samavaya/agriculture/alert-service/internal/models"
)

// These cover the places where the stored model is wider than the proto, which
// is where information gets lost silently if the mapping is careless.

func TestMetricValuesSurviveIntoTheMetricsMap(t *testing.T) {
	// The proto has no metric_value or threshold_value field, so they are
	// folded into the metrics map rather than dropped: "soil moisture 0.11
	// against a threshold of 0.15" is what makes an alert actionable, as
	// opposed to "soil is dry".
	got := alertToProto(&models.Alert{
		ID: "a-1", FieldID: "f-1", MetricValue: 0.11, ThresholdValue: 0.15,
		Severity: models.AlertSeverityWarning, Status: models.AlertStatusActive,
	})
	if got.GetMetrics()["value"] != 0.11 || got.GetMetrics()["threshold"] != 0.15 {
		t.Errorf("metrics %v lost the value or the threshold", got.GetMetrics())
	}
}

func TestFoldedMetricsDoNotOverwriteTheOriginals(t *testing.T) {
	got := alertToProto(&models.Alert{
		ID: "a-1", FieldID: "f-1",
		Metrics:     map[string]float64{"humidity": 82},
		MetricValue: 1.2, ThresholdValue: 2.0,
	})
	if got.GetMetrics()["humidity"] != 82 {
		t.Errorf("metrics %v dropped a value the upstream sent", got.GetMetrics())
	}
}

func TestExpiredIsReportedAsResolved(t *testing.T) {
	// The proto has no EXPIRED. Both mean the alert is closed and needs no
	// action, which is the distinction a client acts on.
	got := alertToProto(&models.Alert{ID: "a-1", FieldID: "f-1", Status: models.AlertStatusExpired})
	if got.GetStatus() != pb.AlertStatus_ALERT_STATUS_RESOLVED {
		t.Errorf("status %v, want RESOLVED", got.GetStatus())
	}
}

func TestFilteringForResolvedAlsoFindsExpired(t *testing.T) {
	// Follows from the mapping above: a caller asking for closed alerts would
	// otherwise silently miss every expired one.
	got := statusesFromProto(pb.AlertStatus_ALERT_STATUS_RESOLVED)
	if len(got) != 2 {
		t.Fatalf("got %v, want both RESOLVED and EXPIRED", got)
	}
}

func TestPageTokenRoundTrip(t *testing.T) {
	offset, err := parsePageToken("40")
	if err != nil || offset != 40 {
		t.Fatalf("parsePageToken(40) = %d, %v", offset, err)
	}
	if _, err := parsePageToken(""); err != nil {
		t.Errorf("an empty token should mean the first page, got %v", err)
	}
	// A client whose token is corrupt is better told so than handed page one
	// again under the impression it is paging forward.
	if _, err := parsePageToken("not-a-number"); err == nil {
		t.Error("a malformed page token was accepted")
	}
	if _, err := parsePageToken("-5"); err == nil {
		t.Error("a negative page token was accepted")
	}
}

func TestNextTokenStopsAtTheEnd(t *testing.T) {
	if got := nextToken(0, 50, 120); got != "50" {
		t.Errorf("next token %q, want 50", got)
	}
	// Advancing by rows returned, not by the requested page size, so a short
	// page cannot produce a token pointing at where the caller already is.
	if got := nextToken(100, 20, 120); got != "" {
		t.Errorf("next token %q at the end of the results, want empty", got)
	}
	if got := nextToken(100, 0, 120); got != "" {
		t.Errorf("next token %q for an empty page, want empty", got)
	}
}

func TestClampPageSize(t *testing.T) {
	if got := clampPageSize(0); got != defaultPageSize {
		t.Errorf("clampPageSize(0) = %d, want the default", got)
	}
	if got := clampPageSize(10_000); got != maxPageSize {
		t.Errorf("clampPageSize(10000) = %d, want the maximum", got)
	}
	if got := clampPageSize(25); got != 25 {
		t.Errorf("clampPageSize(25) = %d", got)
	}
}

func TestParseDateAcceptsBothForms(t *testing.T) {
	if _, err := parseDate("2026-03-15", "start_date"); err != nil {
		t.Errorf("a bare date is what a human types: %v", err)
	}
	if _, err := parseDate("2026-03-15T06:00:00Z", "start_date"); err != nil {
		t.Errorf("RFC 3339 is what the rest of the platform emits: %v", err)
	}
	if _, err := parseDate("15/03/2026", "start_date"); err == nil {
		t.Error("an ambiguous date format was accepted")
	}
	if got, err := parseDate("", "start_date"); err != nil || got != nil {
		t.Errorf("an empty date should mean no constraint, got %v, %v", got, err)
	}
}
