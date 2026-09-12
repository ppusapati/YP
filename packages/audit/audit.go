// Package audit provides structured audit logging for the YieldPoint platform.
//
// It captures who did what, when, where, on which resource, with what result,
// and stores entries in a PostgreSQL audit_logs table. A ConnectRPC interceptor
// is included to automatically log all mutation operations (Create/Update/Delete).
//
// Usage:
//
//	pool := pgxpool.New(ctx, connString)
//	logger := audit.NewPostgresAuditLogger(pool, audit.WithRetention(90 * 24 * time.Hour))
//	interceptor := audit.AuditInterceptor(logger)
//	handler := connect.NewUnaryHandler(svc, connect.WithInterceptors(interceptor))
package audit

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"connectrpc.com/connect"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/ulid"
)

// AuditLogger defines the interface for recording audit events.
type AuditLogger interface {
	// Log records an audit entry. Implementations must be safe for concurrent use.
	Log(ctx context.Context, entry AuditEntry) error

	// Query retrieves audit entries matching the given filter.
	Query(ctx context.Context, filter AuditFilter) ([]AuditEntry, error)

	// EnsureSchema creates the audit_logs table if it does not exist.
	EnsureSchema(ctx context.Context) error
}

// AuditEntry represents a single auditable event.
type AuditEntry struct {
	// ID is a unique ULID for this entry.
	ID string `json:"id"`

	// Who performed the action.
	UserID   string `json:"user_id"`
	TenantID string `json:"tenant_id"`
	Role     string `json:"role,omitempty"`

	// What happened.
	Action   string `json:"action"`   // e.g. "Create", "Update", "Delete"
	Resource string `json:"resource"` // e.g. "Field", "Sensor", "CropPlan"

	// When it happened.
	Timestamp time.Time `json:"timestamp"`

	// Where the action originated.
	ClientIP  string `json:"client_ip,omitempty"`
	UserAgent string `json:"user_agent,omitempty"`
	RequestID string `json:"request_id,omitempty"`

	// What was the target.
	ResourceID string `json:"resource_id,omitempty"`

	// What was the outcome.
	Result    string `json:"result"` // "success" or "failure"
	ErrorCode string `json:"error_code,omitempty"`

	// Additional context.
	Metadata map[string]string `json:"metadata,omitempty"`

	// The RPC procedure name, e.g. "/farm.v1.FarmService/CreateFarm"
	Procedure string `json:"procedure,omitempty"`
}

// AuditFilter defines query criteria for retrieving audit entries.
type AuditFilter struct {
	UserID     string
	TenantID   string
	Action     string
	Resource   string
	ResourceID string
	StartTime  time.Time
	EndTime    time.Time
	Limit      int
	Offset     int
}

// LoggerOption configures a PostgresAuditLogger.
type LoggerOption func(*PostgresAuditLogger)

// WithRetention sets the retention period for audit entries.
// Entries older than this are eligible for deletion during cleanup.
// Default is 365 days.
func WithRetention(d time.Duration) LoggerOption {
	return func(l *PostgresAuditLogger) {
		l.retention = d
	}
}

// WithTableName overrides the default audit_logs table name.
func WithTableName(name string) LoggerOption {
	return func(l *PostgresAuditLogger) {
		l.tableName = name
	}
}

// PostgresAuditLogger stores audit entries in PostgreSQL.
type PostgresAuditLogger struct {
	pool      *pgxpool.Pool
	retention time.Duration
	tableName string
}

// NewPostgresAuditLogger creates a new PostgreSQL-backed audit logger.
func NewPostgresAuditLogger(pool *pgxpool.Pool, opts ...LoggerOption) *PostgresAuditLogger {
	l := &PostgresAuditLogger{
		pool:      pool,
		retention: 365 * 24 * time.Hour, // 1 year default
		tableName: "audit_logs",
	}
	for _, opt := range opts {
		opt(l)
	}
	return l
}

// EnsureSchema creates the audit_logs table and indices if they do not exist.
func (l *PostgresAuditLogger) EnsureSchema(ctx context.Context) error {
	query := fmt.Sprintf(`
		CREATE TABLE IF NOT EXISTS %s (
			id          TEXT PRIMARY KEY,
			user_id     TEXT NOT NULL,
			tenant_id   TEXT NOT NULL,
			role        TEXT,
			action      TEXT NOT NULL,
			resource    TEXT NOT NULL,
			resource_id TEXT,
			procedure   TEXT,
			timestamp   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
			client_ip   TEXT,
			user_agent  TEXT,
			request_id  TEXT,
			result      TEXT NOT NULL DEFAULT 'success',
			error_code  TEXT,
			metadata    JSONB,
			created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
		);

		CREATE INDEX IF NOT EXISTS idx_%s_tenant_time
			ON %s (tenant_id, timestamp DESC);

		CREATE INDEX IF NOT EXISTS idx_%s_user_time
			ON %s (user_id, timestamp DESC);

		CREATE INDEX IF NOT EXISTS idx_%s_resource
			ON %s (resource, resource_id);
	`, l.tableName,
		l.tableName, l.tableName,
		l.tableName, l.tableName,
		l.tableName, l.tableName,
	)

	_, err := l.pool.Exec(ctx, query)
	return err
}

// Log records an audit entry in the database.
func (l *PostgresAuditLogger) Log(ctx context.Context, entry AuditEntry) error {
	if entry.ID == "" {
		entry.ID = ulid.NewString()
	}
	if entry.Timestamp.IsZero() {
		entry.Timestamp = time.Now().UTC()
	}

	var metadataJSON []byte
	if len(entry.Metadata) > 0 {
		var err error
		metadataJSON, err = json.Marshal(entry.Metadata)
		if err != nil {
			return fmt.Errorf("audit: failed to marshal metadata: %w", err)
		}
	}

	query := fmt.Sprintf(`
		INSERT INTO %s (
			id, user_id, tenant_id, role, action, resource, resource_id,
			procedure, timestamp, client_ip, user_agent, request_id,
			result, error_code, metadata
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15)
	`, l.tableName)

	_, err := l.pool.Exec(ctx, query,
		entry.ID,
		entry.UserID,
		entry.TenantID,
		entry.Role,
		entry.Action,
		entry.Resource,
		entry.ResourceID,
		entry.Procedure,
		entry.Timestamp,
		entry.ClientIP,
		entry.UserAgent,
		entry.RequestID,
		entry.Result,
		entry.ErrorCode,
		metadataJSON,
	)
	if err != nil {
		return fmt.Errorf("audit: failed to insert entry: %w", err)
	}
	return nil
}

// Query retrieves audit entries matching the filter.
func (l *PostgresAuditLogger) Query(ctx context.Context, filter AuditFilter) ([]AuditEntry, error) {
	var conditions []string
	var args []interface{}
	argIdx := 1

	if filter.TenantID != "" {
		conditions = append(conditions, fmt.Sprintf("tenant_id = $%d", argIdx))
		args = append(args, filter.TenantID)
		argIdx++
	}
	if filter.UserID != "" {
		conditions = append(conditions, fmt.Sprintf("user_id = $%d", argIdx))
		args = append(args, filter.UserID)
		argIdx++
	}
	if filter.Action != "" {
		conditions = append(conditions, fmt.Sprintf("action = $%d", argIdx))
		args = append(args, filter.Action)
		argIdx++
	}
	if filter.Resource != "" {
		conditions = append(conditions, fmt.Sprintf("resource = $%d", argIdx))
		args = append(args, filter.Resource)
		argIdx++
	}
	if filter.ResourceID != "" {
		conditions = append(conditions, fmt.Sprintf("resource_id = $%d", argIdx))
		args = append(args, filter.ResourceID)
		argIdx++
	}
	if !filter.StartTime.IsZero() {
		conditions = append(conditions, fmt.Sprintf("timestamp >= $%d", argIdx))
		args = append(args, filter.StartTime)
		argIdx++
	}
	if !filter.EndTime.IsZero() {
		conditions = append(conditions, fmt.Sprintf("timestamp <= $%d", argIdx))
		args = append(args, filter.EndTime)
		argIdx++
	}

	where := ""
	if len(conditions) > 0 {
		where = "WHERE " + strings.Join(conditions, " AND ")
	}

	limit := filter.Limit
	if limit <= 0 {
		limit = 100
	}

	query := fmt.Sprintf(`
		SELECT id, user_id, tenant_id, role, action, resource, resource_id,
			procedure, timestamp, client_ip, user_agent, request_id,
			result, error_code, metadata
		FROM %s %s
		ORDER BY timestamp DESC
		LIMIT $%d OFFSET $%d
	`, l.tableName, where, argIdx, argIdx+1)

	args = append(args, limit, filter.Offset)

	rows, err := l.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("audit: query failed: %w", err)
	}
	defer rows.Close()

	var entries []AuditEntry
	for rows.Next() {
		var e AuditEntry
		var metadataJSON []byte
		var role, resourceID, procedure, clientIP, userAgent, requestID, errorCode *string

		err := rows.Scan(
			&e.ID, &e.UserID, &e.TenantID, &role, &e.Action, &e.Resource, &resourceID,
			&procedure, &e.Timestamp, &clientIP, &userAgent, &requestID,
			&e.Result, &errorCode, &metadataJSON,
		)
		if err != nil {
			return nil, fmt.Errorf("audit: scan failed: %w", err)
		}

		if role != nil {
			e.Role = *role
		}
		if resourceID != nil {
			e.ResourceID = *resourceID
		}
		if procedure != nil {
			e.Procedure = *procedure
		}
		if clientIP != nil {
			e.ClientIP = *clientIP
		}
		if userAgent != nil {
			e.UserAgent = *userAgent
		}
		if requestID != nil {
			e.RequestID = *requestID
		}
		if errorCode != nil {
			e.ErrorCode = *errorCode
		}

		if len(metadataJSON) > 0 {
			_ = json.Unmarshal(metadataJSON, &e.Metadata)
		}

		entries = append(entries, e)
	}

	return entries, rows.Err()
}

// Cleanup deletes audit entries older than the configured retention period.
func (l *PostgresAuditLogger) Cleanup(ctx context.Context) (int64, error) {
	cutoff := time.Now().UTC().Add(-l.retention)
	query := fmt.Sprintf("DELETE FROM %s WHERE timestamp < $1", l.tableName)
	tag, err := l.pool.Exec(ctx, query, cutoff)
	if err != nil {
		return 0, fmt.Errorf("audit: cleanup failed: %w", err)
	}
	return tag.RowsAffected(), nil
}

// mutationPrefixes are the RPC method name prefixes that indicate write operations.
var mutationPrefixes = []string{"Create", "Update", "Delete", "Remove", "Set", "Upsert", "Patch", "Archive"}

// isMutation returns true if the procedure name indicates a mutation.
func isMutation(procedure string) bool {
	// Procedure format: "/package.Service/MethodName"
	parts := strings.Split(procedure, "/")
	if len(parts) < 3 {
		return false
	}
	method := parts[len(parts)-1]
	for _, prefix := range mutationPrefixes {
		if strings.HasPrefix(method, prefix) {
			return true
		}
	}
	return false
}

// extractAction derives the action name from a procedure.
// e.g. "/farm.v1.FarmService/CreateFarm" -> "Create"
func extractAction(procedure string) string {
	parts := strings.Split(procedure, "/")
	if len(parts) < 3 {
		return "Unknown"
	}
	method := parts[len(parts)-1]
	for _, prefix := range mutationPrefixes {
		if strings.HasPrefix(method, prefix) {
			return prefix
		}
	}
	return method
}

// extractResource derives the resource name from a procedure.
// e.g. "/farm.v1.FarmService/CreateFarm" -> "Farm"
func extractResource(procedure string) string {
	parts := strings.Split(procedure, "/")
	if len(parts) < 3 {
		return "Unknown"
	}
	method := parts[len(parts)-1]
	for _, prefix := range mutationPrefixes {
		if strings.HasPrefix(method, prefix) {
			return strings.TrimPrefix(method, prefix)
		}
	}
	return method
}

// AuditInterceptor returns a ConnectRPC unary interceptor that logs mutations.
// It captures user context from p9context and request context for tracing.
// Only Create/Update/Delete/Remove/Set/Upsert/Patch/Archive operations are logged.
func AuditInterceptor(logger AuditLogger) connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			procedure := req.Spec().Procedure

			if !isMutation(procedure) {
				return next(ctx, req)
			}

			resp, rpcErr := next(ctx, req)

			// Build audit entry from context
			entry := AuditEntry{
				ID:        ulid.NewString(),
				Action:    extractAction(procedure),
				Resource:  extractResource(procedure),
				Procedure: procedure,
				Timestamp: time.Now().UTC(),
			}

			// Extract user info
			if user, ok := p9context.FromUserContext(ctx); ok {
				entry.UserID = user.UserID
				entry.TenantID = user.TenantID
				entry.Role = user.Role
			}

			// Extract request info
			if reqCtx, ok := p9context.FromRequestContext(ctx); ok {
				entry.ClientIP = reqCtx.ClientIP
				entry.UserAgent = reqCtx.UserAgent
				entry.RequestID = reqCtx.RequestID
			}

			if rpcErr != nil {
				entry.Result = "failure"
				if connectErr, ok := rpcErr.(*connect.Error); ok {
					entry.ErrorCode = connectErr.Code().String()
				}
			} else {
				entry.Result = "success"
			}

			// Log asynchronously to avoid slowing the RPC path.
			// In production, consider a buffered channel + background writer.
			go func() {
				logCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
				defer cancel()
				_ = logger.Log(logCtx, entry)
			}()

			return resp, rpcErr
		}
	}
}
