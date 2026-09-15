package realtime

import (
	"errors"
	"testing"
)

// Neither transport had any tenant isolation. A client subscribed by sending a topic
// string, the hub stored it verbatim, and a broadcast went to everyone
// subscribed to that string — so an authenticated user in one tenant who named
// another tenant's field received that field's live sensor readings, irrigation
// events and alerts, and the SSE broker delivered an untopiced event to every
// subscriber on the process. These are the tests that say it cannot happen
// again, and they are named after the leak rather than after the functions.

func TestAClientCannotSubscribeToAnotherTenantsTopic(t *testing.T) {
	// The whole reason this file exists.
	_, err := ScopeTopic("tenant-a", TenantTopic("tenant-b", "sensor.field-9"))
	if !errors.Is(err, ErrTopicOtherTenant) {
		t.Fatalf("error %v; a client reached across the tenant boundary", err)
	}
}

func TestABareTopicIsScopedToTheCallersOwnTenant(t *testing.T) {
	// A client asking for "sensor.field-1" gets its own tenant's stream and has
	// no way to express anyone else's. This is what makes the scoping
	// structural rather than a rule clients have to follow.
	got, err := ScopeTopic("tenant-a", "sensor.field-1")
	if err != nil {
		t.Fatalf("ScopeTopic: %v", err)
	}
	if want := TenantTopic("tenant-a", "sensor.field-1"); got != want {
		t.Errorf("got %q, want %q", got, want)
	}
}

func TestAConnectionWithNoTenantCannotSubscribeToAnything(t *testing.T) {
	// Not treated as "all tenants", which is what an unscoped connection would
	// have amounted to before.
	if _, err := ScopeTopic("", "sensor.field-1"); !errors.Is(err, ErrNoTenant) {
		t.Errorf("error %v, want ErrNoTenant", err)
	}
}

func TestAnEmptyTopicIsRefused(t *testing.T) {
	if _, err := ScopeTopic("tenant-a", ""); !errors.Is(err, ErrEmptyTopic) {
		t.Errorf("error %v, want ErrEmptyTopic", err)
	}
}

func TestAMalformedPrefixDoesNotImpersonateATenant(t *testing.T) {
	// "t//sensor" parses as a tenant of "" under a careless split. Treated as
	// an ordinary name and scoped to the caller, so it cannot match a topic
	// belonging to a tenant whose id is empty.
	for _, requested := range []string{"t//sensor.field-1", "t/tenant-b", "t/tenant-b/"} {
		got, err := ScopeTopic("tenant-a", requested)
		if err != nil {
			t.Fatalf("ScopeTopic(%q): %v", requested, err)
		}
		owner, _, ok := SplitTopic(got)
		if !ok || owner != "tenant-a" {
			t.Errorf("%q resolved to %q, owned by %q", requested, got, owner)
		}
	}
}

func TestTopicOwnershipIsFalseForAnUnqualifiedTopic(t *testing.T) {
	// A topic with no tenant belongs to nobody. Answering true here would
	// restore exactly the behaviour being replaced.
	if TopicBelongsTo("sensor.field-1", "tenant-a") {
		t.Error("an unqualified topic was reported as owned")
	}
	if TopicBelongsTo(TenantTopic("", "sensor.field-1"), "") {
		t.Error("an empty tenant was reported as owning a topic")
	}
}

func TestSplitTopicRoundTrips(t *testing.T) {
	topic := TenantTopic("tenant-a", "sensor.field-1")
	owner, name, ok := SplitTopic(topic)
	if !ok || owner != "tenant-a" || name != "sensor.field-1" {
		t.Errorf("SplitTopic(%q) = (%q, %q, %v)", topic, owner, name, ok)
	}

	// A name containing a slash survives: only the first segment is the tenant.
	nested := TenantTopic("tenant-a", "map/field-1/gps")
	owner, name, ok = SplitTopic(nested)
	if !ok || owner != "tenant-a" || name != "map/field-1/gps" {
		t.Errorf("SplitTopic(%q) = (%q, %q, %v)", nested, owner, name, ok)
	}
}
