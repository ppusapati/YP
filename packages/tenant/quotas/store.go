package quotas

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// QuotaStore defines the persistence interface for quota data.
type QuotaStore interface {
	// GetLimits retrieves all quota limits for a tenant.
	GetLimits(ctx context.Context, tenantID string) (*QuotaConfig, error)
	// SetLimits upserts quota limits for a tenant.
	SetLimits(ctx context.Context, config QuotaConfig) error
	// GetUsage retrieves current usage for a specific quota type.
	GetUsage(ctx context.Context, tenantID string, quotaType QuotaType) (*QuotaUsage, error)
	// IncrementUsage atomically increments usage by delta. Returns the updated usage.
	IncrementUsage(ctx context.Context, tenantID string, quotaType QuotaType, delta int64) (*QuotaUsage, error)
	// SetUsage sets the absolute usage value for a quota type.
	SetUsage(ctx context.Context, tenantID string, quotaType QuotaType, value int64) error
	// ResetUsage resets the usage for a rate-based quota (e.g., API requests at window boundary).
	ResetUsage(ctx context.Context, tenantID string, quotaType QuotaType) error
	// GetAllUsage retrieves current usage for all quota types for a tenant.
	GetAllUsage(ctx context.Context, tenantID string) ([]QuotaUsage, error)
}

// PostgresQuotaStore implements QuotaStore backed by PostgreSQL.
type PostgresQuotaStore struct {
	pool *pgxpool.Pool
}

// NewPostgresQuotaStore creates a new PostgreSQL-backed quota store.
func NewPostgresQuotaStore(pool *pgxpool.Pool) *PostgresQuotaStore {
	return &PostgresQuotaStore{pool: pool}
}

// GetLimits retrieves all quota limits for a tenant.
func (s *PostgresQuotaStore) GetLimits(ctx context.Context, tenantID string) (*QuotaConfig, error) {
	rows, err := s.pool.Query(ctx,
		`SELECT quota_type, quota_limit, updated_at
		 FROM tenant_quota_limits
		 WHERE tenant_id = $1`,
		tenantID,
	)
	if err != nil {
		return nil, fmt.Errorf("query quota limits: %w", err)
	}
	defer rows.Close()

	config := &QuotaConfig{
		TenantID: tenantID,
		Limits:   make(map[QuotaType]int64),
	}

	for rows.Next() {
		var qt string
		var limit int64
		var updatedAt time.Time
		if err := rows.Scan(&qt, &limit, &updatedAt); err != nil {
			return nil, fmt.Errorf("scan quota limit: %w", err)
		}
		config.Limits[QuotaType(qt)] = limit
		if updatedAt.After(config.UpdatedAt) {
			config.UpdatedAt = updatedAt
		}
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate quota limits: %w", err)
	}

	return config, nil
}

// SetLimits upserts quota limits for a tenant.
func (s *PostgresQuotaStore) SetLimits(ctx context.Context, config QuotaConfig) error {
	tx, err := s.pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin transaction: %w", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck

	for qt, limit := range config.Limits {
		_, err := tx.Exec(ctx,
			`INSERT INTO tenant_quota_limits (tenant_id, quota_type, quota_limit, updated_at)
			 VALUES ($1, $2, $3, NOW())
			 ON CONFLICT (tenant_id, quota_type)
			 DO UPDATE SET quota_limit = $3, updated_at = NOW()`,
			config.TenantID, string(qt), limit,
		)
		if err != nil {
			return fmt.Errorf("upsert quota limit %s: %w", qt, err)
		}
	}

	return tx.Commit(ctx)
}

// GetUsage retrieves current usage for a specific quota type.
func (s *PostgresQuotaStore) GetUsage(ctx context.Context, tenantID string, quotaType QuotaType) (*QuotaUsage, error) {
	usage := &QuotaUsage{
		TenantID: tenantID,
		Type:     quotaType,
	}

	err := s.pool.QueryRow(ctx,
		`SELECT u.current_usage, l.quota_limit, u.window_start, u.updated_at
		 FROM tenant_quota_usage u
		 JOIN tenant_quota_limits l ON u.tenant_id = l.tenant_id AND u.quota_type = l.quota_type
		 WHERE u.tenant_id = $1 AND u.quota_type = $2`,
		tenantID, string(quotaType),
	).Scan(&usage.CurrentUsage, &usage.Limit, &usage.WindowStart, &usage.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("query quota usage: %w", err)
	}

	return usage, nil
}

// IncrementUsage atomically increments usage and returns the updated record.
func (s *PostgresQuotaStore) IncrementUsage(ctx context.Context, tenantID string, quotaType QuotaType, delta int64) (*QuotaUsage, error) {
	usage := &QuotaUsage{
		TenantID: tenantID,
		Type:     quotaType,
	}

	err := s.pool.QueryRow(ctx,
		`INSERT INTO tenant_quota_usage (tenant_id, quota_type, current_usage, window_start, updated_at)
		 VALUES ($1, $2, $3, NOW(), NOW())
		 ON CONFLICT (tenant_id, quota_type)
		 DO UPDATE SET current_usage = tenant_quota_usage.current_usage + $3, updated_at = NOW()
		 RETURNING current_usage, window_start, updated_at`,
		tenantID, string(quotaType), delta,
	).Scan(&usage.CurrentUsage, &usage.WindowStart, &usage.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("increment quota usage: %w", err)
	}

	// Fetch the limit separately so the caller has the full picture.
	var limit int64
	err = s.pool.QueryRow(ctx,
		`SELECT quota_limit FROM tenant_quota_limits WHERE tenant_id = $1 AND quota_type = $2`,
		tenantID, string(quotaType),
	).Scan(&limit)
	if err != nil {
		return nil, fmt.Errorf("fetch quota limit: %w", err)
	}
	usage.Limit = limit

	return usage, nil
}

// SetUsage sets the absolute usage value for a quota type.
func (s *PostgresQuotaStore) SetUsage(ctx context.Context, tenantID string, quotaType QuotaType, value int64) error {
	_, err := s.pool.Exec(ctx,
		`INSERT INTO tenant_quota_usage (tenant_id, quota_type, current_usage, window_start, updated_at)
		 VALUES ($1, $2, $3, NOW(), NOW())
		 ON CONFLICT (tenant_id, quota_type)
		 DO UPDATE SET current_usage = $3, updated_at = NOW()`,
		tenantID, string(quotaType), value,
	)
	if err != nil {
		return fmt.Errorf("set quota usage: %w", err)
	}
	return nil
}

// ResetUsage resets usage and the window start for a rate-based quota.
func (s *PostgresQuotaStore) ResetUsage(ctx context.Context, tenantID string, quotaType QuotaType) error {
	_, err := s.pool.Exec(ctx,
		`UPDATE tenant_quota_usage
		 SET current_usage = 0, window_start = NOW(), updated_at = NOW()
		 WHERE tenant_id = $1 AND quota_type = $2`,
		tenantID, string(quotaType),
	)
	if err != nil {
		return fmt.Errorf("reset quota usage: %w", err)
	}
	return nil
}

// GetAllUsage retrieves current usage for all quota types for a tenant.
func (s *PostgresQuotaStore) GetAllUsage(ctx context.Context, tenantID string) ([]QuotaUsage, error) {
	rows, err := s.pool.Query(ctx,
		`SELECT u.quota_type, u.current_usage, l.quota_limit, u.window_start, u.updated_at
		 FROM tenant_quota_usage u
		 JOIN tenant_quota_limits l ON u.tenant_id = l.tenant_id AND u.quota_type = l.quota_type
		 WHERE u.tenant_id = $1`,
		tenantID,
	)
	if err != nil {
		return nil, fmt.Errorf("query all quota usage: %w", err)
	}
	defer rows.Close()

	var usages []QuotaUsage
	for rows.Next() {
		var u QuotaUsage
		var qt string
		if err := rows.Scan(&qt, &u.CurrentUsage, &u.Limit, &u.WindowStart, &u.UpdatedAt); err != nil {
			return nil, fmt.Errorf("scan quota usage: %w", err)
		}
		u.TenantID = tenantID
		u.Type = QuotaType(qt)
		usages = append(usages, u)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate quota usage: %w", err)
	}

	return usages, nil
}
