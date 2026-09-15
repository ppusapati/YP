package websocket

import "p9e.in/samavaya/packages/realtime"

// Tenant scoping lives in packages/realtime, because the SSE broker needs the
// same rules and two copies of an access control is one copy too many. These
// aliases keep it reachable under the name callers already use.
const TopicTenantPrefix = realtime.TopicTenantPrefix

// Errors returned when a topic cannot be scoped.
var (
	ErrTopicOtherTenant = realtime.ErrTopicOtherTenant
	ErrNoTenant         = realtime.ErrNoTenant
	ErrEmptyTopic       = realtime.ErrEmptyTopic
)

// TenantTopic builds the qualified topic for a name within a tenant.
var TenantTopic = realtime.TenantTopic

// SplitTopic separates a qualified topic into its tenant and name.
var SplitTopic = realtime.SplitTopic

// ScopeTopic resolves the topic a client may actually subscribe to.
var ScopeTopic = realtime.ScopeTopic

// TopicBelongsTo reports whether a qualified topic belongs to a tenant.
var TopicBelongsTo = realtime.TopicBelongsTo
