package websocket

import (
	"context"
	"testing"
	"time"

	"p9e.in/samavaya/packages/p9log"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func newTestHub(t *testing.T) (*Hub, context.CancelFunc) {
	t.Helper()
	log := p9log.NewNopLogger()
	hub := NewHub(log)
	ctx, cancel := context.WithCancel(context.Background())
	go hub.Run(ctx)
	// Give the hub goroutine a moment to start.
	time.Sleep(10 * time.Millisecond)
	return hub, cancel
}

func TestHub_RegisterAndUnregister(t *testing.T) {
	hub, cancel := newTestHub(t)
	defer cancel()

	// Simulate a client (without a real websocket connection).
	client := &Client{
		ID:       "test-1",
		UserID:   "user-1",
		TenantID: "tenant-1",
		hub:      hub,
		send:     make(chan []byte, 16),
		topics:   make(map[string]struct{}),
		done:     make(chan struct{}),
	}

	hub.register <- client
	time.Sleep(20 * time.Millisecond)
	assert.Equal(t, 1, hub.ClientCount())

	hub.unregister <- client
	time.Sleep(20 * time.Millisecond)
	assert.Equal(t, 0, hub.ClientCount())
}

func TestHub_TopicSubscription(t *testing.T) {
	hub, cancel := newTestHub(t)
	defer cancel()

	client := &Client{
		ID:       "test-2",
		UserID:   "user-2",
		TenantID: "tenant-2",
		hub:      hub,
		send:     make(chan []byte, 16),
		topics:   make(map[string]struct{}),
		done:     make(chan struct{}),
	}

	hub.register <- client
	time.Sleep(20 * time.Millisecond)

	hub.subscribe <- &Subscription{Client: client, Topic: "sensor.field-1"}
	time.Sleep(20 * time.Millisecond)

	assert.Equal(t, 1, hub.TopicSubscriberCount("sensor.field-1"))
	assert.Equal(t, 0, hub.TopicSubscriberCount("sensor.field-2"))

	topics := hub.TopicList()
	assert.Contains(t, topics, "sensor.field-1")
}

func TestHub_Broadcast(t *testing.T) {
	hub, cancel := newTestHub(t)
	defer cancel()

	client := &Client{
		ID:       "test-3",
		UserID:   "user-3",
		TenantID: "tenant-3",
		hub:      hub,
		send:     make(chan []byte, 16),
		topics:   make(map[string]struct{}),
		done:     make(chan struct{}),
	}

	hub.register <- client
	time.Sleep(20 * time.Millisecond)

	hub.subscribe <- &Subscription{Client: client, Topic: "alert.farm-1"}
	time.Sleep(20 * time.Millisecond)

	err := hub.Broadcast("alert.farm-1", map[string]string{"severity": "high"})
	require.NoError(t, err)

	select {
	case data := <-client.send:
		msg, err := DecodeMessage(data)
		require.NoError(t, err)
		assert.Equal(t, MessageTypeBroadcast, msg.Type)
		assert.Equal(t, "alert.farm-1", msg.Topic)
	case <-time.After(time.Second):
		t.Fatal("timed out waiting for broadcast message")
	}
}

func TestHub_BroadcastNoSubscribers(t *testing.T) {
	hub, cancel := newTestHub(t)
	defer cancel()

	// Broadcasting to a topic with no subscribers should not panic.
	err := hub.Broadcast("empty.topic", "no one here")
	assert.NoError(t, err)
}

func TestHub_DirectMessage(t *testing.T) {
	hub, cancel := newTestHub(t)
	defer cancel()

	client := &Client{
		ID:       "dm-target",
		UserID:   "user-4",
		TenantID: "tenant-4",
		hub:      hub,
		send:     make(chan []byte, 16),
		topics:   make(map[string]struct{}),
		done:     make(chan struct{}),
	}

	hub.register <- client
	time.Sleep(20 * time.Millisecond)

	err := hub.SendDirect("dm-target", map[string]string{"msg": "hello"})
	require.NoError(t, err)

	select {
	case data := <-client.send:
		msg, err := DecodeMessage(data)
		require.NoError(t, err)
		assert.Equal(t, MessageTypeDirectMessage, msg.Type)
		assert.Equal(t, "dm-target", msg.TargetID)
	case <-time.After(time.Second):
		t.Fatal("timed out waiting for direct message")
	}
}

func TestHub_UnsubscribeRemovesTopic(t *testing.T) {
	hub, cancel := newTestHub(t)
	defer cancel()

	client := &Client{
		ID:       "unsub-test",
		UserID:   "user-5",
		TenantID: "tenant-5",
		hub:      hub,
		send:     make(chan []byte, 16),
		topics:   make(map[string]struct{}),
		done:     make(chan struct{}),
	}

	hub.register <- client
	time.Sleep(20 * time.Millisecond)

	hub.subscribe <- &Subscription{Client: client, Topic: "irrigation.field-1"}
	time.Sleep(20 * time.Millisecond)
	assert.Equal(t, 1, hub.TopicSubscriberCount("irrigation.field-1"))

	hub.unsubscribe <- &Subscription{Client: client, Topic: "irrigation.field-1"}
	time.Sleep(20 * time.Millisecond)
	assert.Equal(t, 0, hub.TopicSubscriberCount("irrigation.field-1"))
}

func TestHub_ShutdownClosesClients(t *testing.T) {
	hub, cancel := newTestHub(t)

	client := &Client{
		ID:       "shutdown-test",
		UserID:   "user-6",
		TenantID: "tenant-6",
		hub:      hub,
		send:     make(chan []byte, 16),
		topics:   make(map[string]struct{}),
		done:     make(chan struct{}),
	}

	hub.register <- client
	time.Sleep(20 * time.Millisecond)
	assert.Equal(t, 1, hub.ClientCount())

	cancel() // trigger shutdown
	time.Sleep(50 * time.Millisecond)
	assert.Equal(t, 0, hub.ClientCount())
}
