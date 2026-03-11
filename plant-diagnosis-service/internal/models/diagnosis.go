package models

import (
	"encoding/json"
	"time"

	"p9e.in/samavaya/packages/models"
)

// ─────────────────────────────────────────────────────────────────────────────
// Enum types
// ─────────────────────────────────────────────────────────────────────────────

type ImageType string

const (
	ImageTypeLeaf       ImageType = "LEAF"
	ImageTypeStem       ImageType = "STEM"
	ImageTypeFruit      ImageType = "FRUIT"
	ImageTypeWholePlant ImageType = "WHOLE_PLANT"
	ImageTypeRoot       ImageType = "ROOT"
)

type DiagnosisStatus string

const (
	DiagnosisStatusPending   DiagnosisStatus = "PENDING"
	DiagnosisStatusAnalyzing DiagnosisStatus = "ANALYZING"
	DiagnosisStatusCompleted DiagnosisStatus = "COMPLETED"
	DiagnosisStatusFailed    DiagnosisStatus = "FAILED"
)

type SeverityLevel string

const (
	SeverityMild     SeverityLevel = "MILD"
	SeverityModerate SeverityLevel = "MODERATE"
	SeveritySevere   SeverityLevel = "SEVERE"
	SeverityCritical SeverityLevel = "CRITICAL"
)

// ─────────────────────────────────────────────────────────────────────────────
// Domain models
// ─────────────────────────────────────────────────────────────────────────────

// DiagnosisRequest is the aggregate root for plant diagnosis submissions.
type DiagnosisRequest struct {
	models.BaseModel
	TenantID       string          `json:"tenant_id" db:"tenant_id"`
	FarmID         string          `json:"farm_id" db:"farm_id"`
	FieldID        *string         `json:"field_id" db:"field_id"`
	PlantSpeciesID *string         `json:"plant_species_id" db:"plant_species_id"`
	Status         DiagnosisStatus `json:"status" db:"status"`
	Notes          *string         `json:"notes" db:"notes"`
	Version        int32           `json:"version" db:"version"`

	// Loaded relations (not directly from DB row)
	Images []DiagnosisImage  `json:"images,omitempty" db:"-"`
	Result *DiagnosisResult  `json:"result,omitempty" db:"-"`
}

// DiagnosisImage represents an image attached to a diagnosis request.
type DiagnosisImage struct {
	ID                 int64     `json:"id" db:"id"`
	UUID               string    `json:"uuid" db:"uuid"`
	DiagnosisRequestID int64     `json:"diagnosis_request_id" db:"diagnosis_request_id"`
	ImageURL           string    `json:"image_url" db:"image_url"`
	ImageType          string    `json:"image_type" db:"image_type"`
	SizeBytes          *int64    `json:"size_bytes" db:"size_bytes"`
	MimeType           *string   `json:"mime_type" db:"mime_type"`
	Checksum           *string   `json:"checksum" db:"checksum"`
	UploadedAt         time.Time `json:"uploaded_at" db:"uploaded_at"`
}

// DiagnosisResult holds the AI inference output for a diagnosis request.
type DiagnosisResult struct {
	ID                      int64            `json:"id" db:"id"`
	UUID                    string           `json:"uuid" db:"uuid"`
	DiagnosisRequestID      int64            `json:"diagnosis_request_id" db:"diagnosis_request_id"`
	IdentifiedSpeciesID     *string          `json:"identified_species_id" db:"identified_species_id"`
	IdentifiedSpeciesName   *string          `json:"identified_species_name" db:"identified_species_name"`
	IdentifiedSpeciesConf   *float64         `json:"identified_species_conf" db:"identified_species_conf"`
	DetectedDiseases        json.RawMessage  `json:"detected_diseases" db:"detected_diseases"`
	NutrientDeficiencies    json.RawMessage  `json:"nutrient_deficiencies" db:"nutrient_deficiencies"`
	PestDamage              json.RawMessage  `json:"pest_damage" db:"pest_damage"`
	TreatmentRecommendations json.RawMessage `json:"treatment_recommendations" db:"treatment_recommendations"`
	AIModelVersion          string           `json:"ai_model_version" db:"ai_model_version"`
	ProcessingTimeMs        int64            `json:"processing_time_ms" db:"processing_time_ms"`
	OverallHealthScore      *float64         `json:"overall_health_score" db:"overall_health_score"`
	Summary                 *string          `json:"summary" db:"summary"`
	CreatedAt               time.Time        `json:"created_at" db:"created_at"`
}

// DetectedDisease is the JSON-serialised disease detection result.
type DetectedDisease struct {
	DiseaseID       string        `json:"disease_id"`
	DiseaseName     string        `json:"disease_name"`
	ScientificName  string        `json:"scientific_name,omitempty"`
	ConfidenceScore float64       `json:"confidence_score"`
	Severity        SeverityLevel `json:"severity"`
	Description     string        `json:"description,omitempty"`
	Symptoms        string        `json:"symptoms,omitempty"`
	TreatmentOptions []string    `json:"treatment_options,omitempty"`
	Prevention      string        `json:"prevention,omitempty"`
}

// DetectedNutrientDeficiency is the JSON-serialised nutrient deficiency result.
type DetectedNutrientDeficiency struct {
	Nutrient              string        `json:"nutrient"`
	ConfidenceScore       float64       `json:"confidence_score"`
	Severity              SeverityLevel `json:"severity"`
	Description           string        `json:"description,omitempty"`
	VisualSymptoms        string        `json:"visual_symptoms,omitempty"`
	RecommendedFertilizers []string     `json:"recommended_fertilizers,omitempty"`
	ApplicationMethod     string        `json:"application_method,omitempty"`
}

// DetectedPestDamage is the JSON-serialised pest damage result.
type DetectedPestDamage struct {
	PestID          string        `json:"pest_id"`
	PestName        string        `json:"pest_name"`
	ScientificName  string        `json:"scientific_name,omitempty"`
	ConfidenceScore float64       `json:"confidence_score"`
	DamageLevel     SeverityLevel `json:"damage_level"`
	Description     string        `json:"description,omitempty"`
	DamagePattern   string        `json:"damage_pattern,omitempty"`
	ControlMethods  []string      `json:"control_methods,omitempty"`
}

// IdentifiedSpecies represents the species identification result.
type IdentifiedSpecies struct {
	ID             string  `json:"id"`
	CommonName     string  `json:"common_name"`
	ScientificName string  `json:"scientific_name"`
	Family         string  `json:"family,omitempty"`
	Confidence     float64 `json:"confidence"`
}

// ─────────────────────────────────────────────────────────────────────────────
// Catalog models (reference data)
// ─────────────────────────────────────────────────────────────────────────────

// DiseaseCatalog represents a known plant disease in the reference catalog.
type DiseaseCatalog struct {
	models.BaseModel
	TenantID         string          `json:"tenant_id" db:"tenant_id"`
	DiseaseName      string          `json:"disease_name" db:"disease_name"`
	ScientificName   *string         `json:"scientific_name" db:"scientific_name"`
	Description      *string         `json:"description" db:"description"`
	Symptoms         *string         `json:"symptoms" db:"symptoms"`
	TreatmentOptions json.RawMessage `json:"treatment_options" db:"treatment_options"`
	Prevention       *string         `json:"prevention" db:"prevention"`
	AffectedSpecies  json.RawMessage `json:"affected_species" db:"affected_species"`
}

// NutrientDeficiencyCatalog represents a known nutrient deficiency.
type NutrientDeficiencyCatalog struct {
	models.BaseModel
	TenantID              string          `json:"tenant_id" db:"tenant_id"`
	Nutrient              string          `json:"nutrient" db:"nutrient"`
	Description           *string         `json:"description" db:"description"`
	VisualSymptoms        *string         `json:"visual_symptoms" db:"visual_symptoms"`
	RecommendedFertilizers json.RawMessage `json:"recommended_fertilizers" db:"recommended_fertilizers"`
	ApplicationMethod     *string         `json:"application_method" db:"application_method"`
	AffectedSpecies       json.RawMessage `json:"affected_species" db:"affected_species"`
}

// PestCatalog represents a known pest in the reference catalog.
type PestCatalog struct {
	models.BaseModel
	TenantID        string          `json:"tenant_id" db:"tenant_id"`
	PestName        string          `json:"pest_name" db:"pest_name"`
	ScientificName  *string         `json:"scientific_name" db:"scientific_name"`
	Description     *string         `json:"description" db:"description"`
	DamagePattern   *string         `json:"damage_pattern" db:"damage_pattern"`
	ControlMethods  json.RawMessage `json:"control_methods" db:"control_methods"`
	AffectedSpecies json.RawMessage `json:"affected_species" db:"affected_species"`
}

// ─────────────────────────────────────────────────────────────────────────────
// Treatment plan model
// ─────────────────────────────────────────────────────────────────────────────

// TreatmentPlan is a generated action plan for a diagnosis.
type TreatmentPlan struct {
	models.BaseModel
	DiagnosisRequestID int64           `json:"diagnosis_request_id" db:"diagnosis_request_id"`
	Title              string          `json:"title" db:"title"`
	Description        *string         `json:"description" db:"description"`
	Priority           string          `json:"priority" db:"priority"`
	Steps              json.RawMessage `json:"steps" db:"steps"`
	EstimatedCost      *string         `json:"estimated_cost" db:"estimated_cost"`
	EstimatedDays      *int32          `json:"estimated_days" db:"estimated_days"`
}

// TreatmentStep is a single step in a treatment plan (JSON within Steps).
type TreatmentStep struct {
	StepNumber   int32  `json:"step_number"`
	Action       string `json:"action"`
	Product      string `json:"product,omitempty"`
	Dosage       string `json:"dosage,omitempty"`
	Frequency    string `json:"frequency,omitempty"`
	Notes        string `json:"notes,omitempty"`
	DurationDays int32  `json:"duration_days,omitempty"`
}

// ─────────────────────────────────────────────────────────────────────────────
// AI pipeline models
// ─────────────────────────────────────────────────────────────────────────────

// AIInferenceRequest is sent to the Python AI inference service.
type AIInferenceRequest struct {
	RequestID      string   `json:"request_id"`
	ImageURLs      []string `json:"image_urls"`
	ImageTypes     []string `json:"image_types"`
	PlantSpeciesID string   `json:"plant_species_id,omitempty"`
	ModelVersion   string   `json:"model_version,omitempty"`
}

// AIInferenceResponse is received from the Python AI inference service.
type AIInferenceResponse struct {
	RequestID            string                       `json:"request_id"`
	Species              *IdentifiedSpecies           `json:"species,omitempty"`
	Diseases             []DetectedDisease            `json:"diseases,omitempty"`
	NutrientDeficiencies []DetectedNutrientDeficiency `json:"nutrient_deficiencies,omitempty"`
	PestDamage           []DetectedPestDamage         `json:"pest_damage,omitempty"`
	OverallHealthScore   float64                      `json:"overall_health_score"`
	Summary              string                       `json:"summary"`
	ModelVersion         string                       `json:"model_version"`
	ProcessingTimeMs     int64                        `json:"processing_time_ms"`
}

// ImagePreprocessResult is returned by the Rust preprocessing engine.
type ImagePreprocessResult struct {
	RequestID    string   `json:"request_id"`
	ProcessedURLs []string `json:"processed_urls"`
	Metadata     map[string]interface{} `json:"metadata,omitempty"`
}
