// Package kafka implements the outbound.EventPublisher port using IBM/sarama.
package kafka

import (
"context"
"fmt"

"github.com/IBM/sarama"

"p9e.in/samavaya/packages/p9log"

"p9e.in/samavaya/agriculture/field-service/internal/ports/outbound"
)

type eventPublisher struct {
producer sarama.SyncProducer
log      *p9log.Helper
}

// NewEventPublisher creates a new Kafka-backed EventPublisher.
func NewEventPublisher(producer sarama.SyncProducer, log p9log.Logger) outbound.EventPublisher {
return &eventPublisher{
producer: producer,
log:      p9log.NewHelper(p9log.With(log, "component", "FieldEventPublisher")),
}
}

func (p *eventPublisher) Publish(ctx context.Context, topic, key string, payload []byte) error {
if p.producer == nil {
p.log.Debugw("msg", "kafka producer not configured, event dropped", "topic", topic)
return nil
}
msg := &sarama.ProducerMessage{
Topic: topic,
Key:   sarama.StringEncoder(key),
Value: sarama.ByteEncoder(payload),
}
_, _, err := p.producer.SendMessage(msg)
if err != nil {
return fmt.Errorf("publish to %s: %w", topic, err)
}
return nil
}
