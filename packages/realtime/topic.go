package realtime

import (
	"errors"
	"strings"
)

// Package realtime holds what the WebSocket hub and the SSE broker have in
// common, which is the part they both got wrong: tenant scoping for topics.
//
// The hub had none. A client subscribed by sending a topic string and the hub
// stored it verbatim; a broadcast went to everyone subscribed to that string.
// Client carried a TenantID and nothing read it. So an authenticated user in
// one tenant who named another tenant's field — `sensor.<field-id>` — received
// that field's live readings, irrigation events and alerts, on a platform where
// every equivalent read through the database is stopped by row-level security.
//
// Identifiers being ULIDs is not what was protecting this. Ids leak through
// URLs, exports and shared reports, and "hard to guess" is not an access
// control; the rest of this platform does not rely on it and neither does this.
//
// The SSE broker was the same shape and one step worse: it took its topics
// from a query parameter, and an event published with no topic at all was
// delivered to every subscriber on the process regardless of tenant.
//
// Topics are now qualified by tenant — `t/<tenant>/sensor.<field>` — and the
// qualification is structural rather than conventional: a subscriber can only
// subscribe within its own tenant, and both transports check again on
// delivery.

// TopicTenantPrefix marks a tenant-qualified topic.
const TopicTenantPrefix = "t/"

// Errors returned when a topic cannot be scoped.
var (
	// ErrTopicOtherTenant means the client asked for a topic belonging to a
	// different tenant.
	ErrTopicOtherTenant = errors.New("realtime: topic belongs to another tenant")
	// ErrNoTenant means the connection carries no tenant, so no topic can be
	// scoped to it. Refused rather than treated as "all tenants".
	ErrNoTenant = errors.New("realtime: connection has no tenant")
	// ErrEmptyTopic means the topic name was blank.
	ErrEmptyTopic = errors.New("realtime: topic is required")
)

// TenantTopic builds the qualified topic for a name within a tenant.
//
// Publishers must use this. A message on an unqualified topic reaches nobody —
// see Hub.handleBroadcast and Broker.deliver — which is a loud failure rather
// than the quiet cross-tenant delivery it replaced.
func TenantTopic(tenantID, name string) string {
	return TopicTenantPrefix + tenantID + "/" + name
}

// SplitTopic separates a qualified topic into its tenant and name.
//
// ok is false for an unqualified topic, which callers must treat as unusable
// rather than as belonging to everyone.
func SplitTopic(topic string) (tenantID, name string, ok bool) {
	if !strings.HasPrefix(topic, TopicTenantPrefix) {
		return "", topic, false
	}
	rest := topic[len(TopicTenantPrefix):]
	slash := strings.Index(rest, "/")
	if slash <= 0 || slash == len(rest)-1 {
		// "t//name", "t/tenant/" and "t/tenant" are all malformed. Treated as
		// unqualified, so they are refused rather than matching a tenant whose
		// id happens to be empty.
		return "", topic, false
	}
	return rest[:slash], rest[slash+1:], true
}

// ScopeTopic resolves the topic a client may actually subscribe to.
//
// A bare name is qualified with the client's own tenant, so an existing client
// asking for `sensor.field-123` transparently gets its own tenant's stream and
// has no way to express another's. A qualified topic is accepted only when its
// tenant matches.
func ScopeTopic(clientTenantID, requested string) (string, error) {
	if requested == "" {
		return "", ErrEmptyTopic
	}
	if clientTenantID == "" {
		return "", ErrNoTenant
	}

	if tenantID, name, ok := SplitTopic(requested); ok {
		if tenantID != clientTenantID {
			return "", ErrTopicOtherTenant
		}
		return TenantTopic(tenantID, name), nil
	}

	// Unqualified, including the malformed forms SplitTopic rejects. Those are
	// scoped as a literal name rather than refused: a topic that happens to
	// contain a slash is not an attack, and it lands inside the caller's own
	// tenant either way.
	return TenantTopic(clientTenantID, requested), nil
}

// TopicBelongsTo reports whether a qualified topic belongs to a tenant.
//
// False for an unqualified topic: a topic with no tenant belongs to no one, and
// answering true would restore exactly the behaviour this replaces.
func TopicBelongsTo(topic, tenantID string) bool {
	owner, _, ok := SplitTopic(topic)
	return ok && owner == tenantID && tenantID != ""
}
