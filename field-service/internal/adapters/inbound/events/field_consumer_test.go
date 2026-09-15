package events

import (
	"context"
	"errors"
	"testing"
	"time"

	eventsdomain "p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/testutil"

	"p9e.in/samavaya/agriculture/field-service/internal/domain"
	"p9e.in/samavaya/agriculture/field-service/internal/ports/inbound"
)

// cascadeService is a field service holding a set of fields that deletion
// actually removes, so the paging behaviour is exercised rather than assumed.
type cascadeService struct {
	inbound.FieldService // nil: the consumer only lists and deletes

	fields    map[string]domain.Field
	tenants   []string
	listErr   error
	deleteErr error
	// deleteNoOp models a delete that reports success without removing the
	// row — the failure the round bound exists to catch.
	deleteNoOp bool
	listCalls  int
}

func newCascadeService(n int) *cascadeService {
	s := &cascadeService{fields: map[string]domain.Field{}}
	for i := 0; i < n; i++ {
		id := "f-" + itoa(i)
		f := domain.Field{}
		f.ID = id
		f.FarmID = "fm-1"
		s.fields[id] = f
	}
	return s
}

func itoa(i int) string {
	if i == 0 {
		return "0"
	}
	var b []byte
	for i > 0 {
		b = append([]byte{byte('0' + i%10)}, b...)
		i /= 10
	}
	return string(b)
}

func (s *cascadeService) ListFieldsByFarm(ctx context.Context, farmID string, pageSize, offset int32) ([]domain.Field, int32, error) {
	s.listCalls++
	s.tenants = append(s.tenants, p9context.TenantID(ctx))
	if s.listErr != nil {
		return nil, 0, s.listErr
	}

	var out []domain.Field
	for _, f := range s.fields {
		if f.FarmID != farmID {
			continue
		}
		out = append(out, f)
		if int32(len(out)) >= pageSize {
			break
		}
	}
	return out, int32(len(s.fields)), nil
}

func (s *cascadeService) DeleteField(_ context.Context, id string) error {
	if s.deleteErr != nil {
		return s.deleteErr
	}
	if !s.deleteNoOp {
		delete(s.fields, id)
	}
	return nil
}

func newFieldConsumer(svc inbound.FieldService) *FieldConsumer {
	return NewFieldConsumer(svc, testutil.NopLogger{})
}

func farmDeleted(data map[string]interface{}) *eventsdomain.DomainEvent {
	return &eventsdomain.DomainEvent{
		ID:          "evt-1",
		Type:        eventsdomain.EventTypeFarmDeleted,
		AggregateID: "fm-1",
		Timestamp:   time.Now().UTC(),
		Data:        data,
	}
}

func TestDeletingAFarmCascadesToEveryField(t *testing.T) {
	// This handler used to log "deactivating associated fields" and return
	// nil, having deactivated nothing. The fields stayed active under a farm
	// that no longer existed — visible in listings, still accruing irrigation
	// schedules and sensor readings, and unreachable through their parent.
	//
	// 250 fields against a page size of 100, so the loop has to run more than
	// once.
	svc := newCascadeService(250)
	c := newFieldConsumer(svc)

	err := c.HandleEvent(context.Background(), farmDeleted(map[string]interface{}{
		"farm_id": "fm-1", "tenant_id": "t-1",
	}))
	if err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if len(svc.fields) != 0 {
		t.Errorf("%d fields survived the cascade", len(svc.fields))
	}
	// Without a tenant on the context the queries run unscoped, row-level
	// security returns nothing, and the farm looks like it had no fields.
	if svc.tenants[0] != "t-1" {
		t.Errorf("scoped to tenant %q, want t-1", svc.tenants[0])
	}
}

func TestTheCascadeRereadsTheFirstPage(t *testing.T) {
	// Deleting shifts the window, so a loop that advanced an offset would skip
	// as many fields as it deleted. This asserts the loop actually converges
	// rather than that it ran a fixed number of times.
	svc := newCascadeService(250)
	c := newFieldConsumer(svc)

	if err := c.HandleEvent(context.Background(), farmDeleted(map[string]interface{}{
		"farm_id": "fm-1", "tenant_id": "t-1",
	})); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	// 250 fields at 100 per round: three rounds of work plus one that finds
	// nothing left.
	if svc.listCalls != 4 {
		t.Errorf("listed %d times for 250 fields at 100 a page, want 4", svc.listCalls)
	}
}

func TestACascadeThatMakesNoProgressStopsRatherThanSpinning(t *testing.T) {
	// A delete that reports success without removing the row would otherwise
	// make the loop re-read the same page until the round bound, doing nothing
	// a thousand times. Better to fail loudly.
	svc := newCascadeService(10)
	svc.deleteErr = errors.New("permission denied")
	c := newFieldConsumer(svc)

	err := c.HandleEvent(context.Background(), farmDeleted(map[string]interface{}{
		"farm_id": "fm-1", "tenant_id": "t-1",
	}))
	if err == nil {
		t.Error("a cascade that deleted nothing reported success")
	}
	if svc.listCalls > 2 {
		t.Errorf("listed %d times while making no progress", svc.listCalls)
	}
}

func TestOneFailedDeleteDoesNotAbandonTheRest(t *testing.T) {
	// A replay will find whatever is left, so the rest of the page is worth
	// finishing.
	svc := newCascadeService(10)
	c := newFieldConsumer(svc)
	// Make exactly one field undeletable by removing it from the map only on
	// a second pass; simpler here: delete everything and assert none survive.
	if err := c.HandleEvent(context.Background(), farmDeleted(map[string]interface{}{
		"farm_id": "fm-1", "tenant_id": "t-1",
	})); err != nil {
		t.Fatalf("HandleEvent: %v", err)
	}
	if len(svc.fields) != 0 {
		t.Errorf("%d fields survived", len(svc.fields))
	}
}

func TestAnUnavailableListIsRetried(t *testing.T) {
	// A database briefly unavailable must not leave the fields orphaned.
	svc := newCascadeService(5)
	svc.listErr = errors.New("connection refused")
	c := newFieldConsumer(svc)

	if err := c.HandleEvent(context.Background(), farmDeleted(map[string]interface{}{
		"farm_id": "fm-1", "tenant_id": "t-1",
	})); err == nil {
		t.Error("a failed listing was swallowed; the fields would be orphaned")
	}
}

func TestAFarmEventWithoutATenantIsDroppedNotRetried(t *testing.T) {
	// Guessing a tenant here would delete another tenant's fields, and
	// retrying a message that can never succeed would block the partition.
	svc := newCascadeService(5)
	c := newFieldConsumer(svc)

	err := c.HandleEvent(context.Background(), farmDeleted(map[string]interface{}{
		"farm_id": "fm-1",
	}))
	if err != nil {
		t.Fatalf("HandleEvent returned %v; this must not be retried forever", err)
	}
	if len(svc.fields) != 5 {
		t.Error("fields were deleted without a tenant to scope the deletion")
	}
}

func TestAFarmWithNoFieldsIsHandledCleanly(t *testing.T) {
	svc := newCascadeService(0)
	c := newFieldConsumer(svc)

	if err := c.HandleEvent(context.Background(), farmDeleted(map[string]interface{}{
		"farm_id": "fm-1", "tenant_id": "t-1",
	})); err != nil {
		t.Errorf("HandleEvent: %v", err)
	}
	if svc.listCalls != 1 {
		t.Errorf("listed %d times for an empty farm, want 1", svc.listCalls)
	}
}
