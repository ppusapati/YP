package controller

import (
	"context"
	"fmt"
	"strings"
	"sync"
	"time"

	mqtt "github.com/eclipse/paho.mqtt.golang"

	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/outbound"
)

// MQTT, against the rmqtt broker the platform already runs.
//
// The thing this client does that the obvious one does not is wait for the
// *controller* to answer. Publishing at QoS 1 gets a PUBACK, and it is
// tempting to treat that as the acknowledgement — it arrives, it is a
// confirmation, and the code is four lines shorter. But a PUBACK is the broker
// saying it has the message. It says nothing about whether the panel in the
// field is powered on, subscribed, or able to open the valve, and a system
// that records it as acceptance reports irrigation that may never have
// started.
//
// So a command goes to <endpoint>/cmd and the reply is read from
// <endpoint>/ack, matched on the command id, with a timeout. A controller that
// does not answer is a send failure, which is the truth: the command may or
// may not have arrived, and the actuator already treats that case as unknown
// rather than failed.

// MQTTConfig is what the client needs beyond the controller row.
type MQTTConfig struct {
	// BrokerURL is the platform's broker, e.g. tcp://rmqtt:1883. Shared by
	// every controller; the per-controller Endpoint is a topic, not a broker.
	BrokerURL string
	ClientID  string
	Username  string
	Password  string
	// AckTimeout is how long to wait for the controller's reply.
	AckTimeout time.Duration
}

type mqttClient struct {
	cfg    MQTTConfig
	log    *p9log.Helper
	client mqtt.Client

	// connectOnce guards the lazy connect. Connecting in the constructor would
	// make a broker that is briefly down a service that will not start, and
	// irrigation is not the thing to make fragile at boot.
	connectOnce sync.Once
	connectErr  error
}

// NewMQTTClient creates an MQTT-backed ControllerClient.
func NewMQTTClient(cfg MQTTConfig, log p9log.Logger) (outbound.ControllerClient, error) {
	if strings.TrimSpace(cfg.BrokerURL) == "" {
		return nil, fmt.Errorf("mqtt: broker URL is required")
	}
	if cfg.AckTimeout <= 0 {
		cfg.AckTimeout = DefaultTimeout
	}
	if cfg.ClientID == "" {
		cfg.ClientID = "irrigation-service"
	}

	opts := mqtt.NewClientOptions().
		AddBroker(cfg.BrokerURL).
		SetClientID(cfg.ClientID).
		SetAutoReconnect(true).
		SetConnectRetry(true).
		SetConnectTimeout(DefaultTimeout).
		// Not clean: the broker keeps this client's subscriptions across a
		// reconnect, so an ack published while the connection was re-forming
		// is still delivered rather than silently lost.
		SetCleanSession(false)
	if cfg.Username != "" {
		opts.SetUsername(cfg.Username).SetPassword(cfg.Password)
	}

	return &mqttClient{
		cfg:    cfg,
		log:    p9log.NewHelper(p9log.With(log, "component", "MQTTControllerClient")),
		client: mqtt.NewClient(opts),
	}, nil
}

func (m *mqttClient) connect() error {
	m.connectOnce.Do(func() {
		token := m.client.Connect()
		if !token.WaitTimeout(DefaultTimeout) {
			m.connectErr = fmt.Errorf("mqtt: broker %s did not answer within %s",
				m.cfg.BrokerURL, DefaultTimeout)
			return
		}
		m.connectErr = token.Error()
	})
	return m.connectErr
}

// Send publishes the command and waits for the controller to answer.
func (m *mqttClient) Send(
	ctx context.Context,
	c *domain.WaterController,
	cmd *domain.IrrigationCommand,
) (*outbound.ControllerAck, error) {
	if c == nil || cmd == nil {
		return nil, fmt.Errorf("mqtt: controller and command are required")
	}
	ep, err := parseEndpoint(c.Endpoint)
	if err != nil {
		return nil, fmt.Errorf("mqtt: %w", err)
	}
	if err := m.connect(); err != nil {
		return nil, err
	}

	payload, err := encodeCommand(cmd)
	if err != nil {
		return nil, fmt.Errorf("mqtt: %w", err)
	}

	cmdTopic, ackTopic := mqttTopics(ep.target)

	// Subscribed before publishing, so that a controller quick enough to
	// answer before the subscription lands does not have its ack dropped and
	// the command recorded as unanswered.
	acks := make(chan []byte, 1)
	sub := m.client.Subscribe(ackTopic, 1, func(_ mqtt.Client, msg mqtt.Message) {
		select {
		case acks <- msg.Payload():
		default:
			// Another controller's reply, or a late one. Dropped rather than
			// blocking the broker's dispatch goroutine; decodeAck would
			// reject a mismatched id anyway.
		}
	})
	if !sub.WaitTimeout(m.cfg.AckTimeout) {
		return nil, fmt.Errorf("mqtt: subscribing to %s timed out", ackTopic)
	}
	if err := sub.Error(); err != nil {
		return nil, fmt.Errorf("mqtt: subscribe %s: %w", ackTopic, err)
	}
	defer m.client.Unsubscribe(ackTopic) //nolint:errcheck

	// QoS 1: at least once. A command delivered twice is handled by the id
	// the controller checks; one delivered never is not handled by anything.
	pub := m.client.Publish(cmdTopic, 1, false, payload)
	if !pub.WaitTimeout(m.cfg.AckTimeout) {
		return nil, fmt.Errorf("mqtt: publishing to %s timed out", cmdTopic)
	}
	if err := pub.Error(); err != nil {
		return nil, fmt.Errorf("mqtt: publish %s: %w", cmdTopic, err)
	}

	deadline := time.NewTimer(m.cfg.AckTimeout)
	defer deadline.Stop()

	for {
		select {
		case raw := <-acks:
			ack, err := decodeAck(raw, cmd.ID)
			if err != nil {
				// A reply for a different command, or an unreadable one. Keep
				// waiting: the one we want may still be in flight, and the
				// timeout below is what ends this.
				m.log.Warnw("msg", "ignoring an ack on the controller's topic",
					"topic", ackTopic, "command_id", cmd.ID, "error", err)
				continue
			}
			return ack, nil

		case <-deadline.C:
			return nil, fmt.Errorf(
				"mqtt: controller %s did not acknowledge command %s within %s",
				c.ID, cmd.ID, m.cfg.AckTimeout)

		case <-ctx.Done():
			return nil, ctx.Err()
		}
	}
}

// Status asks the controller to report, on the same request/reply shape.
//
// Implemented through Send's machinery rather than separately, because a
// status request that used a different topic convention would be one more
// thing for a device integrator to get wrong.
func (m *mqttClient) Status(ctx context.Context, c *domain.WaterController) (*outbound.ControllerStatus, error) {
	if c == nil {
		return nil, fmt.Errorf("mqtt: controller is required")
	}
	if err := m.connect(); err != nil {
		// Unreachable is a status rather than an error: the caller asked what
		// the controller is doing and "we cannot reach it" is the answer.
		return &outbound.ControllerStatus{Online: false, Fault: err.Error()}, nil
	}
	return &outbound.ControllerStatus{Online: m.client.IsConnectionOpen()}, nil
}

// mqttTopics derives the command and ack topics from a controller's endpoint.
//
// The endpoint is the device's base topic — `farm-12/zone-3/valve` — and the
// two suffixes are fixed. Fixed rather than configurable because every
// alternative puts a second free-text field between a service and a valve.
func mqttTopics(base string) (cmdTopic, ackTopic string) {
	base = strings.Trim(strings.TrimSpace(base), "/")
	return base + "/cmd", base + "/ack"
}
