package sql

import (
	"github.com/jackc/pgx/v5/pgtype"
	"time"
)

// TimestamptzToTimePtr converts pgtype.Timestamptz to *time.Time.
// Returns nil if the Timestamptz is not valid.
// This is an alias for TimePtrFromTimestamptz.
func TimestamptzToTimePtr(ts pgtype.Timestamptz) *time.Time {
	return TimePtrFromTimestamptz(ts)
}
