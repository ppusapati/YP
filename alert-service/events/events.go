// Package events re-exports alert-service's inbound Kafka adapter for callers
// outside this service. See the repositories package for why this is an alias
// shim rather than a second copy.
package events

import (
	internalevents "p9e.in/samavaya/agriculture/alert-service/internal/events"
)

// Topics this consumer subscribes to.
const (
	WeatherEventTopic = internalevents.WeatherEventTopic
	SensorEventTopic  = internalevents.SensorEventTopic
	PestEventTopic    = internalevents.PestEventTopic
)

// AlertConsumer turns alert events from other services into stored alerts.
type AlertConsumer = internalevents.AlertConsumer

// NewAlertConsumer creates the consumer.
var NewAlertConsumer = internalevents.NewAlertConsumer
