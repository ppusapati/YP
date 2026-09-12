package sse

import (
	"encoding/json"
	"fmt"
	"strings"
	"time"
)

// Event represents a single Server-Sent Event as defined by the SSE
// specification (https://html.spec.whatwg.org/multipage/server-sent-events.html).
type Event struct {
	// ID is the event identifier. The client uses this when reconnecting
	// via the Last-Event-ID header.
	ID string
	// Type is the event type (the "event" field in SSE). If empty, the
	// client's "message" event listener receives it.
	Type string
	// Data is the payload. It can span multiple lines; each line becomes
	// a separate "data:" field in the wire format.
	Data string
	// Retry, when positive, suggests a reconnection interval in milliseconds
	// to the client.
	Retry int
	// Topic is an application-level routing field (not part of the SSE spec).
	// The broker uses it to filter which clients receive the event.
	Topic string
	// Timestamp records when the event was created.
	Timestamp time.Time
}

// NewEvent creates an Event with a type, topic, and data payload.
// The data is JSON-encoded if it is not already a string.
func NewEvent(eventType, topic string, data interface{}) (*Event, error) {
	var dataStr string
	switch v := data.(type) {
	case string:
		dataStr = v
	case []byte:
		dataStr = string(v)
	case json.RawMessage:
		dataStr = string(v)
	default:
		encoded, err := json.Marshal(data)
		if err != nil {
			return nil, fmt.Errorf("sse: failed to marshal event data: %w", err)
		}
		dataStr = string(encoded)
	}

	return &Event{
		Type:      eventType,
		Topic:     topic,
		Data:      dataStr,
		Timestamp: time.Now(),
	}, nil
}

// Format serializes the event into the SSE wire format suitable for writing
// directly to an http.ResponseWriter.
func (e *Event) Format() []byte {
	var b strings.Builder

	if e.ID != "" {
		fmt.Fprintf(&b, "id: %s\n", e.ID)
	}
	if e.Type != "" {
		fmt.Fprintf(&b, "event: %s\n", e.Type)
	}
	if e.Retry > 0 {
		fmt.Fprintf(&b, "retry: %d\n", e.Retry)
	}

	// Each line of data must be sent as a separate "data:" field.
	for _, line := range strings.Split(e.Data, "\n") {
		fmt.Fprintf(&b, "data: %s\n", line)
	}

	// An empty line terminates the event.
	b.WriteString("\n")
	return []byte(b.String())
}
