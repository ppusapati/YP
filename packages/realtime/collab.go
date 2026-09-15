package realtime

import (
	"sync"
	"time"
)

// Collaborative editing of a field inspection.
//
// Two agronomists open the same draft inspection — one walking the field, one
// at a desk with the satellite history — and both type. The question every
// collaborative editor has to answer is what happens when they type into the
// same box, and the wrong answers are worse than no collaboration at all:
//
//   - **Last write wins, silently.** One agronomist's findings vanish while
//     they are looking at them. They do not notice until the report is filed.
//   - **Whole-document locking.** One person edits, the other watches. That is
//     not collaboration; it is a queue.
//   - **Character-level merging (a CRDT).** Correct, and the wrong tool here.
//     An inspection is a form — a health score, a findings paragraph, a list of
//     issues — not a shared prose document, and the cost of getting a CRDT
//     subtly wrong is silent corruption of an agronomic record.
//
// What this does instead: **per-field last-write-wins with an explicit
// version, and a loser who is told.** Each field of the form carries its own
// version. An edit names the version it was based on. If that is current, it
// applies and the version increments. If it is not, the edit is refused and
// the editor is handed the value that beat them, so they can see the
// difference and decide — rather than discovering later that their paragraph
// is gone.
//
// Two people editing *different* fields never conflict, which is the common
// case: one fills in the health score while the other writes the findings.

// InspectionFields are the editable parts of an inspection form.
//
// Enumerated rather than free-form, so a typo in a client cannot create a
// phantom field that is versioned, broadcast and never persisted — which would
// look exactly like an edit that worked.
var InspectionFields = map[string]bool{
	"findings":        true,
	"notes":           true,
	"health_score":    true,
	"recommendations": true,
	"issues":          true,
	"photos":          true,
}

// FieldValue is one field of the form at one version.
type FieldValue struct {
	// Value is the field's content, as the client sent it. Kept as-is: this
	// package brokers edits and does not interpret an inspection's meaning.
	Value interface{} `json:"value"`

	// Version increments on every accepted edit to this field.
	Version int64 `json:"version"`

	// EditedBy and EditedAt are who last changed it and when, so the other
	// editor sees "R. Patil changed this a moment ago" rather than watching
	// text change by itself.
	EditedBy string    `json:"edited_by"`
	EditedAt time.Time `json:"edited_at"`
}

// Edit is one proposed change.
type Edit struct {
	InspectionID string      `json:"inspection_id"`
	TenantID     string      `json:"tenant_id"`
	Field        string      `json:"field"`
	Value        interface{} `json:"value"`

	// BaseVersion is the version the editor was looking at.
	//
	// Zero means "I am writing this field for the first time", which is
	// accepted only while the field is genuinely unset. Treating zero as
	// "force" would make every client that forgets to track versions into a
	// silent overwriter.
	BaseVersion int64 `json:"base_version"`

	EditedBy string `json:"edited_by"`
}

// EditResult is what happened to an edit.
type EditResult struct {
	// Accepted is false when the edit lost to a newer one.
	Accepted bool `json:"accepted"`

	// Field is the field the edit addressed.
	Field string `json:"field"`

	// Current is the field's value now — the edit's own value when accepted,
	// and the value that beat it when refused. Returned either way so a client
	// never has to ask a second question to find out where it stands.
	Current FieldValue `json:"current"`
}

// InspectionSession is the live state of one inspection being edited.
type InspectionSession struct {
	InspectionID string
	TenantID     string

	mu     sync.RWMutex
	fields map[string]FieldValue
	now    func() time.Time
}

// SessionStore holds the live sessions.
type SessionStore struct {
	mu       sync.Mutex
	sessions map[string]*InspectionSession
	now      func() time.Time
}

// NewSessionStore creates an empty store.
func NewSessionStore(opts ...SessionOption) *SessionStore {
	s := &SessionStore{
		sessions: make(map[string]*InspectionSession),
		now:      time.Now,
	}
	for _, opt := range opts {
		opt(s)
	}
	return s
}

// SessionOption configures a SessionStore.
type SessionOption func(*SessionStore)

// WithSessionClock replaces the clock, for tests.
func WithSessionClock(now func() time.Time) SessionOption {
	return func(s *SessionStore) { s.now = now }
}

// Session returns the live session for an inspection, creating it on first
// use, seeded from the persisted values the caller supplies.
//
// The seed matters: a session created empty would let the first editor's
// `base_version: 0` overwrite findings that are already in the database,
// because an unset field accepts a zero base. Seeding makes the stored values
// version 1, which a first-time editor cannot silently replace.
func (s *SessionStore) Session(tenantID, inspectionID string, seed map[string]interface{}) (*InspectionSession, error) {
	if tenantID == "" {
		return nil, ErrNoTenant
	}
	if inspectionID == "" {
		return nil, ErrEmptyTopic
	}

	key := tenantID + "/" + inspectionID

	s.mu.Lock()
	defer s.mu.Unlock()

	if existing, ok := s.sessions[key]; ok {
		return existing, nil
	}

	fields := make(map[string]FieldValue, len(seed))
	at := s.now()
	for name, value := range seed {
		if !InspectionFields[name] {
			continue
		}
		fields[name] = FieldValue{Value: value, Version: 1, EditedAt: at}
	}

	session := &InspectionSession{
		InspectionID: inspectionID,
		TenantID:     tenantID,
		fields:       fields,
		now:          s.now,
	}
	s.sessions[key] = session
	return session, nil
}

// Close discards a session, once nobody is editing it.
func (s *SessionStore) Close(tenantID, inspectionID string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	delete(s.sessions, tenantID+"/"+inspectionID)
}

// Count is the number of live sessions.
func (s *SessionStore) Count() int {
	s.mu.Lock()
	defer s.mu.Unlock()
	return len(s.sessions)
}

// Apply attempts an edit.
//
// Returns the result and an error only for edits that are malformed rather
// than merely losing: a refused edit is an ordinary outcome of two people
// working at once, not a failure.
func (sess *InspectionSession) Apply(edit Edit) (EditResult, error) {
	if edit.TenantID != sess.TenantID {
		return EditResult{}, ErrTopicOtherTenant
	}
	if !InspectionFields[edit.Field] {
		return EditResult{}, ErrEditUnknownField
	}
	if edit.EditedBy == "" {
		return EditResult{}, ErrEmptyMember
	}

	sess.mu.Lock()
	defer sess.mu.Unlock()

	current, exists := sess.fields[edit.Field]

	// An edit based on a version that is not the current one lost the race.
	// The winner's value goes back, so the editor sees what replaced theirs.
	if exists && edit.BaseVersion != current.Version {
		return EditResult{Accepted: false, Field: edit.Field, Current: current}, nil
	}
	// Writing a field that has never been set requires claiming so. A client
	// that sends a stale non-zero base against an unset field is confused
	// about which inspection it is editing.
	if !exists && edit.BaseVersion != 0 {
		return EditResult{
			Accepted: false,
			Field:    edit.Field,
			Current:  FieldValue{Version: 0},
		}, nil
	}

	next := FieldValue{
		Value:    edit.Value,
		Version:  current.Version + 1,
		EditedBy: edit.EditedBy,
		EditedAt: sess.now(),
	}
	sess.fields[edit.Field] = next

	return EditResult{Accepted: true, Field: edit.Field, Current: next}, nil
}

// Snapshot is every field's current value and version.
//
// What a client is sent when it joins, so it starts from the same state as
// everyone already in the session rather than from whatever the database had
// when its page loaded.
func (sess *InspectionSession) Snapshot() map[string]FieldValue {
	sess.mu.RLock()
	defer sess.mu.RUnlock()

	out := make(map[string]FieldValue, len(sess.fields))
	for name, value := range sess.fields {
		out[name] = value
	}
	return out
}

// Topic is the tenant-qualified topic for this session.
func (sess *InspectionSession) Topic() string {
	return TenantTopic(sess.TenantID, InspectionTopic(sess.InspectionID))
}

// Collaborative session event names.
const (
	EventEditApplied = "edit_applied"
	EventEditRefused = "edit_refused"
	EventSnapshot    = "snapshot"
)
