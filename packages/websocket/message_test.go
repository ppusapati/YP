package websocket

import (
	"encoding/json"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestNewMessage(t *testing.T) {
	msg, err := NewMessage(MessageTypeBroadcast, "sensor.field-1", map[string]string{"temp": "25.3"})
	require.NoError(t, err)

	assert.Equal(t, MessageTypeBroadcast, msg.Type)
	assert.Equal(t, "sensor.field-1", msg.Topic)
	assert.NotEmpty(t, msg.ID)
	assert.False(t, msg.Timestamp.IsZero())
	assert.NotNil(t, msg.Data)
}

func TestNewMessage_NilData(t *testing.T) {
	msg, err := NewMessage(MessageTypeSubscribe, "alert.farm-1", nil)
	require.NoError(t, err)
	assert.Nil(t, msg.Data)
}

func TestNewBroadcastMessage(t *testing.T) {
	msg, err := NewBroadcastMessage("sensor.field-2", "hello")
	require.NoError(t, err)
	assert.Equal(t, MessageTypeBroadcast, msg.Type)
	assert.Equal(t, "sensor.field-2", msg.Topic)
}

func TestNewDirectMessage(t *testing.T) {
	msg, err := NewDirectMessage("client-123", map[string]int{"count": 42})
	require.NoError(t, err)
	assert.Equal(t, MessageTypeDirectMessage, msg.Type)
	assert.Equal(t, "client-123", msg.TargetID)
}

func TestNewErrorMessage(t *testing.T) {
	msg := NewErrorMessage("something went wrong")
	assert.Equal(t, MessageTypeError, msg.Type)
	assert.Equal(t, "something went wrong", msg.Error)
	assert.NotEmpty(t, msg.ID)
}

func TestNewAckMessage(t *testing.T) {
	msg := NewAckMessage("sensor.field-1")
	assert.Equal(t, MessageTypeAck, msg.Type)
	assert.Equal(t, "sensor.field-1", msg.Topic)
}

func TestMessage_EncodeAndDecode(t *testing.T) {
	original, err := NewBroadcastMessage("alert.farm-5", map[string]interface{}{"severity": "high"})
	require.NoError(t, err)

	data, err := original.Encode()
	require.NoError(t, err)

	decoded, err := DecodeMessage(data)
	require.NoError(t, err)

	assert.Equal(t, original.ID, decoded.ID)
	assert.Equal(t, original.Type, decoded.Type)
	assert.Equal(t, original.Topic, decoded.Topic)
	assert.Equal(t, original.Error, decoded.Error)
}

func TestDecodeMessage_InvalidJSON(t *testing.T) {
	_, err := DecodeMessage([]byte("not json"))
	assert.Error(t, err)
}

func TestDecodeMessage_RoundTrip(t *testing.T) {
	payload := map[string]interface{}{
		"temperature": 23.5,
		"humidity":    68.0,
		"field_id":    "abc-123",
	}
	msg, err := NewBroadcastMessage("sensor.abc-123", payload)
	require.NoError(t, err)

	bytes, err := msg.Encode()
	require.NoError(t, err)

	decoded, err := DecodeMessage(bytes)
	require.NoError(t, err)

	// Verify the data payload round-trips correctly.
	var decodedPayload map[string]interface{}
	err = json.Unmarshal(decoded.Data, &decodedPayload)
	require.NoError(t, err)
	assert.Equal(t, 23.5, decodedPayload["temperature"])
	assert.Equal(t, "abc-123", decodedPayload["field_id"])
}

func TestValidateTopicPattern(t *testing.T) {
	tests := []struct {
		topic string
		valid bool
	}{
		{"sensor.field-1", true},
		{"alert.farm-2", true},
		{"irrigation.field-3", true},
		{"sensor.", false},   // empty identifier
		{"alert.", false},    // empty identifier
		{"unknown.x", false}, // unrecognized prefix
		{"", false},
		{"sensor", false}, // no dot separator
	}

	for _, tt := range tests {
		t.Run(tt.topic, func(t *testing.T) {
			assert.Equal(t, tt.valid, ValidateTopicPattern(tt.topic))
		})
	}
}
