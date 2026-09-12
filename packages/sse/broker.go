package sse

import (
	"context"
	"sync"
	"sync/atomic"

	"p9e.in/samavaya/packages/p9log"
)

// subscriber is an internal representation of a connected SSE client.
type subscriber struct {
	id     string
	events chan *Event
	topics map[string]struct{}
	done   chan struct{}
	closed atomic.Bool
}

// Broker manages SSE client channels and delivers events to subscribers
// based on topic filtering.
type Broker struct {
	// subscribers holds all connected SSE clients, keyed by subscriber ID.
	subscribers map[string]*subscriber
	// topicSubs maps topics to subscriber IDs for fast fan-out.
	topicSubs map[string]map[string]*subscriber

	mu  sync.RWMutex
	log p9log.Helper

	// publish is the channel through which events enter the broker.
	publish chan *Event
}

// NewBroker creates a ready-to-run SSE broker.
func NewBroker(log p9log.Logger) *Broker {
	return &Broker{
		subscribers: make(map[string]*subscriber),
		topicSubs:   make(map[string]map[string]*subscriber),
		publish:     make(chan *Event, 256),
		log:         *p9log.NewHelper(p9log.With(log, "module", "sse-broker")),
	}
}

// Run starts the broker event loop. It blocks until ctx is cancelled.
func (b *Broker) Run(ctx context.Context) {
	b.log.Info("SSE broker started")
	defer b.log.Info("SSE broker stopped")

	for {
		select {
		case <-ctx.Done():
			b.shutdown()
			return
		case event := <-b.publish:
			b.deliver(event)
		}
	}
}

// Subscribe registers a new SSE client with the broker and returns a channel
// on which the client receives events, plus a cleanup function. The topics
// parameter controls which events the client receives; an empty list means
// the client gets all events.
func (b *Broker) Subscribe(id string, topics []string) (<-chan *Event, func()) {
	sub := &subscriber{
		id:     id,
		events: make(chan *Event, 64),
		topics: make(map[string]struct{}, len(topics)),
		done:   make(chan struct{}),
	}
	for _, t := range topics {
		sub.topics[t] = struct{}{}
	}

	b.mu.Lock()
	b.subscribers[id] = sub
	for _, t := range topics {
		if b.topicSubs[t] == nil {
			b.topicSubs[t] = make(map[string]*subscriber)
		}
		b.topicSubs[t][id] = sub
	}
	b.mu.Unlock()

	b.log.Debugf("subscriber %s connected (topics=%v)", id, topics)

	cleanup := func() {
		if sub.closed.CompareAndSwap(false, true) {
			close(sub.done)
			b.removeSubscriber(sub)
		}
	}

	return sub.events, cleanup
}

// AddTopic adds a topic subscription for an existing subscriber.
func (b *Broker) AddTopic(subscriberID, topic string) {
	b.mu.Lock()
	defer b.mu.Unlock()

	sub, ok := b.subscribers[subscriberID]
	if !ok {
		return
	}

	sub.topics[topic] = struct{}{}
	if b.topicSubs[topic] == nil {
		b.topicSubs[topic] = make(map[string]*subscriber)
	}
	b.topicSubs[topic][subscriberID] = sub
}

// RemoveTopic removes a topic subscription for an existing subscriber.
func (b *Broker) RemoveTopic(subscriberID, topic string) {
	b.mu.Lock()
	defer b.mu.Unlock()

	sub, ok := b.subscribers[subscriberID]
	if !ok {
		return
	}

	delete(sub.topics, topic)
	if subs, ok := b.topicSubs[topic]; ok {
		delete(subs, subscriberID)
		if len(subs) == 0 {
			delete(b.topicSubs, topic)
		}
	}
}

// Publish sends an event to all subscribers whose topics match. If the
// event's Topic is empty, it is delivered to all subscribers.
func (b *Broker) Publish(event *Event) {
	b.publish <- event
}

// PublishData is a convenience method that creates and publishes an event.
func (b *Broker) PublishData(eventType, topic string, data interface{}) error {
	event, err := NewEvent(eventType, topic, data)
	if err != nil {
		return err
	}
	b.Publish(event)
	return nil
}

// deliver fans out an event to matching subscribers.
func (b *Broker) deliver(event *Event) {
	b.mu.RLock()
	defer b.mu.RUnlock()

	if event.Topic == "" {
		// Broadcast to all subscribers.
		for _, sub := range b.subscribers {
			b.trySend(sub, event)
		}
		return
	}

	// Deliver to topic subscribers.
	if subs, ok := b.topicSubs[event.Topic]; ok {
		for _, sub := range subs {
			b.trySend(sub, event)
		}
	}
}

// trySend attempts to send an event to a subscriber without blocking.
func (b *Broker) trySend(sub *subscriber, event *Event) {
	select {
	case sub.events <- event:
	default:
		b.log.Debugf("dropping event for subscriber %s: buffer full", sub.id)
	}
}

// removeSubscriber removes a subscriber from all internal tracking structures.
func (b *Broker) removeSubscriber(sub *subscriber) {
	b.mu.Lock()
	defer b.mu.Unlock()

	delete(b.subscribers, sub.id)
	for topic := range sub.topics {
		if subs, ok := b.topicSubs[topic]; ok {
			delete(subs, sub.id)
			if len(subs) == 0 {
				delete(b.topicSubs, topic)
			}
		}
	}
	close(sub.events)
	b.log.Debugf("subscriber %s disconnected", sub.id)
}

// SubscriberCount returns the number of active subscribers.
func (b *Broker) SubscriberCount() int {
	b.mu.RLock()
	defer b.mu.RUnlock()
	return len(b.subscribers)
}

// TopicSubscriberCount returns the number of subscribers for a topic.
func (b *Broker) TopicSubscriberCount(topic string) int {
	b.mu.RLock()
	defer b.mu.RUnlock()
	return len(b.topicSubs[topic])
}

// shutdown closes all subscriber channels.
func (b *Broker) shutdown() {
	b.mu.Lock()
	defer b.mu.Unlock()

	for _, sub := range b.subscribers {
		if sub.closed.CompareAndSwap(false, true) {
			close(sub.done)
			close(sub.events)
		}
	}
	b.subscribers = make(map[string]*subscriber)
	b.topicSubs = make(map[string]map[string]*subscriber)
}
