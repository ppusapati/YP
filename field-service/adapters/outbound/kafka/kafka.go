// Package kafka re-exports field-service's outbound event publisher. See the
// application package for why this is an alias shim rather than a copy.
package kafka

import (
	internalkafka "p9e.in/samavaya/agriculture/field-service/internal/adapters/outbound/kafka"
)

// NewEventPublisher creates the Kafka-backed publisher.
var NewEventPublisher = internalkafka.NewEventPublisher
