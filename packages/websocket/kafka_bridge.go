package websocket

import (
	"context"
	"encoding/json"
	"fmt"

	"p9e.in/samavaya/packages/events/consumer"
	"p9e.in/samavaya/packages/p9log"
)

// TopicMapping maps a Kafka topic name to a WebSocket topic pattern.
// For example, mapping Kafka topic "yp.sensor.readings" to the WebSocket
// topic prefix "sensor." so that messages arrive at "sensor.<field_id>".
type TopicMapping struct {
	// KafkaTopic is the Kafka topic to consume from.
	KafkaTopic string
	// WSTopicPrefix is the WebSocket topic prefix to broadcast to.
	// The full WebSocket topic is built as WSTopicPrefix + the key extracted
	// from the message (see KeyField).
	WSTopicPrefix string
	// KeyField is the JSON field name in the Kafka message payload used as
	// the routing suffix. For example, if KeyField is "field_id" and the
	// message contains {"field_id": "abc"}, the WebSocket topic becomes
	// WSTopicPrefix + "abc". If empty, the Kafka message key is used.
	KeyField string
}

// BridgeConfig configures the Kafka-to-WebSocket bridge.
type BridgeConfig struct {
	// Hub is the WebSocket hub to broadcast messages to.
	Hub *Hub
	// Consumer is the Kafka consumer used to subscribe to topics.
	Consumer *consumer.KafkaConsumer
	// Mappings defines how Kafka topics map to WebSocket topics.
	Mappings []TopicMapping
	// Log is the logger.
	Log p9log.Logger
}

// KafkaBridge consumes messages from Kafka topics and broadcasts them to
// matching WebSocket topic subscribers through the Hub.
type KafkaBridge struct {
	hub      *Hub
	consumer *consumer.KafkaConsumer
	mappings []TopicMapping
	log      p9log.Helper
}

// NewKafkaBridge creates a new bridge with the given configuration.
func NewKafkaBridge(cfg BridgeConfig) *KafkaBridge {
	return &KafkaBridge{
		hub:      cfg.Hub,
		consumer: cfg.Consumer,
		mappings: cfg.Mappings,
		log:      *p9log.NewHelper(p9log.With(cfg.Log, "module", "kafka-ws-bridge")),
	}
}

// Start begins consuming from all configured Kafka topics and forwarding
// messages to the WebSocket hub. It is non-blocking; each topic subscription
// runs in its own goroutine.
func (b *KafkaBridge) Start(ctx context.Context) error {
	for _, m := range b.mappings {
		mapping := m // capture for closure
		b.log.Infof("starting bridge: kafka=%s -> ws=%s*", mapping.KafkaTopic, mapping.WSTopicPrefix)

		err := b.consumer.Subscribe(ctx, mapping.KafkaTopic, func(ctx context.Context, data []byte) error {
			return b.handleMessage(mapping, data)
		})
		if err != nil {
			return err
		}
	}
	return nil
}

// handleMessage processes a single Kafka message, extracts the routing key,
// and broadcasts to the appropriate WebSocket topic.
func (b *KafkaBridge) handleMessage(mapping TopicMapping, data []byte) error {
	// Parse the payload to extract the routing key.
	var payload map[string]interface{}
	if err := json.Unmarshal(data, &payload); err != nil {
		b.log.Warnf("failed to parse Kafka message as JSON: %v", err)
		// Still try to broadcast to the prefix topic without suffix.
		return b.broadcastRaw(mapping.WSTopicPrefix, data)
	}

	// Determine the WebSocket topic suffix.
	suffix := ""
	if mapping.KeyField != "" {
		if val, ok := payload[mapping.KeyField]; ok {
			suffix = toString(val)
		}
	}

	wsTopic := mapping.WSTopicPrefix + suffix
	return b.broadcastRaw(wsTopic, data)
}

// broadcastRaw creates a broadcast message with raw JSON data and sends it
// through the hub.
func (b *KafkaBridge) broadcastRaw(topic string, data []byte) error {
	msg, err := NewBroadcastMessage(topic, json.RawMessage(data))
	if err != nil {
		return err
	}
	b.hub.BroadcastRaw(msg)
	b.log.Debugf("bridged message to ws topic: %s", topic)
	return nil
}

// DefaultMappings returns the standard topic mappings for the YieldPoint
// platform.
func DefaultMappings() []TopicMapping {
	return []TopicMapping{
		{
			KafkaTopic:    "yp.sensor.readings",
			WSTopicPrefix: TopicPrefixSensor,
			KeyField:      "field_id",
		},
		{
			KafkaTopic:    "yp.alerts",
			WSTopicPrefix: TopicPrefixAlert,
			KeyField:      "farm_id",
		},
		{
			KafkaTopic:    "yp.irrigation.events",
			WSTopicPrefix: TopicPrefixIrrigation,
			KeyField:      "field_id",
		},
	}
}

// toString converts an interface value to its string representation.
func toString(v interface{}) string {
	switch val := v.(type) {
	case string:
		return val
	case float64:
		// Avoid trailing decimals for integer-valued floats.
		if val == float64(int64(val)) {
			return fmt.Sprintf("%d", int64(val))
		}
		return fmt.Sprintf("%g", val)
	default:
		data, _ := json.Marshal(val)
		// Strip surrounding quotes if present.
		s := string(data)
		if len(s) >= 2 && s[0] == '"' && s[len(s)-1] == '"' {
			return s[1 : len(s)-1]
		}
		return s
	}
}
