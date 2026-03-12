package mappers

import (
	"encoding/json"

	"google.golang.org/protobuf/types/known/timestamppb"

	farmmodels "p9e.in/samavaya/agriculture/farm-service/internal/models"
	pb "p9e.in/samavaya/agriculture/farm-service/api/v1"
	"p9e.in/samavaya/packages/convert/ptr"
)

// ---- Proto enum <-> Domain enum conversions ----

// ProtoFarmTypeToDomain converts a proto FarmType to the domain FarmType.
func ProtoFarmTypeToDomain(ft pb.FarmType) farmmodels.FarmType {
	switch ft {
	case pb.FarmType_FARM_TYPE_CROP:
		return farmmodels.FarmTypeCrop
	case pb.FarmType_FARM_TYPE_LIVESTOCK:
		return farmmodels.FarmTypeLivestock
	case pb.FarmType_FARM_TYPE_MIXED:
		return farmmodels.FarmTypeMixed
	case pb.FarmType_FARM_TYPE_AQUACULTURE:
		return farmmodels.FarmTypeAquaculture
	default:
		return farmmodels.FarmTypeUnspecified
	}
}

// DomainFarmTypeToProto converts a domain FarmType to the proto FarmType.
func DomainFarmTypeToProto(ft farmmodels.FarmType) pb.FarmType {
	switch ft {
	case farmmodels.FarmTypeCrop:
		return pb.FarmType_FARM_TYPE_CROP
	case farmmodels.FarmTypeLivestock:
		return pb.FarmType_FARM_TYPE_LIVESTOCK
	case farmmodels.FarmTypeMixed:
		return pb.FarmType_FARM_TYPE_MIXED
	case farmmodels.FarmTypeAquaculture:
		return pb.FarmType_FARM_TYPE_AQUACULTURE
	default:
		return pb.FarmType_FARM_TYPE_UNSPECIFIED
	}
}

// ProtoFarmStatusToDomain converts a proto FarmStatus to the domain FarmStatus.
func ProtoFarmStatusToDomain(s pb.FarmStatus) farmmodels.FarmStatus {
	switch s {
	case pb.FarmStatus_FARM_STATUS_ACTIVE:
		return farmmodels.FarmStatusActive
	case pb.FarmStatus_FARM_STATUS_INACTIVE:
		return farmmodels.FarmStatusInactive
	case pb.FarmStatus_FARM_STATUS_PENDING:
		return farmmodels.FarmStatusPending
	case pb.FarmStatus_FARM_STATUS_SUSPENDED:
		return farmmodels.FarmStatusSuspended
	case pb.FarmStatus_FARM_STATUS_ARCHIVED:
		return farmmodels.FarmStatusArchived
	default:
		return farmmodels.FarmStatusUnspecified
	}
}

// DomainFarmStatusToProto converts a domain FarmStatus to the proto FarmStatus.
func DomainFarmStatusToProto(s farmmodels.FarmStatus) pb.FarmStatus {
	switch s {
	case farmmodels.FarmStatusActive:
		return pb.FarmStatus_FARM_STATUS_ACTIVE
	case farmmodels.FarmStatusInactive:
		return pb.FarmStatus_FARM_STATUS_INACTIVE
	case farmmodels.FarmStatusPending:
		return pb.FarmStatus_FARM_STATUS_PENDING
	case farmmodels.FarmStatusSuspended:
		return pb.FarmStatus_FARM_STATUS_SUSPENDED
	case farmmodels.FarmStatusArchived:
		return pb.FarmStatus_FARM_STATUS_ARCHIVED
	default:
		return pb.FarmStatus_FARM_STATUS_UNSPECIFIED
	}
}

// ProtoSoilTypeToDomain converts a proto SoilType to the domain SoilType.
func ProtoSoilTypeToDomain(s pb.SoilType) farmmodels.SoilType {
	switch s {
	case pb.SoilType_SOIL_TYPE_CLAY:
		return farmmodels.SoilTypeClay
	case pb.SoilType_SOIL_TYPE_SANDY:
		return farmmodels.SoilTypeSandy
	case pb.SoilType_SOIL_TYPE_LOAMY:
		return farmmodels.SoilTypeLoamy
	case pb.SoilType_SOIL_TYPE_SILT:
		return farmmodels.SoilTypeSilt
	case pb.SoilType_SOIL_TYPE_PEAT:
		return farmmodels.SoilTypePeat
	case pb.SoilType_SOIL_TYPE_CHALKY:
		return farmmodels.SoilTypeChalky
	case pb.SoilType_SOIL_TYPE_LATERITE:
		return farmmodels.SoilTypeLaterite
	case pb.SoilType_SOIL_TYPE_BLACK:
		return farmmodels.SoilTypeBlack
	case pb.SoilType_SOIL_TYPE_RED:
		return farmmodels.SoilTypeRed
	case pb.SoilType_SOIL_TYPE_ALLUVIAL:
		return farmmodels.SoilTypeAlluvial
	default:
		return farmmodels.SoilTypeUnspecified
	}
}

// DomainSoilTypeToProto converts a domain SoilType to the proto SoilType.
func DomainSoilTypeToProto(s farmmodels.SoilType) pb.SoilType {
	switch s {
	case farmmodels.SoilTypeClay:
		return pb.SoilType_SOIL_TYPE_CLAY
	case farmmodels.SoilTypeSandy:
		return pb.SoilType_SOIL_TYPE_SANDY
	case farmmodels.SoilTypeLoamy:
		return pb.SoilType_SOIL_TYPE_LOAMY
	case farmmodels.SoilTypeSilt:
		return pb.SoilType_SOIL_TYPE_SILT
	case farmmodels.SoilTypePeat:
		return pb.SoilType_SOIL_TYPE_PEAT
	case farmmodels.SoilTypeChalky:
		return pb.SoilType_SOIL_TYPE_CHALKY
	case farmmodels.SoilTypeLaterite:
		return pb.SoilType_SOIL_TYPE_LATERITE
	case farmmodels.SoilTypeBlack:
		return pb.SoilType_SOIL_TYPE_BLACK
	case farmmodels.SoilTypeRed:
		return pb.SoilType_SOIL_TYPE_RED
	case farmmodels.SoilTypeAlluvial:
		return pb.SoilType_SOIL_TYPE_ALLUVIAL
	default:
		return pb.SoilType_SOIL_TYPE_UNSPECIFIED
	}
}

// ProtoClimateZoneToDomain converts a proto ClimateZone to the domain ClimateZone.
func ProtoClimateZoneToDomain(c pb.ClimateZone) farmmodels.ClimateZone {
	switch c {
	case pb.ClimateZone_CLIMATE_ZONE_TROPICAL:
		return farmmodels.ClimateZoneTropical
	case pb.ClimateZone_CLIMATE_ZONE_SUBTROPICAL:
		return farmmodels.ClimateZoneSubtropical
	case pb.ClimateZone_CLIMATE_ZONE_ARID:
		return farmmodels.ClimateZoneArid
	case pb.ClimateZone_CLIMATE_ZONE_SEMIARID:
		return farmmodels.ClimateZoneSemiarid
	case pb.ClimateZone_CLIMATE_ZONE_TEMPERATE:
		return farmmodels.ClimateZoneTemperate
	case pb.ClimateZone_CLIMATE_ZONE_CONTINENTAL:
		return farmmodels.ClimateZoneContinental
	case pb.ClimateZone_CLIMATE_ZONE_POLAR:
		return farmmodels.ClimateZonePolar
	case pb.ClimateZone_CLIMATE_ZONE_MEDITERRANEAN:
		return farmmodels.ClimateZoneMediterranean
	case pb.ClimateZone_CLIMATE_ZONE_MONSOON:
		return farmmodels.ClimateZoneMonsoon
	default:
		return farmmodels.ClimateZoneUnspecified
	}
}

// DomainClimateZoneToProto converts a domain ClimateZone to the proto ClimateZone.
func DomainClimateZoneToProto(c farmmodels.ClimateZone) pb.ClimateZone {
	switch c {
	case farmmodels.ClimateZoneTropical:
		return pb.ClimateZone_CLIMATE_ZONE_TROPICAL
	case farmmodels.ClimateZoneSubtropical:
		return pb.ClimateZone_CLIMATE_ZONE_SUBTROPICAL
	case farmmodels.ClimateZoneArid:
		return pb.ClimateZone_CLIMATE_ZONE_ARID
	case farmmodels.ClimateZoneSemiarid:
		return pb.ClimateZone_CLIMATE_ZONE_SEMIARID
	case farmmodels.ClimateZoneTemperate:
		return pb.ClimateZone_CLIMATE_ZONE_TEMPERATE
	case farmmodels.ClimateZoneContinental:
		return pb.ClimateZone_CLIMATE_ZONE_CONTINENTAL
	case farmmodels.ClimateZonePolar:
		return pb.ClimateZone_CLIMATE_ZONE_POLAR
	case farmmodels.ClimateZoneMediterranean:
		return pb.ClimateZone_CLIMATE_ZONE_MEDITERRANEAN
	case farmmodels.ClimateZoneMonsoon:
		return pb.ClimateZone_CLIMATE_ZONE_MONSOON
	default:
		return pb.ClimateZone_CLIMATE_ZONE_UNSPECIFIED
	}
}

// ---- Domain -> Proto conversions ----

// FarmToProto converts a domain Farm to its proto representation.
func FarmToProto(f *farmmodels.Farm) *pb.Farm {
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
func FarmBoundaryToProto(b *farmmodels.FarmBoundary) *pb.FarmBoundary {
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
func FarmOwnerToProto(o *farmmodels.FarmOwner) *pb.FarmOwner {
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
func CreateFarmRequestToDomain(req *pb.CreateFarmRequest, tenantID, userID string) *farmmodels.Farm {
	farm := &farmmodels.Farm{
		TenantID:          tenantID,
		Name:              req.GetName(),
		Description:       ptr.StringOrNil(req.GetDescription()),
		TotalAreaHectares: req.GetTotalAreaHectares(),
		FarmType:          ProtoFarmTypeToDomain(req.GetFarmType()),
		Status:            farmmodels.FarmStatusPending,
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

// CreateFarmOwnerFromProto converts a proto FarmOwner from the CreateFarm request to a domain FarmOwner.
func CreateFarmOwnerFromProto(o *pb.FarmOwner, farmID int64, farmUUID, tenantID, userID string) *farmmodels.FarmOwner {
	if o == nil {
		return nil
	}

	return &farmmodels.FarmOwner{
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
func FarmsToProto(farms []farmmodels.Farm) []*pb.Farm {
	if farms == nil {
		return nil
	}
	result := make([]*pb.Farm, len(farms))
	for i := range farms {
		result[i] = FarmToProto(&farms[i])
	}
	return result
}
