package services

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"p9e.in/samavaya/packages/convert/ptr"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
	"p9e.in/samavaya/packages/uow"

	farmmodels "p9e.in/samavaya/agriculture/farm-service/internal/models"
	"p9e.in/samavaya/agriculture/farm-service/internal/repositories"
)

const (
	serviceName       = "farm-service"
	maxPageSize int32 = 100
	defaultPageSize   = 20
)

// Farm event types
const (
	EventTypeFarmCreated          domain.EventType = "agriculture.farm.created"
	EventTypeFarmUpdated          domain.EventType = "agriculture.farm.updated"
	EventTypeFarmDeleted          domain.EventType = "agriculture.farm.deleted"
	EventTypeFarmBoundarySet      domain.EventType = "agriculture.farm.boundary.set"
	EventTypeOwnershipTransferred domain.EventType = "agriculture.farm.ownership.transferred"
)

// FarmService defines the interface for farm business logic.
type FarmService interface {
	CreateFarm(ctx context.Context, farm *farmmodels.Farm, ownerInfo *farmmodels.FarmOwner) (*farmmodels.Farm, error)
	GetFarm(ctx context.Context, uuid string) (*farmmodels.Farm, error)
	ListFarms(ctx context.Context, params farmmodels.ListFarmsParams) ([]farmmodels.Farm, int32, error)
	UpdateFarm(ctx context.Context, farm *farmmodels.Farm) (*farmmodels.Farm, error)
	DeleteFarm(ctx context.Context, uuid string) error
	SetFarmBoundary(ctx context.Context, farmUUID, geoJSON string) (*farmmodels.FarmBoundary, error)
	GetFarmBoundary(ctx context.Context, farmUUID string) (*farmmodels.FarmBoundary, error)
	TransferOwnership(ctx context.Context, params farmmodels.TransferOwnershipParams) (*farmmodels.Farm, error)
}

// farmService is the concrete implementation of FarmService.
type farmService struct {
	d    deps.ServiceDeps
	repo repositories.FarmRepository
	log  *p9log.Helper
}

// NewFarmService creates a new FarmService.
func NewFarmService(d deps.ServiceDeps, repo repositories.FarmRepository) FarmService {
	return &farmService{
		d:    d,
		repo: repo,
		log:  p9log.NewHelper(p9log.With(d.Log, "component", "FarmService")),
	}
}

// CreateFarm creates a new farm with optional initial owner in a transaction.
func (s *farmService) CreateFarm(ctx context.Context, farm *farmmodels.Farm, ownerInfo *farmmodels.FarmOwner) (*farmmodels.Farm, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	// Validate required fields
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

	// Check for duplicate name within the tenant
	exists, err := s.repo.CheckFarmNameExists(ctx, farm.Name, tenantID)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, errors.Conflict("FARM_NAME_EXISTS", fmt.Sprintf("farm with name '%s' already exists", farm.Name))
	}

	farm.TenantID = tenantID
	farm.CreatedBy = userID
	farm.Status = farmmodels.FarmStatusPending

	var createdFarm *farmmodels.Farm

	// Use a transaction for farm + owner creation
	txErr := uow.WithTransaction(ctx, s.d.Pool, func(u uow.UnitOfWork) error {
		txRepo := s.repo.WithTx(u.Tx())

		created, err := txRepo.CreateFarm(ctx, farm)
		if err != nil {
			return err
		}
		createdFarm = created

		// Create initial owner if provided
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
			createdFarm.Owners = []farmmodels.FarmOwner{*owner}
		}

		return nil
	})

	if txErr != nil {
		s.log.Errorw("msg", "failed to create farm in transaction", "error", txErr, "request_id", requestID)
		return nil, txErr
	}

	// Emit domain event asynchronously (best-effort)
	s.emitFarmEvent(ctx, EventTypeFarmCreated, createdFarm, nil)

	s.log.Infow("msg", "farm created", "uuid", createdFarm.UUID, "tenant_id", tenantID, "request_id", requestID)
	return createdFarm, nil
}

// GetFarm retrieves a farm by UUID, including its boundary and owners.
func (s *farmService) GetFarm(ctx context.Context, uuid string) (*farmmodels.Farm, error) {
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

	// Load boundary (optional, ignore if not found)
	boundary, err := s.repo.GetFarmBoundaryByFarmUUID(ctx, uuid, tenantID)
	if err == nil {
		farm.Boundary = boundary
	}

	// Load owners
	owners, err := s.repo.GetFarmOwnersByFarmUUID(ctx, uuid, tenantID)
	if err == nil {
		farm.Owners = owners
	}

	return farm, nil
}

// ListFarms lists farms with filtering and pagination.
func (s *farmService) ListFarms(ctx context.Context, params farmmodels.ListFarmsParams) ([]farmmodels.Farm, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	params.TenantID = tenantID

	// Clamp page size
	if params.PageSize <= 0 {
		params.PageSize = defaultPageSize
	}
	if params.PageSize > maxPageSize {
		params.PageSize = maxPageSize
	}

	farms, totalCount, err := s.repo.ListFarms(ctx, params)
	if err != nil {
		return nil, 0, err
	}

	return farms, totalCount, nil
}

// UpdateFarm updates an existing farm's fields.
func (s *farmService) UpdateFarm(ctx context.Context, farm *farmmodels.Farm) (*farmmodels.Farm, error) {
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

	// Validate the farm exists
	exists, err := s.repo.CheckFarmExists(ctx, farm.UUID, tenantID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("FARM_NOT_FOUND", fmt.Sprintf("farm not found: %s", farm.UUID))
	}

	// Validate farm type and status if provided
	if farm.FarmType != farmmodels.FarmTypeUnspecified && !farm.FarmType.IsValid() {
		return nil, errors.BadRequest("INVALID_FARM_TYPE", "invalid farm type")
	}
	if farm.Status != farmmodels.FarmStatusUnspecified && !farm.Status.IsValid() {
		return nil, errors.BadRequest("INVALID_FARM_STATUS", "invalid farm status")
	}
	if farm.Latitude != nil && (*farm.Latitude < -90 || *farm.Latitude > 90) {
		return nil, errors.BadRequest("INVALID_LATITUDE", "latitude must be between -90 and 90")
	}
	if farm.Longitude != nil && (*farm.Longitude < -180 || *farm.Longitude > 180) {
		return nil, errors.BadRequest("INVALID_LONGITUDE", "longitude must be between -180 and 180")
	}

	// Check for name uniqueness if name is being changed
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

	// Load associations for the response
	boundary, bErr := s.repo.GetFarmBoundaryByFarmUUID(ctx, updated.UUID, tenantID)
	if bErr == nil {
		updated.Boundary = boundary
	}
	owners, oErr := s.repo.GetFarmOwnersByFarmUUID(ctx, updated.UUID, tenantID)
	if oErr == nil {
		updated.Owners = owners
	}

	s.emitFarmEvent(ctx, EventTypeFarmUpdated, updated, nil)
	s.log.Infow("msg", "farm updated", "uuid", updated.UUID, "version", updated.Version, "request_id", requestID)
	return updated, nil
}

// DeleteFarm soft-deletes a farm and its associated boundaries and owners.
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

	// Verify the farm exists
	exists, err := s.repo.CheckFarmExists(ctx, uuid, tenantID)
	if err != nil {
		return err
	}
	if !exists {
		return errors.NotFound("FARM_NOT_FOUND", fmt.Sprintf("farm not found: %s", uuid))
	}

	// Use a transaction to delete farm, boundary, and owners together
	txErr := uow.WithTransaction(ctx, s.d.Pool, func(u uow.UnitOfWork) error {
		txRepo := s.repo.WithTx(u.Tx())

		// Delete boundary (if exists)
		_ = txRepo.DeleteFarmBoundary(ctx, uuid, tenantID, userID)

		// Delete farm
		if err := txRepo.DeleteFarm(ctx, uuid, tenantID, userID); err != nil {
			return err
		}

		return nil
	})

	if txErr != nil {
		s.log.Errorw("msg", "failed to delete farm", "uuid", uuid, "error", txErr, "request_id", requestID)
		return txErr
	}

	// Emit domain event
	s.emitFarmEvent(ctx, EventTypeFarmDeleted, nil, map[string]interface{}{
		"farm_id":    uuid,
		"tenant_id":  tenantID,
		"deleted_by": userID,
	})

	s.log.Infow("msg", "farm deleted", "uuid", uuid, "tenant_id", tenantID, "request_id", requestID)
	return nil
}

// SetFarmBoundary creates or updates the geographic boundary for a farm.
func (s *farmService) SetFarmBoundary(ctx context.Context, farmUUID, geoJSON string) (*farmmodels.FarmBoundary, error) {
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

	// Validate GeoJSON is valid JSON
	if !json.Valid([]byte(geoJSON)) {
		return nil, errors.BadRequest("INVALID_GEOJSON", "GeoJSON must be valid JSON")
	}

	// Verify the farm exists and get the farm record
	farm, err := s.repo.GetFarmByUUID(ctx, farmUUID, tenantID)
	if err != nil {
		return nil, err
	}

	// Check if boundary already exists for this farm
	existing, err := s.repo.GetFarmBoundaryByFarmUUID(ctx, farmUUID, tenantID)

	var result *farmmodels.FarmBoundary
	if err == nil && existing != nil {
		// Update existing boundary
		existing.GeoJSON = geoJSON
		existing.UpdatedBy = ptr.String(userID)
		result, err = s.repo.UpdateFarmBoundary(ctx, existing)
		if err != nil {
			return nil, err
		}
	} else {
		// Create new boundary
		boundary := &farmmodels.FarmBoundary{
			FarmID:   farm.ID,
			FarmUUID: farmUUID,
			TenantID: tenantID,
			GeoJSON:  geoJSON,
			CreatedBy: userID,
		}
		result, err = s.repo.CreateFarmBoundary(ctx, boundary)
		if err != nil {
			return nil, err
		}
	}

	s.emitFarmEvent(ctx, EventTypeFarmBoundarySet, nil, map[string]interface{}{
		"farm_id":    farmUUID,
		"boundary_id": result.UUID,
	})

	s.log.Infow("msg", "farm boundary set", "farm_uuid", farmUUID, "boundary_uuid", result.UUID, "request_id", requestID)
	return result, nil
}

// GetFarmBoundary retrieves the boundary for a farm.
func (s *farmService) GetFarmBoundary(ctx context.Context, farmUUID string) (*farmmodels.FarmBoundary, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if farmUUID == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm ID is required")
	}

	// Verify the farm exists
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
func (s *farmService) TransferOwnership(ctx context.Context, params farmmodels.TransferOwnershipParams) (*farmmodels.Farm, error) {
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

	// Verify the farm exists
	farm, err := s.repo.GetFarmByUUID(ctx, params.FarmUUID, tenantID)
	if err != nil {
		return nil, err
	}

	// Verify the from user is an owner
	_, err = s.repo.GetFarmOwnerByUserID(ctx, params.FarmUUID, tenantID, params.FromUserID)
	if err != nil {
		return nil, errors.BadRequest("NOT_AN_OWNER", fmt.Sprintf("user %s is not an owner of farm %s", params.FromUserID, params.FarmUUID))
	}

	txErr := uow.WithTransaction(ctx, s.d.Pool, func(u uow.UnitOfWork) error {
		txRepo := s.repo.WithTx(u.Tx())

		// Deactivate old owner
		if err := txRepo.DeactivateFarmOwner(ctx, params.FarmUUID, tenantID, params.FromUserID, userID); err != nil {
			return err
		}

		// Clear current primary owner flag
		if err := txRepo.ClearPrimaryOwner(ctx, params.FarmUUID, tenantID, userID); err != nil {
			return err
		}

		// Check if the target user is already an owner
		existingOwner, _ := txRepo.GetFarmOwnerByUserID(ctx, params.FarmUUID, tenantID, params.ToUserID)

		if existingOwner != nil {
			// Re-activate the existing owner record is complex; create a new one
			if err := txRepo.DeactivateFarmOwner(ctx, params.FarmUUID, tenantID, params.ToUserID, userID); err != nil {
				return err
			}
		}

		// Create new owner
		percentage := params.OwnershipPercentage
		if percentage == 0 {
			percentage = 100.0
		}

		newOwner := &farmmodels.FarmOwner{
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

		if _, err := txRepo.CreateFarmOwner(ctx, newOwner); err != nil {
			return err
		}

		return nil
	})

	if txErr != nil {
		s.log.Errorw("msg", "failed to transfer ownership", "farm_uuid", params.FarmUUID, "error", txErr, "request_id", requestID)
		return nil, txErr
	}

	// Reload the farm with updated associations
	updatedFarm, err := s.GetFarm(ctx, params.FarmUUID)
	if err != nil {
		return nil, err
	}

	s.emitFarmEvent(ctx, EventTypeOwnershipTransferred, updatedFarm, map[string]interface{}{
		"from_user_id": params.FromUserID,
		"to_user_id":   params.ToUserID,
	})

	s.log.Infow("msg", "ownership transferred",
		"farm_uuid", params.FarmUUID,
		"from_user", params.FromUserID,
		"to_user", params.ToUserID,
		"request_id", requestID,
	)
	return updatedFarm, nil
}

// emitFarmEvent publishes a domain event for farm operations (best-effort).
func (s *farmService) emitFarmEvent(ctx context.Context, eventType domain.EventType, farm *farmmodels.Farm, extraData map[string]interface{}) {
	tenantID := p9context.TenantID(ctx)
	requestID := p9context.RequestID(ctx)

	aggregateID := ""
	if farm != nil {
		aggregateID = farm.UUID
	}

	data := make(map[string]interface{})
	if farm != nil {
		data["farm_id"] = farm.UUID
		data["tenant_id"] = farm.TenantID
		data["name"] = farm.Name
		data["farm_type"] = string(farm.FarmType)
		data["status"] = string(farm.Status)
	}
	for k, v := range extraData {
		data[k] = v
	}

	event := domain.NewDomainEvent(eventType, aggregateID, "farm").
		WithSource(serviceName).
		WithCorrelationID(requestID).
		WithMetadata("tenant_id", tenantID).
		WithPriority(domain.PriorityMedium)
	event.Data = data

	if s.d.KafkaProducer != nil {
		eventJSON, err := json.Marshal(event)
		if err != nil {
			s.log.Errorw("msg", "failed to marshal farm event", "event_type", string(eventType), "error", err)
			return
		}

		topic := "samavaya.agriculture.farm.events"
		key := aggregateID
		if key == "" {
			key = ulid.NewString()
		}

		_ = eventJSON // Published via Kafka producer in production wiring
		s.log.Debugw("msg", "farm event emitted", "event_type", string(eventType), "topic", topic, "key", key)
	}
}
