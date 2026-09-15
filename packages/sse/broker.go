package sse

import (
	"context"
	"sync"
	"sync/atomic"

	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/realtime"
)

// subscriber is an internal representation of a connected SSE client.
type subscriber struct {
	id string
	// tenantID is the tenant this connection belongs to. Every topic it holds
	// is qualified with it, and delivery checks it again.
	tenantID string
	events   chan *Event
	topics   map[string]struct{}
	done     chan struct{}
	closed   atomic.Bool
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

// Subscribe registers a new SSE client with the broker.
//
// Requested topics are scoped to tenantID: a bare name is qualified with it and
// a name qualified with another tenant's is dropped. This used to take its
// topics straight from a query parameter and store them verbatim, so naming
// another tenant's field was all it took to stream that field's alerts.
//
// An empty topic list no longer means "all events". It means this subscriber
// receives nothing until it asks for something, because the previous reading —
// every event on the process, from every tenant — is the one thing it must not
// mean.
//
// A connection with no tenant is refused: cleanup is returned so the caller can
// defer it unconditionally, and the channel is closed immediately.
func (b *Broker) Subscribe(id, tenantID string, topics []string) (<-chan *Event, func()) {
	sub := &subscriber{
		id:       id,
		tenantID: tenantID,
		events:   make(chan *Event, 64),
		topics:   make(map[string]struct{}, len(topics)),
		done:     make(chan struct{}),
	}

	if tenantID == "" {
		b.log.Errorf("refusing SSE subscriber %s: no tenant on the connection", id)
		close(sub.events)
		return sub.events, func() {}
	}

	scoped := make([]string, 0, len(topics))
	for _, t := range topics {
		topic, err := realtime.ScopeTopic(tenantID, t)
		if err != nil {
			b.log.Warnf("subscriber %s: refusing topic %q: %v", id, t, err)
			continue
		}
		sub.topics[topic] = struct{}{}
		scoped = append(scoped, topic)
	}

	b.mu.Lock()
	b.subscribers[id] = sub
	for _, t := range scoped {
		if b.topicSubs[t] == nil {
			b.topicSubs[t] = make(map[string]*subscriber)
		}
		b.topicSubs[t][id] = sub
	}
	b.mu.Unlock()

	b.log.Debugf("subscriber %s connected (tenant=%s, topics=%v)", id, tenantID, scoped)

	cleanup := func() {
		if sub.closed.CompareAndSwap(false, true) {
			close(sub.done)
			b.removeSubscriber(sub)
		}
	}

	return sub.events, cleanup
}

// AddTopic adds a topic subscription for an existing subscriber, scoped to
// that subscriber's tenant.
func (b *Broker) AddTopic(subscriberID, requested string) {
	b.mu.Lock()
	defer b.mu.Unlock()

	sub, ok := b.subscribers[subscriberID]
	if !ok {
		return
	}

	topic, err := realtime.ScopeTopic(sub.tenantID, requested)
	if err != nil {
		b.log.Warnf("subscriber %s: refusing topic %q: %v", subscriberID, requested, err)
		return
	}

	sub.topics[topic] = struct{}{}
	if b.topicSubs[topic] == nil {
		b.topicSubs[topic] = make(map[string]*subscriber)
	}
	b.topicSubs[topic][subscriberID] = sub
}

// RemoveTopic removes a topic subscription for an existing subscriber.
func (b *Broker) RemoveTopic(subscriberID, requested string) {
	b.mu.Lock()
	defer b.mu.Unlock()

	sub, ok := b.subscribers[subscriberID]
	if !ok {
		return
	}

	topic, err := realtime.ScopeTopic(sub.tenantID, requested)
	if err != nil {
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

// Publish sends an event to the subscribers of its topic.
//
// The topic must be tenant-qualified — build it with realtime.TenantTopic. An
// event with no tenant reaches nobody.
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

	// An unqualified topic — including the empty one — reaches nobody.
	//
	// This used to be the opposite: an event published with no topic went to
	// every subscriber on the process, across every tenant, which made
	// forgetting the topic a cross-tenant broadcast rather than a no-op.
	owner, _, qualified := realtime.SplitTopic(event.Topic)
	if !qualified {
		b.log.Errorf("refusing to deliver event %q on unqualified topic %q: "+
			"publishers must use realtime.TenantTopic", event.Type, event.Topic)
		return
	}

	subs, ok := b.topicSubs[event.Topic]
	if !ok {
		return
	}
	for _, sub := range subs {
		// Checked again on the way out, not only at subscribe time.
		if sub.tenantID != owner {
			b.log.Errorf("dropping subscriber %s from topic %q: tenant %q does not own it",
				sub.id, event.Topic, sub.tenantID)
			continue
		}
		b.trySend(sub, event)
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
