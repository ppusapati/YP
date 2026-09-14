package ai

import (
	"context"
	"fmt"

	"google.golang.org/grpc"

	aipb "p9e.in/samavaya/agriculture/ai-gateway/api/v1"
)

// The AI gateway is called through its generated gRPC stubs so the request
// bytes match the Rust server's proto definition exactly.

// SampleContext is attached to vision requests so collected training samples
// carry tenant, location, and crop metadata for review and evaluation slicing.
type SampleContext struct {
	TenantID    string
	FarmID      string
	FieldID     string
	Crop        string
	Latitude    float64
	Longitude   float64
	SubmittedBy string
}

func (s *SampleContext) toProto() *aipb.SampleContext {
	if s == nil {
		return nil
	}
	return &aipb.SampleContext{
		TenantId:    s.TenantID,
		FarmId:      s.FarmID,
		FieldId:     s.FieldID,
		Crop:        s.Crop,
		Latitude:    s.Latitude,
		Longitude:   s.Longitude,
		SubmittedBy: s.SubmittedBy,
	}
}

func imagesToProto(images []ImageInput) []*aipb.ImageData {
	out := make([]*aipb.ImageData, 0, len(images))
	for _, img := range images {
		out = append(out, &aipb.ImageData{
			ImageUrl:  img.ImageURL,
			ImageType: img.ImageType,
			MimeType:  img.MimeType,
		})
	}
	return out
}

func gatewayClient(conn *grpc.ClientConn) aipb.AIGatewayServiceClient {
	return aipb.NewAIGatewayServiceClient(conn)
}

// callDiagnoseImage performs the DiagnoseImage gRPC call.
func callDiagnoseImage(ctx context.Context, conn *grpc.ClientConn, requestID string, images []ImageInput, plantSpeciesID string, sctx *SampleContext) (*DiagnosisResult, error) {
	resp, err := gatewayClient(conn).DiagnoseImage(ctx, &aipb.DiagnoseImageRequest{
		RequestId:      requestID,
		Images:         imagesToProto(images),
		PlantSpeciesId: plantSpeciesID,
		Operations:     []string{"resize", "normalize", "enhance"},
		Context:        sctx.toProto(),
	})
	if err != nil {
		return nil, fmt.Errorf("DiagnoseImage invoke failed: %w", err)
	}
	return parseDiagnosisResult(resp), nil
}

// callDetectPests performs the DetectPests gRPC call.
func callDetectPests(ctx context.Context, conn *grpc.ClientConn, requestID string, images []ImageInput, plantSpeciesID string, sctx *SampleContext) (*PestDetectionResult, error) {
	resp, err := gatewayClient(conn).DetectPests(ctx, &aipb.DetectPestsRequest{
		RequestId:      requestID,
		Images:         imagesToProto(images),
		PlantSpeciesId: plantSpeciesID,
		Context:        sctx.toProto(),
	})
	if err != nil {
		return nil, fmt.Errorf("DetectPests invoke failed: %w", err)
	}
	return parsePestDetectionResult(resp), nil
}

// callDetectNutrientDeficiency performs the DetectNutrientDeficiency gRPC call.
func callDetectNutrientDeficiency(ctx context.Context, conn *grpc.ClientConn, requestID string, images []ImageInput, plantSpeciesID string, sctx *SampleContext) (*NutrientDeficiencyResult, error) {
	resp, err := gatewayClient(conn).DetectNutrientDeficiency(ctx, &aipb.DetectNutrientDeficiencyRequest{
		RequestId:      requestID,
		Images:         imagesToProto(images),
		PlantSpeciesId: plantSpeciesID,
		Context:        sctx.toProto(),
	})
	if err != nil {
		return nil, fmt.Errorf("DetectNutrientDeficiency invoke failed: %w", err)
	}
	return parseNutrientDeficiencyResult(resp), nil
}

// callClassifyPlant performs the ClassifyPlant gRPC call.
func callClassifyPlant(ctx context.Context, conn *grpc.ClientConn, requestID string, images []ImageInput, sctx *SampleContext) (*SpeciesClassificationResult, error) {
	resp, err := gatewayClient(conn).ClassifyPlant(ctx, &aipb.ClassifyPlantRequest{
		RequestId: requestID,
		Images:    imagesToProto(images),
		Context:   sctx.toProto(),
	})
	if err != nil {
		return nil, fmt.Errorf("ClassifyPlant invoke failed: %w", err)
	}
	return parseSpeciesResult(resp), nil
}

// callGeneratePrescription performs the GeneratePrescription gRPC call.
func callGeneratePrescription(ctx context.Context, conn *grpc.ClientConn, requestID string, input PrescriptionInput) (*PrescriptionResult, error) {
	resp, err := gatewayClient(conn).GeneratePrescription(ctx, &aipb.GeneratePrescriptionRequest{
		RequestId: requestID,
		FieldId:   input.FieldID,
		CropRequirements: &aipb.PrescriptionCropRequirements{
			CropType:        input.CropType,
			TargetYieldKgHa: input.TargetYieldKgHa,
		},
		PrescriptionTypes: input.PrescriptionTypes,
	})
	if err != nil {
		return nil, fmt.Errorf("GeneratePrescription invoke failed: %w", err)
	}
	return parsePrescriptionResult(resp), nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Response mappers (proto -> typed result)
// ─────────────────────────────────────────────────────────────────────────────


// parseExplanations converts the gateway's explanations, which are absent
// whenever the answer came from a model with no gradient to explain.
func parseExplanations(in []*aipb.Explanation) []Explanation {
	out := make([]Explanation, 0, len(in))
	for _, e := range in {
		out = append(out, Explanation{
			Task:          e.GetTask(),
			ClassName:     e.GetClassName(),
			HeatmapPNG:    e.GetHeatmapPng(),
			HeatmapWidth:  e.GetHeatmapWidth(),
			HeatmapHeight: e.GetHeatmapHeight(),
			FocusX:        e.GetFocusX(),
			FocusY:        e.GetFocusY(),
			FocusWidth:    e.GetFocusWidth(),
			FocusHeight:   e.GetFocusHeight(),
			FocusCoverage: e.GetFocusCoverage(),
			Summary:       e.GetSummary(),
			Method:        e.GetMethod(),
			Localised:     e.GetLocalised(),
		})
	}
	return out
}

func parseDiagnosisResult(resp *aipb.DiagnoseImageResponse) *DiagnosisResult {
	result := &DiagnosisResult{}
	if resp == nil {
		return result
	}
	result.RequestID = resp.GetRequestId()
	result.OverallHealthScore = resp.GetOverallHealthScore()
	result.Summary = resp.GetSummary()
	result.ModelVersion = resp.GetModelVersion()
	result.ProcessingTimeMs = resp.GetProcessingTimeMs()
	for _, d := range resp.GetDiseases() {
		result.Diseases = append(result.Diseases, DetectedDisease{
			DiseaseID:        d.GetDiseaseId(),
			DiseaseName:      d.GetDiseaseName(),
			ScientificName:   d.GetScientificName(),
			ConfidenceScore:  d.GetConfidenceScore(),
			Severity:         d.GetSeverity(),
			Description:      d.GetDescription(),
			Symptoms:         d.GetSymptoms(),
			Prevention:       d.GetPrevention(),
			TreatmentOptions: d.GetTreatmentOptions(),
		})
	}
	return result
}

func parsePestDetectionResult(resp *aipb.DetectPestsResponse) *PestDetectionResult {
	result := &PestDetectionResult{}
	if resp == nil {
		return result
	}
	result.RequestID = resp.GetRequestId()
	result.ModelVersion = resp.GetModelVersion()
	result.ProcessingTimeMs = resp.GetProcessingTimeMs()
	result.Explanations = parseExplanations(resp.GetExplanations())
	for _, p := range resp.GetPests() {
		result.Pests = append(result.Pests, DetectedPest{
			PestID:          p.GetPestId(),
			PestName:        p.GetPestName(),
			ScientificName:  p.GetScientificName(),
			ConfidenceScore: p.GetConfidenceScore(),
			DamageLevel:     p.GetDamageLevel(),
			Description:     p.GetDescription(),
			DamagePattern:   p.GetDamagePattern(),
			ControlMethods:  p.GetControlMethods(),
		})
	}
	return result
}

func parseNutrientDeficiencyResult(resp *aipb.DetectNutrientDeficiencyResponse) *NutrientDeficiencyResult {
	result := &NutrientDeficiencyResult{}
	if resp == nil {
		return result
	}
	result.RequestID = resp.GetRequestId()
	result.ModelVersion = resp.GetModelVersion()
	result.ProcessingTimeMs = resp.GetProcessingTimeMs()
	result.Explanations = parseExplanations(resp.GetExplanations())
	for _, d := range resp.GetDeficiencies() {
		result.Deficiencies = append(result.Deficiencies, DetectedNutrientDeficiency{
			Nutrient:               d.GetNutrient(),
			ConfidenceScore:        d.GetConfidenceScore(),
			Severity:               d.GetSeverity(),
			Description:            d.GetDescription(),
			VisualSymptoms:         d.GetVisualSymptoms(),
			RecommendedFertilizers: d.GetRecommendedFertilizers(),
			ApplicationMethod:      d.GetApplicationMethod(),
		})
	}
	return result
}

func parseSpeciesResult(resp *aipb.ClassifyPlantResponse) *SpeciesClassificationResult {
	result := &SpeciesClassificationResult{}
	if resp == nil {
		return result
	}
	result.RequestID = resp.GetRequestId()
	result.ModelVersion = resp.GetModelVersion()
	result.ProcessingTimeMs = resp.GetProcessingTimeMs()
	if s := resp.GetSpecies(); s != nil {
		result.SpeciesID = s.GetSpeciesId()
		result.CommonName = s.GetCommonName()
		result.ScientificName = s.GetScientificName()
		result.Family = s.GetFamily()
		result.Confidence = s.GetConfidence()
	}
	return result
}

func parsePrescriptionResult(resp *aipb.GeneratePrescriptionResponse) *PrescriptionResult {
	result := &PrescriptionResult{}
	if resp == nil {
		return result
	}
	result.RequestID = resp.GetRequestId()
	result.FieldID = resp.GetFieldId()
	result.EstimatedCostSavingsPct = resp.GetEstimatedCostSavingsPct()
	result.EstimatedYieldGainPct = resp.GetEstimatedYieldGainPct()
	result.ProcessingTimeMs = resp.GetProcessingTimeMs()
	for _, p := range resp.GetPrescriptions() {
		pm := PrescriptionMap{
			PrescriptionType: p.GetPrescriptionType(),
			Rates:            p.GetRates(),
			Unit:             p.GetUnit(),
			TotalAmount:      p.GetTotalAmount(),
		}
		for _, z := range p.GetZoneSummaries() {
			pm.ZoneSummaries = append(pm.ZoneSummaries, PrescriptionZone{
				Zone:        z.GetZone(),
				CellCount:   z.GetCellCount(),
				AreaHa:      z.GetAreaHa(),
				MeanRate:    z.GetMeanRate(),
				MinRate:     z.GetMinRate(),
				MaxRate:     z.GetMaxRate(),
				TotalAmount: z.GetTotalAmount(),
			})
		}
		result.Prescriptions = append(result.Prescriptions, pm)
	}
	return result
}
