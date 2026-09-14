// Package services re-exports alert-service's application layer for callers
// outside this service. See the repositories package for why this is an alias
// shim rather than a second copy.
package services

import (
	internalservices "p9e.in/samavaya/agriculture/alert-service/internal/services"
)

// ListAlertsInput holds the filter parameters for listing alerts.
type ListAlertsInput = internalservices.ListAlertsInput

// ListAlertHistoryInput holds the filter parameters for listing alert history.
type ListAlertHistoryInput = internalservices.ListAlertHistoryInput

// AlertService defines the business logic interface for alert operations.
type AlertService = internalservices.AlertService

// NewAlertService creates a new AlertService instance.
var NewAlertService = internalservices.NewAlertService
