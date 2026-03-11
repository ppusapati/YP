package kafka

import "context"

// Producer is the interface for publishing messages to Kafka topics.
type Producer interface {
	Produce(ctx context.Context, topic string, data string) error
}
