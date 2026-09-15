package application

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"strings"
	"testing"
	"time"

	"go.uber.org/zap"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"

	"p9e.in/samavaya/agriculture/device-service/internal/domain"
)

var testNow = time.Date(2026, 3, 14, 9, 0, 0, 0, time.UTC)

// ─────────────────────────────────────────────────────────────────────────────
// Fakes
// ─────────────────────────────────────────────────────────────────────────────

type fakeRepo struct {
	devices  map[string]*domain.Device
	bySerial map[string]*domain.Device
	rollouts map[string]*domain.FirmwareRollout

	healthWrites int
	savedRollout *domain.FirmwareRollout
	updates      []domain.DeviceUpdate
}

func newRepo() *fakeRepo {
	return &fakeRepo{
		devices:  map[string]*domain.Device{},
		bySerial: map[string]*domain.Device{},
		rollouts: map[string]*domain.FirmwareRollout{},
	}
}

func (f *fakeRepo) CreateDevice(_ context.Context, d *domain.Device) (*domain.Device, error) {
	f.devices[d.ID] = d
	f.bySerial[d.Serial] = d
	return d, nil
}

func (f *fakeRepo) GetDevice(_ context.Context, id, _ string) (*domain.Device, error) {
	d, ok := f.devices[id]
	if !ok {
		return nil, errors.NotFound("DEVICE_NOT_FOUND", "not found")
	}
	return d, nil
}

func (f *fakeRepo) GetDeviceBySerial(_ context.Context, serial, _ string) (*domain.Device, error) {
	d, ok := f.bySerial[serial]
	if !ok {
		return nil, errors.NotFound("DEVICE_NOT_FOUND", "not found")
	}
	return d, nil
}

func (f *fakeRepo) ListDevices(_ context.Context, _ domain.ListDevicesParams) ([]domain.Device, int64, error) {
	var out []domain.Device
	for _, d := range f.devices {
		out = append(out, *d)
	}
	return out, int64(len(out)), nil
}

func (f *fakeRepo) UpdateDeviceHealth(_ context.Context, _ *domain.Device) error {
	f.healthWrites++
	return nil
}

func (f *fakeRepo) RetireDevice(_ context.Context, id, _, reason string) (*domain.Device, error) {
	d, ok := f.devices[id]
	if !ok {
		return nil, errors.NotFound("DEVICE_NOT_FOUND", "not found")
	}
	at := testNow
	d.RetiredAt = &at
	d.RetiredReason = reason
	return d, nil
}

func (f *fakeRepo) FleetDevices(_ context.Context, _, _ string) ([]domain.Device, error) {
	var out []domain.Device
	for _, d := range f.devices {
		out = append(out, *d)
	}
	return out, nil
}

func (f *fakeRepo) CreateRollout(_ context.Context, r *domain.FirmwareRollout) (*domain.FirmwareRollout, error) {
	f.rollouts[r.ID] = r
	return r, nil
}

func (f *fakeRepo) GetRollout(_ context.Context, id, _ string) (*domain.FirmwareRollout, error) {
	r, ok := f.rollouts[id]
	if !ok {
		return nil, errors.NotFound("ROLLOUT_NOT_FOUND", "not found")
	}
	return r, nil
}

func (f *fakeRepo) SaveRollout(_ context.Context, r *domain.FirmwareRollout) error {
	f.savedRollout = r
	return nil
}

func (f *fakeRepo) ListRollouts(_ context.Context, _ domain.ListRolloutsParams) ([]domain.FirmwareRollout, int64, error) {
	return nil, 0, nil
}

func (f *fakeRepo) UpsertDeviceUpdate(_ context.Context, u *domain.DeviceUpdate) error {
	f.updates = append(f.updates, *u)
	return nil
}

type fakePublisher struct{ topics []string }

func (f *fakePublisher) Publish(_ context.Context, topic, _ string, _ []byte) error {
	f.topics = append(f.topics, topic)
	return nil
}

func newService(repo *fakeRepo) (*deviceService, *fakePublisher) {
	pub := &fakePublisher{}
	svc := NewDeviceService(repo, pub, p9log.NewLogger(zap.NewNop())).(*deviceService)
	svc.now = func() time.Time { return testNow }
	return svc, pub
}

func tenantCtx(id string) context.Context {
	return p9context.NewConnectionInfo(context.Background(), &saas.ConnectionInfo{TenantID: id})
}

func isBadRequest(err error, reason string) bool {
	return err != nil && errors.IsBadRequest(err) && errors.Reason(err) == reason
}

// ─────────────────────────────────────────────────────────────────────────────
// Provisioning
// ─────────────────────────────────────────────────────────────────────────────

func TestProvisionDevice_IssuesATokenAndStoresOnlyItsHash(t *testing.T) {
	// Unlike a user password, nobody can rotate a device's token by logging
	// in, so the blast radius of storing it in the clear is the life of the
	// hardware — and that hardware opens irrigation valves.
	repo := newRepo()
	svc, _ := newService(repo)

	result, err := svc.ProvisionDevice(tenantCtx("tenant-1"), &domain.Device{
		Serial: "SP-0001",
		Kind:   domain.KindSoilProbe,
	})
	if err != nil {
		t.Fatalf("provision: %v", err)
	}

	if result.EnrolmentToken == "" {
		t.Fatal("no token was issued")
	}
	stored := repo.devices[result.Device.ID].EnrolmentTokenHash
	if stored == "" {
		t.Fatal("no token hash was stored")
	}
	if strings.Contains(stored, result.EnrolmentToken) {
		t.Fatal("the token itself was stored")
	}

	sum := sha256.Sum256([]byte(result.EnrolmentToken))
	if stored != hex.EncodeToString(sum[:]) {
		t.Error("the stored hash does not match the issued token")
	}
}

func TestProvisionDevice_IssuesADifferentTokenEachTime(t *testing.T) {
	repo := newRepo()
	svc, _ := newService(repo)

	first, _ := svc.ProvisionDevice(tenantCtx("t1"), &domain.Device{Serial: "A", Kind: domain.KindSoilProbe})
	second, _ := svc.ProvisionDevice(tenantCtx("t1"), &domain.Device{Serial: "B", Kind: domain.KindSoilProbe})

	if first.EnrolmentToken == second.EnrolmentToken {
		t.Fatal("two devices were issued the same credential")
	}
}

func TestProvisionDevice_RefusesADuplicateSerial(t *testing.T) {
	// Almost always a technician re-scanning a device. Saying so is more
	// useful than a unique-constraint error from the database.
	repo := newRepo()
	svc, _ := newService(repo)
	ctx := tenantCtx("tenant-1")

	if _, err := svc.ProvisionDevice(ctx, &domain.Device{Serial: "SP-0001", Kind: domain.KindSoilProbe}); err != nil {
		t.Fatalf("first provision: %v", err)
	}

	_, err := svc.ProvisionDevice(ctx, &domain.Device{Serial: "SP-0001", Kind: domain.KindSoilProbe})
	if err == nil {
		t.Fatal("a duplicate serial was enrolled twice")
	}
	if errors.Reason(err) != "DEVICE_ALREADY_ENROLLED" {
		t.Errorf("reason = %q", errors.Reason(err))
	}
}

func TestProvisionDevice_DefaultsTheFleet(t *testing.T) {
	repo := newRepo()
	svc, _ := newService(repo)

	result, err := svc.ProvisionDevice(tenantCtx("t1"), &domain.Device{
		Serial: "SP-0001", Kind: domain.KindSoilProbe,
	})
	if err != nil {
		t.Fatalf("provision: %v", err)
	}
	if result.Device.Fleet != "default" {
		t.Errorf("fleet = %q; a device with no fleet is invisible to every fleet view", result.Device.Fleet)
	}
}

func TestProvisionDevice_RequiresATenant(t *testing.T) {
	svc, _ := newService(newRepo())

	_, err := svc.ProvisionDevice(context.Background(), &domain.Device{Serial: "A", Kind: domain.KindSoilProbe})
	if !isBadRequest(err, "MISSING_TENANT") {
		t.Fatalf("expected MISSING_TENANT, got %v", err)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Heartbeats
// ─────────────────────────────────────────────────────────────────────────────

func enrolled(repo *fakeRepo, id string) *domain.Device {
	d := &domain.Device{ID: id, TenantID: "tenant-1", Serial: id, Kind: domain.KindSoilProbe, Fleet: "north"}
	repo.devices[id] = d
	repo.bySerial[id] = d
	return d
}

func beat(deviceID string, at time.Time, battery float64) domain.Heartbeat {
	return domain.Heartbeat{DeviceID: deviceID, RecordedAt: at, BatteryPercent: battery}
}

func TestRecordHeartbeats_AppliesTheBatch(t *testing.T) {
	repo := newRepo()
	device := enrolled(repo, "dev-1")
	svc, _ := newService(repo)

	result, err := svc.RecordHeartbeats(tenantCtx("tenant-1"), []domain.Heartbeat{
		beat("dev-1", testNow.Add(-10*time.Minute), 80),
	})
	if err != nil {
		t.Fatalf("heartbeats: %v", err)
	}

	if result.Recorded != 1 {
		t.Errorf("recorded = %d, want 1", result.Recorded)
	}
	if device.BatteryPercent != 80 {
		t.Errorf("battery = %v", device.BatteryPercent)
	}
}

func TestRecordHeartbeats_OneBadBeatDoesNotSinkTheBatch(t *testing.T) {
	// A gateway uploads hundreds at once after an outage. Refusing the lot
	// because one has a broken clock would leave the whole fleet offline.
	repo := newRepo()
	enrolled(repo, "dev-1")
	svc, _ := newService(repo)

	result, err := svc.RecordHeartbeats(tenantCtx("tenant-1"), []domain.Heartbeat{
		beat("dev-1", testNow.Add(-10*time.Minute), 80),
		beat("dev-2", testNow.Add(time.Hour), 80), // clock an hour fast
	})
	if err != nil {
		t.Fatalf("heartbeats: %v", err)
	}

	if result.Recorded != 1 {
		t.Errorf("recorded = %d, want 1", result.Recorded)
	}
	if len(result.Rejected) != 1 {
		t.Fatalf("rejected = %v", result.Rejected)
	}
	if !strings.Contains(result.Rejected[0], "dev-2") {
		t.Errorf("the rejection does not name the device: %q", result.Rejected[0])
	}
}

func TestRecordHeartbeats_GroupsABacklogIntoOneWrite(t *testing.T) {
	// Fifty readings for one device should be one load and one save, not fifty
	// of each — which is the difference between a gateway reconnecting and a
	// gateway reconnecting taking the database down.
	repo := newRepo()
	enrolled(repo, "dev-1")
	svc, _ := newService(repo)

	var beats []domain.Heartbeat
	for i := 50; i > 0; i-- {
		beats = append(beats, beat("dev-1", testNow.Add(-time.Duration(i)*time.Minute), 70))
	}

	result, err := svc.RecordHeartbeats(tenantCtx("tenant-1"), beats)
	if err != nil {
		t.Fatalf("heartbeats: %v", err)
	}

	if result.Recorded != 50 {
		t.Errorf("recorded = %d, want 50", result.Recorded)
	}
	if repo.healthWrites != 1 {
		t.Errorf("health writes = %d, want 1", repo.healthWrites)
	}
}

func TestRecordHeartbeats_RejectsAnUnenrolledDevice(t *testing.T) {
	// Hardware reporting under a serial nobody provisioned is either a
	// misconfigured device or somebody else's; either way it does not get a row.
	repo := newRepo()
	svc, _ := newService(repo)

	result, err := svc.RecordHeartbeats(tenantCtx("tenant-1"), []domain.Heartbeat{
		beat("ghost", testNow.Add(-time.Minute), 80),
	})
	if err != nil {
		t.Fatalf("heartbeats: %v", err)
	}

	if result.Recorded != 0 {
		t.Errorf("recorded = %d, want 0", result.Recorded)
	}
	if len(result.Rejected) != 1 || !strings.Contains(result.Rejected[0], "not enrolled") {
		t.Errorf("rejected = %v", result.Rejected)
	}
}

func TestRecordHeartbeats_ARetiredDeviceDoesNotComeBack(t *testing.T) {
	// A retired device still transmitting is worth knowing about, but it must
	// not walk back into the fleet view by itself.
	repo := newRepo()
	d := enrolled(repo, "dev-1")
	at := testNow.Add(-48 * time.Hour)
	d.RetiredAt = &at
	svc, _ := newService(repo)

	result, _ := svc.RecordHeartbeats(tenantCtx("tenant-1"), []domain.Heartbeat{
		beat("dev-1", testNow.Add(-time.Minute), 80),
	})

	if result.Recorded != 0 {
		t.Error("a retired device was revived by a heartbeat")
	}
	if len(result.Rejected) != 1 || !strings.Contains(result.Rejected[0], "retired") {
		t.Errorf("rejected = %v", result.Rejected)
	}
}

func TestRecordHeartbeats_AnAllStaleBatchWritesNothing(t *testing.T) {
	// A replayed backlog is not an error and not a write either.
	repo := newRepo()
	d := enrolled(repo, "dev-1")
	seen := testNow.Add(-time.Minute)
	d.LastSeenAt = &seen
	svc, _ := newService(repo)

	result, err := svc.RecordHeartbeats(tenantCtx("tenant-1"), []domain.Heartbeat{
		beat("dev-1", testNow.Add(-3*time.Hour), 90),
	})
	if err != nil {
		t.Fatalf("heartbeats: %v", err)
	}

	if repo.healthWrites != 0 {
		t.Error("a stale backlog caused a write")
	}
	if result.Recorded != 0 {
		t.Errorf("recorded = %d, want 0", result.Recorded)
	}
}

func TestRecordHeartbeats_RefusesAnEmptyBatch(t *testing.T) {
	svc, _ := newService(newRepo())

	if _, err := svc.RecordHeartbeats(tenantCtx("t1"), nil); !isBadRequest(err, "NO_HEARTBEATS") {
		t.Fatalf("expected NO_HEARTBEATS, got %v", err)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Reads derive status
// ─────────────────────────────────────────────────────────────────────────────

func TestGetDevice_DerivesStatusOnRead(t *testing.T) {
	// Nothing writes "offline" — a device that stops reporting is exactly the
	// thing that cannot write it.
	repo := newRepo()
	d := enrolled(repo, "dev-1")
	seen := testNow.Add(-2 * domain.OfflineAfter)
	d.LastSeenAt = &seen
	svc, _ := newService(repo)

	got, err := svc.GetDevice(tenantCtx("tenant-1"), "dev-1")
	if err != nil {
		t.Fatalf("get: %v", err)
	}
	if got.Status != domain.StatusOffline {
		t.Errorf("status = %s, want OFFLINE", got.Status)
	}
}

func TestListDevices_FiltersOnDerivedStatus(t *testing.T) {
	repo := newRepo()
	online := enrolled(repo, "dev-online")
	seen := testNow.Add(-time.Minute)
	online.LastSeenAt = &seen
	offline := enrolled(repo, "dev-offline")
	old := testNow.Add(-2 * domain.OfflineAfter)
	offline.LastSeenAt = &old
	svc, _ := newService(repo)

	devices, total, err := svc.ListDevices(tenantCtx("tenant-1"), domain.ListDevicesParams{
		Status: domain.StatusOffline,
	})
	if err != nil {
		t.Fatalf("list: %v", err)
	}

	if len(devices) != 1 || devices[0].ID != "dev-offline" {
		t.Fatalf("filtered list = %v", devices)
	}
	// The count has to match the page, or the UI shows "1 of 2".
	if total != 1 {
		t.Errorf("total = %d, want 1", total)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Fleet health
// ─────────────────────────────────────────────────────────────────────────────

func TestGetFleetHealth(t *testing.T) {
	repo := newRepo()
	online := enrolled(repo, "a")
	seen := testNow.Add(-time.Minute)
	online.LastSeenAt = &seen
	enrolled(repo, "b") // never seen: provisioned
	svc, _ := newService(repo)

	health, err := svc.GetFleetHealth(tenantCtx("tenant-1"), "north")
	if err != nil {
		t.Fatalf("health: %v", err)
	}

	if health.Total != 2 || health.Online != 1 || health.Provisioned != 1 {
		t.Errorf("health = %+v", health)
	}
}

func TestGetFleetHealth_RequiresAFleet(t *testing.T) {
	svc, _ := newService(newRepo())

	if _, err := svc.GetFleetHealth(tenantCtx("t1"), " "); !isBadRequest(err, "MISSING_FLEET") {
		t.Fatalf("expected MISSING_FLEET, got %v", err)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Rollouts
// ─────────────────────────────────────────────────────────────────────────────

func newRollout(repo *fakeRepo, threshold float64) *domain.FirmwareRollout {
	r := &domain.FirmwareRollout{
		ID:               "roll-1",
		TenantID:         "tenant-1",
		Fleet:            "north",
		Kind:             domain.KindSoilProbe,
		Version:          "2.5.0",
		ArtifactURL:      "https://firmware.example/a.bin",
		ArtifactSHA256:   "abc",
		State:            domain.RolloutInProgress,
		StagePercent:     10,
		FailureThreshold: threshold,
	}
	repo.rollouts[r.ID] = r
	return r
}

func TestCreateRollout_StagesByDefault(t *testing.T) {
	// A rollout that starts at the whole fleet is not staged, and staging is
	// the point.
	repo := newRepo()
	svc, _ := newService(repo)

	created, err := svc.CreateRollout(tenantCtx("tenant-1"), &domain.FirmwareRollout{
		Fleet:          "north",
		Kind:           domain.KindSoilProbe,
		Version:        "2.5.0",
		ArtifactURL:    "https://firmware.example/a.bin",
		ArtifactSHA256: "abc",
	})
	if err != nil {
		t.Fatalf("create: %v", err)
	}

	if created.StagePercent != 10 {
		t.Errorf("stage = %d, want 10", created.StagePercent)
	}
	if created.State != domain.RolloutPending {
		t.Errorf("state = %s, want PENDING", created.State)
	}
}

func TestCreateRollout_RefusesAnArtifactWithNoChecksum(t *testing.T) {
	svc, _ := newService(newRepo())

	_, err := svc.CreateRollout(tenantCtx("tenant-1"), &domain.FirmwareRollout{
		Fleet:       "north",
		Version:     "2.5.0",
		ArtifactURL: "https://firmware.example/a.bin",
	})
	if !isBadRequest(err, "INVALID_ROLLOUT") {
		t.Fatalf("expected INVALID_ROLLOUT, got %v", err)
	}
}

func TestReportUpdate_HaltsAndAnnouncesAFailingRollout(t *testing.T) {
	// A state change nobody is told about is one that gets noticed when the
	// next stage does not happen.
	repo := newRepo()
	r := newRollout(repo, 0.10)
	r.Succeeded = 9
	svc, pub := newService(repo)

	_, rollout, err := svc.ReportUpdate(tenantCtx("tenant-1"), &domain.DeviceUpdate{
		DeviceID:  "dev-1",
		RolloutID: "roll-1",
		State:     domain.UpdateFailed,
	})
	if err != nil {
		t.Fatalf("report: %v", err)
	}

	if rollout.State != domain.RolloutHalted {
		t.Fatalf("state = %s, want HALTED", rollout.State)
	}
	if len(pub.topics) != 1 || pub.topics[0] != topicRolloutHalted {
		t.Errorf("published = %v, want one halt event", pub.topics)
	}
	if repo.savedRollout == nil || repo.savedRollout.State != domain.RolloutHalted {
		t.Error("the halt was not persisted")
	}
}

func TestReportUpdate_RecordsProgressWithoutHalting(t *testing.T) {
	repo := newRepo()
	newRollout(repo, 0.10)
	svc, pub := newService(repo)

	_, rollout, err := svc.ReportUpdate(tenantCtx("tenant-1"), &domain.DeviceUpdate{
		DeviceID:  "dev-1",
		RolloutID: "roll-1",
		State:     domain.UpdateSucceeded,
	})
	if err != nil {
		t.Fatalf("report: %v", err)
	}

	if rollout.State == domain.RolloutHalted {
		t.Error("a successful update halted the rollout")
	}
	if len(pub.topics) != 0 {
		t.Errorf("published %v for an ordinary success", pub.topics)
	}
	if len(repo.updates) != 1 {
		t.Errorf("the device's progress was not recorded: %v", repo.updates)
	}
}

func TestReportUpdate_RequiresBothIDs(t *testing.T) {
	svc, _ := newService(newRepo())

	_, _, err := svc.ReportUpdate(tenantCtx("t1"), &domain.DeviceUpdate{DeviceID: "dev-1"})
	if !isBadRequest(err, "MISSING_IDS") {
		t.Fatalf("expected MISSING_IDS, got %v", err)
	}
}

func TestAdvanceRollout_IsForwardOnly(t *testing.T) {
	repo := newRepo()
	r := newRollout(repo, 0.10)
	r.StagePercent = 50
	svc, _ := newService(repo)

	_, err := svc.AdvanceRollout(tenantCtx("tenant-1"), "roll-1", 20)
	if !isBadRequest(err, "ROLLOUT_NOT_ADVANCED") {
		t.Fatalf("expected ROLLOUT_NOT_ADVANCED, got %v", err)
	}
}

func TestRetireDevice_Announces(t *testing.T) {
	repo := newRepo()
	enrolled(repo, "dev-1")
	svc, pub := newService(repo)

	device, err := svc.RetireDevice(tenantCtx("tenant-1"), "dev-1", "replaced")
	if err != nil {
		t.Fatalf("retire: %v", err)
	}

	if device.RetiredAt == nil {
		t.Error("the device was not retired")
	}
	if len(pub.topics) != 1 || pub.topics[0] != topicDeviceRetired {
		t.Errorf("published = %v", pub.topics)
	}
}
