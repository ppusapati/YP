// Package inbound defines the primary ports — the interfaces that drive the
// farm-service application core.  These interfaces are implemented by the
// application service and called by inbound adapters (ConnectRPC handler,
// Kafka consumer).
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/farm-service/internal/domain"
)

// FarmService is the primary port for all farm business operations.
// Inbound adapters (grpc handler, event consumer) depend on this interface,
// never on the concrete application service.
type FarmService interface {
	CreateFarm(ctx context.Context, farm *domain.Farm, ownerInfo *domain.FarmOwner) (*domain.Farm, error)
	GetFarm(ctx context.Context, uuid string) (*domain.Farm, error)
	ListFarms(ctx context.Context, params domain.ListFarmsParams) ([]domain.Farm, int32, error)
	UpdateFarm(ctx context.Context, farm *domain.Farm) (*domain.Farm, error)
	DeleteFarm(ctx context.Context, uuid string) error
	SetFarmBoundary(ctx context.Context, farmUUID, geoJSON string) (*domain.FarmBoundary, error)
	GetFarmBoundary(ctx context.Context, farmUUID string) (*domain.FarmBoundary, error)
	TransferOwnership(ctx context.Context, params domain.TransferOwnershipParams) (*domain.Farm, error)

	CreateManagementUnit(ctx context.Context, unit *domain.ManagementUnit) (*domain.ManagementUnit, error)
	GetManagementUnit(ctx context.Context, id string) (*domain.ManagementUnit, error)
	ListManagementUnits(ctx context.Context, params domain.ListManagementUnitsParams) ([]domain.ManagementUnit, int32, error)
	UpdateManagementUnit(ctx context.Context, unit *domain.ManagementUnit) (*domain.ManagementUnit, error)
	DeleteManagementUnit(ctx context.Context, id string) error
	AssignFieldsToUnit(ctx context.Context, unitID string, fieldIDs []string) (*domain.ManagementUnit, error)
	RemoveFieldsFromUnit(ctx context.Context, unitID string, fieldIDs []string) (*domain.ManagementUnit, error)
}
