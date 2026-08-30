package ai

import (
	"context"
	"fmt"

	"google.golang.org/grpc"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/dynamicpb"
	"google.golang.org/protobuf/reflect/protoreflect"
	"google.golang.org/protobuf/types/known/structpb"
)

// AI Gateway gRPC method paths matching the proto service definition.
const (
	methodDiagnoseImage             = "/agriculture.ai.v1.AIGatewayService/DiagnoseImage"
	methodDetectPests               = "/agriculture.ai.v1.AIGatewayService/DetectPests"
	methodDetectNutrientDeficiency  = "/agriculture.ai.v1.AIGatewayService/DetectNutrientDeficiency"
	methodClassifyPlant             = "/agriculture.ai.v1.AIGatewayService/ClassifyPlant"
)

// ─────────────────────────────────────────────────────────────────────────────
// Wire-format request/response types
// These mirror the proto messages and are used for manual gRPC marshaling.
// When generated pb stubs are available, replace these with the generated types.
// ─────────────────────────────────────────────────────────────────────────────

// diagnoseImageReq is the wire-format request for DiagnoseImage.
type diagnoseImageReq struct {
	RequestID      string       `protobuf:"bytes,1,opt,name=request_id" json:"request_id"`
	Images         []*imageData `protobuf:"bytes,2,rep,name=images" json:"images"`
	PlantSpeciesID string       `protobuf:"bytes,3,opt,name=plant_species_id" json:"plant_species_id"`
	Operations     []string     `protobuf:"bytes,4,rep,name=operations" json:"operations"`
}

type imageData struct {
	ImageURL  string `protobuf:"bytes,1,opt,name=image_url" json:"image_url"`
	ImageType string `protobuf:"bytes,3,opt,name=image_type" json:"image_type"`
	MimeType  string `protobuf:"bytes,4,opt,name=mime_type" json:"mime_type"`
}

// diagnoseImageResp is the wire-format response for DiagnoseImage.
type diagnoseImageResp struct {
	RequestID          string               `protobuf:"bytes,1,opt,name=request_id" json:"request_id"`
	Diseases           []*diseaseDetection  `protobuf:"bytes,2,rep,name=diseases" json:"diseases"`
	OverallHealthScore float64              `protobuf:"fixed64,3,opt,name=overall_health_score" json:"overall_health_score"`
	Summary            string               `protobuf:"bytes,4,opt,name=summary" json:"summary"`
	ModelVersion       string               `protobuf:"bytes,5,opt,name=model_version" json:"model_version"`
	ProcessingTimeMs   int64                `protobuf:"varint,6,opt,name=processing_time_ms" json:"processing_time_ms"`
}

type diseaseDetection struct {
	DiseaseID        string   `protobuf:"bytes,1,opt" json:"disease_id"`
	DiseaseName      string   `protobuf:"bytes,2,opt" json:"disease_name"`
	ScientificName   string   `protobuf:"bytes,3,opt" json:"scientific_name"`
	ConfidenceScore  float64  `protobuf:"fixed64,4,opt" json:"confidence_score"`
	Severity         string   `protobuf:"bytes,5,opt" json:"severity"`
	Description      string   `protobuf:"bytes,6,opt" json:"description"`
	Symptoms         string   `protobuf:"bytes,7,opt" json:"symptoms"`
	TreatmentOptions []string `protobuf:"bytes,8,rep" json:"treatment_options"`
	Prevention       string   `protobuf:"bytes,9,opt" json:"prevention"`
}

// ─────────────────────────────────────────────────────────────────────────────
// gRPC call implementations using JSON codec for simplicity.
// In production with generated stubs, these become one-liners.
// ─────────────────────────────────────────────────────────────────────────────

// jsonCodec implements grpc encoding.Codec for JSON marshaling.
// This allows calling gRPC services without generated proto stubs.
type jsonCodec struct{}

func (jsonCodec) Marshal(v interface{}) ([]byte, error) {
	if msg, ok := v.(proto.Message); ok {
		return proto.Marshal(msg)
	}
	return nil, fmt.Errorf("jsonCodec: cannot marshal %T", v)
}

func (jsonCodec) Unmarshal(data []byte, v interface{}) error {
	if msg, ok := v.(proto.Message); ok {
		return proto.Unmarshal(data, msg)
	}
	return fmt.Errorf("jsonCodec: cannot unmarshal into %T", v)
}

func (jsonCodec) Name() string { return "proto" }

// callDiagnoseImage performs the DiagnoseImage gRPC call.
func callDiagnoseImage(ctx context.Context, conn *grpc.ClientConn, requestID string, images []ImageInput, plantSpeciesID string) (*DiagnosisResult, error) {
	// Build proto request manually using structpb for generic message handling.
	// This approach works without generated Go stubs for the AI gateway proto.
	reqFields := map[string]*structpb.Value{
		"request_id":       structpb.NewStringValue(requestID),
		"plant_species_id": structpb.NewStringValue(plantSpeciesID),
	}

	imageList := make([]*structpb.Value, 0, len(images))
	for _, img := range images {
		imgStruct, _ := structpb.NewStruct(map[string]interface{}{
			"image_url":  img.ImageURL,
			"image_type": img.ImageType,
			"mime_type":  img.MimeType,
		})
		imageList = append(imageList, structpb.NewStructValue(imgStruct))
	}
	reqFields["images"] = structpb.NewListValue(&structpb.ListValue{Values: imageList})
	reqFields["operations"] = structpb.NewListValue(&structpb.ListValue{
		Values: []*structpb.Value{
			structpb.NewStringValue("resize"),
			structpb.NewStringValue("normalize"),
			structpb.NewStringValue("enhance"),
		},
	})

	reqMsg := &structpb.Struct{Fields: reqFields}
	respMsg := &structpb.Struct{}

	err := conn.Invoke(ctx, methodDiagnoseImage, reqMsg, respMsg)
	if err != nil {
		return nil, fmt.Errorf("DiagnoseImage invoke failed: %w", err)
	}

	return parseDiagnosisResult(respMsg), nil
}

// callDetectPests performs the DetectPests gRPC call.
func callDetectPests(ctx context.Context, conn *grpc.ClientConn, requestID string, images []ImageInput, plantSpeciesID string) (*PestDetectionResult, error) {
	reqFields := map[string]*structpb.Value{
		"request_id":       structpb.NewStringValue(requestID),
		"plant_species_id": structpb.NewStringValue(plantSpeciesID),
	}

	imageList := make([]*structpb.Value, 0, len(images))
	for _, img := range images {
		imgStruct, _ := structpb.NewStruct(map[string]interface{}{
			"image_url":  img.ImageURL,
			"image_type": img.ImageType,
		})
		imageList = append(imageList, structpb.NewStructValue(imgStruct))
	}
	reqFields["images"] = structpb.NewListValue(&structpb.ListValue{Values: imageList})

	reqMsg := &structpb.Struct{Fields: reqFields}
	respMsg := &structpb.Struct{}

	err := conn.Invoke(ctx, methodDetectPests, reqMsg, respMsg)
	if err != nil {
		return nil, fmt.Errorf("DetectPests invoke failed: %w", err)
	}

	return parsePestDetectionResult(respMsg), nil
}

// callDetectNutrientDeficiency performs the DetectNutrientDeficiency gRPC call.
func callDetectNutrientDeficiency(ctx context.Context, conn *grpc.ClientConn, requestID string, images []ImageInput, plantSpeciesID string) (*NutrientDeficiencyResult, error) {
	reqFields := map[string]*structpb.Value{
		"request_id":       structpb.NewStringValue(requestID),
		"plant_species_id": structpb.NewStringValue(plantSpeciesID),
	}

	imageList := make([]*structpb.Value, 0, len(images))
	for _, img := range images {
		imgStruct, _ := structpb.NewStruct(map[string]interface{}{
			"image_url":  img.ImageURL,
			"image_type": img.ImageType,
		})
		imageList = append(imageList, structpb.NewStructValue(imgStruct))
	}
	reqFields["images"] = structpb.NewListValue(&structpb.ListValue{Values: imageList})

	reqMsg := &structpb.Struct{Fields: reqFields}
	respMsg := &structpb.Struct{}

	err := conn.Invoke(ctx, methodDetectNutrientDeficiency, reqMsg, respMsg)
	if err != nil {
		return nil, fmt.Errorf("DetectNutrientDeficiency invoke failed: %w", err)
	}

	return parseNutrientDeficiencyResult(respMsg), nil
}

// callClassifyPlant performs the ClassifyPlant gRPC call.
func callClassifyPlant(ctx context.Context, conn *grpc.ClientConn, requestID string, images []ImageInput) (*SpeciesClassificationResult, error) {
	reqFields := map[string]*structpb.Value{
		"request_id": structpb.NewStringValue(requestID),
	}

	imageList := make([]*structpb.Value, 0, len(images))
	for _, img := range images {
		imgStruct, _ := structpb.NewStruct(map[string]interface{}{
			"image_url":  img.ImageURL,
			"image_type": img.ImageType,
		})
		imageList = append(imageList, structpb.NewStructValue(imgStruct))
	}
	reqFields["images"] = structpb.NewListValue(&structpb.ListValue{Values: imageList})

	reqMsg := &structpb.Struct{Fields: reqFields}
	respMsg := &structpb.Struct{}

	err := conn.Invoke(ctx, methodClassifyPlant, reqMsg, respMsg)
	if err != nil {
		return nil, fmt.Errorf("ClassifyPlant invoke failed: %w", err)
	}

	return parseSpeciesResult(respMsg), nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Response parsers (structpb -> typed result)
// ─────────────────────────────────────────────────────────────────────────────

func parseDiagnosisResult(resp *structpb.Struct) *DiagnosisResult {
	result := &DiagnosisResult{}
	if resp == nil || resp.Fields == nil {
		return result
	}

	result.RequestID = getStringField(resp, "request_id")
	result.OverallHealthScore = getNumberField(resp, "overall_health_score")
	result.Summary = getStringField(resp, "summary")
	result.ModelVersion = getStringField(resp, "model_version")
	result.ProcessingTimeMs = int64(getNumberField(resp, "processing_time_ms"))

	if diseaseList, ok := resp.Fields["diseases"]; ok {
		if lv := diseaseList.GetListValue(); lv != nil {
			for _, dv := range lv.Values {
				if ds := dv.GetStructValue(); ds != nil {
					result.Diseases = append(result.Diseases, DetectedDisease{
						DiseaseID:       getStringField(ds, "disease_id"),
						DiseaseName:     getStringField(ds, "disease_name"),
						ScientificName:  getStringField(ds, "scientific_name"),
						ConfidenceScore: getNumberField(ds, "confidence_score"),
						Severity:        getStringField(ds, "severity"),
						Description:     getStringField(ds, "description"),
						Symptoms:        getStringField(ds, "symptoms"),
						Prevention:      getStringField(ds, "prevention"),
						TreatmentOptions: getStringListField(ds, "treatment_options"),
					})
				}
			}
		}
	}

	return result
}

func parsePestDetectionResult(resp *structpb.Struct) *PestDetectionResult {
	result := &PestDetectionResult{}
	if resp == nil || resp.Fields == nil {
		return result
	}

	result.RequestID = getStringField(resp, "request_id")
	result.ModelVersion = getStringField(resp, "model_version")
	result.ProcessingTimeMs = int64(getNumberField(resp, "processing_time_ms"))

	if pestList, ok := resp.Fields["pests"]; ok {
		if lv := pestList.GetListValue(); lv != nil {
			for _, pv := range lv.Values {
				if ps := pv.GetStructValue(); ps != nil {
					result.Pests = append(result.Pests, DetectedPest{
						PestID:          getStringField(ps, "pest_id"),
						PestName:        getStringField(ps, "pest_name"),
						ScientificName:  getStringField(ps, "scientific_name"),
						ConfidenceScore: getNumberField(ps, "confidence_score"),
						DamageLevel:     getStringField(ps, "damage_level"),
						Description:     getStringField(ps, "description"),
						DamagePattern:   getStringField(ps, "damage_pattern"),
						ControlMethods:  getStringListField(ps, "control_methods"),
					})
				}
			}
		}
	}

	return result
}

func parseNutrientDeficiencyResult(resp *structpb.Struct) *NutrientDeficiencyResult {
	result := &NutrientDeficiencyResult{}
	if resp == nil || resp.Fields == nil {
		return result
	}

	result.RequestID = getStringField(resp, "request_id")
	result.ModelVersion = getStringField(resp, "model_version")
	result.ProcessingTimeMs = int64(getNumberField(resp, "processing_time_ms"))

	if defList, ok := resp.Fields["deficiencies"]; ok {
		if lv := defList.GetListValue(); lv != nil {
			for _, dv := range lv.Values {
				if ds := dv.GetStructValue(); ds != nil {
					result.Deficiencies = append(result.Deficiencies, DetectedNutrientDeficiency{
						Nutrient:              getStringField(ds, "nutrient"),
						ConfidenceScore:       getNumberField(ds, "confidence_score"),
						Severity:              getStringField(ds, "severity"),
						Description:           getStringField(ds, "description"),
						VisualSymptoms:        getStringField(ds, "visual_symptoms"),
						RecommendedFertilizers: getStringListField(ds, "recommended_fertilizers"),
						ApplicationMethod:     getStringField(ds, "application_method"),
					})
				}
			}
		}
	}

	return result
}

func parseSpeciesResult(resp *structpb.Struct) *SpeciesClassificationResult {
	result := &SpeciesClassificationResult{}
	if resp == nil || resp.Fields == nil {
		return result
	}

	result.RequestID = getStringField(resp, "request_id")
	result.ModelVersion = getStringField(resp, "model_version")
	result.ProcessingTimeMs = int64(getNumberField(resp, "processing_time_ms"))

	if species, ok := resp.Fields["species"]; ok {
		if ss := species.GetStructValue(); ss != nil {
			result.SpeciesID = getStringField(ss, "species_id")
			result.CommonName = getStringField(ss, "common_name")
			result.ScientificName = getStringField(ss, "scientific_name")
			result.Family = getStringField(ss, "family")
			result.Confidence = getNumberField(ss, "confidence")
		}
	}

	return result
}

// ─────────────────────────────────────────────────────────────────────────────
// structpb field accessors
// ─────────────────────────────────────────────────────────────────────────────

func getStringField(s *structpb.Struct, key string) string {
	if v, ok := s.Fields[key]; ok {
		return v.GetStringValue()
	}
	return ""
}

func getNumberField(s *structpb.Struct, key string) float64 {
	if v, ok := s.Fields[key]; ok {
		return v.GetNumberValue()
	}
	return 0
}

func getStringListField(s *structpb.Struct, key string) []string {
	if v, ok := s.Fields[key]; ok {
		if lv := v.GetListValue(); lv != nil {
			result := make([]string, 0, len(lv.Values))
			for _, item := range lv.Values {
				result = append(result, item.GetStringValue())
			}
			return result
		}
	}
	return nil
}

// Ensure unused imports are consumed (these are used when generated stubs are available).
var _ protoreflect.Descriptor
var _ *dynamicpb.Message
