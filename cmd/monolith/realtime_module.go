package main

import (
	"context"
	"encoding/json"
	"net/http"
	"time"

	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/realtime"
	"p9e.in/samavaya/packages/sse"
	"p9e.in/samavaya/packages/websocket"
)

// The real-time transport, and the two features that ride on it.
//
// The hub, the SSE broker, the Kafka bridge and the routing middleware were all
// written and **nothing mounted any of them**. No service constructed a Hub, no
// mux served `/ws`, and the gateway had no route to one. So "WebSocket gateway
// for real-time sensor streaming" and "SSE for alert notifications" were both
// complete as code and unreachable as product: a client that connected got a
// 404 from the catch-all.
//
// This is what serves them, and what the field map and collaborative inspection
// are built on.

// realtimeModule holds the live state the monolith keeps for real-time
// features. Unlike the ConnectRPC modules, this one is returned rather than
// only registered, because publishers elsewhere in the process need the hub.
type realtimeModule struct {
	Hub      *websocket.Hub
	Broker   *sse.Broker
	Presence *realtime.Presence
	Sessions *realtime.SessionStore

	log p9log.Helper
}

// presenceSweepInterval is how often expired members are swept.
//
// A third of the TTL, so a departure is noticed within about half a minute
// without the sweep becoming the thing that wakes the process up.
const presenceSweepInterval = realtime.DefaultPresenceTTL / 3

// registerRealtimeModule mounts /ws and /events and starts the hub.
//
// Returns the module so the caller can stop it, and so publishers — the Kafka
// bridge, the inspection service — can broadcast through the same hub the
// clients are connected to.
func registerRealtimeModule(ctx context.Context, mux *http.ServeMux, infra *sharedInfra) *realtimeModule {
	log := p9log.NewHelper(p9log.With(infra.logger, "module", "realtime"))

	hub := websocket.NewHub(infra.logger)
	broker := sse.NewBroker(infra.logger)

	m := &realtimeModule{
		Hub:      hub,
		Broker:   broker,
		Presence: realtime.NewPresence(),
		Sessions: realtime.NewSessionStore(),
		log:      *log,
	}

	go hub.Run(ctx)
	go broker.Run(ctx)
	go m.sweepPresence(ctx)

	// Both handlers authenticate for themselves. The ConnectRPC interceptor
	// chain does not run here: a WebSocket upgrade is not an RPC, and an SSE
	// stream is a long-lived GET rather than a unary call.
	auth := websocket.DefaultAuthenticator()

	mux.Handle("/ws", websocket.NewHandler(websocket.HandlerConfig{
		Hub:  hub,
		Auth: auth,
		Log:  infra.logger,
	}))

	mux.Handle("/events", sse.NewHandler(sse.HandlerConfig{
		Broker: broker,
		Log:    infra.logger,
	}))

	log.Infow("msg", "real-time transport mounted", "paths", "/ws,/events")
	return m
}

// sweepPresence drops members that stopped reporting and tells their rooms.
//
// Expiry is applied on read as well, so a missed sweep never shows a stale
// member — this is what lets the people still in the room be *told* that
// someone has gone, rather than watching a list quietly stop being true.
func (m *realtimeModule) sweepPresence(ctx context.Context) {
	ticker := time.NewTicker(presenceSweepInterval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			for _, topic := range m.Presence.Sweep() {
				m.broadcastPresence(topic)
			}
		}
	}
}

// broadcastPresence sends a room its current member list.
func (m *realtimeModule) broadcastPresence(topic string) {
	members := m.Presence.Members(topic)
	if err := m.Hub.Broadcast(topic, realtime.NewEnvelope(realtime.EventPresenceUpdate, members)); err != nil {
		m.log.Errorw("msg", "could not broadcast presence", "topic", topic, "error", err)
	}
}

// PublishPosition broadcasts one machine's position to a field's map watchers,
// and refreshes its presence so the machine appears in the room's member list
// for as long as it keeps reporting.
//
// Returns an error for a position that cannot be drawn, rather than
// broadcasting it: a fix at Null Island or one from two hours ago is worse
// than no dot, because the map shows it with the same confidence as a good one.
func (m *realtimeModule) PublishPosition(p realtime.MachinePosition) error {
	if err := p.Validate(time.Now()); err != nil {
		return err
	}

	topic := p.Topic()
	if _, err := m.Presence.Join(topic, p.AsMember()); err != nil {
		return err
	}

	return m.Hub.Broadcast(topic, realtime.NewEnvelope(realtime.EventMachineMoved, p))
}

// PublishOverlay tells a field's map watchers that new imagery is available.
func (m *realtimeModule) PublishOverlay(o realtime.ImageryOverlay) error {
	if err := o.Validate(); err != nil {
		return err
	}
	return m.Hub.Broadcast(o.Topic(), realtime.NewEnvelope(realtime.EventOverlayReady, o))
}

// JoinInspection puts an editor into a collaborative session and returns the
// snapshot they should start from.
//
// The snapshot comes from the live session rather than from the database,
// because an editor whose page loaded a minute ago would otherwise begin from
// state that is already stale and immediately lose their first edit.
func (m *realtimeModule) JoinInspection(
	tenantID, inspectionID string,
	editor realtime.Member,
	persisted map[string]interface{},
) (map[string]realtime.FieldValue, []realtime.Member, error) {
	session, err := m.Sessions.Session(tenantID, inspectionID, persisted)
	if err != nil {
		return nil, nil, err
	}

	members, err := m.Presence.Join(session.Topic(), editor)
	if err != nil {
		return nil, nil, err
	}

	m.broadcastPresence(session.Topic())
	return session.Snapshot(), members, nil
}

// ApplyInspectionEdit applies one edit and tells the room.
//
// A refused edit is broadcast to nobody and returned to its author alone: the
// other editors' state did not change, and telling them about a change that
// did not happen would make them redraw a field they are typing in.
func (m *realtimeModule) ApplyInspectionEdit(edit realtime.Edit) (realtime.EditResult, error) {
	session, err := m.Sessions.Session(edit.TenantID, edit.InspectionID, nil)
	if err != nil {
		return realtime.EditResult{}, err
	}

	result, err := session.Apply(edit)
	if err != nil || !result.Accepted {
		return result, err
	}

	if err := m.Hub.Broadcast(
		session.Topic(),
		realtime.NewEnvelope(realtime.EventEditApplied, result),
	); err != nil {
		m.log.Errorw("msg", "could not broadcast edit", "topic", session.Topic(), "error", err)
	}
	return result, nil
}

// LeaveInspection removes an editor and tells the room.
func (m *realtimeModule) LeaveInspection(tenantID, inspectionID, editorID string) {
	topic := realtime.TenantTopic(tenantID, realtime.InspectionTopic(inspectionID))
	remaining := m.Presence.Leave(topic, editorID)
	m.broadcastPresence(topic)

	// The last editor out closes the session. Keeping it would hold every
	// inspection ever opened in memory for the life of the process.
	if len(remaining) == 0 {
		m.Sessions.Close(tenantID, inspectionID)
	}
}

// Disconnected removes a client from every room it had joined.
//
// Without this a dropped client holds its place in each one until its presence
// expires, and the rooms show an editor who is not there.
func (m *realtimeModule) Disconnected(memberID string) {
	for _, topic := range m.Presence.LeaveAll(memberID) {
		m.broadcastPresence(topic)
	}
}

// decodeEnvelope is a small helper for handlers that receive a client payload.
func decodeEnvelope(raw json.RawMessage, into interface{}) error {
	if len(raw) == 0 {
		return realtime.ErrEmptyTopic
	}
	return json.Unmarshal(raw, into)
}

// FieldMapBridgeMappings routes the Kafka topics that feed a field map.
//
// The bridge qualifies each WebSocket topic with the tenant it reads from the
// payload and drops a message that carries none — so a producer that loses the
// tenant gets silence rather than a cross-tenant broadcast.
//
// `field_id` is the routing key for both: a map subscriber has one field open,
// and the id in the payload is what decides which map a position lands on.
func FieldMapBridgeMappings() []websocket.TopicMapping {
	return []websocket.TopicMapping{
		{
			// Telematics from tractors, sprayers and harvesters, and position
			// reports from the mobile app while a scout walks a field.
			KafkaTopic:    "yp.machine.positions",
			WSTopicPrefix: realtime.TopicPrefixFieldMap,
			KeyField:      "field_id",
		},
		{
			// Emitted when satellite-tile finishes a tileset or an ingested
			// drone orthomosaic becomes servable, so a map that is already
			// open picks the layer up without polling for it.
			KafkaTopic:    "yp.imagery.overlays",
			WSTopicPrefix: realtime.TopicPrefixFieldMap,
			KeyField:      "field_id",
		},
	}
}
