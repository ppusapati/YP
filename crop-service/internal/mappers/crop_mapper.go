package mappers

import (
	"strings"
	"time"

	pb "p9e.in/samavaya/agriculture/crop-service/api/v1"
	cropmodels "p9e.in/samavaya/agriculture/crop-service/internal/models"
	pkgmodels "p9e.in/samavaya/packages/models"
	"p9e.in/samavaya/packages/ulid"

	"google.golang.org/protobuf/types/known/timestamppb"
)

// --- Category Mapping ---

// CategoryToProto converts a domain CropCategory to its proto enum value.
func CategoryToProto(c cropmodels.CropCategory) pb.CropCategory {
	switch c {
	case cropmodels.CropCategoryCereal:
		return pb.CropCategory_CROP_CATEGORY_CEREAL
	case cropmodels.CropCategoryLegume:
		return pb.CropCategory_CROP_CATEGORY_LEGUME
	case cropmodels.CropCategoryVegetable:
		return pb.CropCategory_CROP_CATEGORY_VEGETABLE
	case cropmodels.CropCategoryFruit:
		return pb.CropCategory_CROP_CATEGORY_FRUIT
	case cropmodels.CropCategoryOilseed:
		return pb.CropCategory_CROP_CATEGORY_OILSEED
	case cropmodels.CropCategoryFiber:
		return pb.CropCategory_CROP_CATEGORY_FIBER
	case cropmodels.CropCategorySpice:
		return pb.CropCategory_CROP_CATEGORY_SPICE
	default:
		return pb.CropCategory_CROP_CATEGORY_UNSPECIFIED
	}
}

// CategoryFromProto converts a proto CropCategory enum to the domain type.
func CategoryFromProto(c pb.CropCategory) cropmodels.CropCategory {
	switch c {
	case pb.CropCategory_CROP_CATEGORY_CEREAL:
		return cropmodels.CropCategoryCereal
	case pb.CropCategory_CROP_CATEGORY_LEGUME:
		return cropmodels.CropCategoryLegume
	case pb.CropCategory_CROP_CATEGORY_VEGETABLE:
		return cropmodels.CropCategoryVegetable
	case pb.CropCategory_CROP_CATEGORY_FRUIT:
		return cropmodels.CropCategoryFruit
	case pb.CropCategory_CROP_CATEGORY_OILSEED:
		return cropmodels.CropCategoryOilseed
	case pb.CropCategory_CROP_CATEGORY_FIBER:
		return cropmodels.CropCategoryFiber
	case pb.CropCategory_CROP_CATEGORY_SPICE:
		return cropmodels.CropCategorySpice
	default:
		return cropmodels.CropCategoryUnspecified
	}
}

// CategoryFromString converts a string to domain CropCategory.
func CategoryFromString(s string) cropmodels.CropCategory {
	switch strings.ToUpper(s) {
	case "CEREAL":
		return cropmodels.CropCategoryCereal
	case "LEGUME":
		return cropmodels.CropCategoryLegume
	case "VEGETABLE":
		return cropmodels.CropCategoryVegetable
	case "FRUIT":
		return cropmodels.CropCategoryFruit
	case "OILSEED":
		return cropmodels.CropCategoryOilseed
	case "FIBER":
		return cropmodels.CropCategoryFiber
	case "SPICE":
		return cropmodels.CropCategorySpice
	default:
		return cropmodels.CropCategoryUnspecified
	}
}

// --- Crop Mapping ---

// CropToProto converts a domain Crop to its protobuf representation.
func CropToProto(c *cropmodels.Crop) *pb.Crop {
	if c == nil {
		return nil
	}

	crop := &pb.Crop{
		Id:                     c.UUID,
		TenantId:               c.TenantID,
		Name:                   c.Name,
		ScientificName:         c.ScientificName,
		Family:                 c.Family,
		Category:               CategoryToProto(c.Category),
		Description:            c.Description,
		ImageUrl:               c.ImageURL,
		DiseaseSusceptibilities: c.DiseaseSusceptibilities,
		CompanionPlants:        c.CompanionPlants,
		RotationGroup:          c.RotationGroup,
		Version:                c.Version,
		CreatedAt:              timestamppb.New(c.CreatedAt),
	}

	if c.UpdatedAt != nil {
		crop.UpdatedAt = timestamppb.New(*c.UpdatedAt)
	}

	// Map nested relations
	if len(c.Varieties) > 0 {
		crop.Varieties = make([]*pb.CropVariety, len(c.Varieties))
		for i := range c.Varieties {
			crop.Varieties[i] = CropVarietyToProto(&c.Varieties[i])
		}
	}

	if len(c.GrowthStages) > 0 {
		crop.GrowthStages = make([]*pb.GrowthStage, len(c.GrowthStages))
		for i := range c.GrowthStages {
			crop.GrowthStages[i] = GrowthStageToProto(&c.GrowthStages[i])
		}
	}

	if c.Requirements != nil {
		crop.Requirements = CropRequirementsToProto(c.Requirements)
	}

	return crop
}

// CropFromCreateRequest builds a domain Crop from a CreateCropRequest.
func CropFromCreateRequest(req *pb.CreateCropRequest, userID string) *cropmodels.Crop {
	now := time.Now()
	return &cropmodels.Crop{
		BaseModel: baseModel(userID, now),
		TenantID:  req.GetTenantId(),
		Name:      strings.TrimSpace(req.GetName()),
		ScientificName: strings.TrimSpace(req.GetScientificName()),
		Family:         strings.TrimSpace(req.GetFamily()),
		Category:       CategoryFromProto(req.GetCategory()),
		Description:    req.GetDescription(),
		ImageURL:       req.GetImageUrl(),
		DiseaseSusceptibilities: req.GetDiseaseSusceptibilities(),
		CompanionPlants:        req.GetCompanionPlants(),
		RotationGroup:          req.GetRotationGroup(),
		Version:                1,
	}
}

// CropSliceToProto converts a slice of domain Crops to proto.
func CropSliceToProto(crops []*cropmodels.Crop) []*pb.Crop {
	result := make([]*pb.Crop, len(crops))
	for i, c := range crops {
		result[i] = CropToProto(c)
	}
	return result
}

// --- CropVariety Mapping ---

// CropVarietyToProto converts a domain CropVariety to proto.
func CropVarietyToProto(v *cropmodels.CropVariety) *pb.CropVariety {
	if v == nil {
		return nil
	}

	variety := &pb.CropVariety{
		Id:                          v.UUID,
		CropId:                      "", // Populated by caller if needed
		Name:                        v.Name,
		Description:                 v.Description,
		MaturityDays:                v.MaturityDays,
		YieldPotentialKgPerHectare:  v.YieldPotentialKgPerHectare,
		IsHybrid:                    v.IsHybrid,
		DiseaseResistance:           v.DiseaseResistance,
		SuitableRegions:             v.SuitableRegions,
		SeedRateKgPerHectare:        v.SeedRateKgPerHectare,
		CreatedAt:                   timestamppb.New(v.CreatedAt),
	}

	if v.UpdatedAt != nil {
		variety.UpdatedAt = timestamppb.New(*v.UpdatedAt)
	}

	return variety
}

// CropVarietyFromAddRequest builds a domain CropVariety from an AddVarietyRequest.
func CropVarietyFromAddRequest(req *pb.AddVarietyRequest, cropID int64, userID string) *cropmodels.CropVariety {
	now := time.Now()
	return &cropmodels.CropVariety{
		BaseModel:                  baseModel(userID, now),
		CropID:                     cropID,
		TenantID:                   req.GetTenantId(),
		Name:                       strings.TrimSpace(req.GetName()),
		Description:                req.GetDescription(),
		MaturityDays:               req.GetMaturityDays(),
		YieldPotentialKgPerHectare: req.GetYieldPotentialKgPerHectare(),
		IsHybrid:                   req.GetIsHybrid(),
		DiseaseResistance:          req.GetDiseaseResistance(),
		SuitableRegions:            req.GetSuitableRegions(),
		SeedRateKgPerHectare:       req.GetSeedRateKgPerHectare(),
	}
}

// CropVarietySliceToProto converts a slice of domain varieties to proto.
func CropVarietySliceToProto(varieties []*cropmodels.CropVariety) []*pb.CropVariety {
	result := make([]*pb.CropVariety, len(varieties))
	for i, v := range varieties {
		result[i] = CropVarietyToProto(v)
	}
	return result
}

// --- GrowthStage Mapping ---

// GrowthStageToProto converts a domain CropGrowthStage to proto.
func GrowthStageToProto(gs *cropmodels.CropGrowthStage) *pb.GrowthStage {
	if gs == nil {
		return nil
	}

	stage := &pb.GrowthStage{
		Id:                   gs.UUID,
		CropId:               "", // Populated by caller if needed
		Name:                 gs.Name,
		StageOrder:           gs.StageOrder,
		DurationDays:         gs.DurationDays,
		WaterRequirementMm:   gs.WaterRequirementMM,
		NutrientRequirements: gs.NutrientRequirements,
		Description:          gs.Description,
		OptimalTempMin:       gs.OptimalTempMin,
		OptimalTempMax:       gs.OptimalTempMax,
		CreatedAt:            timestamppb.New(gs.CreatedAt),
	}

	if gs.UpdatedAt != nil {
		stage.UpdatedAt = timestamppb.New(*gs.UpdatedAt)
	}

	return stage
}

// GrowthStageSliceToProto converts a slice of domain growth stages to proto.
func GrowthStageSliceToProto(stages []*cropmodels.CropGrowthStage) []*pb.GrowthStage {
	result := make([]*pb.GrowthStage, len(stages))
	for i, s := range stages {
		result[i] = GrowthStageToProto(s)
	}
	return result
}

// --- CropRequirements Mapping ---

// CropRequirementsToProto converts domain CropRequirements to proto.
func CropRequirementsToProto(r *cropmodels.CropRequirements) *pb.CropRequirements {
	if r == nil {
		return nil
	}

	req := &pb.CropRequirements{
		Id:                       r.UUID,
		CropId:                   "", // Populated by caller if needed
		OptimalTempMin:           r.OptimalTempMin,
		OptimalTempMax:           r.OptimalTempMax,
		OptimalHumidityMin:       r.OptimalHumidityMin,
		OptimalHumidityMax:       r.OptimalHumidityMax,
		OptimalSoilPhMin:        r.OptimalSoilPhMin,
		OptimalSoilPhMax:        r.OptimalSoilPhMax,
		WaterRequirementMmPerDay: r.WaterRequirementMMPerDay,
		SunlightHours:           r.SunlightHours,
		FrostTolerant:           r.FrostTolerant,
		DroughtTolerant:         r.DroughtTolerant,
		SoilTypePreference:      r.SoilTypePreference,
		NutrientRequirements:    r.NutrientRequirements,
		CreatedAt:               timestamppb.New(r.CreatedAt),
	}

	if r.UpdatedAt != nil {
		req.UpdatedAt = timestamppb.New(*r.UpdatedAt)
	}

	return req
}

// --- CropRecommendation Mapping ---

// CropRecommendationToProto converts a domain CropRecommendation to proto.
func CropRecommendationToProto(r *cropmodels.CropRecommendation) *pb.CropRecommendation {
	if r == nil {
		return nil
	}

	rec := &pb.CropRecommendation{
		Id:                    r.UUID,
		CropId:                "", // Populated by caller if needed
		TenantId:              r.TenantID,
		RecommendationType:    r.RecommendationType,
		Title:                 r.Title,
		Description:           r.Description,
		Severity:              r.Severity,
		ConfidenceScore:       r.ConfidenceScore,
		Parameters:            r.Parameters,
		ApplicableGrowthStage: r.ApplicableGrowthStage,
		CreatedAt:             timestamppb.New(r.CreatedAt),
	}

	if r.ValidFrom != nil {
		rec.ValidFrom = timestamppb.New(*r.ValidFrom)
	}
	if r.ValidUntil != nil {
		rec.ValidUntil = timestamppb.New(*r.ValidUntil)
	}

	return rec
}

// --- Helpers ---

func baseModel(userID string, now time.Time) pkgmodels.BaseModel {
	return pkgmodels.BaseModel{
		UUID:      ulid.NewString(),
		IsActive:  true,
		CreatedBy: userID,
		CreatedAt: now,
	}
}
