package offboarding

import (
	"context"
	"errors"
	"testing"
	"time"

	"p9e.in/samavaya/packages/saas"
)

// The tests that matter here are the ones about refusing to destroy data.
// Every guard in this package exists because of a specific way offboarding
// goes wrong, so each one has a test named after that failure rather than
// after the method it exercises.

const secret = "test-secret"

var frozen = time.Date(2026, 3, 15, 12, 0, 0, 0, time.UTC)

// ── fakes ───────────────────────────────────────────────────────────────────

type fakeStore struct {
	tenants map[string]*saas.TenantConfig
	deleted []string
	updates []bool
	failOn  string
}

func (s *fakeStore) GetByNameOrId(_ context.Context, id string) (*saas.TenantConfig, error) {
	cfg, ok := s.tenants[id]
	if !ok {
		return nil, errors.New("not found")
	}
	return cfg, nil
}

func (s *fakeStore) UpdateStatus(_ context.Context, _ string, active bool) error {
	if s.failOn == "update" {
		return errors.New("master db unavailable")
	}
	s.updates = append(s.updates, active)
	return nil
}

func (s *fakeStore) DeleteTenant(_ context.Context, id string) error {
	if s.failOn == "delete" {
		return errors.New("master db unavailable")
	}
	s.deleted = append(s.deleted, id)
	return nil
}

type fakeRecords struct{ recs map[string]*OffboardingRecord }

func newFakeRecords() *fakeRecords { return &fakeRecords{recs: map[string]*OffboardingRecord{}} }

func (r *fakeRecords) Get(_ context.Context, id string) (*OffboardingRecord, error) {
	rec, ok := r.recs[id]
	if !ok {
		return nil, errors.New("no record")
	}
	return rec, nil
}

func (r *fakeRecords) Save(_ context.Context, rec *OffboardingRecord) error {
	copied := *rec
	r.recs[rec.TenantID] = &copied
	return nil
}

type fakeArchiver struct {
	rows       int64
	archiveErr error
	verifyErr  error
	verified   int
}

func (a *fakeArchiver) Archive(_ context.Context, _, dest string) (*ArchiveInfo, error) {
	if a.archiveErr != nil {
		return nil, a.archiveErr
	}
	return &ArchiveInfo{Location: dest, Tables: 12, Rows: a.rows, Bytes: a.rows * 100,
		Checksum: "abc123", CreatedAt: frozen}, nil
}

func (a *fakeArchiver) VerifyArchive(_ context.Context, _ *ArchiveInfo) error {
	a.verified++
	return a.verifyErr
}

type fakePurger struct {
	dropped []string
	rowsOf  []string
	err     error
}

func (p *fakePurger) DropDatabase(_ context.Context, name string) error {
	if p.err != nil {
		return p.err
	}
	p.dropped = append(p.dropped, name)
	return nil
}

func (p *fakePurger) DeleteTenantRows(_ context.Context, db, tenantID string) (int64, error) {
	if p.err != nil {
		return 0, p.err
	}
	p.rowsOf = append(p.rowsOf, db+"/"+tenantID)
	return 42, nil
}

// ── harness ─────────────────────────────────────────────────────────────────

type harness struct {
	o        *Offboarder
	store    *fakeStore
	records  *fakeRecords
	archiver *fakeArchiver
	purger   *fakePurger
	now      time.Time
}

func newHarness(t *testing.T, tenantType saas.TenantType) *harness {
	t.Helper()
	h := &harness{
		store: &fakeStore{tenants: map[string]*saas.TenantConfig{
			"t-1": {ID: "t-1", Name: "acme-farms", Type: tenantType, IsActive: true},
		}},
		records:  newFakeRecords(),
		archiver: &fakeArchiver{rows: 5000},
		purger:   &fakePurger{},
		now:      frozen,
	}
	h.o = New(h.store, h.records, h.archiver, h.purger, secret,
		WithSharedDBName("shared"),
		WithArchiveRoot("/archives"),
		WithClock(func() time.Time { return h.now }))
	return h
}

func (h *harness) request() OffboardRequest {
	return OffboardRequest{TenantID: "t-1", Reason: "customer cancelled", RequestedBy: "ops@example.com"}
}

// toVerified drives the tenant to the last reversible stage.
func (h *harness) toVerified(t *testing.T) {
	t.Helper()
	ctx := context.Background()
	if _, err := h.o.Suspend(ctx, h.request()); err != nil {
		t.Fatalf("Suspend: %v", err)
	}
	if _, err := h.o.Archive(ctx, "t-1"); err != nil {
		t.Fatalf("Archive: %v", err)
	}
	if _, err := h.o.Verify(ctx, "t-1"); err != nil {
		t.Fatalf("Verify: %v", err)
	}
}

func (h *harness) purge(force bool) (*OffboardingRecord, error) {
	return h.o.Purge(context.Background(), PurgeRequest{
		TenantID:     "t-1",
		Confirmation: h.o.ConfirmationToken("t-1"),
		RequestedBy:  "ops@example.com",
		Force:        force,
	})
}

// ── the lifecycle ───────────────────────────────────────────────────────────

func TestTheHappyPathEndsPurged(t *testing.T) {
	h := newHarness(t, saas.TenantTypePaid)
	h.toVerified(t)
	h.now = frozen.Add(DefaultGracePeriod + time.Hour)

	rec, err := h.purge(false)
	if err != nil {
		t.Fatalf("Purge: %v", err)
	}
	if rec.Stage != StagePurged {
		t.Errorf("stage %q, want purged", rec.Stage)
	}
	if len(h.purger.dropped) != 1 || h.purger.dropped[0] != "acme-farms" {
		t.Errorf("dropped %v, want the tenant's own database", h.purger.dropped)
	}
	if len(h.store.deleted) != 1 {
		t.Errorf("tenant record was not removed")
	}
	// Every stage should be on the record: an offboarding is a thing someone
	// will be asked to account for later.
	if len(rec.Steps) != 4 {
		t.Errorf("recorded %d steps, want suspend/archive/verify/purge", len(rec.Steps))
	}
}

func TestSuspensionIsReversible(t *testing.T) {
	h := newHarness(t, saas.TenantTypePaid)
	ctx := context.Background()

	if _, err := h.o.Suspend(ctx, h.request()); err != nil {
		t.Fatalf("Suspend: %v", err)
	}
	rec, err := h.o.Reinstate(ctx, "t-1")
	if err != nil {
		t.Fatalf("Reinstate: %v", err)
	}
	if rec.Stage != StageActive {
		t.Errorf("stage %q, want active", rec.Stage)
	}
	// Suspend deactivated, reinstate reactivated.
	if len(h.store.updates) != 2 || h.store.updates[0] != false || h.store.updates[1] != true {
		t.Errorf("status updates %v, want [false true]", h.store.updates)
	}
}

func TestAPurgedTenantCannotBeReinstated(t *testing.T) {
	// Reporting success here would restore a tenant record pointing at data
	// that no longer exists — an account that appears to work and has lost
	// everything, which is worse than a clear refusal.
	h := newHarness(t, saas.TenantTypePaid)
	h.toVerified(t)
	h.now = frozen.Add(DefaultGracePeriod + time.Hour)
	if _, err := h.purge(false); err != nil {
		t.Fatalf("Purge: %v", err)
	}

	if _, err := h.o.Reinstate(context.Background(), "t-1"); !errors.Is(err, ErrAlreadyOffboarded) {
		t.Errorf("Reinstate after purge returned %v, want ErrAlreadyOffboarded", err)
	}
}

// ── the guards ──────────────────────────────────────────────────────────────

func TestPurgingAFreeTenantNeverDropsTheSharedDatabase(t *testing.T) {
	// The single most destructive mistake available here: free-tier tenants
	// share one database, and dropping it destroys every other tenant on it.
	h := newHarness(t, saas.TenantTypeFree)
	h.toVerified(t)
	h.now = frozen.Add(DefaultGracePeriod + time.Hour)

	if _, err := h.purge(false); err != nil {
		t.Fatalf("Purge: %v", err)
	}
	if len(h.purger.dropped) != 0 {
		t.Fatalf("dropped databases %v for a free-tier tenant", h.purger.dropped)
	}
	if len(h.purger.rowsOf) != 1 || h.purger.rowsOf[0] != "shared/t-1" {
		t.Errorf("row deletions %v, want the tenant's rows from the shared database", h.purger.rowsOf)
	}
}

func TestARecordNamingTheSharedDatabaseIsNeverDropped(t *testing.T) {
	// Defence in depth: even if the record claims the paid tier, a database
	// named as the shared one must not be dropped. A single wrong field should
	// not be able to destroy other tenants' data.
	h := newHarness(t, saas.TenantTypePaid)
	h.toVerified(t)
	rec, _ := h.records.Get(context.Background(), "t-1")
	rec.DatabaseName = "shared"
	_ = h.records.Save(context.Background(), rec)
	h.now = frozen.Add(DefaultGracePeriod + time.Hour)

	if _, err := h.purge(false); err != nil {
		t.Fatalf("Purge: %v", err)
	}
	if len(h.purger.dropped) != 0 {
		t.Errorf("dropped %v; the shared database must never be dropped", h.purger.dropped)
	}
}

func TestPurgeRefusesWithoutAVerifiedArchive(t *testing.T) {
	// "We took a backup" and "the backup is there" are different claims, and
	// only the second justifies destroying the original.
	h := newHarness(t, saas.TenantTypePaid)
	ctx := context.Background()
	if _, err := h.o.Suspend(ctx, h.request()); err != nil {
		t.Fatalf("Suspend: %v", err)
	}
	if _, err := h.o.Archive(ctx, "t-1"); err != nil {
		t.Fatalf("Archive: %v", err)
	}
	// Archived but not verified.
	h.now = frozen.Add(DefaultGracePeriod + time.Hour)

	if _, err := h.purge(false); !errors.Is(err, ErrNoVerifiedArchive) {
		t.Errorf("Purge returned %v, want ErrNoVerifiedArchive", err)
	}
	if len(h.purger.dropped) != 0 {
		t.Error("data was destroyed without a verified archive")
	}
}

func TestForceSkipsTheGracePeriodButNotTheArchive(t *testing.T) {
	// An escape hatch wide enough to destroy unexported data would be used.
	h := newHarness(t, saas.TenantTypePaid)
	ctx := context.Background()
	if _, err := h.o.Suspend(ctx, h.request()); err != nil {
		t.Fatalf("Suspend: %v", err)
	}

	if _, err := h.purge(true); !errors.Is(err, ErrNoVerifiedArchive) {
		t.Errorf("forced purge with no archive returned %v, want ErrNoVerifiedArchive", err)
	}
	if len(h.purger.dropped) != 0 {
		t.Fatal("a forced purge destroyed unexported data")
	}

	// With a verified archive, force does bypass the grace period.
	if _, err := h.o.Archive(ctx, "t-1"); err != nil {
		t.Fatalf("Archive: %v", err)
	}
	if _, err := h.o.Verify(ctx, "t-1"); err != nil {
		t.Fatalf("Verify: %v", err)
	}
	if _, err := h.purge(true); err != nil {
		t.Errorf("forced purge with a verified archive returned %v", err)
	}
}

func TestTheGracePeriodHoldsTheData(t *testing.T) {
	// Somebody offboards the wrong tenant. The difference between noticing in
	// a week and noticing in an hour is whether the data still exists.
	h := newHarness(t, saas.TenantTypePaid)
	h.toVerified(t)
	h.now = frozen.Add(24 * time.Hour) // a day in, twenty-nine to go

	_, err := h.purge(false)
	if !errors.Is(err, ErrGracePeriodActive) {
		t.Errorf("Purge returned %v, want ErrGracePeriodActive", err)
	}
	if len(h.purger.dropped) != 0 {
		t.Error("data was destroyed inside the grace period")
	}
	// And the tenant can still be brought back.
	if _, err := h.o.Reinstate(context.Background(), "t-1"); err != nil {
		t.Errorf("Reinstate inside the grace period returned %v", err)
	}
}

func TestPurgingWithTheWrongConfirmationFails(t *testing.T) {
	// The guard against acting on the wrong tenant, which is the mistake that
	// actually happens.
	h := newHarness(t, saas.TenantTypePaid)
	h.toVerified(t)
	h.now = frozen.Add(DefaultGracePeriod + time.Hour)

	_, err := h.o.Purge(context.Background(), PurgeRequest{
		TenantID:     "t-1",
		Confirmation: h.o.ConfirmationToken("t-2"), // a different tenant's token
		RequestedBy:  "ops@example.com",
	})
	if !errors.Is(err, ErrConfirmationMismatch) {
		t.Errorf("Purge returned %v, want ErrConfirmationMismatch", err)
	}
	if len(h.purger.dropped) != 0 {
		t.Error("data was destroyed on an unconfirmed purge")
	}
}

func TestAnEmptyArchiveIsRejected(t *testing.T) {
	// An archive with no rows is the shape a purge would accept and a restore
	// could not use.
	h := newHarness(t, saas.TenantTypePaid)
	h.archiver.rows = 0
	ctx := context.Background()
	if _, err := h.o.Suspend(ctx, h.request()); err != nil {
		t.Fatalf("Suspend: %v", err)
	}
	if _, err := h.o.Archive(ctx, "t-1"); !errors.Is(err, ErrArchiveEmpty) {
		t.Errorf("Archive returned %v, want ErrArchiveEmpty", err)
	}
}

func TestAFailedVerificationBlocksThePurge(t *testing.T) {
	h := newHarness(t, saas.TenantTypePaid)
	h.archiver.verifyErr = errors.New("checksum mismatch")
	ctx := context.Background()
	if _, err := h.o.Suspend(ctx, h.request()); err != nil {
		t.Fatalf("Suspend: %v", err)
	}
	if _, err := h.o.Archive(ctx, "t-1"); err != nil {
		t.Fatalf("Archive: %v", err)
	}
	if _, err := h.o.Verify(ctx, "t-1"); err == nil {
		t.Fatal("a corrupt archive verified successfully")
	}

	h.now = frozen.Add(DefaultGracePeriod + time.Hour)
	if _, err := h.purge(false); err == nil {
		t.Error("purge proceeded after verification failed")
	}
}

func TestArchivingRequiresSuspensionFirst(t *testing.T) {
	// A tenant still taking writes produces an archive that matches no moment
	// in time.
	h := newHarness(t, saas.TenantTypePaid)
	h.records.recs["t-1"] = &OffboardingRecord{TenantID: "t-1", Stage: StageActive}

	if _, err := h.o.Archive(context.Background(), "t-1"); !errors.Is(err, ErrNotSuspended) {
		t.Errorf("Archive returned %v, want ErrNotSuspended", err)
	}
}

func TestTheTenantRecordIsRemovedLast(t *testing.T) {
	// If it went first and the data purge then failed, the data would be left
	// behind with nothing pointing at it: unreachable, and invisible to the
	// next attempt.
	h := newHarness(t, saas.TenantTypePaid)
	h.toVerified(t)
	h.purger.err = errors.New("database busy")
	h.now = frozen.Add(DefaultGracePeriod + time.Hour)

	if _, err := h.purge(false); err == nil {
		t.Fatal("purge reported success despite the data purge failing")
	}
	if len(h.store.deleted) != 0 {
		t.Error("the tenant record was removed while its data still exists")
	}
}

func TestAFailedStageIsRecorded(t *testing.T) {
	// A stalled offboarding has to be visible, not silently absent.
	h := newHarness(t, saas.TenantTypePaid)
	h.store.failOn = "update"

	if _, err := h.o.Suspend(context.Background(), h.request()); err == nil {
		t.Fatal("Suspend reported success despite the store failing")
	}
	rec, err := h.records.Get(context.Background(), "t-1")
	if err != nil {
		t.Fatalf("no record was persisted for the failed attempt: %v", err)
	}
	if rec.Stage != StageFailed || rec.Error == "" {
		t.Errorf("record does not show the failure: %+v", rec)
	}
}

// ── requests and tokens ─────────────────────────────────────────────────────

func TestAnOffboardingMustSayWhoAndWhy(t *testing.T) {
	// An offboarding nobody can explain later is indistinguishable from an
	// accident.
	cases := []struct {
		name string
		req  OffboardRequest
		want error
	}{
		{"no tenant", OffboardRequest{Reason: "r", RequestedBy: "u"}, ErrTenantIDRequired},
		{"no reason", OffboardRequest{TenantID: "t", RequestedBy: "u"}, ErrReasonRequired},
		{"no requester", OffboardRequest{TenantID: "t", Reason: "r"}, ErrRequestedByRequired},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if err := tc.req.Validate(); !errors.Is(err, tc.want) {
				t.Errorf("Validate() = %v, want %v", err, tc.want)
			}
		})
	}
}

func TestConfirmationTokensAreTenantSpecificAndStable(t *testing.T) {
	a := ConfirmationToken("t-1", secret)
	if a != ConfirmationToken("t-1", secret) {
		t.Error("the token changes between calls; it could not be copied from a UI")
	}
	if a == ConfirmationToken("t-2", secret) {
		t.Error("two tenants share a token; the guard does nothing")
	}
	if a == ConfirmationToken("t-1", "other-secret") {
		t.Error("the token does not depend on the deployment secret")
	}
	if !ValidConfirmation("t-1", secret, a) {
		t.Error("a freshly derived token did not validate")
	}
	if ValidConfirmation("t-1", secret, "") {
		t.Error("an empty token validated")
	}
}

func TestPurgePlanReportsWhatWouldHappen(t *testing.T) {
	// A dry run is the cheapest way to catch the wrong target.
	paid := newHarness(t, saas.TenantTypePaid)
	paid.toVerified(t)
	db, drops, err := paid.o.PurgePlan(context.Background(), "t-1")
	if err != nil {
		t.Fatalf("PurgePlan: %v", err)
	}
	if db != "acme-farms" || !drops {
		t.Errorf("paid plan: %q drop=%v, want the tenant's database dropped", db, drops)
	}

	free := newHarness(t, saas.TenantTypeFree)
	free.toVerified(t)
	db, drops, err = free.o.PurgePlan(context.Background(), "t-1")
	if err != nil {
		t.Fatalf("PurgePlan: %v", err)
	}
	if db != "shared" || drops {
		t.Errorf("free plan: %q drop=%v, want rows deleted from the shared database", db, drops)
	}
}

func TestStageReversibility(t *testing.T) {
	reversible := []Stage{StageSuspended, StageArchived, StageVerified}
	for _, s := range reversible {
		if !s.Reversible() {
			t.Errorf("%q should be reversible", s)
		}
	}
	for _, s := range []Stage{StageActive, StagePurged} {
		if s.Reversible() {
			t.Errorf("%q should not be reversible", s)
		}
	}
	if !StagePurged.Terminal() {
		t.Error("purged should be terminal")
	}
}
