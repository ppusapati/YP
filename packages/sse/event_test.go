package sse

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestNewEvent(t *testing.T) {
	event, err := NewEvent("reading", "sensor.field-1", map[string]float64{"temp": 25.0})
	require.NoError(t, err)

	assert.Equal(t, "reading", event.Type)
	assert.Equal(t, "sensor.field-1", event.Topic)
	assert.Contains(t, event.Data, "25")
	assert.False(t, event.Timestamp.IsZero())
}

func TestNewEvent_StringData(t *testing.T) {
	event, err := NewEvent("message", "alert.farm-1", "hello world")
	require.NoError(t, err)
	assert.Equal(t, "hello world", event.Data)
}

func TestNewEvent_ByteData(t *testing.T) {
	event, err := NewEvent("raw", "sensor.field-1", []byte(`{"key":"value"}`))
	require.NoError(t, err)
	assert.Equal(t, `{"key":"value"}`, event.Data)
}

func TestEvent_Format_Basic(t *testing.T) {
	event := &Event{
		Type: "message",
		Data: "hello",
	}

	output := string(event.Format())
	assert.Contains(t, output, "event: message\n")
	assert.Contains(t, output, "data: hello\n")
	assert.True(t, output[len(output)-2:] == "\n\n", "should end with double newline")
}

func TestEvent_Format_WithID(t *testing.T) {
	event := &Event{
		ID:   "evt-42",
		Type: "update",
		Data: "payload",
	}

	output := string(event.Format())
	assert.Contains(t, output, "id: evt-42\n")
	assert.Contains(t, output, "event: update\n")
	assert.Contains(t, output, "data: payload\n")
}

func TestEvent_Format_WithRetry(t *testing.T) {
	event := &Event{
		Type:  "keepalive",
		Data:  "ping",
		Retry: 3000,
	}

	output := string(event.Format())
	assert.Contains(t, output, "retry: 3000\n")
}

func TestEvent_Format_MultilineData(t *testing.T) {
	event := &Event{
		Type: "log",
		Data: "line one\nline two\nline three",
	}

	output := string(event.Format())
	assert.Contains(t, output, "data: line one\n")
	assert.Contains(t, output, "data: line two\n")
	assert.Contains(t, output, "data: line three\n")
}

func TestEvent_Format_EmptyTypeAndID(t *testing.T) {
	event := &Event{
		Data: "just data",
	}

	output := string(event.Format())
	assert.NotContains(t, output, "id:")
	assert.NotContains(t, output, "event:")
	assert.Contains(t, output, "data: just data\n")
}

func TestEvent_Format_AllFields(t *testing.T) {
	event := &Event{
		ID:    "id-1",
		Type:  "sensor_reading",
		Data:  `{"temp":22.5}`,
		Retry: 5000,
	}

	output := string(event.Format())
	assert.Contains(t, output, "id: id-1\n")
	assert.Contains(t, output, "event: sensor_reading\n")
	assert.Contains(t, output, "retry: 5000\n")
	assert.Contains(t, output, `data: {"temp":22.5}`)
}
