package mappers

import (
	"encoding/json"

	pb "p9e.in/samavaya/agriculture/plant-diagnosis-service/api/v1"
	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/models"
	"p9e.in/samavaya/packages/convert/ptr"

	"google.golang.org/protobuf/types/known/timestamppb"
)

// ─────────────────────────────────────────────────────────────────────────────
// Proto → Domain  (inbound)
// ─────────────────────────────────────────────────────────────────────────────

// ImageInputToModel converts a proto ImageInput to a domain DiagnosisImage.
func ImageInputToModel(in *pb.ImageInput) models.DiagnosisImage {
	return models.DiagnosisImage{
		ImageURL:  in.GetImageUrl(),
		ImageType: protoImageTypeToString(in.GetImageType()),
		MimeType:  ptr.StringOrNil(in.GetMimeType()),
	}
}

// ImageInputsToModels converts a slice of proto ImageInput to domain models.
func ImageInputsToModels(inputs []*pb.ImageInput) []models.DiagnosisImage {
	out := make([]models.DiagnosisImage, 0, len(inputs))
	for _, in := range inputs {
		out = append(out, ImageInputToModel(in))
	}
	return out
}

// ─────────────────────────────────────────────────────────────────────────────
// Domain → Proto  (outbound)
// ─────────────────────────────────────────────────────────────────────────────

// DiagnosisRequestToProto converts a domain DiagnosisRequest to its proto message.
func DiagnosisRequestToProto(d *models.DiagnosisRequest) *pb.DiagnosisRequest {
	if d == nil {
		return nil
	}

	out := &pb.DiagnosisRequest{
		Id:             d.UUID,
		TenantId:       d.TenantID,
		FarmId:         d.FarmID,
		FieldId:        ptr.Deref(d.FieldID),
		PlantSpeciesId: ptr.Deref(d.PlantSpeciesID),
		Status:         diagnosisStatusToProto(d.Status),
		Notes:          ptr.Deref(d.Notes),
		CreatedBy:      d.CreatedBy,
		CreatedAt:      timestamppb.New(d.CreatedAt),
		Version:        d.Version,
	}

	if d.UpdatedAt != nil {
		out.UpdatedAt = timestamppb.New(*d.UpdatedAt)
	}

	// Map images
	out.Images = make([]*pb.DiagnosisImage, 0, len(d.Images))
	for i := range d.Images {
		out.Images = append(out.Images, DiagnosisImageToProto(&d.Images[i]))
	}

	// Map result
	if d.Result != nil {
		out.Result = DiagnosisResultToProto(d.Result)
	}

	return out
}

// DiagnosisImageToProto converts a domain DiagnosisImage to its proto message.
func DiagnosisImageToProto(img *models.DiagnosisImage) *pb.DiagnosisImage {
	if img == nil {
		return nil
	}
	out := &pb.DiagnosisImage{
		Id:         img.UUID,
		ImageUrl:   img.ImageURL,
		ImageType:  stringToProtoImageType(img.ImageType),
		SizeBytes:  ptr.Deref(img.SizeBytes),
		MimeType:   ptr.Deref(img.MimeType),
		Checksum:   ptr.Deref(img.Checksum),
		UploadedAt: timestamppb.New(img.UploadedAt),
	}
	return out
}

// DiagnosisResultToProto converts a domain DiagnosisResult to its proto message.
func DiagnosisResultToProto(r *models.DiagnosisResult) *pb.DiagnosisResult {
	if r == nil {
		return nil
	}

	out := &pb.DiagnosisResult{
		Id:                    r.UUID,
		DiagnosisRequestId:    "", // populated by caller if needed
		AiModelVersion:        r.AIModelVersion,
		ProcessingTimeMs:      r.ProcessingTimeMs,
		OverallHealthScore:    ptr.Deref(r.OverallHealthScore),
		Summary:               ptr.Deref(r.Summary),
		CreatedAt:             timestamppb.New(r.CreatedAt),
	}

	// Identified species
	if r.IdentifiedSpeciesID != nil {
		out.IdentifiedSpecies = &pb.PlantSpecies{
			Id:             ptr.Deref(r.IdentifiedSpeciesID),
			CommonName:     ptr.Deref(r.IdentifiedSpeciesName),
			Confidence:     ptr.Deref(r.IdentifiedSpeciesConf),
		}
	}

	// Detected diseases
	out.DetectedDiseases = unmarshalDiseases(r.DetectedDiseases)

	// Nutrient deficiencies
	out.NutrientDeficiencies = unmarshalNutrientDeficiencies(r.NutrientDeficiencies)

	// Pest damage
	out.PestDamage = unmarshalPestDamage(r.PestDamage)

	// Treatment recommendations
	out.TreatmentRecommendations = unmarshalStringSlice(r.TreatmentRecommendations)

	return out
}

// DiseaseCatalogToProto converts a domain DiseaseCatalog to the proto DiseaseInfo.
func DiseaseCatalogToProto(d *models.DiseaseCatalog) *pb.DiseaseInfo {
	if d == nil {
		return nil
	}
	out := &pb.DiseaseInfo{
		DiseaseId:      d.UUID,
		DiseaseName:    d.DiseaseName,
		ScientificName: ptr.Deref(d.ScientificName),
		Description:    ptr.Deref(d.Description),
		Symptoms:       ptr.Deref(d.Symptoms),
		Prevention:     ptr.Deref(d.Prevention),
	}
	out.TreatmentOptions = unmarshalStringSlice(d.TreatmentOptions)
	return out
}

// TreatmentPlanToProto converts a domain TreatmentPlan to the proto message.
func TreatmentPlanToProto(tp *models.TreatmentPlan) *pb.TreatmentPlan {
	if tp == nil {
		return nil
	}
	out := &pb.TreatmentPlan{
		Id:            tp.UUID,
		Title:         tp.Title,
		Description:   ptr.Deref(tp.Description),
		Priority:      severityStringToProto(tp.Priority),
		EstimatedCost: ptr.Deref(tp.EstimatedCost),
		EstimatedDays: ptr.Deref(tp.EstimatedDays),
		CreatedAt:     timestamppb.New(tp.CreatedAt),
	}

	// Steps
	var steps []models.TreatmentStep
	if len(tp.Steps) > 0 {
		_ = json.Unmarshal(tp.Steps, &steps)
	}
	out.Steps = make([]*pb.TreatmentStep, 0, len(steps))
	for _, s := range steps {
		out.Steps = append(out.Steps, &pb.TreatmentStep{
			StepNumber:   s.StepNumber,
			Action:       s.Action,
			Product:      s.Product,
			Dosage:       s.Dosage,
			Frequency:    s.Frequency,
			Notes:        s.Notes,
			DurationDays: s.DurationDays,
		})
	}

	return out
}

// IdentifiedSpeciesToProto maps domain IdentifiedSpecies to proto PlantSpecies.
func IdentifiedSpeciesToProto(s *models.IdentifiedSpecies) *pb.PlantSpecies {
	if s == nil {
		return nil
	}
	return &pb.PlantSpecies{
		Id:             s.ID,
		CommonName:     s.CommonName,
		ScientificName: s.ScientificName,
		Family:         s.Family,
		Confidence:     s.Confidence,
	}
}

// DetectedDiseaseToProto converts a domain DetectedDisease to proto DiseaseInfo.
func DetectedDiseaseToProto(d *models.DetectedDisease) *pb.DiseaseInfo {
	return &pb.DiseaseInfo{
		DiseaseId:        d.DiseaseID,
		DiseaseName:      d.DiseaseName,
		ScientificName:   d.ScientificName,
		ConfidenceScore:  d.ConfidenceScore,
		Severity:         severityStringToProto(string(d.Severity)),
		Description:      d.Description,
		Symptoms:         d.Symptoms,
		TreatmentOptions: d.TreatmentOptions,
		Prevention:       d.Prevention,
	}
}

// DetectedNutrientDeficiencyToProto converts domain to proto.
func DetectedNutrientDeficiencyToProto(n *models.DetectedNutrientDeficiency) *pb.NutrientDeficiency {
	return &pb.NutrientDeficiency{
		Nutrient:               n.Nutrient,
		ConfidenceScore:        n.ConfidenceScore,
		Severity:               severityStringToProto(string(n.Severity)),
		Description:            n.Description,
		VisualSymptoms:         n.VisualSymptoms,
		RecommendedFertilizers: n.RecommendedFertilizers,
		ApplicationMethod:      n.ApplicationMethod,
	}
}

// DetectedPestDamageToProto converts domain to proto.
func DetectedPestDamageToProto(p *models.DetectedPestDamage) *pb.PestDamage {
	return &pb.PestDamage{
		PestId:          p.PestID,
		PestName:        p.PestName,
		ScientificName:  p.ScientificName,
		ConfidenceScore: p.ConfidenceScore,
		DamageLevel:     severityStringToProto(string(p.DamageLevel)),
		Description:     p.Description,
		DamagePattern:   p.DamagePattern,
		ControlMethods:  p.ControlMethods,
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// AI inference response → Domain
// ─────────────────────────────────────────────────────────────────────────────

// AIResponseToResult converts an AIInferenceResponse into a DiagnosisResult ready for persistence.
func AIResponseToResult(resp *models.AIInferenceResponse, requestDBID int64) (*models.DiagnosisResult, error) {
	diseases, err := json.Marshal(resp.Diseases)
	if err != nil {
		return nil, err
	}
	nutrients, err := json.Marshal(resp.NutrientDeficiencies)
	if err != nil {
		return nil, err
	}
	pests, err := json.Marshal(resp.PestDamage)
	if err != nil {
		return nil, err
	}
	recommendations := make([]string, 0)
	for _, d := range resp.Diseases {
		recommendations = append(recommendations, d.TreatmentOptions...)
	}
	recsJSON, err := json.Marshal(recommendations)
	if err != nil {
		return nil, err
	}

	result := &models.DiagnosisResult{
		DiagnosisRequestID:       requestDBID,
		DetectedDiseases:         diseases,
		NutrientDeficiencies:     nutrients,
		PestDamage:               pests,
		TreatmentRecommendations: recsJSON,
		AIModelVersion:           resp.ModelVersion,
		ProcessingTimeMs:         resp.ProcessingTimeMs,
		OverallHealthScore:       &resp.OverallHealthScore,
		Summary:                  &resp.Summary,
	}

	if resp.Species != nil {
		result.IdentifiedSpeciesID = &resp.Species.ID
		result.IdentifiedSpeciesName = &resp.Species.CommonName
		result.IdentifiedSpeciesConf = &resp.Species.Confidence
	}

	return result, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Enum mapping helpers
// ─────────────────────────────────────────────────────────────────────────────

func protoImageTypeToString(t pb.ImageType) string {
	switch t {
	case pb.ImageType_IMAGE_TYPE_LEAF:
		return string(models.ImageTypeLeaf)
	case pb.ImageType_IMAGE_TYPE_STEM:
		return string(models.ImageTypeStem)
	case pb.ImageType_IMAGE_TYPE_FRUIT:
		return string(models.ImageTypeFruit)
	case pb.ImageType_IMAGE_TYPE_WHOLE_PLANT:
		return string(models.ImageTypeWholePlant)
	case pb.ImageType_IMAGE_TYPE_ROOT:
		return string(models.ImageTypeRoot)
	default:
		return string(models.ImageTypeLeaf)
	}
}

func stringToProtoImageType(s string) pb.ImageType {
	switch models.ImageType(s) {
	case models.ImageTypeLeaf:
		return pb.ImageType_IMAGE_TYPE_LEAF
	case models.ImageTypeStem:
		return pb.ImageType_IMAGE_TYPE_STEM
	case models.ImageTypeFruit:
		return pb.ImageType_IMAGE_TYPE_FRUIT
	case models.ImageTypeWholePlant:
		return pb.ImageType_IMAGE_TYPE_WHOLE_PLANT
	case models.ImageTypeRoot:
		return pb.ImageType_IMAGE_TYPE_ROOT
	default:
		return pb.ImageType_IMAGE_TYPE_UNSPECIFIED
	}
}

func diagnosisStatusToProto(s models.DiagnosisStatus) pb.DiagnosisStatus {
	switch s {
	case models.DiagnosisStatusPending:
		return pb.DiagnosisStatus_DIAGNOSIS_STATUS_PENDING
	case models.DiagnosisStatusAnalyzing:
		return pb.DiagnosisStatus_DIAGNOSIS_STATUS_ANALYZING
	case models.DiagnosisStatusCompleted:
		return pb.DiagnosisStatus_DIAGNOSIS_STATUS_COMPLETED
	case models.DiagnosisStatusFailed:
		return pb.DiagnosisStatus_DIAGNOSIS_STATUS_FAILED
	default:
		return pb.DiagnosisStatus_DIAGNOSIS_STATUS_UNSPECIFIED
	}
}

func severityStringToProto(s string) pb.Severity {
	switch models.SeverityLevel(s) {
	case models.SeverityMild:
		return pb.Severity_SEVERITY_MILD
	case models.SeverityModerate:
		return pb.Severity_SEVERITY_MODERATE
	case models.SeveritySevere:
		return pb.Severity_SEVERITY_SEVERE
	case models.SeverityCritical:
		return pb.Severity_SEVERITY_CRITICAL
	default:
		return pb.Severity_SEVERITY_UNSPECIFIED
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// JSON unmarshal helpers (JSONB → proto slices)
// ─────────────────────────────────────────────────────────────────────────────

func unmarshalDiseases(data json.RawMessage) []*pb.DiseaseInfo {
	if len(data) == 0 {
		return nil
	}
	var items []models.DetectedDisease
	if err := json.Unmarshal(data, &items); err != nil {
		return nil
	}
	out := make([]*pb.DiseaseInfo, 0, len(items))
	for i := range items {
		out = append(out, DetectedDiseaseToProto(&items[i]))
	}
	return out
}

func unmarshalNutrientDeficiencies(data json.RawMessage) []*pb.NutrientDeficiency {
	if len(data) == 0 {
		return nil
	}
	var items []models.DetectedNutrientDeficiency
	if err := json.Unmarshal(data, &items); err != nil {
		return nil
	}
	out := make([]*pb.NutrientDeficiency, 0, len(items))
	for i := range items {
		out = append(out, DetectedNutrientDeficiencyToProto(&items[i]))
	}
	return out
}

func unmarshalPestDamage(data json.RawMessage) []*pb.PestDamage {
	if len(data) == 0 {
		return nil
	}
	var items []models.DetectedPestDamage
	if err := json.Unmarshal(data, &items); err != nil {
		return nil
	}
	out := make([]*pb.PestDamage, 0, len(items))
	for i := range items {
		out = append(out, DetectedPestDamageToProto(&items[i]))
	}
	return out
}

func unmarshalStringSlice(data json.RawMessage) []string {
	if len(data) == 0 {
		return nil
	}
	var items []string
	if err := json.Unmarshal(data, &items); err != nil {
		return nil
	}
	return items
}
