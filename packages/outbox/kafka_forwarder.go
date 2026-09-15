package outbox

import (
	"context"
	"fmt"

	"github.com/IBM/sarama"
)

// kafkaForwarder implements KafkaPublisher by writing to a sarama.SyncProducer.
type kafkaForwarder struct {
	producer sarama.SyncProducer
}

// NewKafkaForwarder wraps a sarama.SyncProducer as a KafkaPublisher
// suitable for passing to NewRelay.
func NewKafkaForwarder(producer sarama.SyncProducer) KafkaPublisher {
	return &kafkaForwarder{producer: producer}
}

func (f *kafkaForwarder) Publish(_ context.Context, topic, key string, payload []byte) error {
	msg := &sarama.ProducerMessage{
		Topic: topic,
		Key:   sarama.StringEncoder(key),
		Value: sarama.ByteEncoder(payload),
	}
	_, _, err := f.producer.SendMessage(msg)
	if err != nil {
		return fmt.Errorf("kafka forwarder: %w", err)
	}
	return nil
}
