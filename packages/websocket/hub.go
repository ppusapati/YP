package websocket

import (
	"context"
	"sync"

	"p9e.in/samavaya/packages/p9log"
)

// Subscription represents a client subscribing to or unsubscribing from a topic.
type Subscription struct {
	Client *Client
	Topic  string
}

// Hub maintains the set of active clients and broadcasts messages to
// subscribers of specific topics.
type Hub struct {
	// clients is the set of registered clients keyed by client ID.
	clients map[string]*Client
	// topics maps each topic to the set of clients subscribed to it.
	topics map[string]map[string]*Client

	register    chan *Client
	unregister  chan *Client
	subscribe   chan *Subscription
	unsubscribe chan *Subscription
	broadcast   chan *Message

	log p9log.Helper
	mu  sync.RWMutex
}

// NewHub creates a ready-to-run Hub.
func NewHub(log p9log.Logger) *Hub {
	return &Hub{
		clients:     make(map[string]*Client),
		topics:      make(map[string]map[string]*Client),
		register:    make(chan *Client, 64),
		unregister:  make(chan *Client, 64),
		subscribe:   make(chan *Subscription, 64),
		unsubscribe: make(chan *Subscription, 64),
		broadcast:   make(chan *Message, 256),
		log:         *p9log.NewHelper(p9log.With(log, "module", "ws-hub")),
	}
}

// Run starts the hub event loop. It blocks until ctx is cancelled.
func (h *Hub) Run(ctx context.Context) {
	h.log.Info("WebSocket hub started")
	defer h.log.Info("WebSocket hub stopped")

	for {
		select {
		case <-ctx.Done():
			h.shutdown()
			return

		case client := <-h.register:
			h.mu.Lock()
			h.clients[client.ID] = client
			h.mu.Unlock()
			h.log.Debugf("client registered: %s (user=%s, tenant=%s)", client.ID, client.UserID, client.TenantID)

		case client := <-h.unregister:
			h.mu.Lock()
			if _, ok := h.clients[client.ID]; ok {
				delete(h.clients, client.ID)
				// Remove from all topics.
				for topic, subscribers := range h.topics {
					delete(subscribers, client.ID)
					if len(subscribers) == 0 {
						delete(h.topics, topic)
					}
				}
				close(client.send)
				client.Close()
			}
			h.mu.Unlock()
			h.log.Debugf("client unregistered: %s", client.ID)

		case sub := <-h.subscribe:
			h.mu.Lock()
			if h.topics[sub.Topic] == nil {
				h.topics[sub.Topic] = make(map[string]*Client)
			}
			h.topics[sub.Topic][sub.Client.ID] = sub.Client
			h.mu.Unlock()
			h.log.Debugf("client %s subscribed to %s", sub.Client.ID, sub.Topic)

		case sub := <-h.unsubscribe:
			h.mu.Lock()
			if subscribers, ok := h.topics[sub.Topic]; ok {
				delete(subscribers, sub.Client.ID)
				if len(subscribers) == 0 {
					delete(h.topics, sub.Topic)
				}
			}
			h.mu.Unlock()
			h.log.Debugf("client %s unsubscribed from %s", sub.Client.ID, sub.Topic)

		case msg := <-h.broadcast:
			h.handleBroadcast(msg)
		}
	}
}

// handleBroadcast delivers a message to subscribers of its topic, or to a
// specific client for direct messages.
func (h *Hub) handleBroadcast(msg *Message) {
	switch msg.Type {
	case MessageTypeBroadcast:
		h.mu.RLock()
		subscribers, ok := h.topics[msg.Topic]
		if !ok {
			h.mu.RUnlock()
			return
		}
		// Take a snapshot to avoid holding the lock during writes.
		targets := make([]*Client, 0, len(subscribers))
		for _, c := range subscribers {
			targets = append(targets, c)
		}
		h.mu.RUnlock()

		data, err := msg.Encode()
		if err != nil {
			h.log.Errorf("failed to encode broadcast message: %v", err)
			return
		}
		for _, c := range targets {
			if err := c.Send(data); err != nil {
				h.log.Debugf("failed to send to client %s: %v", c.ID, err)
			}
		}

	case MessageTypeDirectMessage:
		h.mu.RLock()
		target, ok := h.clients[msg.TargetID]
		h.mu.RUnlock()
		if !ok {
			h.log.Debugf("direct message target not found: %s", msg.TargetID)
			return
		}
		data, err := msg.Encode()
		if err != nil {
			h.log.Errorf("failed to encode direct message: %v", err)
			return
		}
		if err := target.Send(data); err != nil {
			h.log.Debugf("failed to send direct message to client %s: %v", msg.TargetID, err)
		}
	}
}

// Broadcast sends a message to all subscribers of the given topic.
func (h *Hub) Broadcast(topic string, data interface{}) error {
	msg, err := NewBroadcastMessage(topic, data)
	if err != nil {
		return err
	}
	h.broadcast <- msg
	return nil
}

// BroadcastRaw sends a pre-built message through the hub's broadcast channel.
func (h *Hub) BroadcastRaw(msg *Message) {
	h.broadcast <- msg
}

// SendDirect sends a direct message to a specific client by ID.
func (h *Hub) SendDirect(clientID string, data interface{}) error {
	msg, err := NewDirectMessage(clientID, data)
	if err != nil {
		return err
	}
	h.broadcast <- msg
	return nil
}

// Register queues a client for registration with the hub.
func (h *Hub) Register(client *Client) {
	h.register <- client
}

// ClientCount returns the number of connected clients.
func (h *Hub) ClientCount() int {
	h.mu.RLock()
	defer h.mu.RUnlock()
	return len(h.clients)
}

// TopicSubscriberCount returns the number of subscribers for a topic.
func (h *Hub) TopicSubscriberCount(topic string) int {
	h.mu.RLock()
	defer h.mu.RUnlock()
	return len(h.topics[topic])
}

// TopicList returns all active topics.
func (h *Hub) TopicList() []string {
	h.mu.RLock()
	defer h.mu.RUnlock()
	out := make([]string, 0, len(h.topics))
	for t := range h.topics {
		out = append(out, t)
	}
	return out
}

// shutdown closes all connected clients.
func (h *Hub) shutdown() {
	h.mu.Lock()
	defer h.mu.Unlock()
	for _, c := range h.clients {
		close(c.send)
		c.Close()
	}
	h.clients = make(map[string]*Client)
	h.topics = make(map[string]map[string]*Client)
}
