package consumer

import (
	"sync/atomic"

	"p9e.in/samavaya/packages/api/v1/message"
	"p9e.in/samavaya/packages/p9log"

	"github.com/IBM/sarama"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/anypb"
)

type KafkaHandler struct {
	KafkaMessages chan *message.EventMessage
	Consumer      *KafkaConsumer
	log           p9log.Logger
	processedMsgs atomic.Uint64
}

func (h *KafkaHandler) Setup(_ sarama.ConsumerGroupSession) error {
	return nil
}

func (h *KafkaHandler) Cleanup(_ sarama.ConsumerGroupSession) error {
	return nil
}

func (h *KafkaHandler) ConsumeClaim(session sarama.ConsumerGroupSession, claim sarama.ConsumerGroupClaim) error {
	for msg := range claim.Messages() {
		m := message.EventMessage{}
		if errs := proto.Unmarshal(msg.Value, &m); errs != nil {
			// Kept in step with the handler package's copy: a message that is
			// not an EventMessage is a bare payload from the outbox relay, not
			// a corrupt one, and dropping it loses real traffic. The nil check
			// matters because this field is unexported and unset on a literal.
			if h.log != nil {
				_ = h.log.Log(p9log.LevelDebug, "msg", "message is not an EventMessage envelope; treating it as a bare payload",
					"topic", msg.Topic, "partition", msg.Partition, "offset", msg.Offset,
					"error", errs)
			}
			m = message.EventMessage{
				Key:       string(msg.Key),
				Topic:     msg.Topic,
				Partition: msg.Partition,
				Offset:    msg.Offset,
				Value:     &anypb.Any{Value: msg.Value},
			}
		}

		h.KafkaMessages <- &m
		session.MarkMessage(msg, "")

		if h.Consumer != nil {
			h.Consumer.updateCommittedOffset(&m)
		}

		// Track processed messages atomically
		h.processedMsgs.Add(1)
	}

	return nil
}

// GetProcessedMessageCount returns the number of processed messages
func (h *KafkaHandler) GetProcessedMessageCount() uint64 {
	return h.processedMsgs.Load()
}
