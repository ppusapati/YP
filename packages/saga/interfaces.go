// Package saga provides distributed saga transaction orchestration
package saga

import (
	"context"
	"time"
)

// SagaOrchestrator coordinates the execution of all saga steps
type SagaOrchestrator interface {
	// ExecuteSaga starts a new saga execution
	ExecuteSaga(ctx context.Context, sagaType string, input *SagaExecutionInput) (*SagaExecution, error)

	// ResumeSaga resumes interrupted saga from last successful step
	ResumeSaga(ctx context.Context, sagaID string) (*SagaExecution, error)

	// GetExecution retrieves current saga execution state
	GetExecution(ctx context.Context, sagaID string) (*SagaExecution, error)

	// GetExecutionTimeline retrieves all steps executed so far
	GetExecutionTimeline(ctx context.Context, sagaID string) ([]*StepExecution, error)

	// RegisterSagaHandler registers handler for specific saga type
	RegisterSagaHandler(sagaType string, handler SagaHandler) error
}

// SagaStepExecutor executes individual saga steps by invoking service handlers via RPC
type SagaStepExecutor interface {
	// ExecuteStep executes a single saga step with timeout and retry
	ExecuteStep(ctx context.Context, sagaID string, stepNum int, stepDef *StepDefinition) (*StepResult, error)

	// GetStepStatus retrieves status of executed step
	GetStepStatus(ctx context.Context, sagaID string, stepNum int) (*StepExecution, error)
}

// SagaTimeoutHandler manages step execution timeouts, retries, and circuit breaker
type SagaTimeoutHandler interface {
	// SetupStepTimeout sets up timeout for a step
	SetupStepTimeout(ctx context.Context, sagaID string, stepNum int, timeoutSeconds int32) error

	// CancelStepTimeout cancels timeout for completed step
	CancelStepTimeout(sagaID string, stepNum int) error

	// CheckExpired checks if saga/step has expired
	CheckExpired(sagaID string, stepNum int) (bool, error)

	// GetRetryConfig returns retry configuration for step
	GetRetryConfig(sagaType string, stepNum int) (*RetryConfiguration, error)
}

// SagaEventPublisher publishes saga step events to Kafka for asynchronous processing
type SagaEventPublisher interface {
	// PublishStepStarted publishes step started event
	PublishStepStarted(ctx context.Context, sagaID string, stepNum int) error

	// PublishStepCompleted publishes step completed event with result
	PublishStepCompleted(ctx context.Context, sagaID string, stepNum int, result interface{}) error

	// PublishStepFailed publishes step failed event
	PublishStepFailed(ctx context.Context, sagaID string, stepNum int, err error) error

	// PublishStepRetrying publishes step retrying event
	PublishStepRetrying(ctx context.Context, sagaID string, stepNum int, attempt int) error

	// PublishSagaCompleted publishes saga completed event
	PublishSagaCompleted(ctx context.Context, sagaID string) error

	// PublishSagaFailed publishes saga failed event
	PublishSagaFailed(ctx context.Context, sagaID string, err error) error

	// PublishCompensationStarted publishes compensation started event
	PublishCompensationStarted(ctx context.Context, sagaID string, failedStep int) error

	// PublishCompensationCompleted publishes compensation completed event
	PublishCompensationCompleted(ctx context.Context, sagaID string) error
}

// SagaHandler defines a saga implementation with steps and handlers
type SagaHandler interface {
	// SagaType returns the saga type identifier (e.g., "SAGA-S01")
	SagaType() string

	// GetStepDefinitions returns all steps in saga
	GetStepDefinitions() []*StepDefinition

	// GetStepDefinition returns definition for specific step
	GetStepDefinition(stepNum int) *StepDefinition

	// ValidateInput validates input for saga execution
	ValidateInput(input interface{}) error
}

// RpcConnector provides abstraction for invoking service handlers via RPC
type RpcConnector interface {
	// InvokeHandler calls a service handler via RPC
	// serviceName: e.g., "sales-order", "inventory-core"
	// method: e.g., "CreateOrder", "ReserveStock"
	// input: request message (proto format)
	// returns: response message (proto format)
	InvokeHandler(ctx context.Context, serviceName string, method string, input interface{}) (interface{}, error)

	// GetServiceEndpoint returns endpoint URL for service
	GetServiceEndpoint(serviceName string) (string, error)

	// RegisterService registers service endpoint
	RegisterService(serviceName string, endpoint string) error
}

// CircuitBreaker provides fault tolerance with state management
type CircuitBreaker interface {
	// Call executes function with circuit breaker protection
	Call(fn func() error) error

	// GetStatus returns current circuit breaker status
	GetStatus() CircuitBreakerStatus

	// Reset resets circuit breaker to closed state
	Reset()
}

// SagaRepository provides data access for saga instances
type SagaRepository interface {
	// GetByID retrieves saga by ID
	GetByID(ctx context.Context, sagaID string) (*SagaExecution, error)

	// Create creates new saga execution record
	Create(ctx context.Context, saga *SagaExecution) error

	// Update updates saga execution record
	Update(ctx context.Context, saga *SagaExecution) error

	// GetBySagaID gets saga by saga ID (for recovery)
	GetBySagaID(ctx context.Context, sagaID string) (*SagaExecution, error)
}

// SagaExecutionLogRepository provides audit trail for saga execution
type SagaExecutionLogRepository interface {
	// GetBySagaID retrieves all execution log entries for a saga
	GetBySagaID(ctx context.Context, sagaID string) ([]*StepExecution, error)

	// Create creates new execution log entry
	Create(ctx context.Context, entry *StepExecution) error

	// Update updates execution log entry
	Update(ctx context.Context, entry *StepExecution) error
}

// SagaTimeoutLogRepository provides timeout tracking
type SagaTimeoutLogRepository interface {
	// Create creates timeout tracking entry
	Create(ctx context.Context, sagaID string, stepNum int, timeoutAt time.Time) error

	// GetExpiredBefore retrieves timeouts that have expired
	GetExpiredBefore(ctx context.Context, before time.Time) ([]*TimeoutTracker, error)

	// Delete deletes timeout tracking entry
	Delete(ctx context.Context, sagaID string, stepNum int) error
}

// SagaCompensationEngine handles compensation execution
type SagaCompensationEngine interface {
	// StartCompensation begins compensation process for failed saga
	StartCompensation(ctx context.Context, sagaID string, failedStepNum int, err error) error

	// ExecuteCompensation executes compensation for specific step
	ExecuteCompensation(ctx context.Context, sagaID string, stepNum int) error

	// GetCompensationStatus retrieves compensation status
	GetCompensationStatus(ctx context.Context, sagaID string) (CompensationStatus, error)
}
