// Package events re-exports field-service's inbound Kafka adapter. See the
// application package for why this is an alias shim rather than a copy.
package events

import (
	internalevents "p9e.in/samavaya/agriculture/field-service/internal/adapters/inbound/events"
)

// Topics from OTHER services that field-service consumes.
const (
	FarmEventTopic   = internalevents.FarmEventTopic
	CropEventTopic   = internalevents.CropEventTopic
	SensorEventTopic = internalevents.SensorEventTopic
)

// FieldConsumer is the inbound Kafka adapter that reacts to cross-service
// domain events.
type FieldConsumer = internalevents.FieldConsumer

// NewFieldConsumer creates the consumer.
var NewFieldConsumer = internalevents.NewFieldConsumer
