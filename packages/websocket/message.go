package websocket

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"
)

// MessageType identifies the kind of WebSocket message being exchanged.
type MessageType string

const (
	// MessageTypeSubscribe is sent by the client to subscribe to a topic.
	MessageTypeSubscribe MessageType = "subscribe"
	// MessageTypeUnsubscribe is sent by the client to unsubscribe from a topic.
	MessageTypeUnsubscribe MessageType = "unsubscribe"
	// MessageTypeBroadcast is used to broadcast data to all subscribers of a topic.
	MessageTypeBroadcast MessageType = "broadcast"
	// MessageTypeDirectMessage is used to send a message to a specific client.
	MessageTypeDirectMessage MessageType = "direct_message"
	// MessageTypeError is sent to a client when an error occurs.
	MessageTypeError MessageType = "error"
	// MessageTypePing is used for keepalive.
	MessageTypePing MessageType = "ping"
	// MessageTypePong is the response to a ping.
	MessageTypePong MessageType = "pong"
	// MessageTypeAck acknowledges a subscribe or unsubscribe.
	MessageTypeAck MessageType = "ack"
)

// Message is the envelope for all WebSocket communication.
type Message struct {
	// ID uniquely identifies this message.
	ID string `json:"id"`
	// Type indicates what kind of message this is.
	Type MessageType `json:"type"`
	// Topic is the subject this message relates to (e.g. "sensor.field-123").
	Topic string `json:"topic,omitempty"`
	// TargetID is the recipient client ID for direct messages.
	TargetID string `json:"target_id,omitempty"`
	// Data carries the payload as raw JSON.
	Data json.RawMessage `json:"data,omitempty"`
	// Error carries an error description when Type is MessageTypeError.
	Error string `json:"error,omitempty"`
	// Timestamp records when the message was created.
	Timestamp time.Time `json:"timestamp"`
}

// NewMessage creates a new Message with a generated ID and the current timestamp.
func NewMessage(msgType MessageType, topic string, data interface{}) (*Message, error) {
	var rawData json.RawMessage
	if data != nil {
		var err error
		rawData, err = json.Marshal(data)
		if err != nil {
			return nil, fmt.Errorf("websocket: failed to marshal message data: %w", err)
		}
	}
	return &Message{
		ID:        uuid.New().String(),
		Type:      msgType,
		Topic:     topic,
		Data:      rawData,
		Timestamp: time.Now(),
	}, nil
}

// NewBroadcastMessage creates a broadcast message for the given topic.
func NewBroadcastMessage(topic string, data interface{}) (*Message, error) {
	return NewMessage(MessageTypeBroadcast, topic, data)
}

// NewDirectMessage creates a direct message targeting a specific client.
func NewDirectMessage(targetID string, data interface{}) (*Message, error) {
	msg, err := NewMessage(MessageTypeDirectMessage, "", data)
	if err != nil {
		return nil, err
	}
	msg.TargetID = targetID
	return msg, nil
}

// NewErrorMessage creates an error message.
func NewErrorMessage(errText string) *Message {
	return &Message{
		ID:        uuid.New().String(),
		Type:      MessageTypeError,
		Error:     errText,
		Timestamp: time.Now(),
	}
}

// NewAckMessage creates an acknowledgment message for a subscription action.
func NewAckMessage(topic string) *Message {
	return &Message{
		ID:        uuid.New().String(),
		Type:      MessageTypeAck,
		Topic:     topic,
		Timestamp: time.Now(),
	}
}

// Encode serializes the message to JSON bytes.
func (m *Message) Encode() ([]byte, error) {
	return json.Marshal(m)
}

// DecodeMessage deserializes JSON bytes into a Message.
func DecodeMessage(data []byte) (*Message, error) {
	var msg Message
	if err := json.Unmarshal(data, &msg); err != nil {
		return nil, fmt.Errorf("websocket: failed to decode message: %w", err)
	}
	return &msg, nil
}

// TopicPattern defines the well-known topic prefixes for the platform.
const (
	// TopicPrefixSensor is the prefix for real-time sensor data topics.
	// Format: sensor.<field_id>
	TopicPrefixSensor = "sensor."
	// TopicPrefixAlert is the prefix for alert notification topics.
	// Format: alert.<farm_id>
	TopicPrefixAlert = "alert."
	// TopicPrefixIrrigation is the prefix for irrigation control topics.
	// Format: irrigation.<field_id>
	TopicPrefixIrrigation = "irrigation."
)

// ValidateTopicPattern checks whether a topic string starts with one of the
// supported prefixes and has a non-empty identifier after the prefix.
func ValidateTopicPattern(topic string) bool {
	prefixes := []string{TopicPrefixSensor, TopicPrefixAlert, TopicPrefixIrrigation}
	for _, p := range prefixes {
		if len(topic) > len(p) && topic[:len(p)] == p {
			return true
		}
	}
	return false
}
