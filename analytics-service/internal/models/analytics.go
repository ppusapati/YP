package models

// FieldAnalyticsSummary holds aggregated analytics for a single field.
type FieldAnalyticsSummary struct {
	FieldID         string  `json:"field_id" db:"field_id"`
	FieldName       string  `json:"field_name" db:"field_name"`
	MeanYield       float64 `json:"mean_yield" db:"mean_yield"`
	PeakYield       float64 `json:"peak_yield" db:"peak_yield"`
	YieldTrend      string  `json:"yield_trend" db:"yield_trend"` // "increasing", "decreasing", "stable"
	AvgStressDays   float64 `json:"avg_stress_days" db:"avg_stress_days"`
	AvgNDVI         float64 `json:"avg_ndvi" db:"avg_ndvi"`
	SeasonsAnalyzed int32   `json:"seasons_analyzed" db:"seasons_analyzed"`
}

// YieldTrendPoint is a single data point in a yield trend series.
type YieldTrendPoint struct {
	Season     string  `json:"season"`
	Crop       string  `json:"crop"`
	YieldValue float64 `json:"yield_value"`
	NDVI       float64 `json:"ndvi"`
}

// SeasonComparison contains a season-by-season comparison for a field.
type SeasonComparison struct {
	Season          string   `json:"season"`
	Crop            string   `json:"crop"`
	YieldValue      float64  `json:"yield_value"`
	YieldVsMeanPct  float64  `json:"yield_vs_mean_pct"`
	StressDays      int32    `json:"stress_days"`
	StressVsMeanPct float64  `json:"stress_vs_mean_pct"`
	NDVIPeak        float64  `json:"ndvi_peak"`
	NDVIVsMeanPct   float64  `json:"ndvi_vs_mean_pct"`
	NotableEvents   []string `json:"notable_events"`
}

// RotationAnalysis holds crop rotation analysis results for a field.
type RotationAnalysis struct {
	EffectivenessScore float64  `json:"effectiveness_score"`
	DiversityIndex     float64  `json:"diversity_index"`
	RotationLength     int32    `json:"rotation_length"`
	SoilHealthImpact   string   `json:"soil_health_impact"`
	RotationPattern    []string `json:"rotation_pattern"`
	Recommendations    []string `json:"recommendations"`
}

// HistoricalMetrics contains aggregate metrics across multiple fields.
type HistoricalMetrics struct {
	MeanYield       float64                 `json:"mean_yield"`
	PeakYield       float64                 `json:"peak_yield"`
	YieldTrend      string                  `json:"yield_trend"`
	AvgStressDays   float64                 `json:"avg_stress_days"`
	AvgNDVI         float64                 `json:"avg_ndvi"`
	SeasonsAnalyzed int32                   `json:"seasons_analyzed"`
	Fields          []FieldAnalyticsSummary `json:"fields"`
}

// CrossFieldTrendPoint represents trend data for one field in a cross-field
// comparison.
type CrossFieldTrendPoint struct {
	FieldID   string    `json:"field_id"`
	FieldName string    `json:"field_name"`
	Values    []float64 `json:"values"`
	Labels    []string  `json:"labels"`
}
