package consumer

import (
	"context"
	"fmt"
	"sync"
	"sync/atomic"
	"time"

	"google.golang.org/protobuf/types/known/wrapperspb"

	"p9e.in/samavaya/packages/api/v1/message"
	"p9e.in/samavaya/packages/events/config"
	"p9e.in/samavaya/packages/events/handler"
	"p9e.in/samavaya/packages/p9log"

	"github.com/IBM/sarama"
)

type KafkaConsumer struct {
	config *config.KafkaConfig
	// logger is kept alongside the helper because the message handler needs a
	// Logger, not a Helper, to build its own.
	logger    p9log.Logger
	log       p9log.Helper
	committed atomic.Value
	shutdown  atomic.Bool
	groups    []sarama.ConsumerGroup
	groupsMu  sync.Mutex
}

func NewKafkaConsumer(config *config.KafkaConfig, lg p9log.Logger) *KafkaConsumer {
	kc := &KafkaConsumer{
		config: config,
		logger: lg,
		log:    *p9log.NewHelper(p9log.With(lg, "caller", "Kafka Consumer")),
	}
	kc.committed.Store(make(map[string]map[int32]int64))
	return kc
}

// ConsumerGroup joins a Kafka consumer group.
//
// Returns the error rather than ending the process, which is what this used to
// do: a Fatalf here called os.Exit inside a library, so a broker that was
// briefly unreachable at boot took the whole service down — including the RPCs
// it could still have served. Worse, Subscribe below declares an error return
// that every caller checks, and could never return one: the only failure path
// exited instead, so thirteen services had a warning branch that had never
// run.
//
// Returns (nil, nil) once Cleanup has been called, which is a shutdown in
// progress rather than a failure.
func (kc *KafkaConsumer) ConsumerGroup(groupName string) (sarama.ConsumerGroup, error) {
	if kc.shutdown.Load() {
		return nil, nil
	}

	consumerConfig := kc.createConsumerConfig()
	consumer, err := sarama.NewConsumerGroup([]string{kc.config.Broker}, groupName, consumerConfig)
	if err != nil {
		return nil, fmt.Errorf("joining Kafka consumer group %q at %s: %w",
			groupName, kc.config.Broker, err)
	}

	kc.groupsMu.Lock()
	kc.groups = append(kc.groups, consumer)
	kc.groupsMu.Unlock()
	return consumer, nil
}

func (kc *KafkaConsumer) Consume(ctx context.Context, kafkaMessages chan *message.EventMessage) {
	ctx = kc.watchSignals(ctx)

	consumer, err := kc.ConsumerGroup(kc.config.Group)
	if err != nil {
		kc.log.Errorf("Not consuming: %v", err)
		return
	}
	if consumer == nil {
		// Shutting down. Deferring Close on this used to panic on a nil
		// interface, turning an orderly shutdown into a crash.
		return
	}
	defer consumer.Close()

	for _, topic := range kc.config.Topic {
		kc.ConsumingTopic(ctx, consumer, topic, kafkaMessages)
	}

	<-ctx.Done()
	kc.log.Info("Kafka consumer shutdown initiated")
}

func (kc *KafkaConsumer) ConsumingTopic(ctx context.Context, consumer sarama.ConsumerGroup, topic string, kafkaMessages chan *message.EventMessage) {
	handler := handler.NewKafkaHandler(kc.logger)
	handler.KafkaMessages = kafkaMessages

	go func() {
		for {
			select {
			case <-ctx.Done():
				return
			default:
				if err := consumer.Consume(ctx, []string{topic}, handler); err != nil {
					kc.log.Errorf("Error consuming topic %s: %v", topic, err)
				}
			}
		}
	}()
}

func (kc *KafkaConsumer) updateCommittedOffset(m *message.EventMessage) {
	committed := kc.committed.Load().(map[string]map[int32]int64)

	if committed[m.Topic] == nil {
		committed[m.Topic] = make(map[int32]int64)
	}

	if committed[m.Topic][m.Partition] < m.Offset {
		committed[m.Topic][m.Partition] = m.Offset
		kc.committed.Store(committed)
	}
}

func (kc *KafkaConsumer) watchSignals(ctx context.Context) context.Context {
	ctx, cancel := context.WithCancel(ctx)

	go func() {
		<-ctx.Done()
		kc.shutdown.Store(true)
		kc.closeAllGroups()
		cancel()
	}()

	return ctx
}

func (kc *KafkaConsumer) closeAllGroups() {
	kc.groupsMu.Lock()
	defer kc.groupsMu.Unlock()
	for _, g := range kc.groups {
		if err := g.Close(); err != nil {
			kc.log.Errorf("Error closing consumer group: %v", err)
		}
	}
	kc.groups = nil
}

// reconnectBackoff is how long Subscribe waits between attempts to reach a
// broker that was not there when the service started.
//
// Bounded and capped rather than immediate, because a broker that is down
// tends to be down for a while, and thirty services retrying in a tight loop
// is its own outage.
const (
	reconnectInitial = 2 * time.Second
	reconnectMax     = 30 * time.Second
)

// Subscribe registers a callback handler for a given topic. It creates a
// consumer group and starts consuming in the background. The handler is called
// for each message received on the topic with the raw payload bytes extracted
// from the EventMessage's Any value.
//
// Returns an error when the broker cannot be reached on the first attempt —
// which is new, and is the point. This used to end the process from inside
// ConsumerGroup, so the error every caller checks could never be returned and
// their warning branch had never run.
//
// It then keeps trying in the background until ctx ends. Without that, fixing
// the crash would have traded a service that restarts loudly for one that
// starts, consumes nothing for ever, and reports itself healthy — and a
// consumer that silently stops is how a farm's sensor readings, field
// deletions and crop assignments go quietly missing.
//
// So the error means "not consuming yet", not "never will". A caller that
// wants to refuse to start can still treat it as fatal.
func (kc *KafkaConsumer) Subscribe(ctx context.Context, topic string, handler func(ctx context.Context, data []byte) error) error {
	if kc.shutdown.Load() {
		return nil
	}

	consumer, err := kc.ConsumerGroup(kc.config.Group + "-" + topic)
	if err != nil {
		// Keep trying, and tell the caller it is not consuming right now.
		go kc.resubscribe(ctx, topic, handler)
		return err
	}
	if consumer == nil {
		return nil
	}

	kc.consume(ctx, consumer, topic, handler)
	return nil
}

// resubscribe retries until the broker accepts or ctx ends.
func (kc *KafkaConsumer) resubscribe(ctx context.Context, topic string, handler func(ctx context.Context, data []byte) error) {
	wait := reconnectInitial
	for {
		timer := time.NewTimer(wait)
		select {
		case <-ctx.Done():
			timer.Stop()
			return
		case <-timer.C:
		}

		if kc.shutdown.Load() {
			return
		}

		consumer, err := kc.ConsumerGroup(kc.config.Group + "-" + topic)
		if err != nil {
			if wait *= 2; wait > reconnectMax {
				wait = reconnectMax
			}
			continue
		}
		if consumer == nil {
			return
		}

		kc.log.Infow("msg", "subscribed to topic after an earlier failure", "topic", topic)
		kc.consume(ctx, consumer, topic, handler)
		return
	}
}

// consume pumps one topic's messages into the handler until ctx ends.
func (kc *KafkaConsumer) consume(ctx context.Context, consumer sarama.ConsumerGroup, topic string, handler func(ctx context.Context, data []byte) error) {
	msgCh := make(chan *message.EventMessage, 100)
	kc.ConsumingTopic(ctx, consumer, topic, msgCh)

	go func() {
		defer consumer.Close()
		for {
			select {
			case <-ctx.Done():
				return
			case msg, ok := <-msgCh:
				if !ok {
					return
				}
				data := payloadOf(msg)
				if err := handler(ctx, data); err != nil {
					kc.log.Errorf("Error handling message from topic %s: %v", topic, err)
				}
			}
		}
	}()
}

func (kc *KafkaConsumer) Cleanup() {
	kc.shutdown.Store(true)
	kc.closeAllGroups()
}

func (kc *KafkaConsumer) createConsumerConfig() *sarama.Config {
	config := sarama.NewConfig()
	config.Version, _ = sarama.ParseKafkaVersion(kc.config.KafkaVersion)

	switch kc.config.Assignor {
	case "sticky":
		config.Consumer.Group.Rebalance.Strategy = sarama.NewBalanceStrategySticky()
	case "roundrobin":
		config.Consumer.Group.Rebalance.Strategy = sarama.NewBalanceStrategyRoundRobin()
	case "range":
		config.Consumer.Group.Rebalance.Strategy = sarama.NewBalanceStrategyRange()
	default:
		kc.log.Errorf("Unrecognized consumer group partition assignor: %s", kc.config.Assignor)
	}

	return config
}

// payloadOf returns the bytes a domain handler should parse.
//
// Three shapes reach here and they are not interchangeable:
//
//   - A bare payload, put on the partition by the outbox relay. The handler
//     carries it through in an Any with no type URL, so the bytes are the
//     payload exactly as published. This is what every service in this
//     repository actually produces.
//   - An Any wrapping a StringValue, which is how DomainEventPublisher packs
//     an event. Reading Any.Value directly here yields the marshalled
//     StringValue — the JSON with a protobuf tag and length glued to the
//     front — which no json.Unmarshal will accept.
//   - Anything else, returned as-is for the handler to reject.
func payloadOf(m *message.EventMessage) []byte {
	v := m.GetValue()
	if v == nil {
		return nil
	}
	if v.GetTypeUrl() == "" {
		return v.GetValue()
	}

	var s wrapperspb.StringValue
	if v.MessageIs(&s) && v.UnmarshalTo(&s) == nil {
		return []byte(s.GetValue())
	}
	var b wrapperspb.BytesValue
	if v.MessageIs(&b) && v.UnmarshalTo(&b) == nil {
		return b.GetValue()
	}
	return v.GetValue()
}
