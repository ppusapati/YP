package outbound

import "context"

// EventPublisher is the secondary port for emitting domain events.
// The Kafka adapter implements this interface.  The application layer
// calls Publish fire-and-forget; errors are logged but do not fail the
// business operation.
type EventPublisher interface {
	// Publish sends an event to the named topic with the given key and payload.
	// key is used for Kafka partition assignment (typically the aggregate UUID).
	Publish(ctx context.Context, topic, key string, payload []byte) error
}
