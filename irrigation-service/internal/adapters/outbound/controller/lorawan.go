package controller

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/base64"
	"encoding/binary"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/outbound"
)

// LoRaWAN, through a network server's downlink queue.
//
// There is no socket to a LoRaWAN device. The gateway network holds it, and a
// downlink is handed to the network server — ChirpStack here — which keeps it
// until the device next transmits. A class A device, which is what runs on a
// battery in a field, opens a receive window for one second after its own
// uplink and is deaf the rest of the time. Between uplinks that is typically
// minutes and by configuration can be an hour.
//
// So this client cannot report that a valve opened, and the interesting part
// of it is that it does not pretend to. The network server's 200 means the
// downlink is queued; ControllerAck.Queued carries that distinction up to the
// actuator, which records "queued for delivery; the controller has not
// confirmed it" rather than an acceptance. An operator reading the command log
// afterwards can tell the difference between water that went on and an
// instruction that was still waiting in a queue.

// LoRaWANConfig points at the network server.
type LoRaWANConfig struct {
	// BaseURL is the network server's API root, e.g. http://chirpstack:8090.
	BaseURL string
	// APIToken authenticates to it. Sent as a Bearer token.
	APIToken string
	// FPort is the application port downlinks are sent on. Devices filter on
	// it, so it has to match what the firmware expects.
	FPort int
	// Confirmed asks the network server for a confirmed downlink, which makes
	// the device acknowledge receipt at the MAC layer.
	//
	// On by default for irrigation. It costs airtime and a retransmission
	// budget, and for a command that opens a valve that is the right trade:
	// the alternative is not knowing whether a stop was heard.
	Confirmed bool
	Timeout   time.Duration
}

type lorawanClient struct {
	cfg  LoRaWANConfig
	http *http.Client
}

// NewLoRaWANClient creates a network-server-backed ControllerClient.
//
// The endpoint is the device's EUI, optionally with an f_port override:
// `0004a30b001c0530?f_port=10`.
func NewLoRaWANClient(cfg LoRaWANConfig) (outbound.ControllerClient, error) {
	if strings.TrimSpace(cfg.BaseURL) == "" {
		return nil, fmt.Errorf("lorawan: network server URL is required")
	}
	if strings.TrimSpace(cfg.APIToken) == "" {
		return nil, fmt.Errorf("lorawan: an API token is required to enqueue downlinks")
	}
	if cfg.FPort <= 0 {
		cfg.FPort = 10
	}
	if cfg.Timeout <= 0 {
		cfg.Timeout = DefaultTimeout
	}
	return &lorawanClient{
		cfg:  cfg,
		http: &http.Client{Timeout: cfg.Timeout},
	}, nil
}

type lorawanQueueItem struct {
	DevEUI    string `json:"devEui"`
	Confirmed bool   `json:"confirmed"`
	FPort     int    `json:"fPort"`
	Data      string `json:"data"`
}

type lorawanQueueRequest struct {
	QueueItem lorawanQueueItem `json:"queueItem"`
}

// Send enqueues the command as a downlink.
//
// Returns Queued rather than Accepted. See the package comment: the device has
// not heard anything yet and may not for some minutes.
func (l *lorawanClient) Send(
	ctx context.Context,
	c *domain.WaterController,
	cmd *domain.IrrigationCommand,
) (*outbound.ControllerAck, error) {
	if c == nil || cmd == nil {
		return nil, fmt.Errorf("lorawan: controller and command are required")
	}
	ep, err := parseEndpoint(c.Endpoint)
	if err != nil {
		return nil, fmt.Errorf("lorawan: %w", err)
	}
	fport, err := ep.intOpt("f_port", l.cfg.FPort)
	if err != nil {
		return nil, fmt.Errorf("lorawan: %w", err)
	}

	payload, err := encodeLoRaWANCommand(cmd)
	if err != nil {
		return nil, fmt.Errorf("lorawan: %w", err)
	}

	body, err := json.Marshal(lorawanQueueRequest{QueueItem: lorawanQueueItem{
		DevEUI:    ep.target,
		Confirmed: l.cfg.Confirmed,
		FPort:     fport,
		Data:      base64.StdEncoding.EncodeToString(payload),
	}})
	if err != nil {
		return nil, fmt.Errorf("lorawan: %w", err)
	}

	endpointURL := fmt.Sprintf("%s/api/devices/%s/queue",
		strings.TrimRight(l.cfg.BaseURL, "/"), ep.target)
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, endpointURL, bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("lorawan: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+l.cfg.APIToken)

	resp, err := l.http.Do(req)
	if err != nil {
		return nil, fmt.Errorf("lorawan: enqueueing a downlink for %s: %w", ep.target, err)
	}
	defer resp.Body.Close() //nolint:errcheck

	// Read a bounded amount: an error page from a misconfigured proxy should
	// not be pulled into memory in full.
	raw, _ := io.ReadAll(io.LimitReader(resp.Body, 8<<10))

	switch {
	case resp.StatusCode == http.StatusOK || resp.StatusCode == http.StatusCreated:
		return &outbound.ControllerAck{
			Accepted: true,
			Queued:   true,
			Reason:   "queued at the network server for the device's next receive window",
		}, nil

	case resp.StatusCode == http.StatusNotFound:
		// The network server does not know this device. A refusal, not a
		// transport fault: retrying will not conjure it.
		return &outbound.ControllerAck{
			Accepted: false,
			Reason:   fmt.Sprintf("the network server has no device with EUI %s", ep.target),
		}, nil

	case resp.StatusCode >= 400 && resp.StatusCode < 500:
		return &outbound.ControllerAck{
			Accepted: false,
			Reason: fmt.Sprintf("the network server rejected the downlink: %s",
				summarise(raw, resp.Status)),
		}, nil

	default:
		// 5xx is the network server having a problem, which says nothing about
		// the command. Returned as an error so the actuator records the send
		// as unknown rather than as a refusal.
		return nil, fmt.Errorf("lorawan: network server returned %s: %s",
			resp.Status, summarise(raw, resp.Status))
	}
}

// Status reports what the network server knows, which is not much.
//
// A LoRaWAN device's valve position is not queryable: asking it would itself
// be a downlink, answered on the device's own schedule. What can be said is
// whether the network server is reachable, and Running is left false rather
// than guessed — the caller reads it as "not known to be running", and
// guessing would make a stuck valve invisible.
func (l *lorawanClient) Status(ctx context.Context, c *domain.WaterController) (*outbound.ControllerStatus, error) {
	if c == nil {
		return nil, fmt.Errorf("lorawan: controller is required")
	}
	ep, err := parseEndpoint(c.Endpoint)
	if err != nil {
		return nil, fmt.Errorf("lorawan: %w", err)
	}

	endpointURL := fmt.Sprintf("%s/api/devices/%s",
		strings.TrimRight(l.cfg.BaseURL, "/"), ep.target)
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, endpointURL, nil)
	if err != nil {
		return nil, fmt.Errorf("lorawan: %w", err)
	}
	req.Header.Set("Authorization", "Bearer "+l.cfg.APIToken)

	resp, err := l.http.Do(req)
	if err != nil {
		return &outbound.ControllerStatus{Online: false, Fault: err.Error()}, nil
	}
	defer resp.Body.Close() //nolint:errcheck
	_, _ = io.Copy(io.Discard, io.LimitReader(resp.Body, 8<<10))

	if resp.StatusCode != http.StatusOK {
		return &outbound.ControllerStatus{
			Online: false,
			Fault:  fmt.Sprintf("the network server returned %s for this device", resp.Status),
		}, nil
	}
	return &outbound.ControllerStatus{Online: true}, nil
}

// maxLoRaWANPayload is the downlink budget at the slowest European data rate.
//
// The floor rather than the typical case, because a device that has drifted to
// SF12 at the edge of a field is exactly the one whose stop command must still
// fit.
const maxLoRaWANPayload = 51

// loRaWANCommandBytes is the fixed size of a downlink command.
const loRaWANCommandBytes = 12

// loRaWANFormatVersion is byte 0, so firmware can reject a layout it predates
// rather than reading a duration out of the wrong offset.
const loRaWANFormatVersion byte = 1

const (
	loRaWANKindStart byte = 1
	loRaWANKindStop  byte = 2
)

// encodeLoRaWANCommand packs a command into twelve bytes.
//
//	[0]     format version
//	[1]     kind: 1 start, 2 stop
//	[2:4]   duration in minutes, big-endian uint16
//	[4:12]  idempotency token
//
// Binary rather than the JSON the other transports carry, and not as an
// optimisation. The JSON command runs to about 140 bytes — two 26-character
// ULIDs and a timestamp — against a 51-byte downlink at SF12, so every single
// command to a device at the edge of a field would have been rejected by the
// network server. A packed frame is what LoRaWAN firmware expects anyway.
//
// The token is the first eight bytes of the command id's SHA-256 rather than
// the id itself, which does not fit. It is deterministic, so a retry of the
// same command carries the same token and the device recognises the repeat
// instead of opening the valve twice — which is the whole job of the id on a
// link this lossy.
func encodeLoRaWANCommand(cmd *domain.IrrigationCommand) ([]byte, error) {
	if cmd == nil {
		return nil, fmt.Errorf("command is required")
	}

	var kind byte
	switch cmd.Kind {
	case domain.CommandStart:
		kind = loRaWANKindStart
	case domain.CommandStop:
		kind = loRaWANKindStop
	default:
		return nil, fmt.Errorf("unknown command kind %q", cmd.Kind)
	}

	// A duration is bounded by MaxRunMinutes long before it reaches here, so
	// this cannot legitimately overflow — but it is two bytes on a wire and a
	// silent wrap would turn a four-hour set into a two-minute one, or worse
	// the other way.
	if cmd.DurationMinutes < 0 || int(cmd.DurationMinutes) > 0xFFFF {
		return nil, fmt.Errorf("duration of %d minutes does not fit a downlink", cmd.DurationMinutes)
	}

	out := make([]byte, loRaWANCommandBytes)
	out[0] = loRaWANFormatVersion
	out[1] = kind
	binary.BigEndian.PutUint16(out[2:4], uint16(cmd.DurationMinutes))
	sum := sha256.Sum256([]byte(cmd.ID))
	copy(out[4:], sum[:8])
	return out, nil
}

// summarise turns a response body into something a log line can carry.
func summarise(raw []byte, fallback string) string {
	text := strings.TrimSpace(string(raw))
	if text == "" {
		return fallback
	}
	if len(text) > 200 {
		return text[:200] + "…"
	}
	return text
}
