// Package outbound defines the secondary ports — the interfaces that the
// farm-service application core drives.  Outbound adapters (postgres, kafka)
// implement these interfaces.  The application layer only imports this package
// and the domain package.
package outbound

import (
	"context"

	"github.com/jackc/pgx/v5"

	"p9e.in/samavaya/agriculture/farm-service/internal/domain"
)

// FarmRepository is the secondary port for farm persistence.
// The postgres adapter implements this interface.
type FarmRepository interface {
	CreateFarm(ctx context.Context, farm *domain.Farm) (*domain.Farm, error)
	GetFarmByUUID(ctx context.Context, uuid, tenantID string) (*domain.Farm, error)
	ListFarms(ctx context.Context, params domain.ListFarmsParams) ([]domain.Farm, int32, error)
	UpdateFarm(ctx context.Context, farm *domain.Farm) (*domain.Farm, error)
	DeleteFarm(ctx context.Context, uuid, tenantID, deletedBy string) error
	CheckFarmExists(ctx context.Context, uuid, tenantID string) (bool, error)
	CheckFarmNameExists(ctx context.Context, name, tenantID string) (bool, error)

	CreateFarmBoundary(ctx context.Context, boundary *domain.FarmBoundary) (*domain.FarmBoundary, error)
	GetFarmBoundaryByFarmUUID(ctx context.Context, farmUUID, tenantID string) (*domain.FarmBoundary, error)
	UpdateFarmBoundary(ctx context.Context, boundary *domain.FarmBoundary) (*domain.FarmBoundary, error)
	DeleteFarmBoundary(ctx context.Context, farmUUID, tenantID, deletedBy string) error

	CreateFarmOwner(ctx context.Context, owner *domain.FarmOwner) (*domain.FarmOwner, error)
	GetFarmOwnersByFarmUUID(ctx context.Context, farmUUID, tenantID string) ([]domain.FarmOwner, error)
	GetFarmOwnerByUserID(ctx context.Context, farmUUID, tenantID, userID string) (*domain.FarmOwner, error)
	DeactivateFarmOwner(ctx context.Context, farmUUID, tenantID, userID, deletedBy string) error
	ClearPrimaryOwner(ctx context.Context, farmUUID, tenantID, updatedBy string) error

	CreateManagementUnit(ctx context.Context, unit *domain.ManagementUnit) (*domain.ManagementUnit, error)
	GetManagementUnitByID(ctx context.Context, id, tenantID string) (*domain.ManagementUnit, error)
	ListManagementUnits(ctx context.Context, params domain.ListManagementUnitsParams) ([]domain.ManagementUnit, int32, error)
	UpdateManagementUnit(ctx context.Context, unit *domain.ManagementUnit) (*domain.ManagementUnit, error)
	DeleteManagementUnit(ctx context.Context, id, tenantID, deletedBy string) error
	GetUnitFieldIDs(ctx context.Context, unitID, tenantID string) ([]string, error)
	AssignFieldsToUnit(ctx context.Context, unitID, tenantID string, fieldIDs []string) error
	RemoveFieldsFromUnit(ctx context.Context, unitID, tenantID string, fieldIDs []string) error

	// WithTx returns a copy of this repository that executes queries inside the
	// provided pgx transaction.  Used by the application layer to compose
	// multiple repository operations atomically.
	WithTx(tx pgx.Tx) FarmRepository
}
