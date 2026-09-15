package realtime

import (
	"sync"
	"testing"
	"time"
)

// A clock the test drives, so expiry is exercised without sleeping.
type fakeClock struct {
	mu sync.Mutex
	t  time.Time
}

func newClock() *fakeClock {
	return &fakeClock{t: time.Date(2026, 3, 14, 9, 0, 0, 0, time.UTC)}
}

func (c *fakeClock) now() time.Time {
	c.mu.Lock()
	defer c.mu.Unlock()
	return c.t
}

func (c *fakeClock) advance(d time.Duration) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.t = c.t.Add(d)
}

func member(id, tenant string) Member {
	return Member{ID: id, TenantID: tenant, Name: id, Role: "agronomist"}
}

func TestPresence_JoinAndList(t *testing.T) {
	clock := newClock()
	p := NewPresence(WithPresenceClock(clock.now))
	topic := TenantTopic("tenant-1", InspectionTopic("insp-1"))

	if _, err := p.Join(topic, member("user-a", "tenant-1")); err != nil {
		t.Fatalf("join: %v", err)
	}
	members, err := p.Join(topic, member("user-b", "tenant-1"))
	if err != nil {
		t.Fatalf("join: %v", err)
	}

	if len(members) != 2 {
		t.Fatalf("expected 2 members, got %d", len(members))
	}
	// Ordered, so two clients rendering the same room agree.
	if members[0].ID != "user-a" || members[1].ID != "user-b" {
		t.Errorf("members are not ordered by id: %v", members)
	}
}

func TestPresence_RefusesAnotherTenantsRoom(t *testing.T) {
	// Presence is a read of who is in a room, and a room belongs to one
	// tenant. Without this, "who else is editing" leaks names and roles
	// across tenants even when the edits themselves do not.
	p := NewPresence()
	topic := TenantTopic("tenant-1", InspectionTopic("insp-1"))

	if _, err := p.Join(topic, member("intruder", "tenant-2")); err != ErrTopicOtherTenant {
		t.Fatalf("expected ErrTopicOtherTenant, got %v", err)
	}
	if p.Count(topic) != 0 {
		t.Error("an intruder was admitted")
	}
}

func TestPresence_RefusesUnqualifiedTopic(t *testing.T) {
	// A topic with no tenant belongs to nobody; admitting to it would restore
	// exactly the cross-tenant behaviour the topic scheme exists to prevent.
	p := NewPresence()

	if _, err := p.Join(InspectionTopic("insp-1"), member("user-a", "tenant-1")); err != ErrTopicOtherTenant {
		t.Fatalf("expected refusal for an unqualified topic, got %v", err)
	}
}

func TestPresence_RefusesEmptyMember(t *testing.T) {
	p := NewPresence()
	topic := TenantTopic("tenant-1", InspectionTopic("insp-1"))

	if _, err := p.Join(topic, Member{TenantID: "tenant-1"}); err != ErrEmptyMember {
		t.Fatalf("expected ErrEmptyMember, got %v", err)
	}
}

func TestPresence_ExpiresAMemberThatWentQuiet(t *testing.T) {
	// The case this exists for: a phone drives out of signal and never sends a
	// leave. Without expiry the map shows a tractor sitting in a field for the
	// rest of the season.
	clock := newClock()
	p := NewPresence(WithPresenceClock(clock.now), WithPresenceTTL(90*time.Second))
	topic := TenantTopic("tenant-1", FieldMapTopic("field-1"))

	if _, err := p.Join(topic, member("tractor-4", "tenant-1")); err != nil {
		t.Fatalf("join: %v", err)
	}

	clock.advance(89 * time.Second)
	if p.Count(topic) != 1 {
		t.Error("member expired early")
	}

	clock.advance(2 * time.Second)
	if p.Count(topic) != 0 {
		t.Error("member outlived its TTL")
	}
}

func TestPresence_HeartbeatKeepsAMemberAlive(t *testing.T) {
	clock := newClock()
	p := NewPresence(WithPresenceClock(clock.now), WithPresenceTTL(90*time.Second))
	topic := TenantTopic("tenant-1", FieldMapTopic("field-1"))

	if _, err := p.Join(topic, member("tractor-4", "tenant-1")); err != nil {
		t.Fatalf("join: %v", err)
	}

	for i := 0; i < 5; i++ {
		clock.advance(60 * time.Second)
		if !p.Heartbeat(topic, "tractor-4") {
			t.Fatalf("heartbeat %d was refused", i)
		}
	}

	if p.Count(topic) != 1 {
		t.Error("a member heartbeating every 60s under a 90s TTL was dropped")
	}
}

func TestPresence_HeartbeatFromAnExpiredMemberIsRefused(t *testing.T) {
	// Refused rather than silently reviving: the room's other participants
	// were told this member left, so they have to be told it is back.
	clock := newClock()
	p := NewPresence(WithPresenceClock(clock.now), WithPresenceTTL(30*time.Second))
	topic := TenantTopic("tenant-1", FieldMapTopic("field-1"))

	if _, err := p.Join(topic, member("scout-1", "tenant-1")); err != nil {
		t.Fatalf("join: %v", err)
	}
	clock.advance(31 * time.Second)

	if p.Heartbeat(topic, "scout-1") {
		t.Error("an expired member was revived without the room being told")
	}
}

func TestPresence_HeartbeatForAnAbsentMember(t *testing.T) {
	p := NewPresence()
	topic := TenantTopic("tenant-1", FieldMapTopic("field-1"))

	if p.Heartbeat(topic, "nobody") {
		t.Error("heartbeat succeeded for a member that never joined")
	}
}

func TestPresence_Leave(t *testing.T) {
	p := NewPresence()
	topic := TenantTopic("tenant-1", InspectionTopic("insp-1"))

	mustJoin(t, p, topic, member("user-a", "tenant-1"))
	mustJoin(t, p, topic, member("user-b", "tenant-1"))

	remaining := p.Leave(topic, "user-a")
	if len(remaining) != 1 || remaining[0].ID != "user-b" {
		t.Fatalf("expected user-b to remain, got %v", remaining)
	}

	if got := p.Leave(topic, "user-b"); got != nil {
		t.Errorf("expected an empty room, got %v", got)
	}
}

func TestPresence_LeaveAllOnDisconnect(t *testing.T) {
	// A client that drops holds its place in every room it joined otherwise.
	p := NewPresence()
	mapTopic := TenantTopic("tenant-1", FieldMapTopic("field-1"))
	inspTopic := TenantTopic("tenant-1", InspectionTopic("insp-1"))

	mustJoin(t, p, mapTopic, member("user-a", "tenant-1"))
	mustJoin(t, p, inspTopic, member("user-a", "tenant-1"))
	mustJoin(t, p, inspTopic, member("user-b", "tenant-1"))

	left := p.LeaveAll("user-a")
	if len(left) != 2 {
		t.Fatalf("expected 2 rooms to be told, got %v", left)
	}
	if p.Count(mapTopic) != 0 {
		t.Error("field map room still holds the disconnected client")
	}
	if p.Count(inspTopic) != 1 {
		t.Error("inspection room lost the wrong member")
	}
}

func TestPresence_SweepReportsTheRoomsThatChanged(t *testing.T) {
	// The sweep is what lets the rooms a member vanished from be *told*;
	// read-time expiry alone leaves the other participants looking at a list
	// that is quietly wrong.
	clock := newClock()
	p := NewPresence(WithPresenceClock(clock.now), WithPresenceTTL(30*time.Second))
	stale := TenantTopic("tenant-1", FieldMapTopic("field-1"))
	fresh := TenantTopic("tenant-1", FieldMapTopic("field-2"))

	mustJoin(t, p, stale, member("tractor-4", "tenant-1"))
	clock.advance(31 * time.Second)
	mustJoin(t, p, fresh, member("tractor-5", "tenant-1"))

	changed := p.Sweep()
	if len(changed) != 1 || changed[0] != stale {
		t.Fatalf("expected only the stale room to change, got %v", changed)
	}
	if p.Count(fresh) != 1 {
		t.Error("the fresh room was swept")
	}
}

func TestPresence_RejoinRefreshesRatherThanDuplicates(t *testing.T) {
	// Two browser tabs belonging to one agronomist are one member. Otherwise
	// "three people are editing this" is a count of sockets, not of people.
	p := NewPresence()
	topic := TenantTopic("tenant-1", InspectionTopic("insp-1"))

	mustJoin(t, p, topic, member("user-a", "tenant-1"))
	members := mustJoin(t, p, topic, member("user-a", "tenant-1"))

	if len(members) != 1 {
		t.Fatalf("expected 1 member, got %d", len(members))
	}
}

func TestPresence_ConcurrentAccess(t *testing.T) {
	// The hub calls this from its event loop while a sweep timer runs
	// elsewhere; run with -race.
	p := NewPresence()
	topic := TenantTopic("tenant-1", FieldMapTopic("field-1"))

	var wg sync.WaitGroup
	for i := 0; i < 20; i++ {
		wg.Add(3)
		go func(i int) { defer wg.Done(); _, _ = p.Join(topic, member("m", "tenant-1")) }(i)
		go func() { defer wg.Done(); p.Members(topic) }()
		go func() { defer wg.Done(); p.Sweep() }()
	}
	wg.Wait()
}

func mustJoin(t *testing.T, p *Presence, topic string, m Member) []Member {
	t.Helper()
	members, err := p.Join(topic, m)
	if err != nil {
		t.Fatalf("join %s: %v", m.ID, err)
	}
	return members
}
