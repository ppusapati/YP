// Package saga provides the main FX module for saga engine
package saga

import (
	"time"

	"go.uber.org/fx"

	"p9e.in/samavaya/packages/saga/compensation"
	"p9e.in/samavaya/packages/saga/connector"
	"p9e.in/samavaya/packages/saga/events"
	"p9e.in/samavaya/packages/saga/executor"
	"p9e.in/samavaya/packages/saga/orchestrator"
	"p9e.in/samavaya/packages/saga/sagas/inventory"
	"p9e.in/samavaya/packages/saga/sagas/purchase"
	"p9e.in/samavaya/packages/saga/sagas/sales"
	"p9e.in/samavaya/packages/saga/sagas/manufacturing"
	"p9e.in/samavaya/packages/saga/sagas/finance"
	"p9e.in/samavaya/packages/saga/sagas/hr"
	"p9e.in/samavaya/packages/saga/sagas/projects"
	"p9e.in/samavaya/packages/saga/sagas/gst"
	"p9e.in/samavaya/packages/saga/sagas/banking"
	"p9e.in/samavaya/packages/saga/sagas/construction"
	"p9e.in/samavaya/packages/saga/sagas/agriculture"
	"p9e.in/samavaya/packages/saga/sagas/retail"
	supplychain "p9e.in/samavaya/packages/saga/sagas/supply-chain"
	"p9e.in/samavaya/packages/saga/sagas/healthcare"
	"p9e.in/samavaya/packages/saga/sagas/warranty"
	"p9e.in/samavaya/packages/saga/timeout"
)

// SagaEngineParams contains all dependencies for saga engine
type SagaEngineParams struct {
	fx.In

	Config                *DefaultConfig
	StepExecutor          SagaStepExecutor
	TimeoutHandler        SagaTimeoutHandler
	EventPublisher        SagaEventPublisher
	Repository            SagaRepository
	ExecutionLogRepository SagaExecutionLogRepository
}

// SagaEngineResult contains all provided components from saga engine module
type SagaEngineResult struct {
	fx.Out

	Orchestrator      SagaOrchestrator
	StepExecutor      SagaStepExecutor
	TimeoutHandler    SagaTimeoutHandler
	EventPublisher    SagaEventPublisher
	Registry          *orchestrator.SagaRegistry
	CircuitBreaker    SagaCircuitBreaker
}

// CircuitBreakerProvider creates a default circuit breaker (can be overridden)
type CircuitBreakerProvider interface {
	CreateCircuitBreaker(serviceName string) SagaCircuitBreaker
}

// SagaCircuitBreaker is an alias for circuit breaker interface
type SagaCircuitBreaker = CircuitBreaker

// SagaEngineModule provides all saga engine components
var SagaEngineModule = fx.Module(
	"saga_engine",

	// Step Executor Components
	fx.Provide(
		func() *executor.IdempotencyImpl {
			// TTL: 1 hour, Max cache size: 10,000 entries
			return executor.NewIdempotencyImpl(1*time.Hour, 10000)
		},
	),

	fx.Provide(
		func() executor.saga.RpcConnector {
			return executor.NewRpcConnectorImpl()
		},
	),

	fx.Provide(
		func(
			rpcConnector saga.RpcConnector,
			idempotency *executor.IdempotencyImpl,
		) SagaStepExecutor {
			return executor.NewStepExecutorImpl(rpcConnector, idempotency)
		},
	),

	// Timeout Handler Components
	fx.Provide(
		func(config *DefaultConfig) SagaTimeoutHandler {
			defaultRetryConfig := &RetryConfiguration{
				MaxRetries:         config.DefaultMaxRetries,
				InitialBackoffMs:   int32(config.DefaultInitialBackoff.Milliseconds()),
				MaxBackoffMs:       int32(config.DefaultMaxBackoff.Milliseconds()),
				BackoffMultiplier:  config.BackoffMultiplier,
				JitterFraction:     config.JitterFraction,
			}

			retryStrategies := make(map[string]*RetryConfiguration)

			return timeout.NewTimeoutHandlerImpl(defaultRetryConfig, retryStrategies)
		},
	),

	// Event Publisher Components
	fx.Provide(
		func() events.KafkaProducer {
			// Use mock producer for now, can be replaced with real Kafka producer
			return &events.MockKafkaProducer{}
		},
	),

	fx.Provide(
		func(kafkaProducer events.KafkaProducer, config *DefaultConfig) SagaEventPublisher {
			return events.NewEventPublisherImpl(config.KafkaTopic, kafkaProducer)
		},
	),

	// Orchestrator Components
	orchestrator.SagaOrchestratorModule,

	// Compensation Components
	compensation.SagaCompensationEngineModule,

	// RPC Connector Components
	connector.ConnectorModule,

	// Sales Saga Handlers (Phase 2)
	sales.SalesSagasModule,
	sales.SalesSagasRegistrationModule,

	// Purchase Saga Handlers (Phase 3)
	purchase.PurchaseSagasModule,
	purchase.PurchaseSagasRegistrationModule,

	// Inventory Saga Handlers (Phase 3)
	inventory.InventorySagasModule,
	inventory.InventorySagasRegistrationModule,

	// Manufacturing Saga Handlers (Phase 4)
	manufacturing.ManufacturingSagasModule,
	manufacturing.ManufacturingSagasRegistrationModule,

	// Finance Saga Handlers (Phase 4)
	finance.FinanceSagasModule,
	finance.FinanceSagasRegistrationModule,

	// HR Saga Handlers (Phase 4)
	hr.HRSagasModule,
	hr.HRSagasRegistrationModule,

	// Projects Saga Handlers (Phase 4)
	projects.ProjectsSagasModule,
	projects.ProjectsSagasRegistrationModule,

	// GST Saga Handlers (Phase 5A)
	gst.GSTSagasModule,
	gst.GSTSagasRegistrationModule,

	// Banking Saga Handlers (Phase 5A)
	banking.BankingSagasModule,
	banking.BankingSagasRegistrationModule,

	// Construction Saga Handlers (Phase 5B)
	construction.ConstructionSagasModule,
	construction.ConstructionSagasRegistrationModule,

	// Agriculture Saga Handlers (Phase 5B)
	agriculture.AgricultureSagasModule,
	agriculture.AgricultureSagasRegistrationModule,

	// Retail Saga Handlers (Phase 6A)
	retail.RetailSagasModule,
	retail.RetailSagasRegistrationModule,

	// Supply Chain Saga Handlers (Phase 6B)
	supplychain.SupplyChainSagasModule,
	supplychain.SupplyChainSagasRegistrationModule,

	// Healthcare Saga Handlers (Phase 6C)
	healthcare.HealthcareSagasModule,
	healthcare.HealthcareSagasRegistrationModule,

	// Warranty Saga Handlers (Phase 6D)
	warranty.WarrantySagasModule,
	warranty.WarrantySagasRegistrationModule,

	// Provide the results
	fx.Provide(
		func(
			registry *orchestrator.SagaRegistry,
			stepExecutor SagaStepExecutor,
			timeoutHandler SagaTimeoutHandler,
			eventPublisher SagaEventPublisher,
			repository SagaRepository,
			execLogRepository SagaExecutionLogRepository,
			config *DefaultConfig,
		) SagaOrchestratorResult {
			orch := orchestrator.NewSagaOrchestratorImpl(
				registry,
				stepExecutor,
				timeoutHandler,
				eventPublisher,
				repository,
				execLogRepository,
				config,
			)

			return SagaOrchestratorResult{
				Orchestrator: orch,
				Registry:     registry,
			}
		},
	),
)

// SagaOrchestratorResult provides orchestrator and registry
type SagaOrchestratorResult struct {
	fx.Out

	Orchestrator SagaOrchestrator
	Registry     *orchestrator.SagaRegistry
}

// MinimalSagaEngineModule provides minimal saga engine with mock implementations
// Useful for testing without full infrastructure
var MinimalSagaEngineModule = fx.Module(
	"saga_engine_minimal",

	// Provide default configuration
	fx.Provide(
		func() *DefaultConfig {
			return &DefaultConfig{
				DefaultTimeoutSeconds:   60,
				DefaultMaxRetries:       3,
				DefaultInitialBackoff:   time.Second,
				DefaultMaxBackoff:       30 * time.Second,
				BackoffMultiplier:       2.0,
				JitterFraction:          0.1,
				CircuitBreakerThreshold: 5,
				CircuitBreakerResetMs:   60000,
				KafkaTopic:              "saga-events",
				KafkaPartitions:         5,
			}
		},
	),

	// Use main saga module
	SagaEngineModule,
)
