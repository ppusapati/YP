// Package events re-exports traceability-service's inbound Kafka adapter. See
// the application package for why this is an alias shim rather than a copy.
package events

import (
	internalevents "p9e.in/samavaya/agriculture/traceability-service/internal/adapters/inbound/events"
)

// Topics from OTHER services that traceability-service consumes.
const (
	FarmEventTopic       = internalevents.FarmEventTopic
	FieldEventTopic      = internalevents.FieldEventTopic
	CropEventTopic       = internalevents.CropEventTopic
	IrrigationEventTopic = internalevents.IrrigationEventTopic
	YieldEventTopic      = internalevents.YieldEventTopic
)

// TraceabilityConsumer is the inbound Kafka adapter that reacts to
// cross-service domain events.
type TraceabilityConsumer = internalevents.TraceabilityConsumer

// NewTraceabilityConsumer creates the consumer.
var NewTraceabilityConsumer = internalevents.NewTraceabilityConsumer
