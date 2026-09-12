package websocket

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestClient_SubscribeAndUnsubscribe(t *testing.T) {
	c := &Client{
		ID:     "client-1",
		topics: make(map[string]struct{}),
	}

	c.Subscribe("sensor.field-1")
	c.Subscribe("alert.farm-2")

	assert.True(t, c.IsSubscribed("sensor.field-1"))
	assert.True(t, c.IsSubscribed("alert.farm-2"))
	assert.False(t, c.IsSubscribed("irrigation.field-3"))

	topics := c.Topics()
	assert.Len(t, topics, 2)

	c.Unsubscribe("sensor.field-1")
	assert.False(t, c.IsSubscribed("sensor.field-1"))
	assert.True(t, c.IsSubscribed("alert.farm-2"))
}

func TestClient_Send_Closed(t *testing.T) {
	c := &Client{
		ID:     "client-2",
		send:   make(chan []byte, 1),
		topics: make(map[string]struct{}),
		done:   make(chan struct{}),
	}

	// Should work when open.
	err := c.Send([]byte("hello"))
	assert.NoError(t, err)

	// Mark as closed.
	c.closed.Store(true)
	err = c.Send([]byte("should fail"))
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "closed")
}

func TestClient_Send_BufferFull(t *testing.T) {
	c := &Client{
		ID:     "client-3",
		send:   make(chan []byte, 1), // buffer of 1
		topics: make(map[string]struct{}),
		done:   make(chan struct{}),
	}

	// Fill the buffer.
	err := c.Send([]byte("first"))
	assert.NoError(t, err)

	// This should fail because buffer is full.
	err = c.Send([]byte("second"))
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "buffer full")
}

func TestClient_Close(t *testing.T) {
	c := &Client{
		ID:     "client-4",
		topics: make(map[string]struct{}),
		done:   make(chan struct{}),
	}

	c.Close()
	// Verify the done channel is closed.
	select {
	case <-c.done:
		// expected
	default:
		t.Fatal("done channel should be closed after Close()")
	}

	// Double close should not panic.
	c.Close()
}

func TestClient_Topics_Snapshot(t *testing.T) {
	c := &Client{
		ID:     "client-5",
		topics: make(map[string]struct{}),
	}

	c.Subscribe("sensor.a")
	c.Subscribe("sensor.b")
	c.Subscribe("alert.c")

	topics := c.Topics()
	assert.Len(t, topics, 3)

	// Modifying the returned slice should not affect internal state.
	c.Unsubscribe("sensor.a")
	assert.Len(t, c.Topics(), 2)
	assert.Len(t, topics, 3) // original snapshot unchanged
}
