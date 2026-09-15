// Package offboarding removes a tenant from the platform: suspend, archive,
// verify, then purge.
//
// It is the mirror of provisioning, but it is not symmetric with it, because
// the failure modes are not symmetric. A provisioning that goes wrong leaves a
// half-built tenant that can be rolled back and retried. An offboarding that
// goes wrong has destroyed data that no longer exists anywhere.
//
// So the stages are separated, ordered, and each one refuses to run until the
// one before it has actually happened:
//
//	Suspend  — stop accepting writes. Fully reversible.
//	Archive  — export everything, with a manifest.
//	Verify   — confirm the archive is real before anything is dropped.
//	Purge    — drop the data. Irreversible.
//
// Three guards exist because each one corresponds to a way this goes wrong in
// practice:
//
//   - A grace period between archive and purge. Somebody offboards the wrong
//     tenant; the difference between noticing in a week and noticing in an hour
//     is whether the data still exists.
//   - Purge refuses to run without a verified archive. "We took a backup" is
//     not the same statement as "the backup is there".
//   - A confirmation token derived from the tenant's own identity, so a purge
//     issued against the wrong id fails rather than succeeding quietly.
package offboarding

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"time"
)

// Errors returned by the offboarder.
var (
	ErrTenantIDRequired     = errors.New("tenant ID is required")
	ErrReasonRequired       = errors.New("an offboarding reason is required")
	ErrRequestedByRequired  = errors.New("requested_by is required")
	ErrTenantNotFound       = errors.New("tenant not found")
	ErrAlreadyOffboarded    = errors.New("tenant has already been purged")
	ErrNotSuspended         = errors.New("tenant must be suspended before archiving")
	ErrNoVerifiedArchive    = errors.New("refusing to purge without a verified archive")
	ErrGracePeriodActive    = errors.New("grace period has not elapsed")
	ErrConfirmationMismatch = errors.New("confirmation token does not match this tenant")
	ErrSharedTenantDrop     = errors.New("refusing to drop a shared database")
	ErrArchiveEmpty         = errors.New("archive contains no rows")
)

// DefaultGracePeriod is how long a tenant's data is kept after archiving
// before a purge is allowed.
//
// Thirty days rather than something shorter because the mistake this guards
// against — offboarding the wrong tenant, or a customer changing their mind —
// is usually noticed in days, not hours, and the storage cost of being wrong
// is trivial next to the cost of being irreversible.
const DefaultGracePeriod = 30 * 24 * time.Hour

// Stage is a point in the offboarding lifecycle.
type Stage string

const (
	// StageActive means offboarding has not started.
	StageActive Stage = "active"
	// StageSuspended means the tenant accepts no writes but retains its data.
	// Reversible with Reinstate.
	StageSuspended Stage = "suspended"
	// StageArchived means the data has been exported but not yet verified.
	StageArchived Stage = "archived"
	// StageVerified means the archive has been checked and the grace period
	// is running. This is the last reversible stage.
	StageVerified Stage = "verified"
	// StagePurged means the data is gone.
	StagePurged Stage = "purged"
	// StageFailed means a stage did not complete.
	StageFailed Stage = "failed"
)

// Terminal reports whether no further stage follows.
func (s Stage) Terminal() bool { return s == StagePurged }

// Reversible reports whether the tenant can still be reinstated.
func (s Stage) Reversible() bool {
	return s == StageSuspended || s == StageArchived || s == StageVerified
}

// OffboardRequest starts or advances an offboarding.
type OffboardRequest struct {
	// TenantID identifies the tenant.
	TenantID string `json:"tenant_id"`
	// Reason records why. Required, and kept on the record: an offboarding
	// nobody can explain later is indistinguishable from an accident.
	Reason string `json:"reason"`
	// RequestedBy identifies who asked for it.
	RequestedBy string `json:"requested_by"`
	// GracePeriod overrides DefaultGracePeriod. Zero uses the default.
	GracePeriod time.Duration `json:"grace_period"`
}

// Validate checks the request.
func (r *OffboardRequest) Validate() error {
	if r.TenantID == "" {
		return ErrTenantIDRequired
	}
	if r.Reason == "" {
		return ErrReasonRequired
	}
	if r.RequestedBy == "" {
		return ErrRequestedByRequired
	}
	return nil
}

// PurgeRequest asks for the irreversible step.
type PurgeRequest struct {
	// TenantID identifies the tenant.
	TenantID string `json:"tenant_id"`
	// Confirmation must equal ConfirmationToken(TenantID, secret). It exists
	// so that a purge aimed at the wrong tenant fails instead of succeeding.
	Confirmation string `json:"confirmation"`
	// RequestedBy identifies who authorised it.
	RequestedBy string `json:"requested_by"`
	// Force skips the grace period. It does not skip the archive check —
	// there is no legitimate reason to destroy data that was never exported,
	// and an escape hatch that wide would be used.
	Force bool `json:"force"`
}

// Validate checks the request.
func (r *PurgeRequest) Validate() error {
	if r.TenantID == "" {
		return ErrTenantIDRequired
	}
	if r.RequestedBy == "" {
		return ErrRequestedByRequired
	}
	return nil
}

// ArchiveInfo records what was exported.
type ArchiveInfo struct {
	// Location is where the archive was written.
	Location string `json:"location"`
	// Tables is the number of tables exported.
	Tables int `json:"tables"`
	// Rows is the total number of rows exported.
	Rows int64 `json:"rows"`
	// Bytes is the archive's size on disk.
	Bytes int64 `json:"bytes"`
	// Checksum fingerprints the archive's manifest, so a later verification
	// can tell "the archive is intact" from "a file exists at that path".
	Checksum string `json:"checksum"`
	// CreatedAt is when the archive was written.
	CreatedAt time.Time `json:"created_at"`
	// VerifiedAt is when it was last checked. Zero means never.
	VerifiedAt time.Time `json:"verified_at,omitempty"`
}

// Verified reports whether the archive has been checked and holds something.
func (a *ArchiveInfo) Verified() bool {
	return a != nil && !a.VerifiedAt.IsZero() && a.Rows > 0
}

// OffboardingRecord is the durable state of one offboarding.
type OffboardingRecord struct {
	TenantID     string       `json:"tenant_id"`
	TenantName   string       `json:"tenant_name"`
	TenantType   string       `json:"tenant_type"`
	DatabaseName string       `json:"database_name"`
	Stage        Stage        `json:"stage"`
	Reason       string       `json:"reason"`
	RequestedBy  string       `json:"requested_by"`
	SuspendedAt  time.Time    `json:"suspended_at,omitempty"`
	ArchivedAt   time.Time    `json:"archived_at,omitempty"`
	VerifiedAt   time.Time    `json:"verified_at,omitempty"`
	PurgedAt     time.Time    `json:"purged_at,omitempty"`
	PurgeableAt  time.Time    `json:"purgeable_at,omitempty"`
	Archive      *ArchiveInfo `json:"archive,omitempty"`
	Steps        []StepResult `json:"steps,omitempty"`
	Error        string       `json:"error,omitempty"`
}

// PurgeReady reports whether the record satisfies every precondition for a
// purge at the given time, and says why not when it does not.
func (r *OffboardingRecord) PurgeReady(now time.Time, force bool) error {
	switch r.Stage {
	case StagePurged:
		return ErrAlreadyOffboarded
	case StageActive:
		return ErrNotSuspended
	}
	if !r.Archive.Verified() {
		return ErrNoVerifiedArchive
	}
	if !force && !r.PurgeableAt.IsZero() && now.Before(r.PurgeableAt) {
		return fmt.Errorf("%w: purgeable at %s", ErrGracePeriodActive,
			r.PurgeableAt.Format(time.RFC3339))
	}
	return nil
}

// StepResult records one stage's outcome.
type StepResult struct {
	Name     string        `json:"name"`
	Stage    Stage         `json:"stage"`
	At       time.Time     `json:"at"`
	Duration time.Duration `json:"duration"`
	Error    string        `json:"error,omitempty"`
}

// ConfirmationToken derives the token that authorises a purge.
//
// Keyed on a deployment secret so it cannot be computed from the tenant id
// alone, and truncated to 16 hex characters because a human has to be able to
// copy it accurately. It is not a security boundary — the caller is already
// authenticated and authorised — it is a guard against acting on the wrong
// tenant, which is the mistake that actually happens.
func ConfirmationToken(tenantID, secret string) string {
	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write([]byte("offboard:" + tenantID))
	return hex.EncodeToString(mac.Sum(nil))[:16]
}

// ValidConfirmation reports whether a token authorises purging this tenant.
func ValidConfirmation(tenantID, secret, token string) bool {
	want := ConfirmationToken(tenantID, secret)
	// Constant-time despite not being a security boundary: it costs nothing
	// and stops this becoming one by accident later.
	return hmac.Equal([]byte(want), []byte(token))
}
