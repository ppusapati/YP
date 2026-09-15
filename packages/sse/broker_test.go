package sse

import (
	"context"
	"testing"
	"time"

	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/realtime"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// tenant is the tenant every subscriber in this file belongs to unless a test
// deliberately uses another.
const tenant = "tenant-a"

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

	events, cleanup := broker.Subscribe("sub-1", tenant, []string{"sensor.field-1"})
	defer cleanup()

	assert.Equal(t, 1, broker.SubscriberCount())
	assert.Equal(t, 1, broker.TopicSubscriberCount(realtime.TenantTopic(tenant, "sensor.field-1")))

	event, err := NewEvent("reading", realtime.TenantTopic(tenant, "sensor.field-1"), map[string]float64{"temp": 22.5})
	require.NoError(t, err)

	broker.Publish(event)

	select {
	case received := <-events:
		assert.Equal(t, "reading", received.Type)
		assert.Equal(t, realtime.TenantTopic(tenant, "sensor.field-1"), received.Topic)
		assert.Contains(t, received.Data, "22.5")
	case <-time.After(time.Second):
		t.Fatal("timed out waiting for event")
	}
}

func TestBroker_TopicFiltering(t *testing.T) {
	broker, cancel := newTestBroker(t)
	defer cancel()

	events1, cleanup1 := broker.Subscribe("sub-1", tenant, []string{"sensor.field-1"})
	defer cleanup1()

	events2, cleanup2 := broker.Subscribe("sub-2", tenant, []string{"alert.farm-1"})
	defer cleanup2()

	// Publish to sensor topic only.
	event, _ := NewEvent("reading", realtime.TenantTopic(tenant, "sensor.field-1"), "data")
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

func TestAnEventWithNoTopicReachesNobody(t *testing.T) {
	// This test used to assert the opposite: an event published with an empty
	// topic went to every subscriber on the process. On a platform where every
	// equivalent read is stopped by row-level security, forgetting the topic
	// was a cross-tenant broadcast.
	broker, cancel := newTestBroker(t)
	defer cancel()

	events1, cleanup1 := broker.Subscribe("sub-1", tenant, []string{"sensor.field-1"})
	defer cleanup1()

	events2, cleanup2 := broker.Subscribe("sub-2", "tenant-b", []string{"alert.farm-1"})
	defer cleanup2()

	event, _ := NewEvent("system", "", "maintenance window")
	broker.Publish(event)

	select {
	case e := <-events1:
		t.Fatalf("an untopiced event was delivered: %+v", e)
	case e := <-events2:
		t.Fatalf("an untopiced event was delivered to another tenant: %+v", e)
	case <-time.After(150 * time.Millisecond):
	}
}

func TestOneTenantDoesNotReceiveAnothersEvents(t *testing.T) {
	// The leak this whole change closes. Both subscribers ask for the same
	// topic name; only the one whose tenant owns it receives anything.
	broker, cancel := newTestBroker(t)
	defer cancel()

	mine, cleanupMine := broker.Subscribe("sub-a", tenant, []string{"sensor.field-1"})
	defer cleanupMine()

	theirs, cleanupTheirs := broker.Subscribe("sub-b", "tenant-b", []string{"sensor.field-1"})
	defer cleanupTheirs()

	event, _ := NewEvent("reading", realtime.TenantTopic(tenant, "sensor.field-1"), "data")
	broker.Publish(event)

	select {
	case <-mine:
	case <-time.After(time.Second):
		t.Fatal("the owning tenant did not receive its own event")
	}

	select {
	case e := <-theirs:
		t.Fatalf("another tenant received the event: %+v", e)
	case <-time.After(150 * time.Millisecond):
	}
}

func TestAConnectionWithNoTenantIsRefused(t *testing.T) {
	// Not subscribed to everything, which is what an unscoped connection would
	// otherwise have amounted to.
	broker, cancel := newTestBroker(t)
	defer cancel()

	events, cleanup := broker.Subscribe("sub-none", "", []string{"sensor.field-1"})
	defer cleanup()

	if _, open := <-events; open {
		t.Error("a connection with no tenant received an event")
	}
	if got := broker.SubscriberCount(); got != 0 {
		t.Errorf("subscriber count %d, want 0", got)
	}
}

func TestATopicNamingAnotherTenantIsDropped(t *testing.T) {
	broker, cancel := newTestBroker(t)
	defer cancel()

	_, cleanup := broker.Subscribe("sub-a", tenant,
		[]string{realtime.TenantTopic("tenant-b", "sensor.field-1")})
	defer cleanup()

	if got := broker.TopicSubscriberCount(realtime.TenantTopic("tenant-b", "sensor.field-1")); got != 0 {
		t.Errorf("subscriber count %d on another tenant's topic, want 0", got)
	}
}

func TestBroker_Cleanup(t *testing.T) {
	broker, cancel := newTestBroker(t)
	defer cancel()

	_, cleanup := broker.Subscribe("sub-1", tenant, []string{"sensor.field-1"})
	assert.Equal(t, 1, broker.SubscriberCount())

	cleanup()
	time.Sleep(20 * time.Millisecond)
	assert.Equal(t, 0, broker.SubscriberCount())
	assert.Equal(t, 0, broker.TopicSubscriberCount(realtime.TenantTopic(tenant, "sensor.field-1")))
}

func TestBroker_DoubleCleanup(t *testing.T) {
	broker, cancel := newTestBroker(t)
	defer cancel()

	_, cleanup := broker.Subscribe("sub-1", tenant, []string{"sensor.field-1"})
	cleanup()
	// Double cleanup should not panic.
	cleanup()
}

func TestBroker_AddAndRemoveTopic(t *testing.T) {
	broker, cancel := newTestBroker(t)
	defer cancel()

	events, cleanup := broker.Subscribe("sub-1", tenant, []string{"sensor.field-1"})
	defer cleanup()

	// Add a new topic.
	broker.AddTopic("sub-1", "alert.farm-1")
	assert.Equal(t, 1, broker.TopicSubscriberCount(realtime.TenantTopic(tenant, "alert.farm-1")))

	// Publish to the new topic.
	event, _ := NewEvent("alert", realtime.TenantTopic(tenant, "alert.farm-1"), "fire")
	broker.Publish(event)

	select {
	case <-events:
		// OK
	case <-time.After(time.Second):
		t.Fatal("should have received event on dynamically added topic")
	}

	// Remove the topic.
	broker.RemoveTopic("sub-1", "alert.farm-1")
	assert.Equal(t, 0, broker.TopicSubscriberCount(realtime.TenantTopic(tenant, "alert.farm-1")))
}

func TestBroker_PublishData(t *testing.T) {
	broker, cancel := newTestBroker(t)
	defer cancel()

	events, cleanup := broker.Subscribe("sub-1", tenant, []string{"irrigation.field-1"})
	defer cleanup()

	err := broker.PublishData("irrigation_update", realtime.TenantTopic(tenant, "irrigation.field-1"), map[string]bool{"active": true})
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

	events, _ := broker.Subscribe("sub-1", tenant, []string{"sensor.field-1"})

	cancel() // shutdown
	time.Sleep(50 * time.Millisecond)

	// Channel should be closed after shutdown.
	_, ok := <-events
	assert.False(t, ok, "events channel should be closed after shutdown")
}
