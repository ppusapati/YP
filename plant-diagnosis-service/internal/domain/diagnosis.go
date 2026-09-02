package domain

import (
	"encoding/json"
	"time"
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
	DiagnosisStatusPending   DiagnosisStatus = "DIAGNOSIS_STATUS_PENDING"
	DiagnosisStatusAnalyzing DiagnosisStatus = "DIAGNOSIS_STATUS_ANALYZING"
	DiagnosisStatusCompleted DiagnosisStatus = "DIAGNOSIS_STATUS_COMPLETED"
	DiagnosisStatusFailed    DiagnosisStatus = "DIAGNOSIS_STATUS_FAILED"
)

type SeverityLevel string

const (
	SeverityUnspecified SeverityLevel = "SEVERITY_UNSPECIFIED"
	SeverityMild        SeverityLevel = "SEVERITY_MILD"
	SeverityModerate    SeverityLevel = "SEVERITY_MODERATE"
	SeveritySevere      SeverityLevel = "SEVERITY_SEVERE"
	SeverityCritical    SeverityLevel = "SEVERITY_CRITICAL"
)

// ─────────────────────────────────────────────────────────────────────────────
// Core domain models
// ─────────────────────────────────────────────────────────────────────────────

// DiagnosisRequest is the aggregate root for plant diagnosis submissions.
// Maps to the diagnosis_requests table (id CHAR(26), images JSONB).
type DiagnosisRequest struct {
	ID             string          `json:"id" db:"id"`
	TenantID       string          `json:"tenant_id" db:"tenant_id"`
	FarmID         string          `json:"farm_id" db:"farm_id"`
	FieldID        *string         `json:"field_id" db:"field_id"`
	PlantSpeciesID *string         `json:"plant_species_id" db:"plant_species_id"`
	Status         DiagnosisStatus `json:"status" db:"status"`
	Notes          *string         `json:"notes" db:"notes"`
	Version        int32           `json:"version" db:"version"`
	CreatedBy      string          `json:"created_by" db:"created_by"`
	CreatedAt      time.Time       `json:"created_at" db:"created_at"`
	UpdatedAt      time.Time       `json:"updated_at" db:"updated_at"`

	// Images are stored as JSONB in the DB row; decoded into this slice.
	Images []DiagnosisImage `json:"images,omitempty" db:"-"`

	// Result is optionally joined from diagnosis_results.
	Result *DiagnosisResult `json:"result,omitempty" db:"-"`
}

// DiagnosisImage represents a single image stored inside the JSONB images
// column of diagnosis_requests.
type DiagnosisImage struct {
	ImageURL  string `json:"image_url"`
	ImageType string `json:"image_type"`
	MimeType  string `json:"mime_type,omitempty"`
}

// DiagnosisResult holds the AI inference output for a diagnosis request.
// Maps to the diagnosis_results table.
type DiagnosisResult struct {
	ID                       string          `json:"id" db:"id"`
	TenantID                 string          `json:"tenant_id" db:"tenant_id"`
	DiagnosisRequestID       string          `json:"diagnosis_request_id" db:"diagnosis_request_id"`
	IdentifiedSpecies        json.RawMessage `json:"identified_species" db:"identified_species"`
	DetectedDiseases         json.RawMessage `json:"detected_diseases" db:"detected_diseases"`
	NutrientDeficiencies     json.RawMessage `json:"nutrient_deficiencies" db:"nutrient_deficiencies"`
	PestDamage               json.RawMessage `json:"pest_damage" db:"pest_damage"`
	TreatmentRecommendations []string        `json:"treatment_recommendations" db:"treatment_recommendations"`
	AIModelVersion           string          `json:"ai_model_version" db:"ai_model_version"`
	ProcessingTimeMs         int64           `json:"processing_time_ms" db:"processing_time_ms"`
	OverallHealthScore       *float64        `json:"overall_health_score" db:"overall_health_score"`
	Summary                  *string         `json:"summary" db:"summary"`
	CreatedAt                time.Time       `json:"created_at" db:"created_at"`
	UpdatedAt                time.Time       `json:"updated_at" db:"updated_at"`
}

// ─────────────────────────────────────────────────────────────────────────────
// Detection / AI result value objects
// ─────────────────────────────────────────────────────────────────────────────

// PlantSpecies represents a plant species identification result.
type PlantSpecies struct {
	ID             string  `json:"id"`
	CommonName     string  `json:"common_name"`
	ScientificName string  `json:"scientific_name"`
	Family         string  `json:"family,omitempty"`
	Confidence     float64 `json:"confidence"`
}

// NutrientDeficiency represents a detected nutrient deficiency.
type NutrientDeficiency struct {
	Nutrient               string        `json:"nutrient"`
	ConfidenceScore        float64       `json:"confidence_score"`
	Severity               SeverityLevel `json:"severity"`
	Description            string        `json:"description,omitempty"`
	VisualSymptoms         string        `json:"visual_symptoms,omitempty"`
	RecommendedFertilizers []string      `json:"recommended_fertilizers,omitempty"`
	ApplicationMethod      string        `json:"application_method,omitempty"`
}

// PestDamage represents detected pest damage.
type PestDamage struct {
	PestID          string        `json:"pest_id"`
	PestName        string        `json:"pest_name"`
	ScientificName  string        `json:"scientific_name,omitempty"`
	ConfidenceScore float64       `json:"confidence_score"`
	DamageLevel     SeverityLevel `json:"damage_level"`
	Description     string        `json:"description,omitempty"`
	DamagePattern   string        `json:"damage_pattern,omitempty"`
	ControlMethods  []string      `json:"control_methods,omitempty"`
}

// ─────────────────────────────────────────────────────────────────────────────
// Reference data models
// ─────────────────────────────────────────────────────────────────────────────

// DiseaseInfo represents a known plant disease in the diseases reference table.
type DiseaseInfo struct {
	ID               string    `json:"id" db:"id"`
	TenantID         string    `json:"tenant_id" db:"tenant_id"`
	DiseaseName      string    `json:"disease_name" db:"disease_name"`
	ScientificName   *string   `json:"scientific_name" db:"scientific_name"`
	ConfidenceScore  float64   `json:"confidence_score" db:"confidence_score"`
	Severity         string    `json:"severity" db:"severity"`
	Description      *string   `json:"description" db:"description"`
	Symptoms         *string   `json:"symptoms" db:"symptoms"`
	TreatmentOptions []string  `json:"treatment_options" db:"treatment_options"`
	Prevention       *string   `json:"prevention" db:"prevention"`
	CreatedAt        time.Time `json:"created_at" db:"created_at"`
	UpdatedAt        time.Time `json:"updated_at" db:"updated_at"`
}

// ─────────────────────────────────────────────────────────────────────────────
// Treatment plan model
// ─────────────────────────────────────────────────────────────────────────────

// TreatmentPlan is a generated action plan for a diagnosis.
// Maps to the treatment_plans table.
type TreatmentPlan struct {
	ID            string          `json:"id" db:"id"`
	TenantID      string          `json:"tenant_id" db:"tenant_id"`
	DiagnosisID   string          `json:"diagnosis_id" db:"diagnosis_id"`
	Title         string          `json:"title" db:"title"`
	Description   *string         `json:"description" db:"description"`
	Priority      string          `json:"priority" db:"priority"`
	Steps         json.RawMessage `json:"steps" db:"steps"`
	EstimatedCost *string         `json:"estimated_cost" db:"estimated_cost"`
	EstimatedDays *int32          `json:"estimated_days" db:"estimated_days"`
	CreatedAt     time.Time       `json:"created_at" db:"created_at"`
	UpdatedAt     time.Time       `json:"updated_at" db:"updated_at"`
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
// Query parameter types
// ─────────────────────────────────────────────────────────────────────────────

// ListDiagnosesParams holds filter and pagination parameters for listing diagnosis requests.
type ListDiagnosesParams struct {
	TenantID string
	FarmID   string
	FieldID  string
	Status   *DiagnosisStatus
	PageSize int32
	Offset   int32
	SortBy   string
	SortDesc bool
}

// ListDiseasesParams holds filter and pagination parameters for listing diseases.
type ListDiseasesParams struct {
	TenantID   string
	SearchTerm string
	PageSize   int32
	Offset     int32
}

// ─────────────────────────────────────────────────────────────────────────────
// AI pipeline models (used by internal/ai package)
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
	RequestID            string               `json:"request_id"`
	Species              *PlantSpecies        `json:"species,omitempty"`
	Diseases             []DetectedDisease    `json:"diseases,omitempty"`
	NutrientDeficiencies []NutrientDeficiency `json:"nutrient_deficiencies,omitempty"`
	PestDamage           []PestDamage         `json:"pest_damage,omitempty"`
	OverallHealthScore   float64              `json:"overall_health_score"`
	Summary              string               `json:"summary"`
	ModelVersion         string               `json:"model_version"`
	ProcessingTimeMs     int64                `json:"processing_time_ms"`
}

// DetectedDisease is the JSON-serialised disease detection result stored in diagnosis_results.
type DetectedDisease struct {
	DiseaseID        string        `json:"disease_id"`
	DiseaseName      string        `json:"disease_name"`
	ScientificName   string        `json:"scientific_name,omitempty"`
	ConfidenceScore  float64       `json:"confidence_score"`
	Severity         SeverityLevel `json:"severity"`
	Description      string        `json:"description,omitempty"`
	Symptoms         string        `json:"symptoms,omitempty"`
	TreatmentOptions []string      `json:"treatment_options,omitempty"`
	Prevention       string        `json:"prevention,omitempty"`
}

// ImagePreprocessResult is returned by the Rust preprocessing engine.
type ImagePreprocessResult struct {
	RequestID     string                 `json:"request_id"`
	ProcessedURLs []string               `json:"processed_urls"`
	Metadata      map[string]interface{} `json:"metadata,omitempty"`
}
