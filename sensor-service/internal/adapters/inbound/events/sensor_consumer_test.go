package events

import (
	"context"
	"errors"
	"sort"
	"strconv"
	"testing"
	"time"

	eventsdomain "p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/testutil"

	"p9e.in/samavaya/agriculture/sensor-service/internal/domain"
	"p9e.in/samavaya/agriculture/sensor-service/internal/ports/inbound"
)

// cascadeService holds sensors whose status decommissioning actually changes,
// so the sweep is exercised rather than assumed. A decommissioned sensor stays
// in the listing, which is exactly the property that makes the offset have to
// advance.
type cascadeService struct {
	inbound.SensorService // nil: the consumer only lists and decommissions

	sensors   map[string]*domain.Sensor
	tenants   []string
	listCalls int

	listErr error
	// decommissionErr fails every decommission.
	decommissionErr error
	// decommissionNoOp reports success without changing the status — the
	// failure an advancing offset must survive and a re-reading loop would
	// spin on.
	decommissionNoOp bool
}

func newCascadeService(onField, onFarmOnly int) *cascadeService {
	s := &cascadeService{sensors: map[string]*domain.Sensor{}}
	for i := 0; i < onField; i++ {
		id := "s-field-" + strconv.Itoa(i)
		sensor := &domain.Sensor{FieldID: "fld-1", FarmID: "fm-1", Status: domain.SensorStatusActive}
		sensor.ID = id
		s.sensors[id] = sensor
	}
	for i := 0; i < onFarmOnly; i++ {
		id := "s-farm-" + strconv.Itoa(i)
		// No field: a weather station by the gate. Nothing about a field
		// deletion reaches it.
		sensor := &domain.Sensor{FarmID: "fm-1", Status: domain.SensorStatusActive}
		sensor.ID = id
		s.sensors[id] = sensor
	}
	return s
}

func (s *cascadeService) ListSensors(ctx context.Context, f domain.SensorListFilter) ([]domain.Sensor, int32, error) {
	s.listCalls++
	s.tenants = append(s.tenants, p9context.TenantID(ctx))
	if s.listErr != nil {
		return nil, 0, s.listErr
	}

	// Sorted so paging is deterministic; a map iteration would make an offset
	// test meaningless.
	ids := make([]string, 0, len(s.sensors))
	for id, sensor := range s.sensors {
		if f.FieldID != "" && sensor.FieldID != f.FieldID {
			continue
		}
		if f.FarmID != "" && sensor.FarmID != f.FarmID {
			continue
		}
		ids = append(ids, id)
	}
	sort.Strings(ids)

	total := int32(len(ids))
	if f.PageOffset >= total {
		return nil, total, nil
	}
	ids = ids[f.PageOffset:]
	if f.PageSize > 0 && int32(len(ids)) > f.PageSize {
		ids = ids[:f.PageSize]
	}

	out := make([]domain.Sensor, 0, len(ids))
	for _, id := range ids {
		out = append(out, *s.sensors[id])
	}
	return out, total, nil
}

func (s *cascadeService) DecommissionSensor(_ context.Context, id, _ string) (*domain.Sensor, error) {
	if s.decommissionErr != nil {
		return nil, s.decommissionErr
	}
	sensor, ok := s.sensors[id]
	if !ok {
		return nil, errors.New("not found")
	}
	if !s.decommissionNoOp {
		sensor.Status = domain.SensorStatusDecommissioned
	}
	return sensor, nil
}

func (s *cascadeService) activeCount() int {
	n := 0
	for _, sensor := range s.sensors {
		if sensor.Status != domain.SensorStatusDecommissioned {
			n++
		}
	}
	return n
}

func fieldDeleted(fieldID, tenantID string) *eventsdomain.DomainEvent {
	return event(eventsdomain.EventTypeFieldDeleted, map[string]any{
		"field_id": fieldID, "tenant_id": tenantID,
	})
}

func farmDeleted(farmID, tenantID string) *eventsdomain.DomainEvent {
	return event(eventsdomain.EventTypeFarmDeleted, map[string]any{
		"farm_id": farmID, "tenant_id": tenantID,
	})
}

func event(t eventsdomain.EventType, data map[string]any) *eventsdomain.DomainEvent {
	return &eventsdomain.DomainEvent{
		ID: "evt-1", Type: t, AggregateID: "agg-1", Timestamp: time.Now(), Data: data,
	}
}

// ---------------------------------------------------------------------------

// The point of the handler: a deleted field's sensors stop being in service.
//
// It used to log "field deleted, decommissioning associated sensors" and
// return nil, having decommissioned nothing — so the sensors stayed ACTIVE,
// kept ingesting readings and kept raising threshold alerts naming a field
// nobody could open.
func TestFieldDeletedDecommissionsItsSensors(t *testing.T) {
	svc := newCascadeService(5, 2)
	c := NewSensorConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}

	for id, s := range svc.sensors {
		onField := s.FieldID == "fld-1"
		decommissioned := s.Status == domain.SensorStatusDecommissioned
		if onField && !decommissioned {
			t.Errorf("sensor %s is on the deleted field and is still %s", id, s.Status)
		}
		if !onField && decommissioned {
			t.Errorf("sensor %s is not on the deleted field and was decommissioned", id)
		}
	}
}

// A farm deletion reaches the sensors that no field-deleted event would: one
// sitting at the farm with no field.
func TestFarmDeletedDecommissionsEverySensorOnIt(t *testing.T) {
	svc := newCascadeService(3, 2)
	c := NewSensorConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), farmDeleted("fm-1", "tenant-a")); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}

	if got := svc.activeCount(); got != 0 {
		t.Errorf("%d sensors still in service after their farm was deleted", got)
	}
}

// The sweep must cross page boundaries. Decommissioning does not remove the
// sensor from the listing, so a loop that re-read page zero would either spin
// or stop after one page.
func TestSweepCrossesPageBoundaries(t *testing.T) {
	// Two and a bit pages at the 100-row page size.
	svc := newCascadeService(0, 250)
	c := NewSensorConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), farmDeleted("fm-1", "tenant-a")); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}

	if got := svc.activeCount(); got != 0 {
		t.Errorf("%d of 250 sensors were left in service; the sweep stopped early", got)
	}
	if svc.listCalls < 3 {
		t.Errorf("listed %d times for 250 sensors at a page size of %d",
			svc.listCalls, cascadePageSize)
	}
}

// A decommission that silently does nothing must terminate rather than spin,
// and must not report the farm as cleaned up when it is not.
func TestANoOpDecommissionTerminates(t *testing.T) {
	// Across several pages, so the offset is what ends the sweep rather than
	// the first short page.
	svc := newCascadeService(0, 250)
	svc.decommissionNoOp = true
	c := NewSensorConsumer(svc, testutil.NopLogger{})

	done := make(chan error, 1)
	go func() { done <- c.HandleEvent(context.Background(), farmDeleted("fm-1", "tenant-a")) }()

	select {
	case <-done:
	case <-time.After(5 * time.Second):
		t.Fatal("the sweep did not terminate against a no-op decommission")
	}
	if svc.activeCount() != 250 {
		t.Errorf("sensors changed state against a no-op decommission")
	}
}

// A listing failure is returned so the consumer retries. Swallowing it would
// let a momentary database blip orphan the whole farm's sensors, with Kafka
// committing the offset on the way past.
func TestAListingFailureIsRetryable(t *testing.T) {
	svc := newCascadeService(2, 0)
	svc.listErr = errors.New("database unavailable")
	c := NewSensorConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err == nil {
		t.Error("a listing failure was reported as a successful handle")
	}
}

// Every sensor on a page failing is returned: the next page would fail the
// same way, and reporting success would have Kafka commit over sensors that
// are still live.
func TestAWhollyFailedPageIsReported(t *testing.T) {
	svc := newCascadeService(3, 0)
	svc.decommissionErr = errors.New("write failed")
	c := NewSensorConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err == nil {
		t.Error("a page where every decommission failed was reported as success")
	}
}

// An event with no tenant cannot be acted on and must be dropped rather than
// retried: it can never succeed, and retrying it forever blocks the partition
// for every event behind it. Guessing a tenant would decommission somebody
// else's sensors.
func TestAnEventWithoutATenantIsDroppedNotRetried(t *testing.T) {
	svc := newCascadeService(3, 0)
	c := NewSensorConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "")); err != nil {
		t.Errorf("a tenantless event was retried: %v", err)
	}
	if svc.listCalls != 0 {
		t.Errorf("a tenantless event still queried: %d calls", svc.listCalls)
	}
	if svc.activeCount() != 3 {
		t.Error("sensors were decommissioned from a tenantless event")
	}
}

// The consumer has no request to inherit a tenant from, so it must attach one.
// Without it every query runs unscoped, RLS returns nothing, and the handler
// reports success over an empty list.
func TestTheSweepRunsInTheEventsTenant(t *testing.T) {
	svc := newCascadeService(2, 0)
	c := NewSensorConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if len(svc.tenants) == 0 {
		t.Fatal("no listing happened")
	}
	for _, got := range svc.tenants {
		if got != "tenant-a" {
			t.Errorf("listed with tenant %q, want tenant-a", got)
		}
	}
}

// A sensor already out of service is skipped, not re-decommissioned. A farm
// deletion follows the per-field deletes field-service cascades, so most of
// these sensors have already been through this once.
func TestAlreadyDecommissionedSensorsAreSkipped(t *testing.T) {
	svc := newCascadeService(2, 0)
	for _, s := range svc.sensors {
		s.Status = domain.SensorStatusDecommissioned
	}
	svc.decommissionErr = errors.New("should not be called")
	c := NewSensorConsumer(svc, testutil.NopLogger{})

	if err := c.HandleEvent(context.Background(), fieldDeleted("fld-1", "tenant-a")); err != nil {
		t.Errorf("re-running the cascade over decommissioned sensors failed: %v", err)
	}
}
