// Package supplychain provides saga handlers for supply chain module workflows
package supplychain

import (
	"go.uber.org/fx"

	"p9e.in/samavaya/packages/saga"
)

// SupplyChainSagasModule provides all supply chain saga handlers with dependency injection
var SupplyChainSagasModule = fx.Module("supply-chain-sagas",
	fx.Provide(
		// SAGA-SC01: Inbound Logistics & Supplier Receipt (Phase 6B)
		fx.Annotate(
			NewInboundLogisticsSaga,
			fx.ResultTags(`group:"saga_handlers"`),
		),
		// SAGA-SC02: Warehouse Operations & Movement (Phase 6B)
		fx.Annotate(
			NewWarehouseOpsSaga,
			fx.ResultTags(`group:"saga_handlers"`),
		),
		// SAGA-SC03: Third-Party Logistics Coordination (Phase 6B)
		fx.Annotate(
			NewThreePLCoordinationSaga,
			fx.ResultTags(`group:"saga_handlers"`),
		),
		// SAGA-SC04: Order Fulfillment & Shipment (Phase 6B)
		fx.Annotate(
			NewOrderFulfillmentSaga,
			fx.ResultTags(`group:"saga_handlers"`),
		),
		// SAGA-SC05: Distribution Center Management (Phase 6B)
		fx.Annotate(
			NewDistributionCenterSaga,
			fx.ResultTags(`group:"saga_handlers"`),
		),
		// SAGA-SC06: Route Optimization & Last-Mile Delivery (Phase 6B)
		fx.Annotate(
			NewRouteOptimizationSaga,
			fx.ResultTags(`group:"saga_handlers"`),
		),
		// SAGA-SC07: Supply Chain Visibility & Tracking (Phase 6B)
		fx.Annotate(
			NewSupplyChainVisibilitySaga,
			fx.ResultTags(`group:"saga_handlers"`),
		),
		// SAGA-SC08: Supplier Performance & Metrics (Phase 6B)
		fx.Annotate(
			NewSupplierPerformanceSaga,
			fx.ResultTags(`group:"saga_handlers"`),
		),
		// SAGA-SC09: Reverse Logistics & Returns (Phase 6B)
		fx.Annotate(
			NewReverseLogisticsSaga,
			fx.ResultTags(`group:"saga_handlers"`),
		),
	),
)

// SupplyChainSagasRegistrationModule registers all supply chain saga handlers with the global registry
var SupplyChainSagasRegistrationModule = fx.Module("supply-chain-sagas-registration",
	fx.Invoke(RegisterSupplyChainSagaHandlers),
)

// RegisterSupplyChainSagaHandlers registers all supply chain saga handlers with the global saga registry
func RegisterSupplyChainSagaHandlers(handlers []saga.SagaHandler) {
	for _, handler := range handlers {
		saga.GlobalSagaRegistry.Register(handler.SagaType(), handler)
	}
}

// ProvideSupplyChainSagaHandlers provides all supply chain saga handlers as a slice
// This is a convenience function for cases where manual aggregation is needed
func ProvideSupplyChainSagaHandlers() []saga.SagaHandler {
	return []saga.SagaHandler{
		NewInboundLogisticsSaga(),
		NewWarehouseOpsSaga(),
		NewThreePLCoordinationSaga(),
		NewOrderFulfillmentSaga(),
		NewDistributionCenterSaga(),
		NewRouteOptimizationSaga(),
		NewSupplyChainVisibilitySaga(),
		NewSupplierPerformanceSaga(),
		NewReverseLogisticsSaga(),
	}
}
