package modulith

import (
	"context"
	"sync"

	"go.uber.org/zap"
)

// EventHandler is a function that handles a domain event.
type EventHandler func(ctx context.Context, topic string, key string, payload []byte) error

// EventBus provides in-process pub/sub for cross-module communication.
// Within the monolith, modules publish events here instead of Kafka.
// Events are dispatched synchronously to all subscribers of the topic.
//
// For events that must also leave the monolith boundary (e.g., to external
// consumers), the bus can optionally forward to Kafka via a configured
// ExternalPublisher.
type EventBus struct {
	subscribers map[string][]subscriberEntry
	mu          sync.RWMutex
	logger      *zap.Logger
	external    ExternalPublisher
}

type subscriberEntry struct {
	module  string
	handler EventHandler
}

// ExternalPublisher forwards events outside the monolith (e.g., to Kafka).
type ExternalPublisher interface {
	Publish(ctx context.Context, topic, key string, payload []byte) error
}

func NewEventBus(logger *zap.Logger) *EventBus {
	return &EventBus{
		subscribers: make(map[string][]subscriberEntry),
		logger:      logger,
	}
}

// SetExternalPublisher configures an optional external publisher (Kafka).
// Events will be forwarded there in addition to in-process subscribers.
func (b *EventBus) SetExternalPublisher(pub ExternalPublisher) {
	b.mu.Lock()
	defer b.mu.Unlock()
	b.external = pub
}

// Subscribe registers a handler for events on the given topic.
func (b *EventBus) Subscribe(module, topic string, handler EventHandler) {
	b.mu.Lock()
	defer b.mu.Unlock()
	b.subscribers[topic] = append(b.subscribers[topic], subscriberEntry{
		module:  module,
		handler: handler,
	})
	b.logger.Info("event subscription registered",
		zap.String("module", module),
		zap.String("topic", topic))
}

// Publish dispatches an event to all in-process subscribers of the topic,
// then optionally forwards to the external publisher. Returns the first
// error encountered (all handlers are still called).
func (b *EventBus) Publish(ctx context.Context, topic, key string, payload []byte) error {
	b.mu.RLock()
	subs := b.subscribers[topic]
	ext := b.external
	b.mu.RUnlock()

	var firstErr error
	for _, sub := range subs {
		if err := sub.handler(ctx, topic, key, payload); err != nil {
			b.logger.Warn("event handler error",
				zap.String("module", sub.module),
				zap.String("topic", topic),
				zap.String("key", key),
				zap.Error(err))
			if firstErr == nil {
				firstErr = err
			}
		}
	}

	if ext != nil {
		if err := ext.Publish(ctx, topic, key, payload); err != nil {
			b.logger.Warn("external publish error",
				zap.String("topic", topic),
				zap.String("key", key),
				zap.Error(err))
			if firstErr == nil {
				firstErr = err
			}
		}
	}

	return firstErr
}

// TopicSubscriberCount returns the number of subscribers for a topic (useful for diagnostics).
func (b *EventBus) TopicSubscriberCount(topic string) int {
	b.mu.RLock()
	defer b.mu.RUnlock()
	return len(b.subscribers[topic])
}
