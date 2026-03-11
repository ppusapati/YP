// Package models contains data structures for saga execution
package models

import (
	"time"
)

// SagaExecution represents a running saga instance
type SagaExecution struct {
	ID                 string                          // ULID
	TenantID           string
	CompanyID          string
	BranchID           string
	SagaType           string                          // e.g., "SAGA-S01", "SAGA-P01"
	Status             SagaExecutionStatus             // Running, Completed, Failed, Compensating, Compensated
	CurrentStep        int32
	TotalSteps         int32
	StartedAt          *time.Time
	CompletedAt        *time.Time
	TimeoutSeconds     int32
	ExpiresAt          *time.Time
	SagaDefinition     []byte                          // JSON: saga step definitions
	ExecutionState     map[string]interface{}          // Step results stored here
	ErrorMessage       string
	ErrorCode          string
	CompensationStatus CompensationStatus              // if status == Compensating
	Metadata           map[string]string
	CreatedAt          *time.Time
	UpdatedAt          *time.Time
}

// SagaExecutionStatus represents saga execution status
type SagaExecutionStatus string

const (
	SagaStatusNotStarted  SagaExecutionStatus = "NOT_STARTED"
	SagaStatusRunning     SagaExecutionStatus = "RUNNING"
	SagaStatusCompleted   SagaExecutionStatus = "COMPLETED"
	SagaStatusFailed      SagaExecutionStatus = "FAILED"
	SagaStatusCompensating SagaExecutionStatus = "COMPENSATING"
	SagaStatusCompensated SagaExecutionStatus = "COMPENSATED"
	SagaStatusAborted     SagaExecutionStatus = "ABORTED"
)

// CompensationStatus represents compensation status
type CompensationStatus string

const (
	CompensationNotStarted  CompensationStatus = "NOT_STARTED"
	CompensationRunning     CompensationStatus = "RUNNING"
	CompensationCompleted   CompensationStatus = "COMPLETED"
	CompensationPartial     CompensationStatus = "PARTIAL"
	CompensationFailed      CompensationStatus = "FAILED"
	CompensationUncompensatable CompensationStatus = "UNCOMPENSATABLE"
)

// SagaExecutionInput is input for starting saga execution
type SagaExecutionInput struct {
	SagaType string                 // e.g., "SAGA-S01"
	Input    map[string]interface{} // Saga-specific input data
	Metadata map[string]string      // Optional metadata
}

// StepDefinition defines a single step in a saga
type StepDefinition struct {
	StepNumber         int32                   // 1-based step number
	ServiceName        string                  // e.g., "sales-order", "inventory-core"
	HandlerMethod      string                  // e.g., "CreateOrder", "ReserveStock"
	InputMapping       map[string]string       // Map saga state to handler input
	RetryConfig        *RetryConfiguration
	TimeoutSeconds     int32
	IsCritical         bool                    // If false, failure is non-blocking
	CompensationSteps  []int32                 // Which steps to compensate if this fails
}

// RetryConfiguration defines retry behavior for a step
type RetryConfiguration struct {
	MaxRetries          int32   // e.g., 3
	InitialBackoffMs    int32   // e.g., 1000 (1 second)
	MaxBackoffMs        int32   // e.g., 30000 (30 seconds)
	BackoffMultiplier   float64 // e.g., 2.0 (exponential)
	JitterFraction      float64 // e.g., 0.1 (10% jitter)
	RetryableErrors     []string // Error codes to retry on
	NonRetryableErrors  []string // Error codes to NOT retry
	CircuitBreakerThreshold int32 // Fail after N consecutive failures
	CircuitBreakerResetMs   int32 // Reset circuit breaker after N milliseconds
}

// StepExecution represents execution of a single step
type StepExecution struct {
	ID              string                    // ULID
	SagaID          string
	TenantID        string
	CompanyID       string
	BranchID        string
	StepNumber      int32
	Status          StepExecutionStatus       // Success, Failed, Timeout, Retrying
	Result          []byte                    // JSON: Handler response
	Error           string
	ErrorCode       string
	ExecutionTimeMs int64
	RetryCount      int32
	CompletedAt     *time.Time
	CreatedAt       *time.Time
	UpdatedAt       *time.Time
}

// StepExecutionStatus represents step execution status
type StepExecutionStatus string

const (
	StepStatusPending   StepExecutionStatus = "PENDING"
	StepStatusRunning   StepExecutionStatus = "RUNNING"
	StepStatusSuccess   StepExecutionStatus = "SUCCESS"
	StepStatusFailed    StepExecutionStatus = "FAILED"
	StepStatusTimeout   StepExecutionStatus = "TIMEOUT"
	StepStatusRetrying  StepExecutionStatus = "RETRYING"
)

// StepResult represents result of executing a step
type StepResult struct {
	StepNumber      int32
	Status          StepExecutionStatus // Success, Failed, Timeout, Retrying
	Result          interface{}          // Handler response
	Error           error
	ErrorCode       string
	ExecutionTimeMs int64
	RetryCount      int32
	CompletedAt     time.Time
}

// TimeoutTracker tracks step timeouts
type TimeoutTracker struct {
	ID          string    // ULID
	SagaID      string
	StepNumber  int32
	TimeoutAt   time.Time
	CreatedAt   time.Time
}

// CircuitBreakerStatus represents circuit breaker state
type CircuitBreakerStatus string

const (
	CircuitBreakerClosed   CircuitBreakerStatus = "CLOSED"    // Normal operation
	CircuitBreakerOpen     CircuitBreakerStatus = "OPEN"      // Failing, reject requests
	CircuitBreakerHalfOpen CircuitBreakerStatus = "HALF_OPEN" // Testing recovery
)

// SagaEvent represents a saga lifecycle event
type SagaEvent struct {
	EventID    string              // ULID
	SagaID     string
	SagaType   string
	EventType  SagaEventType
	StepNumber int32
	Timestamp  time.Time
	Data       []byte              // JSON event payload
}

// SagaEventType represents types of saga events
type SagaEventType string

const (
	SagaEventStepStarted SagaEventType = "SAGA.STEP.STARTED"
	SagaEventStepCompleted SagaEventType = "SAGA.STEP.COMPLETED"
	SagaEventStepFailed SagaEventType = "SAGA.STEP.FAILED"
	SagaEventStepRetrying SagaEventType = "SAGA.STEP.RETRYING"
	SagaEventSagaCompleted SagaEventType = "SAGA.SAGA.COMPLETED"
	SagaEventSagaFailed SagaEventType = "SAGA.SAGA.FAILED"
	SagaEventCompensationStarted SagaEventType = "SAGA.COMPENSATION.STARTED"
	SagaEventCompensationCompleted SagaEventType = "SAGA.COMPENSATION.COMPLETED"
)

// CompensationRecord tracks compensation execution
type CompensationRecord struct {
	ID                  string              // ULID
	SagaID              string
	StepNumber          int32
	ForwardAction       string              // Description
	CompensationAction  string              // Description
	InitiatedAt         time.Time
	CompletedAt         *time.Time
	DurationMs          int64
	CompensationStatus  CompensationStatus
	ErrorMessage        string
	RecoverySteps       []byte              // JSON: manual steps taken
	UserInitiated       bool
	InitiatedByUserID   string              // if user-initiated
}
