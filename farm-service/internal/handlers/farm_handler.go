package handlers

import (
	"context"
	"fmt"
	"strconv"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"

	pb "p9e.in/samavaya/agriculture/farm-service/api/v1"
	"p9e.in/samavaya/agriculture/farm-service/internal/mappers"
	farmmodels "p9e.in/samavaya/agriculture/farm-service/internal/models"
	"p9e.in/samavaya/agriculture/farm-service/internal/services"
)

// FarmHandler implements the ConnectRPC FarmService handler.
type FarmHandler struct {
	d       deps.ServiceDeps
	service services.FarmService
	log     *p9log.Helper
}

// NewFarmHandler creates a new FarmHandler.
func NewFarmHandler(d deps.ServiceDeps, service services.FarmService) *FarmHandler {
	return &FarmHandler{
		d:       d,
		service: service,
		log:     p9log.NewHelper(p9log.With(d.Log, "component", "FarmHandler")),
	}
}

// CreateFarm handles farm creation requests.
func (h *FarmHandler) CreateFarm(ctx context.Context, req *pb.CreateFarmRequest) (*pb.CreateFarmResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	h.log.Infow("msg", "CreateFarm request", "tenant_id", tenantID, "request_id", requestID)

	if req.GetName() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm name is required")
	}

	farm := mappers.CreateFarmRequestToDomain(req, tenantID, userID)

	var ownerInfo *farmmodels.FarmOwner
	if req.GetOwner() != nil {
		ownerInfo = &farmmodels.FarmOwner{
			UserID:              req.GetOwner().GetUserId(),
			OwnerName:           req.GetOwner().GetOwnerName(),
			IsPrimary:           true,
			OwnershipPercentage: req.GetOwner().GetOwnershipPercentage(),
		}
		if req.GetOwner().GetEmail() != "" {
			email := req.GetOwner().GetEmail()
			ownerInfo.Email = &email
		}
		if req.GetOwner().GetPhone() != "" {
			phone := req.GetOwner().GetPhone()
			ownerInfo.Phone = &phone
		}
	}

	created, err := h.service.CreateFarm(ctx, farm, ownerInfo)
	if err != nil {
		h.log.Errorw("msg", "CreateFarm failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.CreateFarmResponse{
		Farm: mappers.FarmToProto(created),
	}, nil
}

// GetFarm handles get farm requests.
func (h *FarmHandler) GetFarm(ctx context.Context, req *pb.GetFarmRequest) (*pb.GetFarmResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetFarm request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm ID is required")
	}

	farm, err := h.service.GetFarm(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetFarmResponse{
		Farm: mappers.FarmToProto(farm),
	}, nil
}

// ListFarms handles list farms requests with filtering and pagination.
func (h *FarmHandler) ListFarms(ctx context.Context, req *pb.ListFarmsRequest) (*pb.ListFarmsResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListFarms request", "request_id", requestID)

	params := farmmodels.ListFarmsParams{
		PageSize: req.GetPageSize(),
	}

	// Parse page token as offset
	if req.GetPageToken() != "" {
		offset, err := strconv.ParseInt(req.GetPageToken(), 10, 32)
		if err == nil {
			params.Offset = int32(offset)
		}
	}

	// Apply filters
	if req.GetFarmType() != pb.FarmType_FARM_TYPE_UNSPECIFIED {
		ft := mappers.ProtoFarmTypeToDomain(req.GetFarmType())
		params.FarmType = &ft
	}
	if req.GetStatus() != pb.FarmStatus_FARM_STATUS_UNSPECIFIED {
		st := mappers.ProtoFarmStatusToDomain(req.GetStatus())
		params.Status = &st
	}
	if req.GetRegion() != "" {
		region := req.GetRegion()
		params.Region = &region
	}
	if req.GetCountry() != "" {
		country := req.GetCountry()
		params.Country = &country
	}
	if req.GetClimateZone() != pb.ClimateZone_CLIMATE_ZONE_UNSPECIFIED {
		cz := mappers.ProtoClimateZoneToDomain(req.GetClimateZone())
		params.ClimateZone = &cz
	}
	if req.GetSearch() != "" {
		search := req.GetSearch()
		params.Search = &search
	}

	farms, totalCount, err := h.service.ListFarms(ctx, params)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.ListFarmsResponse{
		Farms:      mappers.FarmsToProto(farms),
		TotalCount: totalCount,
	}

	// Compute next page token
	nextOffset := params.Offset + params.PageSize
	if nextOffset < totalCount {
		resp.NextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return resp, nil
}

// UpdateFarm handles farm update requests.
func (h *FarmHandler) UpdateFarm(ctx context.Context, req *pb.UpdateFarmRequest) (*pb.UpdateFarmResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	h.log.Infow("msg", "UpdateFarm request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm ID is required")
	}

	farm := &farmmodels.Farm{
		TenantID: tenantID,
	}
	farm.UUID = req.GetId()

	// Apply update mask fields or all provided fields
	if req.GetName() != "" {
		farm.Name = req.GetName()
	}
	if req.GetDescription() != "" {
		desc := req.GetDescription()
		farm.Description = &desc
	}
	if req.GetTotalAreaHectares() > 0 {
		farm.TotalAreaHectares = req.GetTotalAreaHectares()
	}
	if req.GetLocation() != nil {
		lat := req.GetLocation().GetLatitude()
		lng := req.GetLocation().GetLongitude()
		farm.Latitude = &lat
		farm.Longitude = &lng
		if req.GetLocation().GetElevationMeters() != 0 {
			elev := req.GetLocation().GetElevationMeters()
			farm.ElevationMeters = &elev
		}
	}
	if req.GetFarmType() != pb.FarmType_FARM_TYPE_UNSPECIFIED {
		farm.FarmType = mappers.ProtoFarmTypeToDomain(req.GetFarmType())
	}
	if req.GetStatus() != pb.FarmStatus_FARM_STATUS_UNSPECIFIED {
		farm.Status = mappers.ProtoFarmStatusToDomain(req.GetStatus())
	}
	if req.GetSoilType() != pb.SoilType_SOIL_TYPE_UNSPECIFIED {
		st := mappers.ProtoSoilTypeToDomain(req.GetSoilType())
		farm.SoilType = &st
	}
	if req.GetClimateZone() != pb.ClimateZone_CLIMATE_ZONE_UNSPECIFIED {
		cz := mappers.ProtoClimateZoneToDomain(req.GetClimateZone())
		farm.ClimateZone = &cz
	}
	if req.GetElevationMeters() != 0 {
		elev := req.GetElevationMeters()
		farm.ElevationMeters = &elev
	}
	if req.GetAddress() != "" {
		addr := req.GetAddress()
		farm.Address = &addr
	}
	if req.GetRegion() != "" {
		region := req.GetRegion()
		farm.Region = &region
	}
	if req.GetCountry() != "" {
		country := req.GetCountry()
		farm.Country = &country
	}

	updatedBy := userID
	farm.UpdatedBy = &updatedBy

	updated, err := h.service.UpdateFarm(ctx, farm)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.UpdateFarmResponse{
		Farm: mappers.FarmToProto(updated),
	}, nil
}

// DeleteFarm handles farm deletion requests.
func (h *FarmHandler) DeleteFarm(ctx context.Context, req *pb.DeleteFarmRequest) (*pb.DeleteFarmResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "DeleteFarm request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm ID is required")
	}

	err := h.service.DeleteFarm(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.DeleteFarmResponse{
		Success: true,
	}, nil
}

// SetFarmBoundary handles set boundary requests.
func (h *FarmHandler) SetFarmBoundary(ctx context.Context, req *pb.SetFarmBoundaryRequest) (*pb.SetFarmBoundaryResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "SetFarmBoundary request", "farm_id", req.GetFarmId(), "request_id", requestID)

	if req.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}
	if req.GetGeojson() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "geojson is required")
	}

	boundary, err := h.service.SetFarmBoundary(ctx, req.GetFarmId(), req.GetGeojson())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.SetFarmBoundaryResponse{
		Boundary: mappers.FarmBoundaryToProto(boundary),
	}, nil
}

// GetFarmBoundary handles get boundary requests.
func (h *FarmHandler) GetFarmBoundary(ctx context.Context, req *pb.GetFarmBoundaryRequest) (*pb.GetFarmBoundaryResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetFarmBoundary request", "farm_id", req.GetFarmId(), "request_id", requestID)

	if req.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}

	boundary, err := h.service.GetFarmBoundary(ctx, req.GetFarmId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetFarmBoundaryResponse{
		Boundary: mappers.FarmBoundaryToProto(boundary),
	}, nil
}

// TransferOwnership handles ownership transfer requests.
func (h *FarmHandler) TransferOwnership(ctx context.Context, req *pb.TransferOwnershipRequest) (*pb.TransferOwnershipResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "TransferOwnership request",
		"farm_id", req.GetFarmId(),
		"from_user", req.GetFromUserId(),
		"to_user", req.GetToUserId(),
		"request_id", requestID,
	)

	if req.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}
	if req.GetFromUserId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "from_user_id is required")
	}
	if req.GetToUserId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "to_user_id is required")
	}
	if req.GetToOwnerName() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "to_owner_name is required")
	}

	params := farmmodels.TransferOwnershipParams{
		FarmUUID:            req.GetFarmId(),
		FromUserID:          req.GetFromUserId(),
		ToUserID:            req.GetToUserId(),
		ToOwnerName:         req.GetToOwnerName(),
		ToEmail:             req.GetToEmail(),
		ToPhone:             req.GetToPhone(),
		OwnershipPercentage: req.GetOwnershipPercentage(),
	}

	farm, err := h.service.TransferOwnership(ctx, params)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.TransferOwnershipResponse{
		Farm: mappers.FarmToProto(farm),
	}, nil
}
