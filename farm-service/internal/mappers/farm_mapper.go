package mappers

import (
	"encoding/json"

	"google.golang.org/protobuf/types/known/timestamppb"

	"p9e.in/samavaya/agriculture/farm-service/internal/domain"
	pb "p9e.in/samavaya/agriculture/farm-service/api/v1"
	"p9e.in/samavaya/packages/convert/ptr"
)

// ---- Proto enum <-> Domain enum conversions ----

// ProtoFarmTypeToDomain converts a proto FarmType to the domain FarmType.
func ProtoFarmTypeToDomain(ft pb.FarmType) domain.FarmType {
	switch ft {
	case pb.FarmType_FARM_TYPE_CROP:
		return domain.FarmTypeCrop
	case pb.FarmType_FARM_TYPE_LIVESTOCK:
		return domain.FarmTypeLivestock
	case pb.FarmType_FARM_TYPE_MIXED:
		return domain.FarmTypeMixed
	case pb.FarmType_FARM_TYPE_AQUACULTURE:
		return domain.FarmTypeAquaculture
	default:
		return domain.FarmTypeUnspecified
	}
}

// DomainFarmTypeToProto converts a domain FarmType to the proto FarmType.
func DomainFarmTypeToProto(ft domain.FarmType) pb.FarmType {
	switch ft {
	case domain.FarmTypeCrop:
		return pb.FarmType_FARM_TYPE_CROP
	case domain.FarmTypeLivestock:
		return pb.FarmType_FARM_TYPE_LIVESTOCK
	case domain.FarmTypeMixed:
		return pb.FarmType_FARM_TYPE_MIXED
	case domain.FarmTypeAquaculture:
		return pb.FarmType_FARM_TYPE_AQUACULTURE
	default:
		return pb.FarmType_FARM_TYPE_UNSPECIFIED
	}
}

// ProtoFarmStatusToDomain converts a proto FarmStatus to the domain FarmStatus.
func ProtoFarmStatusToDomain(s pb.FarmStatus) domain.FarmStatus {
	switch s {
	case pb.FarmStatus_FARM_STATUS_ACTIVE:
		return domain.FarmStatusActive
	case pb.FarmStatus_FARM_STATUS_INACTIVE:
		return domain.FarmStatusInactive
	case pb.FarmStatus_FARM_STATUS_PENDING:
		return domain.FarmStatusPending
	case pb.FarmStatus_FARM_STATUS_SUSPENDED:
		return domain.FarmStatusSuspended
	case pb.FarmStatus_FARM_STATUS_ARCHIVED:
		return domain.FarmStatusArchived
	default:
		return domain.FarmStatusUnspecified
	}
}

// DomainFarmStatusToProto converts a domain FarmStatus to the proto FarmStatus.
func DomainFarmStatusToProto(s domain.FarmStatus) pb.FarmStatus {
	switch s {
	case domain.FarmStatusActive:
		return pb.FarmStatus_FARM_STATUS_ACTIVE
	case domain.FarmStatusInactive:
		return pb.FarmStatus_FARM_STATUS_INACTIVE
	case domain.FarmStatusPending:
		return pb.FarmStatus_FARM_STATUS_PENDING
	case domain.FarmStatusSuspended:
		return pb.FarmStatus_FARM_STATUS_SUSPENDED
	case domain.FarmStatusArchived:
		return pb.FarmStatus_FARM_STATUS_ARCHIVED
	default:
		return pb.FarmStatus_FARM_STATUS_UNSPECIFIED
	}
}

// ProtoSoilTypeToDomain converts a proto SoilType to the domain SoilType.
func ProtoSoilTypeToDomain(s pb.SoilType) domain.SoilType {
	switch s {
	case pb.SoilType_SOIL_TYPE_CLAY:
		return domain.SoilTypeClay
	case pb.SoilType_SOIL_TYPE_SANDY:
		return domain.SoilTypeSandy
	case pb.SoilType_SOIL_TYPE_LOAMY:
		return domain.SoilTypeLoamy
	case pb.SoilType_SOIL_TYPE_SILT:
		return domain.SoilTypeSilt
	case pb.SoilType_SOIL_TYPE_PEAT:
		return domain.SoilTypePeat
	case pb.SoilType_SOIL_TYPE_CHALKY:
		return domain.SoilTypeChalky
	case pb.SoilType_SOIL_TYPE_LATERITE:
		return domain.SoilTypeLaterite
	case pb.SoilType_SOIL_TYPE_BLACK:
		return domain.SoilTypeBlack
	case pb.SoilType_SOIL_TYPE_RED:
		return domain.SoilTypeRed
	case pb.SoilType_SOIL_TYPE_ALLUVIAL:
		return domain.SoilTypeAlluvial
	default:
		return domain.SoilTypeUnspecified
	}
}

// DomainSoilTypeToProto converts a domain SoilType to the proto SoilType.
func DomainSoilTypeToProto(s domain.SoilType) pb.SoilType {
	switch s {
	case domain.SoilTypeClay:
		return pb.SoilType_SOIL_TYPE_CLAY
	case domain.SoilTypeSandy:
		return pb.SoilType_SOIL_TYPE_SANDY
	case domain.SoilTypeLoamy:
		return pb.SoilType_SOIL_TYPE_LOAMY
	case domain.SoilTypeSilt:
		return pb.SoilType_SOIL_TYPE_SILT
	case domain.SoilTypePeat:
		return pb.SoilType_SOIL_TYPE_PEAT
	case domain.SoilTypeChalky:
		return pb.SoilType_SOIL_TYPE_CHALKY
	case domain.SoilTypeLaterite:
		return pb.SoilType_SOIL_TYPE_LATERITE
	case domain.SoilTypeBlack:
		return pb.SoilType_SOIL_TYPE_BLACK
	case domain.SoilTypeRed:
		return pb.SoilType_SOIL_TYPE_RED
	case domain.SoilTypeAlluvial:
		return pb.SoilType_SOIL_TYPE_ALLUVIAL
	default:
		return pb.SoilType_SOIL_TYPE_UNSPECIFIED
	}
}

// ProtoClimateZoneToDomain converts a proto ClimateZone to the domain ClimateZone.
func ProtoClimateZoneToDomain(c pb.ClimateZone) domain.ClimateZone {
	switch c {
	case pb.ClimateZone_CLIMATE_ZONE_TROPICAL:
		return domain.ClimateZoneTropical
	case pb.ClimateZone_CLIMATE_ZONE_SUBTROPICAL:
		return domain.ClimateZoneSubtropical
	case pb.ClimateZone_CLIMATE_ZONE_ARID:
		return domain.ClimateZoneArid
	case pb.ClimateZone_CLIMATE_ZONE_SEMIARID:
		return domain.ClimateZoneSemiarid
	case pb.ClimateZone_CLIMATE_ZONE_TEMPERATE:
		return domain.ClimateZoneTemperate
	case pb.ClimateZone_CLIMATE_ZONE_CONTINENTAL:
		return domain.ClimateZoneContinental
	case pb.ClimateZone_CLIMATE_ZONE_POLAR:
		return domain.ClimateZonePolar
	case pb.ClimateZone_CLIMATE_ZONE_MEDITERRANEAN:
		return domain.ClimateZoneMediterranean
	case pb.ClimateZone_CLIMATE_ZONE_MONSOON:
		return domain.ClimateZoneMonsoon
	default:
		return domain.ClimateZoneUnspecified
	}
}

// DomainClimateZoneToProto converts a domain ClimateZone to the proto ClimateZone.
func DomainClimateZoneToProto(c domain.ClimateZone) pb.ClimateZone {
	switch c {
	case domain.ClimateZoneTropical:
		return pb.ClimateZone_CLIMATE_ZONE_TROPICAL
	case domain.ClimateZoneSubtropical:
		return pb.ClimateZone_CLIMATE_ZONE_SUBTROPICAL
	case domain.ClimateZoneArid:
		return pb.ClimateZone_CLIMATE_ZONE_ARID
	case domain.ClimateZoneSemiarid:
		return pb.ClimateZone_CLIMATE_ZONE_SEMIARID
	case domain.ClimateZoneTemperate:
		return pb.ClimateZone_CLIMATE_ZONE_TEMPERATE
	case domain.ClimateZoneContinental:
		return pb.ClimateZone_CLIMATE_ZONE_CONTINENTAL
	case domain.ClimateZonePolar:
		return pb.ClimateZone_CLIMATE_ZONE_POLAR
	case domain.ClimateZoneMediterranean:
		return pb.ClimateZone_CLIMATE_ZONE_MEDITERRANEAN
	case domain.ClimateZoneMonsoon:
		return pb.ClimateZone_CLIMATE_ZONE_MONSOON
	default:
		return pb.ClimateZone_CLIMATE_ZONE_UNSPECIFIED
	}
}

// ---- Domain -> Proto conversions ----

// FarmToProto converts a domain Farm to its proto representation.
func FarmToProto(f *domain.Farm) *pb.Farm {
	if f == nil {
		return nil
	}

	farm := &pb.Farm{
		Id:                f.UUID,
		TenantId:          f.TenantID,
		Name:              f.Name,
		Description:       ptr.Deref(f.Description),
		TotalAreaHectares: f.TotalAreaHectares,
		FarmType:          DomainFarmTypeToProto(f.FarmType),
		Status:            DomainFarmStatusToProto(f.Status),
		ElevationMeters:   ptr.Deref(f.ElevationMeters),
		Address:           ptr.Deref(f.Address),
		Region:            ptr.Deref(f.Region),
		Country:           ptr.Deref(f.Country),
		Version:           f.Version,
		CreatedBy:         f.CreatedBy,
		UpdatedBy:         ptr.Deref(f.UpdatedBy),
		CreatedAt:         timestamppb.New(f.CreatedAt),
	}

	if f.Latitude != nil && f.Longitude != nil {
		farm.Location = &pb.FarmLocation{
			Latitude:        *f.Latitude,
			Longitude:       *f.Longitude,
			ElevationMeters: ptr.Deref(f.ElevationMeters),
		}
	}

	if f.SoilType != nil {
		farm.SoilType = DomainSoilTypeToProto(*f.SoilType)
	}

	if f.ClimateZone != nil {
		farm.ClimateZone = DomainClimateZoneToProto(*f.ClimateZone)
	}

	if f.UpdatedAt != nil {
		farm.UpdatedAt = timestamppb.New(*f.UpdatedAt)
	}

	// Convert metadata from JSON to map
	if len(f.Metadata) > 0 {
		md := make(map[string]string)
		_ = json.Unmarshal(f.Metadata, &md)
		farm.Metadata = md
	}

	// Convert boundary if loaded
	if f.Boundary != nil {
		farm.Boundary = FarmBoundaryToProto(f.Boundary)
	}

	// Convert owners if loaded
	if len(f.Owners) > 0 {
		farm.Owners = make([]*pb.FarmOwner, len(f.Owners))
		for i := range f.Owners {
			farm.Owners[i] = FarmOwnerToProto(&f.Owners[i])
		}
	}

	return farm
}

// FarmBoundaryToProto converts a domain FarmBoundary to its proto representation.
func FarmBoundaryToProto(b *domain.FarmBoundary) *pb.FarmBoundary {
	if b == nil {
		return nil
	}

	boundary := &pb.FarmBoundary{
		Id:              b.UUID,
		FarmId:          b.FarmUUID,
		Geojson:         b.GeoJSON,
		AreaHectares:    b.AreaHectares,
		PerimeterMeters: b.PerimeterMeters,
		CreatedAt:       timestamppb.New(b.CreatedAt),
	}

	if b.UpdatedAt != nil {
		boundary.UpdatedAt = timestamppb.New(*b.UpdatedAt)
	}

	return boundary
}

// FarmOwnerToProto converts a domain FarmOwner to its proto representation.
func FarmOwnerToProto(o *domain.FarmOwner) *pb.FarmOwner {
	if o == nil {
		return nil
	}

	owner := &pb.FarmOwner{
		Id:                  o.UUID,
		FarmId:              o.FarmUUID,
		UserId:              o.UserID,
		OwnerName:           o.OwnerName,
		Email:               ptr.Deref(o.Email),
		Phone:               ptr.Deref(o.Phone),
		IsPrimary:           o.IsPrimary,
		OwnershipPercentage: o.OwnershipPercentage,
		AcquiredAt:          timestamppb.New(o.AcquiredAt),
		CreatedAt:           timestamppb.New(o.CreatedAt),
	}

	if o.UpdatedAt != nil {
		owner.UpdatedAt = timestamppb.New(*o.UpdatedAt)
	}

	return owner
}

// ---- Proto -> Domain conversions ----

// CreateFarmRequestToDomain converts a CreateFarm proto request to a domain Farm.
func CreateFarmRequestToDomain(req *pb.CreateFarmRequest, tenantID, userID string) *domain.Farm {
	farm := &domain.Farm{
		TenantID:          tenantID,
		Name:              req.GetName(),
		Description:       ptr.StringOrNil(req.GetDescription()),
		TotalAreaHectares: req.GetTotalAreaHectares(),
		FarmType:          ProtoFarmTypeToDomain(req.GetFarmType()),
		Status:            domain.FarmStatusPending,
		ElevationMeters:   Float64OrNil(req.GetElevationMeters()),
		Address:           ptr.StringOrNil(req.GetAddress()),
		Region:            ptr.StringOrNil(req.GetRegion()),
		Country:           ptr.StringOrNil(req.GetCountry()),
		Version:           1,
	}

	farm.CreatedBy = userID

	if req.GetLocation() != nil {
		farm.Latitude = ptr.Float64(req.GetLocation().GetLatitude())
		farm.Longitude = ptr.Float64(req.GetLocation().GetLongitude())
		if req.GetLocation().GetElevationMeters() != 0 {
			farm.ElevationMeters = ptr.Float64(req.GetLocation().GetElevationMeters())
		}
	}

	if req.GetSoilType() != pb.SoilType_SOIL_TYPE_UNSPECIFIED {
		st := ProtoSoilTypeToDomain(req.GetSoilType())
		farm.SoilType = &st
	}

	if req.GetClimateZone() != pb.ClimateZone_CLIMATE_ZONE_UNSPECIFIED {
		cz := ProtoClimateZoneToDomain(req.GetClimateZone())
		farm.ClimateZone = &cz
	}

	if len(req.GetMetadata()) > 0 {
		md, _ := json.Marshal(req.GetMetadata())
		farm.Metadata = md
	}

	return farm
}

// UpdateFarmRequestToDomain converts an UpdateFarm proto request to a domain Farm.
func UpdateFarmRequestToDomain(req *pb.UpdateFarmRequest, tenantID, userID string) *domain.Farm {
	farm := &domain.Farm{
		TenantID: tenantID,
	}

	farm.UUID = req.GetId()
	farm.UpdatedBy = ptr.String(userID)

	if req.GetName() != "" {
		farm.Name = req.GetName()
	}
	if req.GetDescription() != "" {
		farm.Description = ptr.String(req.GetDescription())
	}
	if req.GetTotalAreaHectares() != 0 {
		farm.TotalAreaHectares = req.GetTotalAreaHectares()
	}
	if req.GetFarmType() != pb.FarmType_FARM_TYPE_UNSPECIFIED {
		farm.FarmType = ProtoFarmTypeToDomain(req.GetFarmType())
	}
	if req.GetStatus() != pb.FarmStatus_FARM_STATUS_UNSPECIFIED {
		farm.Status = ProtoFarmStatusToDomain(req.GetStatus())
	}
	if req.GetElevationMeters() != 0 {
		farm.ElevationMeters = Float64OrNil(req.GetElevationMeters())
	}
	if req.GetAddress() != "" {
		farm.Address = ptr.String(req.GetAddress())
	}
	if req.GetRegion() != "" {
		farm.Region = ptr.String(req.GetRegion())
	}
	if req.GetCountry() != "" {
		farm.Country = ptr.String(req.GetCountry())
	}
	if req.GetSoilType() != pb.SoilType_SOIL_TYPE_UNSPECIFIED {
		st := ProtoSoilTypeToDomain(req.GetSoilType())
		farm.SoilType = &st
	}
	if req.GetClimateZone() != pb.ClimateZone_CLIMATE_ZONE_UNSPECIFIED {
		cz := ProtoClimateZoneToDomain(req.GetClimateZone())
		farm.ClimateZone = &cz
	}
	if req.GetLocation() != nil {
		farm.Latitude = ptr.Float64(req.GetLocation().GetLatitude())
		farm.Longitude = ptr.Float64(req.GetLocation().GetLongitude())
		if req.GetLocation().GetElevationMeters() != 0 {
			farm.ElevationMeters = ptr.Float64(req.GetLocation().GetElevationMeters())
		}
	}
	if len(req.GetMetadata()) > 0 {
		md, _ := json.Marshal(req.GetMetadata())
		farm.Metadata = md
	}

	return farm
}

// CreateFarmOwnerFromProto converts a proto FarmOwner from the CreateFarm request to a domain FarmOwner.
func CreateFarmOwnerFromProto(o *pb.FarmOwner, farmID int64, farmUUID, tenantID, userID string) *domain.FarmOwner {
	if o == nil {
		return nil
	}

	return &domain.FarmOwner{
		FarmID:              farmID,
		FarmUUID:            farmUUID,
		TenantID:            tenantID,
		UserID:              o.GetUserId(),
		OwnerName:           o.GetOwnerName(),
		Email:               ptr.StringOrNil(o.GetEmail()),
		Phone:               ptr.StringOrNil(o.GetPhone()),
		IsPrimary:           true,
		OwnershipPercentage: o.GetOwnershipPercentage(),
		CreatedBy:           userID,
	}
}

// Float64OrNil returns a pointer to f if non-zero, otherwise nil.
func Float64OrNil(f float64) *float64 {
	if f == 0 {
		return nil
	}
	return &f
}

// FarmsToProto converts a slice of domain Farms to their proto representations.
func FarmsToProto(farms []domain.Farm) []*pb.Farm {
	if farms == nil {
		return nil
	}
	result := make([]*pb.Farm, len(farms))
	for i := range farms {
		result[i] = FarmToProto(&farms[i])
	}
	return result
}

// ---- Management Unit enum conversions ----

func ProtoManagementUnitTypeToDomain(t pb.ManagementUnitType) domain.ManagementUnitType {
	switch t {
	case pb.ManagementUnitType_UNIT_TYPE_ZONE:
		return domain.ManagementUnitTypeZone
	case pb.ManagementUnitType_UNIT_TYPE_BLOCK:
		return domain.ManagementUnitTypeBlock
	case pb.ManagementUnitType_UNIT_TYPE_SECTION:
		return domain.ManagementUnitTypeSection
	case pb.ManagementUnitType_UNIT_TYPE_PLOT:
		return domain.ManagementUnitTypePlot
	default:
		return domain.ManagementUnitTypeUnspecified
	}
}

func DomainManagementUnitTypeToProto(t domain.ManagementUnitType) pb.ManagementUnitType {
	switch t {
	case domain.ManagementUnitTypeZone:
		return pb.ManagementUnitType_UNIT_TYPE_ZONE
	case domain.ManagementUnitTypeBlock:
		return pb.ManagementUnitType_UNIT_TYPE_BLOCK
	case domain.ManagementUnitTypeSection:
		return pb.ManagementUnitType_UNIT_TYPE_SECTION
	case domain.ManagementUnitTypePlot:
		return pb.ManagementUnitType_UNIT_TYPE_PLOT
	default:
		return pb.ManagementUnitType_UNIT_TYPE_UNSPECIFIED
	}
}

func ProtoManagementUnitStatusToDomain(s pb.ManagementUnitStatus) domain.ManagementUnitStatus {
	switch s {
	case pb.ManagementUnitStatus_UNIT_STATUS_ACTIVE:
		return domain.ManagementUnitStatusActive
	case pb.ManagementUnitStatus_UNIT_STATUS_INACTIVE:
		return domain.ManagementUnitStatusInactive
	case pb.ManagementUnitStatus_UNIT_STATUS_ARCHIVED:
		return domain.ManagementUnitStatusArchived
	default:
		return domain.ManagementUnitStatusUnspecified
	}
}

func DomainManagementUnitStatusToProto(s domain.ManagementUnitStatus) pb.ManagementUnitStatus {
	switch s {
	case domain.ManagementUnitStatusActive:
		return pb.ManagementUnitStatus_UNIT_STATUS_ACTIVE
	case domain.ManagementUnitStatusInactive:
		return pb.ManagementUnitStatus_UNIT_STATUS_INACTIVE
	case domain.ManagementUnitStatusArchived:
		return pb.ManagementUnitStatus_UNIT_STATUS_ARCHIVED
	default:
		return pb.ManagementUnitStatus_UNIT_STATUS_UNSPECIFIED
	}
}

// ---- Management Unit domain <-> proto conversions ----

func ManagementUnitToProto(u *domain.ManagementUnit) *pb.ManagementUnit {
	if u == nil {
		return nil
	}
	unit := &pb.ManagementUnit{
		Id:              u.ID,
		TenantId:        u.TenantID,
		FarmId:          u.FarmID,
		ParentUnitId:    ptr.Deref(u.ParentUnitID),
		Name:            u.Name,
		Description:     ptr.Deref(u.Description),
		UnitType:        DomainManagementUnitTypeToProto(u.UnitType),
		AreaHectares:    ptr.Deref(u.AreaHectares),
		BoundaryGeojson: ptr.Deref(u.BoundaryGeoJSON),
		ManagerId:       ptr.Deref(u.ManagerID),
		Status:          DomainManagementUnitStatusToProto(u.Status),
		FieldIds:        u.FieldIDs,
		Version:         u.Version,
		CreatedBy:       u.CreatedBy,
		CreatedAt:       timestamppb.New(u.CreatedAt),
		UpdatedAt:       timestamppb.New(u.UpdatedAt),
	}
	return unit
}

func ManagementUnitsToProto(units []domain.ManagementUnit) []*pb.ManagementUnit {
	if units == nil {
		return nil
	}
	result := make([]*pb.ManagementUnit, len(units))
	for i := range units {
		result[i] = ManagementUnitToProto(&units[i])
	}
	return result
}
