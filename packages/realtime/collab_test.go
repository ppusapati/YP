package realtime

import (
	"sync"
	"testing"
	"time"
)

func newSession(t *testing.T, seed map[string]interface{}) *InspectionSession {
	t.Helper()
	store := NewSessionStore()
	sess, err := store.Session("tenant-1", "insp-1", seed)
	if err != nil {
		t.Fatalf("session: %v", err)
	}
	return sess
}

func edit(field string, value interface{}, base int64, by string) Edit {
	return Edit{
		InspectionID: "insp-1",
		TenantID:     "tenant-1",
		Field:        field,
		Value:        value,
		BaseVersion:  base,
		EditedBy:     by,
	}
}

func TestSession_FirstWriteToAnUnsetField(t *testing.T) {
	sess := newSession(t, nil)

	res, err := sess.Apply(edit("findings", "Leaf curl on the north headland.", 0, "user-a"))
	if err != nil {
		t.Fatalf("apply: %v", err)
	}
	if !res.Accepted {
		t.Fatal("first write to an unset field was refused")
	}
	if res.Current.Version != 1 {
		t.Errorf("expected version 1, got %d", res.Current.Version)
	}
	if res.Current.EditedBy != "user-a" {
		t.Errorf("edit was not attributed: %q", res.Current.EditedBy)
	}
}

func TestSession_SequentialEditsToOneField(t *testing.T) {
	sess := newSession(t, nil)

	first, _ := sess.Apply(edit("findings", "one", 0, "user-a"))
	second, err := sess.Apply(edit("findings", "two", first.Current.Version, "user-a"))
	if err != nil {
		t.Fatalf("apply: %v", err)
	}
	if !second.Accepted {
		t.Fatal("an edit based on the current version was refused")
	}
	if second.Current.Version != 2 {
		t.Errorf("expected version 2, got %d", second.Current.Version)
	}
}

func TestSession_TwoPeopleEditingDifferentFieldsNeverConflict(t *testing.T) {
	// The common case: one fills in the health score while the other writes
	// the findings. If this collided, the feature would be useless.
	sess := newSession(t, nil)

	a, err := sess.Apply(edit("findings", "Leaf curl.", 0, "user-a"))
	if err != nil || !a.Accepted {
		t.Fatalf("findings edit: %v accepted=%v", err, a.Accepted)
	}
	b, err := sess.Apply(edit("health_score", 62.5, 0, "user-b"))
	if err != nil || !b.Accepted {
		t.Fatalf("health_score edit: %v accepted=%v", err, b.Accepted)
	}
}

func TestSession_TheLoserIsToldWhatBeatThem(t *testing.T) {
	// The whole point. Silent last-write-wins means one agronomist's findings
	// vanish while they are looking at them, and they do not notice until the
	// report is filed.
	sess := newSession(t, nil)

	first, _ := sess.Apply(edit("findings", "Written by A.", 0, "user-a"))

	// B was still looking at the empty field when they started typing.
	second, err := sess.Apply(edit("findings", "Written by B.", 0, "user-b"))
	if err != nil {
		t.Fatalf("apply: %v", err)
	}

	if second.Accepted {
		t.Fatal("a stale edit overwrote a newer one")
	}
	if second.Current.Value != "Written by A." {
		t.Errorf("the loser was not shown the winning value, got %v", second.Current.Value)
	}
	if second.Current.EditedBy != "user-a" {
		t.Errorf("the loser was not told who beat them, got %q", second.Current.EditedBy)
	}
	if second.Current.Version != first.Current.Version {
		t.Error("a refused edit moved the version")
	}
}

func TestSession_ARefusedEditLeavesTheValueAlone(t *testing.T) {
	sess := newSession(t, nil)

	_, _ = sess.Apply(edit("findings", "Written by A.", 0, "user-a"))
	_, _ = sess.Apply(edit("findings", "Written by B.", 0, "user-b"))

	snapshot := sess.Snapshot()
	if snapshot["findings"].Value != "Written by A." {
		t.Errorf("the refused edit was applied anyway: %v", snapshot["findings"].Value)
	}
}

func TestSession_TheLoserCanRetryOnTheNewVersion(t *testing.T) {
	// Being refused has to be recoverable, or the feature is just a slower way
	// to lose work.
	sess := newSession(t, nil)

	_, _ = sess.Apply(edit("findings", "Written by A.", 0, "user-a"))
	refused, _ := sess.Apply(edit("findings", "Written by B.", 0, "user-b"))

	retry, err := sess.Apply(
		edit("findings", "A's text, plus B's.", refused.Current.Version, "user-b"),
	)
	if err != nil {
		t.Fatalf("retry: %v", err)
	}
	if !retry.Accepted {
		t.Fatal("a retry on the version we were just handed was refused")
	}
}

func TestSession_SeededFieldsCannotBeSilentlyOverwritten(t *testing.T) {
	// A session created empty would let the first editor's base_version 0
	// replace findings already in the database — the exact silent overwrite
	// the versioning exists to stop.
	sess := newSession(t, map[string]interface{}{
		"findings": "Recorded last week.",
	})

	res, err := sess.Apply(edit("findings", "Overwriting blind.", 0, "user-a"))
	if err != nil {
		t.Fatalf("apply: %v", err)
	}
	if res.Accepted {
		t.Fatal("a zero-base edit overwrote a persisted value")
	}
	if res.Current.Value != "Recorded last week." {
		t.Errorf("the persisted value was lost: %v", res.Current.Value)
	}
}

func TestSession_StaleNonZeroBaseAgainstAnUnsetField(t *testing.T) {
	// A client sending a stale non-zero base against a field that has never
	// been set is confused about which inspection it is editing.
	sess := newSession(t, nil)

	res, err := sess.Apply(edit("notes", "text", 7, "user-a"))
	if err != nil {
		t.Fatalf("apply: %v", err)
	}
	if res.Accepted {
		t.Fatal("an edit claiming version 7 of an unset field was accepted")
	}
}

func TestSession_RefusesAnUnknownField(t *testing.T) {
	// A typo in a client must not create a phantom field that is versioned,
	// broadcast and never persisted — which looks exactly like a working edit.
	sess := newSession(t, nil)

	if _, err := sess.Apply(edit("findinsg", "typo", 0, "user-a")); err != ErrEditUnknownField {
		t.Fatalf("expected ErrEditUnknownField, got %v", err)
	}
}

func TestSession_RefusesAnotherTenantsEdit(t *testing.T) {
	sess := newSession(t, nil)

	e := edit("findings", "from elsewhere", 0, "intruder")
	e.TenantID = "tenant-2"

	if _, err := sess.Apply(e); err != ErrTopicOtherTenant {
		t.Fatalf("expected ErrTopicOtherTenant, got %v", err)
	}
}

func TestSession_RefusesAnUnattributedEdit(t *testing.T) {
	// Every edit is attributed, so the other editor sees "R. Patil changed
	// this" rather than watching text change by itself.
	sess := newSession(t, nil)

	if _, err := sess.Apply(edit("findings", "anonymous", 0, "")); err != ErrEmptyMember {
		t.Fatalf("expected ErrEmptyMember, got %v", err)
	}
}

func TestSession_SnapshotIsWhatAJoinerStartsFrom(t *testing.T) {
	sess := newSession(t, map[string]interface{}{"notes": "seeded"})
	_, _ = sess.Apply(edit("findings", "live edit", 0, "user-a"))

	snapshot := sess.Snapshot()

	if snapshot["notes"].Version != 1 {
		t.Errorf("seeded field is at version %d", snapshot["notes"].Version)
	}
	if snapshot["findings"].Value != "live edit" {
		t.Errorf("the live edit is missing from the snapshot: %v", snapshot["findings"])
	}
}

func TestSession_SnapshotIsACopy(t *testing.T) {
	// A caller mutating the returned map must not reach into the session.
	sess := newSession(t, map[string]interface{}{"notes": "seeded"})

	snapshot := sess.Snapshot()
	snapshot["notes"] = FieldValue{Value: "tampered", Version: 99}

	if sess.Snapshot()["notes"].Value != "seeded" {
		t.Error("the snapshot aliases the session's state")
	}
}

func TestSessionStore_SeedIgnoresUnknownFields(t *testing.T) {
	store := NewSessionStore()
	sess, err := store.Session("tenant-1", "insp-1", map[string]interface{}{
		"findings":   "real",
		"deleted_at": "not an editable field",
	})
	if err != nil {
		t.Fatalf("session: %v", err)
	}

	if _, ok := sess.Snapshot()["deleted_at"]; ok {
		t.Error("an unknown field was seeded into the session")
	}
}

func TestSessionStore_ReturnsTheSameSessionForOneInspection(t *testing.T) {
	// Two editors have to land in the same session or they are collaborating
	// with themselves.
	store := NewSessionStore()

	a, _ := store.Session("tenant-1", "insp-1", nil)
	b, _ := store.Session("tenant-1", "insp-1", map[string]interface{}{"notes": "ignored"})

	if a != b {
		t.Fatal("two editors got separate sessions for one inspection")
	}
}

func TestSessionStore_SeparatesTenants(t *testing.T) {
	// Two tenants can hold inspections with the same id; they must not share
	// a session.
	store := NewSessionStore()

	a, _ := store.Session("tenant-1", "insp-1", nil)
	b, _ := store.Session("tenant-2", "insp-1", nil)

	if a == b {
		t.Fatal("two tenants share one session")
	}
	if store.Count() != 2 {
		t.Errorf("expected 2 sessions, got %d", store.Count())
	}
}

func TestSessionStore_RefusesAMissingTenant(t *testing.T) {
	store := NewSessionStore()

	if _, err := store.Session("", "insp-1", nil); err != ErrNoTenant {
		t.Fatalf("expected ErrNoTenant, got %v", err)
	}
}

func TestSessionStore_Close(t *testing.T) {
	store := NewSessionStore()
	_, _ = store.Session("tenant-1", "insp-1", nil)

	store.Close("tenant-1", "insp-1")

	if store.Count() != 0 {
		t.Error("the session outlived its close")
	}
}

func TestSession_Topic(t *testing.T) {
	sess := newSession(t, nil)

	want := TenantTopic("tenant-1", InspectionTopic("insp-1"))
	if got := sess.Topic(); got != want {
		t.Errorf("topic = %q, want %q", got, want)
	}
}

func TestSession_ConcurrentEditsProduceOneWinnerPerVersion(t *testing.T) {
	// Twenty clients all editing from version 0. Exactly one may win; the rest
	// have to be told. Run with -race.
	sess := newSession(t, nil)

	var wg sync.WaitGroup
	accepted := make(chan bool, 20)

	for i := 0; i < 20; i++ {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			res, err := sess.Apply(edit("findings", i, 0, "user"))
			if err != nil {
				t.Errorf("apply: %v", err)
				return
			}
			accepted <- res.Accepted
		}(i)
	}
	wg.Wait()
	close(accepted)

	wins := 0
	for ok := range accepted {
		if ok {
			wins++
		}
	}
	if wins != 1 {
		t.Errorf("expected exactly 1 winner from version 0, got %d", wins)
	}
	if v := sess.Snapshot()["findings"].Version; v != 1 {
		t.Errorf("version advanced past the single accepted edit: %d", v)
	}
}

func TestSessionStore_ClockIsUsedForSeedTimestamps(t *testing.T) {
	at := time.Date(2026, 3, 14, 9, 0, 0, 0, time.UTC)
	store := NewSessionStore(WithSessionClock(func() time.Time { return at }))

	sess, _ := store.Session("tenant-1", "insp-1", map[string]interface{}{"notes": "seeded"})

	if got := sess.Snapshot()["notes"].EditedAt; !got.Equal(at) {
		t.Errorf("seed timestamp = %v, want %v", got, at)
	}
}
