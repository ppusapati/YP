package sse

import (
	"context"
	"testing"
	"time"

	"p9e.in/samavaya/packages/p9log"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func newTestBroker(t *testing.T) (*Broker, context.CancelFunc) {
	t.Helper()
	log := p9log.NewNopLogger()
	broker := NewBroker(log)
	ctx, cancel := context.WithCancel(context.Background())
	go broker.Run(ctx)
	time.Sleep(10 * time.Millisecond)
	return broker, cancel
}

func TestBroker_SubscribeAndReceive(t *testing.T) {
	broker, cancel := newTestBroker(t)
	defer cancel()

	events, cleanup := broker.Subscribe("sub-1", []string{"sensor.field-1"})
	defer cleanup()

	assert.Equal(t, 1, broker.SubscriberCount())
	assert.Equal(t, 1, broker.TopicSubscriberCount("sensor.field-1"))

	event, err := NewEvent("reading", "sensor.field-1", map[string]float64{"temp": 22.5})
	require.NoError(t, err)

	broker.Publish(event)

	select {
	case received := <-events:
		assert.Equal(t, "reading", received.Type)
		assert.Equal(t, "sensor.field-1", received.Topic)
		assert.Contains(t, received.Data, "22.5")
	case <-time.After(time.Second):
		t.Fatal("timed out waiting for event")
	}
}

func TestBroker_TopicFiltering(t *testing.T) {
	broker, cancel := newTestBroker(t)
	defer cancel()

	events1, cleanup1 := broker.Subscribe("sub-1", []string{"sensor.field-1"})
	defer cleanup1()

	events2, cleanup2 := broker.Subscribe("sub-2", []string{"alert.farm-1"})
	defer cleanup2()

	// Publish to sensor topic only.
	event, _ := NewEvent("reading", "sensor.field-1", "data")
	broker.Publish(event)

	// Subscriber 1 should receive the event.
	select {
	case <-events1:
		// OK
	case <-time.After(time.Second):
		t.Fatal("subscriber 1 should have received the event")
	}

	// Subscriber 2 should not receive it.
	select {
	case <-events2:
		t.Fatal("subscriber 2 should not have received the sensor event")
	case <-time.After(100 * time.Millisecond):
		// OK
	}
}

func TestBroker_BroadcastToAll(t *testing.T) {
	broker, cancel := newTestBroker(t)
	defer cancel()

	events1, cleanup1 := broker.Subscribe("sub-1", []string{"sensor.field-1"})
	defer cleanup1()

	events2, cleanup2 := broker.Subscribe("sub-2", []string{"alert.farm-1"})
	defer cleanup2()

	// Publish with empty topic -> broadcast to all.
	event, _ := NewEvent("system", "", "maintenance window")
	broker.Publish(event)

	received := 0
	timeout := time.After(time.Second)
	for received < 2 {
		select {
		case <-events1:
			received++
		case <-events2:
			received++
		case <-timeout:
			t.Fatalf("expected 2 receivers, got %d", received)
		}
	}
	assert.Equal(t, 2, received)
}

func TestBroker_Cleanup(t *testing.T) {
	broker, cancel := newTestBroker(t)
	defer cancel()

	_, cleanup := broker.Subscribe("sub-1", []string{"sensor.field-1"})
	assert.Equal(t, 1, broker.SubscriberCount())

	cleanup()
	time.Sleep(20 * time.Millisecond)
	assert.Equal(t, 0, broker.SubscriberCount())
	assert.Equal(t, 0, broker.TopicSubscriberCount("sensor.field-1"))
}

func TestBroker_DoubleCleanup(t *testing.T) {
	broker, cancel := newTestBroker(t)
	defer cancel()

	_, cleanup := broker.Subscribe("sub-1", []string{"sensor.field-1"})
	cleanup()
	// Double cleanup should not panic.
	cleanup()
}

func TestBroker_AddAndRemoveTopic(t *testing.T) {
	broker, cancel := newTestBroker(t)
	defer cancel()

	events, cleanup := broker.Subscribe("sub-1", []string{"sensor.field-1"})
	defer cleanup()

	// Add a new topic.
	broker.AddTopic("sub-1", "alert.farm-1")
	assert.Equal(t, 1, broker.TopicSubscriberCount("alert.farm-1"))

	// Publish to the new topic.
	event, _ := NewEvent("alert", "alert.farm-1", "fire")
	broker.Publish(event)

	select {
	case <-events:
		// OK
	case <-time.After(time.Second):
		t.Fatal("should have received event on dynamically added topic")
	}

	// Remove the topic.
	broker.RemoveTopic("sub-1", "alert.farm-1")
	assert.Equal(t, 0, broker.TopicSubscriberCount("alert.farm-1"))
}

func TestBroker_PublishData(t *testing.T) {
	broker, cancel := newTestBroker(t)
	defer cancel()

	events, cleanup := broker.Subscribe("sub-1", []string{"irrigation.field-1"})
	defer cleanup()

	err := broker.PublishData("irrigation_update", "irrigation.field-1", map[string]bool{"active": true})
	require.NoError(t, err)

	select {
	case received := <-events:
		assert.Equal(t, "irrigation_update", received.Type)
		assert.Contains(t, received.Data, "true")
	case <-time.After(time.Second):
		t.Fatal("timed out waiting for event")
	}
}

func TestBroker_ShutdownClosesChannels(t *testing.T) {
	broker, cancel := newTestBroker(t)

	events, _ := broker.Subscribe("sub-1", []string{"sensor.field-1"})

	cancel() // shutdown
	time.Sleep(50 * time.Millisecond)

	// Channel should be closed after shutdown.
	_, ok := <-events
	assert.False(t, ok, "events channel should be closed after shutdown")
}
