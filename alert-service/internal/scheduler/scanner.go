// Package scheduler provides a periodic field scanner that evaluates fields
// for risk conditions and creates alerts when thresholds are exceeded.
package scheduler

import (
	"context"
	"sync"
	"time"

	v1 "p9e.in/samavaya/agriculture/alert-service/api/v1"
	"p9e.in/samavaya/agriculture/alert-service/internal/services"
	"p9e.in/samavaya/packages/p9log"
)

// FieldProvider abstracts the source of active fields to scan.
// In production this would call the field-service gRPC endpoint.
type FieldProvider interface {
	// ActiveFieldIDs returns the IDs of all fields that should be evaluated.
	ActiveFieldIDs(ctx context.Context) ([]string, error)
}

// FieldScanner periodically evaluates fields and creates alerts
// when risk scores exceed the configured thresholds.
type FieldScanner struct {
	svc            services.AlertService
	fieldProvider  FieldProvider
	logger         *p9log.Helper

	// cooldownTracker prevents duplicate alerts within the cooldown window.
	// key: fieldID + ":" + metric, value: last alert time
	mu             sync.Mutex
	cooldownTracker map[string]time.Time
}

// NewFieldScanner creates a new FieldScanner.
func NewFieldScanner(svc services.AlertService, fp FieldProvider, logger *p9log.Helper) *FieldScanner {
	return &FieldScanner{
		svc:             svc,
		fieldProvider:   fp,
		logger:          logger,
		cooldownTracker: make(map[string]time.Time),
	}
}

// Run starts the periodic field scanning loop. It blocks until ctx is cancelled.
func (s *FieldScanner) Run(ctx context.Context, interval time.Duration) {
	s.logger.Infof("Field scanner started with interval %s", interval)

	// Run an immediate scan on startup.
	s.scan(ctx)

	ticker := time.NewTicker(interval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			s.logger.Infof("Field scanner stopped: %v", ctx.Err())
			return
		case <-ticker.C:
			s.scan(ctx)
		}
	}
}

// scan performs a single evaluation pass over all active fields.
func (s *FieldScanner) scan(ctx context.Context) {
	fieldIDs, err := s.fieldProvider.ActiveFieldIDs(ctx)
	if err != nil {
		s.logger.Errorf("Failed to fetch active fields: %v", err)
		return
	}

	s.logger.Infof("Scanning %d active fields", len(fieldIDs))

	for _, fieldID := range fieldIDs {
		if ctx.Err() != nil {
			return
		}
		s.evaluateField(ctx, fieldID)
	}

	// Purge expired cooldown entries.
	s.purgeCooldowns()
}

// evaluateField evaluates a single field and logs risk threshold exceedances.
func (s *FieldScanner) evaluateField(ctx context.Context, fieldID string) {
	riskScore, err := s.svc.GetFieldRisk(ctx, fieldID)
	if err != nil {
		s.logger.Errorf("Failed to evaluate field %s: %v", fieldID, err)
		return
	}

	// Fetch the alert rules for this field to check thresholds and cooldowns.
	rules, err := s.svc.ListAlertRules(ctx, fieldID)
	if err != nil {
		s.logger.Errorf("Failed to list alert rules for field %s: %v", fieldID, err)
		return
	}

	// Build a rule lookup by metric name.
	ruleByMetric := make(map[string]*v1.AlertRule, len(rules))
	for _, r := range rules {
		if r.GetEnabled() {
			ruleByMetric[r.GetMetric()] = r
		}
	}

	// Check each risk factor against its corresponding rule threshold.
	for factor, score := range riskScore.GetRiskFactors() {
		rule, hasRule := ruleByMetric[factor]
		if !hasRule {
			continue
		}
		if score >= rule.GetThreshold() {
			s.processRiskExceedance(ctx, fieldID, factor, score, rule, riskScore)
		}
	}
}

// processRiskExceedance handles a risk factor that exceeded its rule threshold.
func (s *FieldScanner) processRiskExceedance(
	ctx context.Context,
	fieldID string,
	metric string,
	score float64,
	rule *v1.AlertRule,
	riskScore *v1.FieldRiskScore,
) {
	_ = ctx // reserved for future alert creation via service

	// Check cooldown.
	cooldownMinutes := int32(60) // default
	cooldownKey := fieldID + ":" + metric
	if s.isCoolingDown(cooldownKey, time.Duration(cooldownMinutes)*time.Minute) {
		s.logger.Infof("Skipping alert (cooldown active): field=%s metric=%s", fieldID, metric)
		return
	}

	// Record cooldown.
	s.recordCooldown(cooldownKey)

	s.logger.Infof("Risk threshold exceeded: field=%s metric=%s score=%.2f threshold=%.2f severity=%s overall=%.2f",
		fieldID, metric, score, rule.GetThreshold(), rule.GetSeverity().String(), riskScore.GetOverallScore())
}

// isCoolingDown checks whether an alert for the given key is within its cooldown window.
func (s *FieldScanner) isCoolingDown(key string, cooldown time.Duration) bool {
	s.mu.Lock()
	defer s.mu.Unlock()

	lastFired, ok := s.cooldownTracker[key]
	if !ok {
		return false
	}
	return time.Since(lastFired) < cooldown
}

// recordCooldown records the current time as the last-fired time for the given key.
func (s *FieldScanner) recordCooldown(key string) {
	s.mu.Lock()
	defer s.mu.Unlock()

	s.cooldownTracker[key] = time.Now()
}

// purgeCooldowns removes entries older than 24 hours to prevent unbounded growth.
func (s *FieldScanner) purgeCooldowns() {
	s.mu.Lock()
	defer s.mu.Unlock()

	cutoff := time.Now().Add(-24 * time.Hour)
	for k, t := range s.cooldownTracker {
		if t.Before(cutoff) {
			delete(s.cooldownTracker, k)
		}
	}
}
