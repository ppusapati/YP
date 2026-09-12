package websocket

import (
	"encoding/json"
	"fmt"
	"sync"
	"sync/atomic"
	"time"

	"p9e.in/samavaya/packages/p9log"

	"golang.org/x/net/websocket"
)

const (
	// writeWait is the time allowed to write a message to the peer.
	writeWait = 10 * time.Second
	// pongWait is the time allowed to read the next pong message from the peer.
	pongWait = 60 * time.Second
	// pingInterval is the interval between ping messages. Must be less than pongWait.
	pingInterval = (pongWait * 9) / 10
	// maxMessageSize is the maximum message size allowed from the peer.
	maxMessageSize = 64 * 1024 // 64 KB
	// sendBufferSize is the capacity of the outbound message channel.
	sendBufferSize = 256
)

// Client wraps a single WebSocket connection and provides read/write pumps,
// ping/pong handling, and graceful close.
type Client struct {
	// ID uniquely identifies this client connection.
	ID string
	// UserID is the authenticated user (extracted from JWT).
	UserID string
	// TenantID is the tenant the user belongs to.
	TenantID string

	hub  *Hub
	conn *websocket.Conn
	send chan []byte
	log  p9log.Helper

	// topics is the set of topics this client is subscribed to.
	topics   map[string]struct{}
	topicsMu sync.RWMutex

	closed atomic.Bool
	done   chan struct{}
}

// NewClient creates a Client bound to the given hub and websocket connection.
func NewClient(id, userID, tenantID string, hub *Hub, conn *websocket.Conn, log p9log.Logger) *Client {
	return &Client{
		ID:       id,
		UserID:   userID,
		TenantID: tenantID,
		hub:      hub,
		conn:     conn,
		send:     make(chan []byte, sendBufferSize),
		log:      *p9log.NewHelper(p9log.With(log, "module", "ws-client", "client_id", id)),
		topics:   make(map[string]struct{}),
		done:     make(chan struct{}),
	}
}

// Subscribe adds a topic to this client's subscriptions.
func (c *Client) Subscribe(topic string) {
	c.topicsMu.Lock()
	c.topics[topic] = struct{}{}
	c.topicsMu.Unlock()
}

// Unsubscribe removes a topic from this client's subscriptions.
func (c *Client) Unsubscribe(topic string) {
	c.topicsMu.Lock()
	delete(c.topics, topic)
	c.topicsMu.Unlock()
}

// IsSubscribed reports whether the client is subscribed to the given topic.
func (c *Client) IsSubscribed(topic string) bool {
	c.topicsMu.RLock()
	_, ok := c.topics[topic]
	c.topicsMu.RUnlock()
	return ok
}

// Topics returns a snapshot of the client's current subscriptions.
func (c *Client) Topics() []string {
	c.topicsMu.RLock()
	defer c.topicsMu.RUnlock()
	out := make([]string, 0, len(c.topics))
	for t := range c.topics {
		out = append(out, t)
	}
	return out
}

// Send enqueues a message for delivery to this client. It is non-blocking;
// if the send buffer is full the message is dropped and an error is returned.
func (c *Client) Send(data []byte) error {
	if c.closed.Load() {
		return fmt.Errorf("websocket: client %s is closed", c.ID)
	}
	select {
	case c.send <- data:
		return nil
	default:
		return fmt.Errorf("websocket: send buffer full for client %s", c.ID)
	}
}

// Close initiates a graceful close of this client.
func (c *Client) Close() {
	if c.closed.CompareAndSwap(false, true) {
		close(c.done)
	}
}

// ReadPump reads messages from the WebSocket connection and dispatches them
// to the hub. It should be run in its own goroutine. When the read pump
// exits it unregisters the client and closes the connection.
func (c *Client) ReadPump() {
	defer func() {
		c.hub.unregister <- c
		c.conn.Close()
	}()

	for {
		select {
		case <-c.done:
			return
		default:
		}

		// Set a read deadline so stale connections get cleaned up.
		if err := c.conn.SetReadDeadline(time.Now().Add(pongWait)); err != nil {
			c.log.Debugf("failed to set read deadline: %v", err)
			return
		}

		var raw []byte
		if err := websocket.Message.Receive(c.conn, &raw); err != nil {
			if !c.closed.Load() {
				c.log.Debugf("read error: %v", err)
			}
			return
		}

		if len(raw) > maxMessageSize {
			c.sendError("message exceeds maximum size")
			continue
		}

		msg, err := DecodeMessage(raw)
		if err != nil {
			c.sendError("invalid message format")
			continue
		}

		c.handleMessage(msg)
	}
}

// WritePump pumps messages from the send channel to the WebSocket connection
// and sends periodic pings. It should be run in its own goroutine.
func (c *Client) WritePump() {
	ticker := time.NewTicker(pingInterval)
	defer func() {
		ticker.Stop()
		c.conn.Close()
	}()

	for {
		select {
		case <-c.done:
			// Send a close frame before exiting.
			_ = c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			return
		case message, ok := <-c.send:
			if !ok {
				// The hub closed the channel.
				return
			}
			if err := c.conn.SetWriteDeadline(time.Now().Add(writeWait)); err != nil {
				return
			}
			if _, err := c.conn.Write(message); err != nil {
				c.log.Debugf("write error: %v", err)
				return
			}
		case <-ticker.C:
			if err := c.conn.SetWriteDeadline(time.Now().Add(writeWait)); err != nil {
				return
			}
			ping := &Message{Type: MessageTypePing, Timestamp: time.Now()}
			data, _ := json.Marshal(ping)
			if _, err := c.conn.Write(data); err != nil {
				c.log.Debugf("ping write error: %v", err)
				return
			}
		}
	}
}

// handleMessage processes an inbound message from the client.
func (c *Client) handleMessage(msg *Message) {
	switch msg.Type {
	case MessageTypeSubscribe:
		if msg.Topic == "" {
			c.sendError("subscribe requires a topic")
			return
		}
		c.Subscribe(msg.Topic)
		c.hub.subscribe <- &Subscription{Client: c, Topic: msg.Topic}
		ack := NewAckMessage(msg.Topic)
		data, _ := ack.Encode()
		_ = c.Send(data)
		c.log.Debugf("subscribed to topic %s", msg.Topic)

	case MessageTypeUnsubscribe:
		if msg.Topic == "" {
			c.sendError("unsubscribe requires a topic")
			return
		}
		c.Unsubscribe(msg.Topic)
		c.hub.unsubscribe <- &Subscription{Client: c, Topic: msg.Topic}
		ack := NewAckMessage(msg.Topic)
		data, _ := ack.Encode()
		_ = c.Send(data)
		c.log.Debugf("unsubscribed from topic %s", msg.Topic)

	case MessageTypePong:
		// Client responded to our ping; nothing else to do.

	case MessageTypePing:
		pong := &Message{Type: MessageTypePong, Timestamp: time.Now()}
		data, _ := json.Marshal(pong)
		_ = c.Send(data)

	default:
		c.sendError(fmt.Sprintf("unsupported message type: %s", msg.Type))
	}
}

// sendError sends an error message back to this client.
func (c *Client) sendError(text string) {
	errMsg := NewErrorMessage(text)
	data, _ := errMsg.Encode()
	_ = c.Send(data)
}
