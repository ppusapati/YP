package websocket

import (
	"testing"
	"time"

	"p9e.in/samavaya/packages/testutil"
)

// The scoping rules themselves are tested in packages/realtime, which owns
// them. These cover the two places the WebSocket transport has to apply them:
// the hub's delivery path, and the Kafka bridge that publishes into it.

// ── The hub ─────────────────────────────────────────────────────────────────

func newClient(id, tenantID string, hub *Hub) *Client {
	return &Client{
		ID:       id,
		UserID:   "user-" + id,
		TenantID: tenantID,
		hub:      hub,
		send:     make(chan []byte, 16),
		topics:   make(map[string]struct{}),
		done:     make(chan struct{}),
	}
}

func TestTheHubDoesNotDeliverAcrossTenantsEvenIfSubscribed(t *testing.T) {
	// Defence in depth. The subscribe path is the control; this is the check
	// that holds if a client ever ends up in h.topics by another route.
	hub, cancel := newTestHub(t)
	defer cancel()

	topic := TenantTopic("tenant-a", "sensor.field-1")
	mine := newClient("a1", "tenant-a", hub)
	theirs := newClient("b1", "tenant-b", hub)

	hub.register <- mine
	hub.register <- theirs
	time.Sleep(20 * time.Millisecond)

	// Both subscribed to tenant-a's topic, which only the first should be able
	// to reach through the client path.
	hub.subscribe <- &Subscription{Client: mine, Topic: topic}
	hub.subscribe <- &Subscription{Client: theirs, Topic: topic}
	time.Sleep(20 * time.Millisecond)

	if err := hub.Broadcast(topic, map[string]string{"moisture": "18"}); err != nil {
		t.Fatalf("Broadcast: %v", err)
	}

	select {
	case <-mine.send:
	case <-time.After(time.Second):
		t.Fatal("the owning tenant did not receive its own broadcast")
	}

	select {
	case data := <-theirs.send:
		t.Fatalf("another tenant received the broadcast: %s", data)
	case <-time.After(100 * time.Millisecond):
	}
}

func TestAnUnqualifiedBroadcastReachesNobody(t *testing.T) {
	// A publisher that forgets TenantTopic gets silence rather than a
	// cross-tenant delivery. Loud in the log, empty on the wire.
	hub, cancel := newTestHub(t)
	defer cancel()

	client := newClient("a1", "tenant-a", hub)
	hub.register <- client
	time.Sleep(20 * time.Millisecond)
	hub.subscribe <- &Subscription{Client: client, Topic: "sensor.field-1"}
	time.Sleep(20 * time.Millisecond)

	if err := hub.Broadcast("sensor.field-1", map[string]string{"moisture": "18"}); err != nil {
		t.Fatalf("Broadcast: %v", err)
	}

	select {
	case data := <-client.send:
		t.Fatalf("an unqualified broadcast was delivered: %s", data)
	case <-time.After(100 * time.Millisecond):
	}
}

// ── The Kafka bridge ────────────────────────────────────────────────────────

func TestTheBridgeScopesEachMessageToItsOwnTenant(t *testing.T) {
	hub, cancel := newTestHub(t)
	defer cancel()

	bridge := NewKafkaBridge(BridgeConfig{Hub: hub, Log: testutil.NopLogger{}})
	mapping := TopicMapping{
		KafkaTopic:    "yp.sensor.readings",
		WSTopicPrefix: "sensor.",
		KeyField:      "field_id",
	}

	mine := newClient("a1", "tenant-a", hub)
	theirs := newClient("b1", "tenant-b", hub)
	hub.register <- mine
	hub.register <- theirs
	time.Sleep(20 * time.Millisecond)

	topic := TenantTopic("tenant-a", "sensor.field-1")
	hub.subscribe <- &Subscription{Client: mine, Topic: topic}
	hub.subscribe <- &Subscription{Client: theirs, Topic: topic}
	time.Sleep(20 * time.Millisecond)

	err := bridge.handleMessage(mapping,
		[]byte(`{"tenant_id":"tenant-a","field_id":"field-1","moisture":18}`))
	if err != nil {
		t.Fatalf("handleMessage: %v", err)
	}

	select {
	case <-mine.send:
	case <-time.After(time.Second):
		t.Fatal("the owning tenant did not receive the bridged reading")
	}
	select {
	case data := <-theirs.send:
		t.Fatalf("another tenant received the bridged reading: %s", data)
	case <-time.After(100 * time.Millisecond):
	}
}

func TestTheBridgeDropsAMessageWithNoTenant(t *testing.T) {
	// It used to broadcast an unparseable or unkeyed message to the bare prefix
	// topic, which every subscriber in every tenant was on.
	hub, cancel := newTestHub(t)
	defer cancel()

	bridge := NewKafkaBridge(BridgeConfig{Hub: hub, Log: testutil.NopLogger{}})
	mapping := TopicMapping{WSTopicPrefix: "sensor.", KeyField: "field_id"}

	client := newClient("a1", "tenant-a", hub)
	hub.register <- client
	time.Sleep(20 * time.Millisecond)
	hub.subscribe <- &Subscription{Client: client, Topic: TenantTopic("tenant-a", "sensor.")}
	time.Sleep(20 * time.Millisecond)

	for _, payload := range [][]byte{
		[]byte(`{"field_id":"field-1","moisture":18}`), // no tenant_id
		[]byte(`not json at all`),
		[]byte(`{"tenant_id":"","field_id":"field-1"}`),
	} {
		if err := bridge.handleMessage(mapping, payload); err != nil {
			t.Errorf("handleMessage(%s) returned %v; a bad message must not stop the consumer", payload, err)
		}
	}

	select {
	case data := <-client.send:
		t.Fatalf("a message with no tenant was delivered: %s", data)
	case <-time.After(100 * time.Millisecond):
	}
}
