// Package application contains the farm-service application service — the
// implementation of the FarmService primary port.  It orchestrates domain
// objects, drives outbound ports (repository, event publisher), and enforces
// business invariants.  It has NO knowledge of ConnectRPC, HTTP, SQL, or Kafka.
package application

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/convert/ptr"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
	"p9e.in/samavaya/packages/uow"

	"p9e.in/samavaya/agriculture/farm-service/internal/domain"
	"p9e.in/samavaya/agriculture/farm-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/farm-service/internal/ports/outbound"
)

const (
	serviceName       = "farm-service"
	farmEventTopic    = "samavaya.agriculture.farm.events"
	maxPageSize int32 = 100
	defaultPageSize   = int32(20)
)

// farmService implements inbound.FarmService.
type farmService struct {
	repo outbound.FarmRepository
	pub  outbound.EventPublisher
	pool *pgxpool.Pool // used only for transaction management
	log  *p9log.Helper
}

// NewFarmService creates a new application-layer FarmService.
// Dependencies are injected from outside (cmd/server/main.go), keeping the
// application layer free of infrastructure wiring.
func NewFarmService(
	repo outbound.FarmRepository,
	pub outbound.EventPublisher,
	pool *pgxpool.Pool,
	log p9log.Logger,
) inbound.FarmService {
	return &farmService{
		repo: repo,
		pub:  pub,
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "FarmService")),
	}
}

// CreateFarm creates a new farm and optionally an initial owner, atomically.
func (s *farmService) CreateFarm(ctx context.Context, farm *domain.Farm, ownerInfo *domain.FarmOwner) (*domain.Farm, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if userID == "" {
		userID = "system"
	}
	if farm.Name == "" {
		return nil, errors.BadRequest("INVALID_FARM_NAME", "farm name is required")
	}
	if !farm.FarmType.IsValid() {
		return nil, errors.BadRequest("INVALID_FARM_TYPE", "invalid farm type")
	}
	if farm.TotalAreaHectares < 0 {
		return nil, errors.BadRequest("INVALID_AREA", "total area must be non-negative")
	}
	if farm.Latitude != nil && (*farm.Latitude < -90 || *farm.Latitude > 90) {
		return nil, errors.BadRequest("INVALID_LATITUDE", "latitude must be between -90 and 90")
	}
	if farm.Longitude != nil && (*farm.Longitude < -180 || *farm.Longitude > 180) {
		return nil, errors.BadRequest("INVALID_LONGITUDE", "longitude must be between -180 and 180")
	}

	exists, err := s.repo.CheckFarmNameExists(ctx, farm.Name, tenantID)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, errors.Conflict("FARM_NAME_EXISTS", fmt.Sprintf("farm with name '%s' already exists", farm.Name))
	}

	farm.TenantID = tenantID
	farm.CreatedBy = userID
	farm.Status = domain.FarmStatusPending

	var createdFarm *domain.Farm

	txErr := uow.WithTransaction(ctx, s.pool, func(u uow.UnitOfWork) error {
		txRepo := s.repo.WithTx(u.Tx())

		created, err := txRepo.CreateFarm(ctx, farm)
		if err != nil {
			return err
		}
		createdFarm = created

		if ownerInfo != nil {
			ownerInfo.FarmID = created.ID
			ownerInfo.FarmUUID = created.UUID
			ownerInfo.TenantID = tenantID
			ownerInfo.CreatedBy = userID
			if ownerInfo.UserID == "" {
				ownerInfo.UserID = userID
			}
			if ownerInfo.OwnershipPercentage == 0 {
				ownerInfo.OwnershipPercentage = 100.0
			}
			ownerInfo.IsPrimary = true

			owner, err := txRepo.CreateFarmOwner(ctx, ownerInfo)
			if err != nil {
				return err
			}
			createdFarm.Owners = []domain.FarmOwner{*owner}
		}
		return nil
	})
	if txErr != nil {
		s.log.Errorw("msg", "failed to create farm", "error", txErr, "request_id", requestID)
		return nil, txErr
	}

	s.emitEvent(ctx, "agriculture.farm.created", createdFarm.UUID, map[string]interface{}{
		"farm_id": createdFarm.UUID, "tenant_id": tenantID,
		"name": createdFarm.Name, "farm_type": string(createdFarm.FarmType),
	})
	s.log.Infow("msg", "farm created", "uuid", createdFarm.UUID, "tenant_id", tenantID)
	return createdFarm, nil
}

// GetFarm retrieves a farm by UUID, including its boundary and owners.
func (s *farmService) GetFarm(ctx context.Context, uuid string) (*domain.Farm, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm ID is required")
	}

	farm, err := s.repo.GetFarmByUUID(ctx, uuid, tenantID)
	if err != nil {
		return nil, err
	}

	if boundary, bErr := s.repo.GetFarmBoundaryByFarmUUID(ctx, uuid, tenantID); bErr == nil {
		farm.Boundary = boundary
	}
	if owners, oErr := s.repo.GetFarmOwnersByFarmUUID(ctx, uuid, tenantID); oErr == nil {
		farm.Owners = owners
	}
	return farm, nil
}

// ListFarms lists farms with filtering and pagination.
func (s *farmService) ListFarms(ctx context.Context, params domain.ListFarmsParams) ([]domain.Farm, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	params.TenantID = tenantID
	if params.PageSize <= 0 {
		params.PageSize = defaultPageSize
	}
	if params.PageSize > maxPageSize {
		params.PageSize = maxPageSize
	}
	return s.repo.ListFarms(ctx, params)
}

// UpdateFarm updates an existing farm's fields.
func (s *farmService) UpdateFarm(ctx context.Context, farm *domain.Farm) (*domain.Farm, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if farm.UUID == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckFarmExists(ctx, farm.UUID, tenantID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("FARM_NOT_FOUND", fmt.Sprintf("farm not found: %s", farm.UUID))
	}

	if farm.FarmType != domain.FarmTypeUnspecified && !farm.FarmType.IsValid() {
		return nil, errors.BadRequest("INVALID_FARM_TYPE", "invalid farm type")
	}
	if farm.Status != domain.FarmStatusUnspecified && !farm.Status.IsValid() {
		return nil, errors.BadRequest("INVALID_FARM_STATUS", "invalid farm status")
	}
	if farm.Latitude != nil && (*farm.Latitude < -90 || *farm.Latitude > 90) {
		return nil, errors.BadRequest("INVALID_LATITUDE", "latitude must be between -90 and 90")
	}
	if farm.Longitude != nil && (*farm.Longitude < -180 || *farm.Longitude > 180) {
		return nil, errors.BadRequest("INVALID_LONGITUDE", "longitude must be between -180 and 180")
	}

	if farm.Name != "" {
		existing, err := s.repo.GetFarmByUUID(ctx, farm.UUID, tenantID)
		if err != nil {
			return nil, err
		}
		if existing.Name != farm.Name {
			nameExists, err := s.repo.CheckFarmNameExists(ctx, farm.Name, tenantID)
			if err != nil {
				return nil, err
			}
			if nameExists {
				return nil, errors.Conflict("FARM_NAME_EXISTS", fmt.Sprintf("farm with name '%s' already exists", farm.Name))
			}
		}
	}

	farm.TenantID = tenantID
	farm.UpdatedBy = ptr.String(userID)

	updated, err := s.repo.UpdateFarm(ctx, farm)
	if err != nil {
		return nil, err
	}

	if b, bErr := s.repo.GetFarmBoundaryByFarmUUID(ctx, updated.UUID, tenantID); bErr == nil {
		updated.Boundary = b
	}
	if o, oErr := s.repo.GetFarmOwnersByFarmUUID(ctx, updated.UUID, tenantID); oErr == nil {
		updated.Owners = o
	}

	s.emitEvent(ctx, "agriculture.farm.updated", updated.UUID, map[string]interface{}{
		"farm_id": updated.UUID, "tenant_id": tenantID,
	})
	s.log.Infow("msg", "farm updated", "uuid", updated.UUID, "request_id", requestID)
	return updated, nil
}

// DeleteFarm soft-deletes a farm and its boundary in a single transaction.
func (s *farmService) DeleteFarm(ctx context.Context, uuid string) error {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return errors.BadRequest("MISSING_FARM_ID", "farm ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckFarmExists(ctx, uuid, tenantID)
	if err != nil {
		return err
	}
	if !exists {
		return errors.NotFound("FARM_NOT_FOUND", fmt.Sprintf("farm not found: %s", uuid))
	}

	txErr := uow.WithTransaction(ctx, s.pool, func(u uow.UnitOfWork) error {
		txRepo := s.repo.WithTx(u.Tx())
		_ = txRepo.DeleteFarmBoundary(ctx, uuid, tenantID, userID)
		return txRepo.DeleteFarm(ctx, uuid, tenantID, userID)
	})
	if txErr != nil {
		s.log.Errorw("msg", "failed to delete farm", "uuid", uuid, "error", txErr, "request_id", requestID)
		return txErr
	}

	s.emitEvent(ctx, "agriculture.farm.deleted", uuid, map[string]interface{}{
		"farm_id": uuid, "tenant_id": tenantID, "deleted_by": userID,
	})
	s.log.Infow("msg", "farm deleted", "uuid", uuid)
	return nil
}

// SetFarmBoundary creates or updates the geographic boundary for a farm.
func (s *farmService) SetFarmBoundary(ctx context.Context, farmUUID, geoJSON string) (*domain.FarmBoundary, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if farmUUID == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm ID is required")
	}
	if geoJSON == "" {
		return nil, errors.BadRequest("MISSING_GEOJSON", "GeoJSON boundary is required")
	}
	if userID == "" {
		userID = "system"
	}
	if !json.Valid([]byte(geoJSON)) {
		return nil, errors.BadRequest("INVALID_GEOJSON", "GeoJSON must be valid JSON")
	}

	farm, err := s.repo.GetFarmByUUID(ctx, farmUUID, tenantID)
	if err != nil {
		return nil, err
	}

	existing, err := s.repo.GetFarmBoundaryByFarmUUID(ctx, farmUUID, tenantID)

	var result *domain.FarmBoundary
	if err == nil && existing != nil {
		existing.GeoJSON = geoJSON
		existing.UpdatedBy = ptr.String(userID)
		result, err = s.repo.UpdateFarmBoundary(ctx, existing)
		if err != nil {
			return nil, err
		}
	} else {
		boundary := &domain.FarmBoundary{
			FarmID:    farm.ID,
			FarmUUID:  farmUUID,
			TenantID:  tenantID,
			GeoJSON:   geoJSON,
			CreatedBy: userID,
		}
		result, err = s.repo.CreateFarmBoundary(ctx, boundary)
		if err != nil {
			return nil, err
		}
	}

	s.emitEvent(ctx, "agriculture.farm.boundary.set", farmUUID, map[string]interface{}{
		"farm_id": farmUUID, "boundary_id": result.UUID,
	})
	s.log.Infow("msg", "farm boundary set", "farm_uuid", farmUUID, "boundary_uuid", result.UUID, "request_id", requestID)
	return result, nil
}

// GetFarmBoundary retrieves the geographic boundary for a farm.
func (s *farmService) GetFarmBoundary(ctx context.Context, farmUUID string) (*domain.FarmBoundary, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if farmUUID == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm ID is required")
	}
	exists, err := s.repo.CheckFarmExists(ctx, farmUUID, tenantID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("FARM_NOT_FOUND", fmt.Sprintf("farm not found: %s", farmUUID))
	}
	return s.repo.GetFarmBoundaryByFarmUUID(ctx, farmUUID, tenantID)
}

// TransferOwnership transfers farm ownership from one user to another.
func (s *farmService) TransferOwnership(ctx context.Context, params domain.TransferOwnershipParams) (*domain.Farm, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if params.FarmUUID == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm ID is required")
	}
	if params.FromUserID == "" {
		return nil, errors.BadRequest("MISSING_FROM_USER", "from_user_id is required")
	}
	if params.ToUserID == "" {
		return nil, errors.BadRequest("MISSING_TO_USER", "to_user_id is required")
	}
	if params.ToOwnerName == "" {
		return nil, errors.BadRequest("MISSING_OWNER_NAME", "to_owner_name is required")
	}
	if params.FromUserID == params.ToUserID {
		return nil, errors.BadRequest("SAME_USER", "cannot transfer ownership to the same user")
	}
	if userID == "" {
		userID = "system"
	}

	farm, err := s.repo.GetFarmByUUID(ctx, params.FarmUUID, tenantID)
	if err != nil {
		return nil, err
	}

	_, err = s.repo.GetFarmOwnerByUserID(ctx, params.FarmUUID, tenantID, params.FromUserID)
	if err != nil {
		return nil, errors.BadRequest("NOT_AN_OWNER", fmt.Sprintf("user %s is not an owner of farm %s", params.FromUserID, params.FarmUUID))
	}

	txErr := uow.WithTransaction(ctx, s.pool, func(u uow.UnitOfWork) error {
		txRepo := s.repo.WithTx(u.Tx())

		if err := txRepo.DeactivateFarmOwner(ctx, params.FarmUUID, tenantID, params.FromUserID, userID); err != nil {
			return err
		}
		if err := txRepo.ClearPrimaryOwner(ctx, params.FarmUUID, tenantID, userID); err != nil {
			return err
		}

		if existingOwner, _ := txRepo.GetFarmOwnerByUserID(ctx, params.FarmUUID, tenantID, params.ToUserID); existingOwner != nil {
			if err := txRepo.DeactivateFarmOwner(ctx, params.FarmUUID, tenantID, params.ToUserID, userID); err != nil {
				return err
			}
		}

		percentage := params.OwnershipPercentage
		if percentage == 0 {
			percentage = 100.0
		}
		newOwner := &domain.FarmOwner{
			FarmID:              farm.ID,
			FarmUUID:            params.FarmUUID,
			TenantID:            tenantID,
			UserID:              params.ToUserID,
			OwnerName:           params.ToOwnerName,
			Email:               ptr.StringOrNil(params.ToEmail),
			Phone:               ptr.StringOrNil(params.ToPhone),
			IsPrimary:           true,
			OwnershipPercentage: percentage,
			AcquiredAt:          time.Now(),
			CreatedBy:           userID,
		}
		_, err := txRepo.CreateFarmOwner(ctx, newOwner)
		return err
	})
	if txErr != nil {
		s.log.Errorw("msg", "failed to transfer ownership", "farm_uuid", params.FarmUUID, "error", txErr, "request_id", requestID)
		return nil, txErr
	}

	updatedFarm, err := s.GetFarm(ctx, params.FarmUUID)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.farm.ownership.transferred", params.FarmUUID, map[string]interface{}{
		"farm_id": params.FarmUUID, "from_user_id": params.FromUserID, "to_user_id": params.ToUserID,
	})
	s.log.Infow("msg", "ownership transferred", "farm_uuid", params.FarmUUID,
		"from_user", params.FromUserID, "to_user", params.ToUserID, "request_id", requestID)
	return updatedFarm, nil
}

// emitEvent publishes a domain event best-effort (errors are logged, not propagated).
func (s *farmService) emitEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
	if s.pub == nil {
		return
	}
	requestID := p9context.RequestID(ctx)

	payload := map[string]interface{}{
		"id":           ulid.NewString(),
		"type":         eventType,
		"aggregate_id": aggregateID,
		"source":       serviceName,
		"correlation_id": requestID,
		"data":         data,
	}
	raw, err := json.Marshal(payload)
	if err != nil {
		s.log.Errorw("msg", "failed to marshal event", "event_type", eventType, "error", err)
		return
	}
	if err := s.pub.Publish(ctx, farmEventTopic, aggregateID, raw); err != nil {
		s.log.Errorw("msg", "failed to publish event", "event_type", eventType, "error", err)
	}
}
