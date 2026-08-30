package models

import "encoding/json"

// AlertRuleThresholds holds the per-alert-type threshold configuration
// that is serialized as JSON in AlertRule.ThresholdJSON.
type AlertRuleThresholds struct {
	// Temperature-based thresholds
	FrostTempC float64 `json:"frost_temp_c,omitempty"`
	HeatTempC  float64 `json:"heat_temp_c,omitempty"`

	// Water-based thresholds
	DroughtSoilMoisture    float64 `json:"drought_soil_moisture,omitempty"`
	ExcessiveRainMM        float64 `json:"excessive_rain_mm,omitempty"`
	WaterStressThreshold   float64 `json:"water_stress_threshold,omitempty"`

	// Pest and disease thresholds
	PestConfidenceThreshold    float64 `json:"pest_confidence_threshold,omitempty"`
	DiseaseConfidenceThreshold float64 `json:"disease_confidence_threshold,omitempty"`

	// Growth and nutrient thresholds
	GrowthDeviationPct       float64 `json:"growth_deviation_pct,omitempty"`
	NutrientSeverityThreshold float64 `json:"nutrient_severity_threshold,omitempty"`

	// General threshold range (for custom rules)
	MinValue *float64 `json:"min_value,omitempty"`
	MaxValue *float64 `json:"max_value,omitempty"`
}

// DefaultThresholds returns the default thresholds matching the Rust alert-engine defaults.
func DefaultThresholds() AlertRuleThresholds {
	return AlertRuleThresholds{
		FrostTempC:                 2.0,
		HeatTempC:                 38.0,
		DroughtSoilMoisture:       0.15,
		ExcessiveRainMM:           50.0,
		WaterStressThreshold:      0.4,
		PestConfidenceThreshold:   0.6,
		DiseaseConfidenceThreshold: 0.5,
		GrowthDeviationPct:        20.0,
		NutrientSeverityThreshold: 0.5,
	}
}

// Marshal serializes AlertRuleThresholds to JSON.
func (t *AlertRuleThresholds) Marshal() (string, error) {
	b, err := json.Marshal(t)
	if err != nil {
		return "", err
	}
	return string(b), nil
}

// ParseThresholds deserializes JSON into AlertRuleThresholds.
func ParseThresholds(raw string) (AlertRuleThresholds, error) {
	var t AlertRuleThresholds
	if raw == "" {
		return DefaultThresholds(), nil
	}
	if err := json.Unmarshal([]byte(raw), &t); err != nil {
		return AlertRuleThresholds{}, err
	}
	return t, nil
}
