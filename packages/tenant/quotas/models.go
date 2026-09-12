package quotas

import (
	"errors"
	"fmt"
	"time"
)

// QuotaType identifies a specific quota dimension.
type QuotaType string

const (
	// QuotaAPIRequests is the maximum API requests per hour.
	QuotaAPIRequests QuotaType = "api_requests_per_hour"
	// QuotaStorageBytes is the maximum storage in bytes.
	QuotaStorageBytes QuotaType = "storage_bytes"
	// QuotaMaxUsers is the maximum number of users per tenant.
	QuotaMaxUsers QuotaType = "max_users"
	// QuotaMaxFields is the maximum number of fields/farms per tenant.
	QuotaMaxFields QuotaType = "max_fields"
)

// AllQuotaTypes returns all defined quota types.
func AllQuotaTypes() []QuotaType {
	return []QuotaType{
		QuotaAPIRequests,
		QuotaStorageBytes,
		QuotaMaxUsers,
		QuotaMaxFields,
	}
}

// QuotaConfig defines the limits for a single tenant.
type QuotaConfig struct {
	// TenantID is the tenant these limits apply to.
	TenantID string `json:"tenant_id" db:"tenant_id"`
	// Limits maps each quota type to its maximum allowed value.
	Limits map[QuotaType]int64 `json:"limits"`
	// UpdatedAt is when the config was last modified.
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

// QuotaUsage records current consumption for a single quota dimension.
type QuotaUsage struct {
	// TenantID is the tenant this usage belongs to.
	TenantID string `json:"tenant_id" db:"tenant_id"`
	// Type is the quota dimension.
	Type QuotaType `json:"type" db:"quota_type"`
	// CurrentUsage is the current consumption count.
	CurrentUsage int64 `json:"current_usage" db:"current_usage"`
	// Limit is the maximum allowed value.
	Limit int64 `json:"limit" db:"quota_limit"`
	// WindowStart is when the current measurement window began (for rate-based quotas).
	WindowStart time.Time `json:"window_start,omitempty" db:"window_start"`
	// UpdatedAt is when this usage record was last updated.
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

// Remaining returns how much of the quota is unused. Returns 0 if over limit.
func (u *QuotaUsage) Remaining() int64 {
	rem := u.Limit - u.CurrentUsage
	if rem < 0 {
		return 0
	}
	return rem
}

// IsExceeded returns true if current usage meets or exceeds the limit.
func (u *QuotaUsage) IsExceeded() bool {
	return u.CurrentUsage >= u.Limit
}

// UsagePercent returns the usage as a percentage of the limit (0-100+).
func (u *QuotaUsage) UsagePercent() float64 {
	if u.Limit == 0 {
		return 100
	}
	return float64(u.CurrentUsage) / float64(u.Limit) * 100
}

// QuotaExceededError is returned when a tenant has exceeded a quota.
type QuotaExceededError struct {
	// TenantID is the tenant that exceeded the quota.
	TenantID string
	// Type is the quota dimension that was exceeded.
	Type QuotaType
	// CurrentUsage is the current consumption.
	CurrentUsage int64
	// Limit is the maximum allowed.
	Limit int64
}

// Error implements the error interface.
func (e *QuotaExceededError) Error() string {
	return fmt.Sprintf("quota exceeded for tenant %s: %s usage %d/%d",
		e.TenantID, e.Type, e.CurrentUsage, e.Limit)
}

// Is allows errors.Is matching against any QuotaExceededError.
func (e *QuotaExceededError) Is(target error) bool {
	_, ok := target.(*QuotaExceededError)
	return ok
}

// ErrQuotaExceeded is a sentinel for errors.Is checks.
var ErrQuotaExceeded = &QuotaExceededError{}

// IsQuotaExceeded returns true if the error is a QuotaExceededError.
func IsQuotaExceeded(err error) bool {
	return errors.Is(err, ErrQuotaExceeded)
}

// DefaultFreeTierLimits returns quota limits for free-tier tenants.
func DefaultFreeTierLimits() map[QuotaType]int64 {
	return map[QuotaType]int64{
		QuotaAPIRequests:  1000,          // 1,000 requests per hour
		QuotaStorageBytes: 1 << 30,       // 1 GB
		QuotaMaxUsers:     5,             // 5 users
		QuotaMaxFields:    10,            // 10 fields/farms
	}
}

// DefaultPaidTierLimits returns quota limits for paid-tier tenants.
func DefaultPaidTierLimits() map[QuotaType]int64 {
	return map[QuotaType]int64{
		QuotaAPIRequests:  100_000,       // 100,000 requests per hour
		QuotaStorageBytes: 100 << 30,     // 100 GB
		QuotaMaxUsers:     500,           // 500 users
		QuotaMaxFields:    10_000,        // 10,000 fields/farms
	}
}
