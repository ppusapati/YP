package outbound

import "context"

// EventPublisher is the secondary port for emitting domain events.
type EventPublisher interface {
	Publish(ctx context.Context, topic, key string, payload []byte) error
}
