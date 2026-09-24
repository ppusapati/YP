package handler

import (
	msgp "p9e.in/samavaya/packages/api/v1/message"
	"p9e.in/samavaya/packages/p9log"

	"github.com/IBM/sarama"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/anypb"
)

type KafkaHandler struct {
	KafkaMessages chan *msgp.EventMessage
	committed     map[string]map[int32]int64
	log           *p9log.Helper
}

// NewKafkaHandler creates a new KafkaHandler instance.
func NewKafkaHandler(lg p9log.Logger) *KafkaHandler {
	return &KafkaHandler{
		KafkaMessages: make(chan *msgp.EventMessage),
		committed:     make(map[string]map[int32]int64),
		log:           p9log.NewHelper(p9log.With(lg, "caller", "Kafka Consumer")),
	}
}

// logger returns a usable helper even for a handler built as a struct literal
// rather than through NewKafkaHandler.
//
// Every field a caller needs is exported, so a literal is the obvious way to
// build one — and the consumer package did exactly that, leaving this field
// unset. The only thing that reads it is the branch below, reached when a
// message fails to unmarshal, so the gap survived until a foreign message
// landed on a topic and segfaulted the service. A logger that is missing is
// not a reason to lose the process.
func (h *KafkaHandler) logger() *p9log.Helper {
	if h.log == nil {
		return p9log.NewHelper(p9log.With(p9log.DefaultLogger, "caller", "Kafka Consumer"))
	}
	return h.log
}

// Setup is called when a new session is established.
func (h *KafkaHandler) Setup(_ sarama.ConsumerGroupSession) error {
	return nil
}

// Cleanup is called when a session is closed.
func (h *KafkaHandler) Cleanup(_ sarama.ConsumerGroupSession) error {
	return nil
}

// ConsumeClaim handles the consumption of Kafka messages.
func (h *KafkaHandler) ConsumeClaim(session sarama.ConsumerGroupSession, claim sarama.ConsumerGroupClaim) error {
	for msg := range claim.Messages() {
		// De-serialize the message.
		//
		// Two wire formats reach this loop. Messages published through
		// producer.ProduceMessage arrive as a marshalled EventMessage. But
		// every service in this repository publishes through the outbox relay,
		// which puts the payload on the partition unwrapped — so the far more
		// common case here is a bare payload that is not an EventMessage at
		// all, and treating that as a failure discards all real traffic.
		//
		// The unwrapped payload is carried through in the envelope's value so
		// that both shapes look identical downstream.
		m := msgp.EventMessage{}
		if errs := proto.Unmarshal(msg.Value, &m); errs != nil {
			h.logger().Log(p9log.LevelDebug, "msg", "message is not an EventMessage envelope; treating it as a bare payload",
				"topic", msg.Topic, "partition", msg.Partition, "offset", msg.Offset,
				"error", errs)
			m = msgp.EventMessage{
				Key:       string(msg.Key),
				Topic:     msg.Topic,
				Partition: msg.Partition,
				Offset:    msg.Offset,
				Value:     &anypb.Any{Value: msg.Value},
			}
		}
		h.KafkaMessages <- &m
		session.MarkMessage(msg, "")

		// Initialize the outer map if it's nil
		if h.committed == nil {
			h.committed = make(map[string]map[int32]int64)
		}

		// Initialize the inner map if it's nil
		if h.committed[m.Topic] == nil {
			h.committed[m.Topic] = make(map[int32]int64)
		}

		// Use a lock-free check to create or update the committed offset
		if h.committed[m.Topic][m.Partition] < m.Offset {
			h.committed[m.Topic][m.Partition] = m.Offset
		}
	}

	return nil
}

// IsOffsetCommitted checks if an offset is committed for a specific topic and partition.
func (h *KafkaHandler) IsOffsetCommitted(topic string, partition int32, offset int64) bool {
	if offsets, found := h.committed[topic]; found {
		return offsets[partition] >= offset
	}
	return false
}
