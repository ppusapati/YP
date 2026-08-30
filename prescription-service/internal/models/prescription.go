package models

// PrescriptionType enumerates the kinds of variable-rate prescriptions.
type PrescriptionType string

const (
	PrescriptionTypeUnspecified PrescriptionType = "unspecified"
	PrescriptionTypeFertilizer  PrescriptionType = "fertilizer"
	PrescriptionTypeIrrigation  PrescriptionType = "irrigation"
	PrescriptionTypeSeeding     PrescriptionType = "seeding"
	PrescriptionTypeLiming      PrescriptionType = "liming"
)

// RateRow is a single row of rate values in a prescription grid.
type RateRow struct {
	Values []float64 `json:"values"`
}

// SoilDataRow is a single row of soil data values.
type SoilDataRow struct {
	Values []float64 `json:"values"`
}

// PrescriptionMap represents one prescription layer (e.g. fertilizer rates).
type PrescriptionMap struct {
	ID               string           `json:"id" db:"id"`
	PrescriptionType PrescriptionType `json:"prescription_type" db:"prescription_type"`
	Unit             string           `json:"unit" db:"unit"`
	Rates            []RateRow        `json:"rates"`
	AvgRate          float64          `json:"avg_rate" db:"avg_rate"`
}

// ZoneSummary summarises prescription rates within a management zone.
type ZoneSummary struct {
	Zone             string           `json:"zone"` // "Low", "Medium", "High"
	PrescriptionType PrescriptionType `json:"prescription_type"`
	AreaHectares     float64          `json:"area_hectares"`
	MinRate          float64          `json:"min_rate"`
	MeanRate         float64          `json:"mean_rate"`
	MaxRate          float64          `json:"max_rate"`
	TotalAmount      float64          `json:"total_amount"`
}

// PrescriptionBundle is the top-level prescription output for a field.
type PrescriptionBundle struct {
	ID                    string            `json:"id" db:"id"`
	FieldID               string            `json:"field_id" db:"field_id"`
	FieldName             string            `json:"field_name" db:"field_name"`
	CropType              string            `json:"crop_type" db:"crop_type"`
	TargetYield           float64           `json:"target_yield" db:"target_yield"`
	CreatedAt             string            `json:"created_at" db:"created_at"`
	EstimatedCostSavings  float64           `json:"estimated_cost_savings" db:"estimated_cost_savings"`
	EstimatedYieldGain    float64           `json:"estimated_yield_gain" db:"estimated_yield_gain"`
	Prescriptions         []PrescriptionMap `json:"prescriptions"`
	ZoneSummaries         []ZoneSummary     `json:"zone_summaries"`
}

// GeneratePrescriptionInput holds the parameters for generating a new
// prescription.
type GeneratePrescriptionInput struct {
	FieldID     string
	CropType    string
	TargetYield float64
	SoilData    []SoilDataRow
}
