// Package kafka implements the outbound.EventPublisher port using IBM/sarama.
package kafka

import (
	"context"
	"fmt"

	"github.com/IBM/sarama"

	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/farm-service/internal/ports/outbound"
)

// eventPublisher sends domain event payloads to Kafka topics.
type eventPublisher struct {
	producer sarama.SyncProducer
	log      *p9log.Helper
}

// NewEventPublisher creates a new Kafka-backed EventPublisher.
// The producer is shared across all topics; pass nil to create a no-op publisher.
func NewEventPublisher(producer sarama.SyncProducer, log p9log.Logger) outbound.EventPublisher {
	return &eventPublisher{
		producer: producer,
		log:      p9log.NewHelper(p9log.With(log, "component", "FarmEventPublisher")),
	}
}

// Publish sends payload bytes to the named Kafka topic using key for partitioning.
func (p *eventPublisher) Publish(ctx context.Context, topic, key string, payload []byte) error {
	if p.producer == nil {
		p.log.Debugw("msg", "kafka producer not configured, event dropped",
			"topic", topic, "key", key)
		return nil
	}

	msg := &sarama.ProducerMessage{
		Topic: topic,
		Key:   sarama.StringEncoder(key),
		Value: sarama.ByteEncoder(payload),
	}

	partition, offset, err := p.producer.SendMessage(msg)
	if err != nil {
		p.log.Errorw("msg", "failed to publish event",
			"topic", topic, "key", key, "error", err)
		return fmt.Errorf("publish to %s: %w", topic, err)
	}

	p.log.Debugw("msg", "event published",
		"topic", topic, "key", key,
		"partition", partition, "offset", offset)
	return nil
}
