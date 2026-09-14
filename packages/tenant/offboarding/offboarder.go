package offboarding

import (
	"context"
	"errors"
	"fmt"
	"time"

	"p9e.in/samavaya/packages/saas"
)

// TenantStore reads and updates tenant records in the master database.
type TenantStore interface {
	GetByNameOrId(ctx context.Context, nameOrId string) (*saas.TenantConfig, error)
	UpdateStatus(ctx context.Context, tenantID string, isActive bool) error
	DeleteTenant(ctx context.Context, tenantID string) error
}

// Archiver exports a tenant's data. In practice this wraps
// packages/tenant/export.
type Archiver interface {
	// Archive writes every table for the tenant and reports what it wrote.
	Archive(ctx context.Context, tenantID, destination string) (*ArchiveInfo, error)
	// VerifyArchive re-reads an archive and confirms it is intact. A separate
	// call, not a flag on Archive, because the question it answers is "is the
	// data still there now" and the useful time to ask is just before a purge.
	VerifyArchive(ctx context.Context, info *ArchiveInfo) error
}

// DataPurger destroys a tenant's data.
type DataPurger interface {
	// DropDatabase removes a dedicated tenant database.
	DropDatabase(ctx context.Context, databaseName string) error
	// DeleteTenantRows removes a tenant's rows from a shared database and
	// reports how many were deleted.
	DeleteTenantRows(ctx context.Context, databaseName, tenantID string) (int64, error)
}

// RecordStore persists offboarding state.
//
// It has to be durable and separate from the tenant record, because the tenant
// record is one of the things a purge destroys — and the audit trail for a
// deletion cannot live inside the thing that was deleted.
type RecordStore interface {
	Get(ctx context.Context, tenantID string) (*OffboardingRecord, error)
	Save(ctx context.Context, rec *OffboardingRecord) error
}

// Clock is overridable so grace-period behaviour can be tested without waiting
// thirty days.
type Clock func() time.Time

// Offboarder runs the offboarding lifecycle.
type Offboarder struct {
	store       TenantStore
	records     RecordStore
	archiver    Archiver
	purger      DataPurger
	secret      string
	sharedDB    string
	archiveRoot string
	grace       time.Duration
	now         Clock
}

// Option configures an Offboarder.
type Option func(*Offboarder)

// WithSharedDBName names the database free-tier tenants share. It is what the
// purger checks against before it would drop anything.
func WithSharedDBName(name string) Option {
	return func(o *Offboarder) { o.sharedDB = name }
}

// WithGracePeriod overrides DefaultGracePeriod.
func WithGracePeriod(d time.Duration) Option {
	return func(o *Offboarder) { o.grace = d }
}

// WithArchiveRoot sets where archives are written.
func WithArchiveRoot(path string) Option {
	return func(o *Offboarder) { o.archiveRoot = path }
}

// WithClock overrides the clock, for tests.
func WithClock(c Clock) Option {
	return func(o *Offboarder) { o.now = c }
}

// New creates an Offboarder. The secret keys purge confirmation tokens.
func New(store TenantStore, records RecordStore, archiver Archiver, purger DataPurger,
	secret string, opts ...Option) *Offboarder {
	o := &Offboarder{
		store:       store,
		records:     records,
		archiver:    archiver,
		purger:      purger,
		secret:      secret,
		sharedDB:    "shared",
		archiveRoot: "/var/lib/yieldpoint/archives",
		grace:       DefaultGracePeriod,
		now:         time.Now,
	}
	for _, opt := range opts {
		opt(o)
	}
	return o
}

// ConfirmationToken returns the token that authorises purging this tenant.
func (o *Offboarder) ConfirmationToken(tenantID string) string {
	return ConfirmationToken(tenantID, o.secret)
}

// Status returns the current offboarding record, or an active one if the
// tenant has never been offboarded.
func (o *Offboarder) Status(ctx context.Context, tenantID string) (*OffboardingRecord, error) {
	rec, err := o.records.Get(ctx, tenantID)
	if err == nil && rec != nil {
		return rec, nil
	}
	cfg, cfgErr := o.store.GetByNameOrId(ctx, tenantID)
	if cfgErr != nil || cfg == nil {
		return nil, ErrTenantNotFound
	}
	return &OffboardingRecord{
		TenantID:   cfg.ID,
		TenantName: cfg.Name,
		TenantType: string(cfg.Type),
		Stage:      StageActive,
	}, nil
}

// Suspend stops the tenant accepting writes without touching its data.
//
// The first and only fully reversible stage, and the one that should be
// reached for when somebody says "cancel this account". Everything after it
// trades reversibility for finality.
func (o *Offboarder) Suspend(ctx context.Context, req OffboardRequest) (*OffboardingRecord, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}
	cfg, err := o.store.GetByNameOrId(ctx, req.TenantID)
	if err != nil || cfg == nil {
		return nil, ErrTenantNotFound
	}

	rec, _ := o.records.Get(ctx, cfg.ID)
	if rec != nil && rec.Stage == StagePurged {
		return nil, ErrAlreadyOffboarded
	}
	if rec == nil {
		rec = &OffboardingRecord{TenantID: cfg.ID}
	}

	start := o.now()
	rec.TenantName = cfg.Name
	rec.TenantType = string(cfg.Type)
	rec.DatabaseName = o.databaseFor(cfg)
	rec.Reason = req.Reason
	rec.RequestedBy = req.RequestedBy

	if err := o.store.UpdateStatus(ctx, cfg.ID, false); err != nil {
		return o.fail(ctx, rec, "suspend", start, err)
	}

	rec.Stage = StageSuspended
	rec.SuspendedAt = start
	rec.Error = ""
	o.step(rec, "suspend", StageSuspended, start, nil)
	return rec, o.records.Save(ctx, rec)
}

// Reinstate undoes an offboarding that has not yet been purged.
func (o *Offboarder) Reinstate(ctx context.Context, tenantID string) (*OffboardingRecord, error) {
	rec, err := o.records.Get(ctx, tenantID)
	if err != nil || rec == nil {
		return nil, ErrTenantNotFound
	}
	if !rec.Stage.Reversible() {
		// Being explicit that the data is gone, rather than reporting a
		// success that restores an empty tenant.
		return nil, ErrAlreadyOffboarded
	}

	start := o.now()
	if err := o.store.UpdateStatus(ctx, tenantID, true); err != nil {
		return o.fail(ctx, rec, "reinstate", start, err)
	}

	rec.Stage = StageActive
	rec.SuspendedAt = time.Time{}
	rec.PurgeableAt = time.Time{}
	rec.Error = ""
	o.step(rec, "reinstate", StageActive, start, nil)
	return rec, o.records.Save(ctx, rec)
}

// Archive exports the tenant's data.
//
// Requires suspension first, so that the export is a consistent picture rather
// than a moving one — a tenant still taking writes produces an archive that
// matches no moment in time.
func (o *Offboarder) Archive(ctx context.Context, tenantID string) (*OffboardingRecord, error) {
	rec, err := o.records.Get(ctx, tenantID)
	if err != nil || rec == nil {
		return nil, ErrTenantNotFound
	}
	if rec.Stage == StagePurged {
		return nil, ErrAlreadyOffboarded
	}
	if rec.Stage == StageActive {
		return nil, ErrNotSuspended
	}

	start := o.now()
	dest := fmt.Sprintf("%s/%s-%s", o.archiveRoot, tenantID, start.UTC().Format("20060102T150405Z"))

	info, err := o.archiver.Archive(ctx, tenantID, dest)
	if err != nil {
		return o.fail(ctx, rec, "archive", start, err)
	}
	if info == nil || info.Rows == 0 {
		// An archive with no rows is the shape a purge would accept and a
		// restore could not use. Better to stop here than to discover it after
		// the data is gone.
		return o.fail(ctx, rec, "archive", start, ErrArchiveEmpty)
	}
	if info.CreatedAt.IsZero() {
		info.CreatedAt = start
	}

	rec.Archive = info
	rec.Stage = StageArchived
	rec.ArchivedAt = start
	rec.Error = ""
	o.step(rec, "archive", StageArchived, start, nil)
	return rec, o.records.Save(ctx, rec)
}

// Verify re-reads the archive and starts the grace period.
//
// Separate from Archive because "we wrote a backup" and "the backup is there"
// are different claims, and only the second one justifies a purge.
func (o *Offboarder) Verify(ctx context.Context, tenantID string) (*OffboardingRecord, error) {
	rec, err := o.records.Get(ctx, tenantID)
	if err != nil || rec == nil {
		return nil, ErrTenantNotFound
	}
	if rec.Stage == StagePurged {
		return nil, ErrAlreadyOffboarded
	}
	if rec.Archive == nil {
		return nil, ErrNoVerifiedArchive
	}

	start := o.now()
	if err := o.archiver.VerifyArchive(ctx, rec.Archive); err != nil {
		return o.fail(ctx, rec, "verify", start, err)
	}
	if rec.Archive.Rows == 0 {
		return o.fail(ctx, rec, "verify", start, ErrArchiveEmpty)
	}

	rec.Archive.VerifiedAt = start
	rec.Stage = StageVerified
	rec.VerifiedAt = start
	rec.PurgeableAt = start.Add(o.grace)
	rec.Error = ""
	o.step(rec, "verify", StageVerified, start, nil)
	return rec, o.records.Save(ctx, rec)
}

// Purge destroys the tenant's data. It cannot be undone.
//
// Everything that can be checked is checked first, because every one of these
// preconditions corresponds to a real way this goes wrong: purging the wrong
// tenant, purging before anyone confirmed the archive, purging an hour after
// somebody clicked the wrong row — and, worst, dropping the shared database
// and taking every other free-tier tenant with it.
func (o *Offboarder) Purge(ctx context.Context, req PurgeRequest) (*OffboardingRecord, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}
	rec, err := o.records.Get(ctx, req.TenantID)
	if err != nil || rec == nil {
		return nil, ErrTenantNotFound
	}
	if !ValidConfirmation(req.TenantID, o.secret, req.Confirmation) {
		return nil, ErrConfirmationMismatch
	}
	if err := rec.PurgeReady(o.now(), req.Force); err != nil {
		return nil, err
	}

	start := o.now()

	// A free-tier tenant lives in a database it shares with every other free
	// tenant. Dropping it would destroy all of them, so the shared name is
	// refused outright rather than guarded by the tenant type alone — a record
	// with the wrong type recorded on it must not be able to cause this.
	if rec.DatabaseName == "" || rec.DatabaseName == o.sharedDB ||
		rec.TenantType == string(saas.TenantTypeFree) {
		if rec.DatabaseName == "" {
			return nil, fmt.Errorf("%w: no database recorded for this tenant", ErrSharedTenantDrop)
		}
		if _, err := o.purger.DeleteTenantRows(ctx, rec.DatabaseName, rec.TenantID); err != nil {
			return o.fail(ctx, rec, "purge", start, err)
		}
	} else {
		if err := o.purger.DropDatabase(ctx, rec.DatabaseName); err != nil {
			return o.fail(ctx, rec, "purge", start, err)
		}
	}

	// The tenant record goes last. If it went first and the data purge then
	// failed, the data would be left behind with nothing pointing at it —
	// unreachable, unbilled, and invisible to the next offboarding attempt.
	if err := o.store.DeleteTenant(ctx, rec.TenantID); err != nil {
		return o.fail(ctx, rec, "purge", start, err)
	}

	rec.Stage = StagePurged
	rec.PurgedAt = start
	rec.Error = ""
	o.step(rec, "purge", StagePurged, start, nil)
	return rec, o.records.Save(ctx, rec)
}

// DropDatabaseName reports which database a purge would act on, and how.
// Useful for a dry run, which is the cheapest way to catch the wrong target.
func (o *Offboarder) PurgePlan(ctx context.Context, tenantID string) (dbName string, dropsDatabase bool, err error) {
	rec, err := o.records.Get(ctx, tenantID)
	if err != nil || rec == nil {
		return "", false, ErrTenantNotFound
	}
	shared := rec.DatabaseName == "" || rec.DatabaseName == o.sharedDB ||
		rec.TenantType == string(saas.TenantTypeFree)
	return rec.DatabaseName, !shared, nil
}

// databaseFor resolves the database a tenant's data lives in.
func (o *Offboarder) databaseFor(cfg *saas.TenantConfig) string {
	if cfg.Type == saas.TenantTypePaid {
		return cfg.Name
	}
	return o.sharedDB
}

func (o *Offboarder) step(rec *OffboardingRecord, name string, stage Stage, start time.Time, err error) {
	s := StepResult{Name: name, Stage: stage, At: start, Duration: o.now().Sub(start)}
	if err != nil {
		s.Error = err.Error()
	}
	rec.Steps = append(rec.Steps, s)
}

// fail records a failed step and persists it, so that a stalled offboarding is
// visible rather than silently absent.
func (o *Offboarder) fail(ctx context.Context, rec *OffboardingRecord, name string, start time.Time, cause error) (*OffboardingRecord, error) {
	rec.Stage = StageFailed
	rec.Error = cause.Error()
	o.step(rec, name, StageFailed, start, cause)
	if saveErr := o.records.Save(ctx, rec); saveErr != nil {
		return nil, errors.Join(cause, saveErr)
	}
	return rec, fmt.Errorf("%s: %w", name, cause)
}
