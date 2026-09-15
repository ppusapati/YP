package realtime

import (
	"sort"
	"sync"
	"time"
)

// Presence tracks who is currently in a topic.
//
// Both real-time features need it and need it identically. A field map shows
// which machines and people are in the field right now; a collaborative
// inspection shows which agronomists have the form open. Neither is answerable
// from a broadcast log — "who is here" is state, and state that nobody holds
// gets reconstructed differently by every client.
//
// Membership expires. A phone that drives out of signal never sends a leave,
// so a registry that only removed members on an explicit departure would show
// a tractor sitting in a field for the rest of the season. Anything that has
// not been heard from within the TTL is gone.
type Presence struct {
	mu sync.RWMutex

	// members[topic][memberID]
	members map[string]map[string]Member

	ttl time.Duration
	now func() time.Time
}

// Member is one participant in a topic.
type Member struct {
	// ID is stable for the participant: a user id, or a device id for a
	// machine. Two browser tabs belonging to one agronomist are one member,
	// which is what makes "three people are editing this" true rather than a
	// count of sockets.
	ID string `json:"id"`

	// TenantID owns this member. Held so a stale entry cannot be read back
	// into the wrong tenant's room.
	TenantID string `json:"tenant_id"`

	// Name is what a person is shown, e.g. "R. Patil" or "Tractor 4".
	Name string `json:"name,omitempty"`

	// Role distinguishes a person from a machine, and one kind of machine from
	// another: "agronomist", "tractor", "drone".
	Role string `json:"role,omitempty"`

	// LastSeen is when this member last sent anything.
	LastSeen time.Time `json:"last_seen"`
}

// PresenceOption configures a Presence registry.
type PresenceOption func(*Presence)

// WithPresenceTTL sets how long a member survives without a heartbeat.
func WithPresenceTTL(ttl time.Duration) PresenceOption {
	return func(p *Presence) { p.ttl = ttl }
}

// WithPresenceClock replaces the clock, for tests.
func WithPresenceClock(now func() time.Time) PresenceOption {
	return func(p *Presence) { p.now = now }
}

// DefaultPresenceTTL is how long a member lives without being heard from.
//
// Ninety seconds because a field client heartbeats every thirty and a rural
// connection drops packets: a tighter window makes members flicker in and out
// while they are demonstrably still there, which is worse than being slightly
// slow to notice a real departure.
const DefaultPresenceTTL = 90 * time.Second

// NewPresence creates a presence registry.
func NewPresence(opts ...PresenceOption) *Presence {
	p := &Presence{
		members: make(map[string]map[string]Member),
		ttl:     DefaultPresenceTTL,
		now:     time.Now,
	}
	for _, opt := range opts {
		opt(p)
	}
	return p
}

// Join adds or refreshes a member in a topic.
//
// The topic must be tenant-qualified and the member's tenant must own it —
// presence is a read of who is in a room, and a room belongs to one tenant.
// Returns the members now present, so the caller can broadcast the new list
// without a second lookup that could race with a concurrent leave.
func (p *Presence) Join(topic string, member Member) ([]Member, error) {
	if member.ID == "" {
		return nil, ErrEmptyMember
	}
	if !TopicBelongsTo(topic, member.TenantID) {
		return nil, ErrTopicOtherTenant
	}

	p.mu.Lock()
	defer p.mu.Unlock()

	if p.members[topic] == nil {
		p.members[topic] = make(map[string]Member)
	}
	member.LastSeen = p.now()
	p.members[topic][member.ID] = member

	return p.membersLocked(topic), nil
}

// Heartbeat refreshes a member's last-seen time.
//
// Returns false when the member was not present — which happens when they were
// expired while out of signal. The caller treats that as a rejoin rather than
// silently reviving an entry, so the room's other participants are told.
func (p *Presence) Heartbeat(topic, memberID string) bool {
	p.mu.Lock()
	defer p.mu.Unlock()

	room, ok := p.members[topic]
	if !ok {
		return false
	}
	member, ok := room[memberID]
	if !ok {
		return false
	}
	// Expired but not yet swept: treat as absent so the caller rejoins and the
	// room is told, rather than having the member reappear with no event.
	if p.now().Sub(member.LastSeen) > p.ttl {
		delete(room, memberID)
		if len(room) == 0 {
			delete(p.members, topic)
		}
		return false
	}
	member.LastSeen = p.now()
	room[memberID] = member
	return true
}

// Leave removes a member and returns who remains.
func (p *Presence) Leave(topic, memberID string) []Member {
	p.mu.Lock()
	defer p.mu.Unlock()

	room, ok := p.members[topic]
	if !ok {
		return nil
	}
	delete(room, memberID)
	if len(room) == 0 {
		delete(p.members, topic)
		return nil
	}
	return p.membersLocked(topic)
}

// LeaveAll removes a member from every topic, for a disconnect.
//
// Returns the topics they were in, so each room can be told. A client that
// drops holds its place in every room it had joined otherwise.
func (p *Presence) LeaveAll(memberID string) []string {
	p.mu.Lock()
	defer p.mu.Unlock()

	var left []string
	for topic, room := range p.members {
		if _, ok := room[memberID]; !ok {
			continue
		}
		delete(room, memberID)
		left = append(left, topic)
		if len(room) == 0 {
			delete(p.members, topic)
		}
	}
	sort.Strings(left)
	return left
}

// Members returns who is currently present, excluding anyone expired.
//
// Ordered by id so two clients rendering the same room agree on the order,
// rather than each getting Go's map iteration order.
func (p *Presence) Members(topic string) []Member {
	p.mu.RLock()
	defer p.mu.RUnlock()
	return p.membersLocked(topic)
}

// Count is the number of live members in a topic.
func (p *Presence) Count(topic string) int {
	return len(p.Members(topic))
}

// Sweep removes expired members and returns the topics that changed.
//
// Called on a timer. Expiry is also applied on read, so a caller that never
// sweeps still never sees a stale member — the sweep is what lets the rooms
// they left be *told*, and what stops the map growing without bound.
func (p *Presence) Sweep() []string {
	p.mu.Lock()
	defer p.mu.Unlock()

	cutoff := p.now().Add(-p.ttl)
	var changed []string

	for topic, room := range p.members {
		removed := false
		for id, m := range room {
			if m.LastSeen.Before(cutoff) {
				delete(room, id)
				removed = true
			}
		}
		if removed {
			changed = append(changed, topic)
		}
		if len(room) == 0 {
			delete(p.members, topic)
		}
	}
	sort.Strings(changed)
	return changed
}

// membersLocked requires at least a read lock.
func (p *Presence) membersLocked(topic string) []Member {
	room, ok := p.members[topic]
	if !ok {
		return nil
	}
	cutoff := p.now().Add(-p.ttl)
	out := make([]Member, 0, len(room))
	for _, m := range room {
		if m.LastSeen.Before(cutoff) {
			continue
		}
		out = append(out, m)
	}
	if len(out) == 0 {
		return nil
	}
	sort.Slice(out, func(i, j int) bool { return out[i].ID < out[j].ID })
	return out
}
