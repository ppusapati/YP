// Package saga provides configuration for saga engine
package saga

import (
	"time"
)

// DefaultConfig provides default saga engine configuration
type DefaultConfig struct {
	// Timeout configuration
	DefaultTimeoutSeconds   int32         = 60
	MaxTimeoutSeconds       int32         = 3600

	// Retry configuration
	DefaultMaxRetries       int32         = 3
	DefaultInitialBackoff   time.Duration = 1 * time.Second
	DefaultMaxBackoff       time.Duration = 30 * time.Second
	BackoffMultiplier       float64       = 2.0
	JitterFraction          float64       = 0.1

	// Circuit breaker configuration
	CircuitBreakerThreshold int32         = 5
	CircuitBreakerResetMs   int32         = 60000 // 1 minute

	// Kafka configuration
	KafkaTopic              string        = "saga-events"
	KafkaPartitions         int32         = 5

	// Database configuration
	SagaExecutionLogTable   string        = "saga_execution_log"
	SagaTimeoutTrackerTable string        = "saga_timeout_tracker"
	SagaCompensationLogTable string       = "saga_compensation_log"
}

// Config holds runtime configuration for saga engine
type Config struct {
	DefaultTimeoutSeconds   int32
	MaxTimeoutSeconds       int32
	DefaultMaxRetries       int32
	DefaultInitialBackoff   time.Duration
	DefaultMaxBackoff       time.Duration
	BackoffMultiplier       float64
	JitterFraction          float64
	CircuitBreakerThreshold int32
	CircuitBreakerResetMs   int32
	KafkaTopic              string
	KafkaPartitions         int32
	SagaExecutionLogTable   string
	SagaTimeoutTrackerTable string
	SagaCompensationLogTable string
}

// NewDefaultConfig returns default configuration
func NewDefaultConfig() *Config {
	return &Config{
		DefaultTimeoutSeconds:   60,
		MaxTimeoutSeconds:       3600,
		DefaultMaxRetries:       3,
		DefaultInitialBackoff:   1 * time.Second,
		DefaultMaxBackoff:       30 * time.Second,
		BackoffMultiplier:       2.0,
		JitterFraction:          0.1,
		CircuitBreakerThreshold: 5,
		CircuitBreakerResetMs:   60000,
		KafkaTopic:              "saga-events",
		KafkaPartitions:         5,
		SagaExecutionLogTable:   "saga_execution_log",
		SagaTimeoutTrackerTable: "saga_timeout_tracker",
		SagaCompensationLogTable: "saga_compensation_log",
	}
}

// StepRetryConfig defines retry behavior for a step
const (
	// Step retry strategies (from SAGA PATTERN CATALOG)

	// Order-to-Cash: 3 retries with exponential backoff (1s, 2s, 4s)
	OrderToCashRetries = 3
	OrderToCashInitialBackoffMs = 1000
	OrderToCashMaxBackoffMs = 30000

	// Procure-to-Pay: varies per step (3-5 retries)
	ProcureToPayRetries = 3
	ProcureToPayInitialBackoffMs = 1000

	// GST operations: 5 retries with extended backoff
	GSTRetries = 5
	GSTInitialBackoffMs = 1000
	GSTMaxBackoffMs = 120000 // 2 minutes
)

// Event types (from SAGA PATTERN CATALOG)
const (
	EventTopicSagaSteps = "saga-steps"
	EventTopicCompensation = "saga-compensation"
	EventTopicErrors = "saga-errors"
)
