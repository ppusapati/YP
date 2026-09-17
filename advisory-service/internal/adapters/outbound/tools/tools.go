package tools

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"connectrpc.com/connect"

	alertv1 "p9e.in/samavaya/agriculture/alert-service/api/v1"
	fieldv1 "p9e.in/samavaya/agriculture/field-service/api/v1"
	irrigationv1 "p9e.in/samavaya/agriculture/irrigation-service/api/v1"
	pestv1 "p9e.in/samavaya/agriculture/pest-prediction-service/api/v1"
	diagnosisv1 "p9e.in/samavaya/agriculture/plant-diagnosis-service/api/v1"
	prescriptionv1 "p9e.in/samavaya/agriculture/prescription-service/api/v1"
	weatherv1 "p9e.in/samavaya/agriculture/weather-service/api/v1"
	yieldv1 "p9e.in/samavaya/agriculture/yield-service/api/v1"

	"p9e.in/samavaya/agriculture/advisory-service/internal/domain"
	"p9e.in/samavaya/agriculture/advisory-service/internal/ports/outbound"
)

// Registry returns every tool whose service is configured.
//
// Built from what is reachable rather than from a fixed list, so the model is
// never offered a tool that cannot run. A model told it can call
// pest_risk in a deployment with no pest-prediction service will call it, get
// an error, and then have to explain that error to a farmer — which reads to
// them as the assistant being broken rather than as a service being absent.
func (c *Clients) Registry() []outbound.Tool {
	var out []outbound.Tool
	if c.Yield != nil {
		out = append(out, &yieldTool{c: c})
	}
	if c.Irrigation != nil {
		out = append(out, &irrigationTool{c: c})
	}
	if c.Pest != nil {
		out = append(out, &pestTool{c: c})
	}
	if c.Field != nil {
		out = append(out, &fieldTool{c: c})
	}
	if c.Alert != nil {
		out = append(out, &alertTool{c: c})
	}
	if c.Weather != nil {
		out = append(out, &weatherTool{c: c})
	}
	if c.Diagnosis != nil {
		out = append(out, &diagnosisTool{c: c})
	}
	if c.Prescription != nil {
		out = append(out, &prescriptionTool{c: c})
	}
	return out
}

// ── Shared helpers ───────────────────────────────────────────────────────────

func decodeArgs(argumentsJSON string, into any) error {
	if strings.TrimSpace(argumentsJSON) == "" {
		argumentsJSON = "{}"
	}
	if err := json.Unmarshal([]byte(argumentsJSON), into); err != nil {
		return fmt.Errorf("the arguments were not valid JSON: %w", err)
	}
	return nil
}

func encodeResult(v any) (string, error) {
	// Indented, because this JSON is read by two audiences that both matter: a
	// model, which does not care, and an agronomist reviewing the exchange,
	// who does.
	raw, err := json.MarshalIndent(v, "", "  ")
	if err != nil {
		return "", err
	}
	return string(raw), nil
}

func schema(properties map[string]any, required ...string) map[string]any {
	s := map[string]any{
		"type":       "object",
		"properties": properties,
	}
	if len(required) > 0 {
		s["required"] = required
	}
	return s
}

func stringProp(description string) map[string]any {
	return map[string]any{"type": "string", "description": description}
}

// appURI builds the deep link a citation opens.
//
// A citation that cannot be followed is a footnote, not evidence. These paths
// match the web shell's routes so pressing a source in the chat opens the
// record the number came from.
func appURI(parts ...string) string {
	return "/" + strings.Join(parts, "/")
}

func argString(m map[string]any, key string) string {
	if v, ok := m[key].(string); ok {
		return v
	}
	return ""
}

func argsMap(argumentsJSON string) map[string]any {
	out := map[string]any{}
	_ = decodeArgs(argumentsJSON, &out)
	return out
}

// ── yield_forecast ───────────────────────────────────────────────────────────

type yieldTool struct{ c *Clients }

func (t *yieldTool) Name() string { return "yield_forecast" }

func (t *yieldTool) Description() string {
	return "Forecast the yield of a specific field for a season, using that field's own " +
		"recorded conditions. Use this instead of estimating a yield yourself. " +
		"Returns kilograms per hectare and the model's confidence."
}

func (t *yieldTool) InputSchema() map[string]any {
	return schema(map[string]any{
		"field_id": stringProp("The field to forecast. Required."),
		"farm_id":  stringProp("The farm the field belongs to, if known."),
		"crop_id":  stringProp("The crop identifier, if known."),
		"season":   stringProp("kharif, rabi or zaid."),
		"year":     map[string]any{"type": "integer", "description": "Four-digit year."},
	}, "field_id")
}

func (t *yieldTool) Call(ctx context.Context, argumentsJSON string) (string, error) {
	var args struct {
		FieldID string `json:"field_id"`
		FarmID  string `json:"farm_id"`
		CropID  string `json:"crop_id"`
		Season  string `json:"season"`
		Year    int32  `json:"year"`
	}
	if err := decodeArgs(argumentsJSON, &args); err != nil {
		return "", err
	}
	if args.FieldID == "" {
		return "", fmt.Errorf("field_id is required")
	}
	if args.Year == 0 {
		args.Year = int32(time.Now().UTC().Year())
	}

	resp, err := t.c.Yield.PredictYield(ctx, connect.NewRequest(&yieldv1.PredictYieldRequest{
		FarmId:  args.FarmID,
		FieldId: args.FieldID,
		CropId:  args.CropID,
		Season:  args.Season,
		Year:    args.Year,
	}))
	if err != nil {
		return "", err
	}

	p := resp.Msg.GetPrediction()
	if p == nil {
		return "", fmt.Errorf("the yield service returned no prediction for this field")
	}
	return encodeResult(map[string]any{
		"field_id":                       p.GetFieldId(),
		"season":                         p.GetSeason(),
		"year":                           p.GetYear(),
		"predicted_yield_kg_per_hectare": p.GetPredictedYieldKgPerHectare(),
		// Reported alongside the figure rather than left in the response for
		// someone to look up. A forecast at 40% confidence and one at 90% are
		// different advice, and a model given only the number will present
		// them identically.
		"confidence_pct": p.GetPredictionConfidencePct(),
		"model_version":  p.GetPredictionModelVersion(),
	})
}

func (t *yieldTool) Citation(argumentsJSON, resultJSON string) domain.Citation {
	fieldID := argString(argsMap(argumentsJSON), "field_id")
	return domain.Citation{
		Kind:     domain.CitationYieldForecast,
		Title:    "Yield forecast for this field (yield-service)",
		Snippet:  resultJSON,
		SourceID: fieldID,
		URI:      appURI("crop-intelligence", "yield"),
		Locale:   domain.LocaleEN,
	}
}

// ── irrigation_decision ──────────────────────────────────────────────────────

type irrigationTool struct{ c *Clients }

func (t *irrigationTool) Name() string { return "irrigation_decision" }

func (t *irrigationTool) Description() string {
	return "Decide whether a field needs irrigating now, from its soil moisture, the " +
		"weather and the crop's water demand. Returns whether to irrigate, the depth in " +
		"millimetres, and the reasoning. Use this rather than judging from a crop guide."
}

func (t *irrigationTool) InputSchema() map[string]any {
	return schema(map[string]any{
		"field_id":     stringProp("The field to decide for. Required."),
		"zone_id":      stringProp("The irrigation zone, if the field has more than one."),
		"crop_type":    stringProp("The crop growing in the field."),
		"growth_stage": stringProp("The crop's current growth stage, if known."),
	}, "field_id")
}

func (t *irrigationTool) Call(ctx context.Context, argumentsJSON string) (string, error) {
	var args struct {
		FieldID     string `json:"field_id"`
		ZoneID      string `json:"zone_id"`
		CropType    string `json:"crop_type"`
		GrowthStage string `json:"growth_stage"`
	}
	if err := decodeArgs(argumentsJSON, &args); err != nil {
		return "", err
	}
	if args.FieldID == "" {
		return "", fmt.Errorf("field_id is required")
	}

	// The measured inputs are deliberately left empty. irrigation-service
	// fills them from the field's own sensors and weather; passing values the
	// model invented would produce a water balance computed on fiction and
	// returned with the authority of a measurement.
	resp, err := t.c.Irrigation.GenerateIrrigationDecision(ctx,
		connect.NewRequest(&irrigationv1.GenerateIrrigationDecisionRequest{
			ZoneId:  args.ZoneID,
			FieldId: args.FieldID,
			Inputs: &irrigationv1.DecisionInputs{
				CropType:    args.CropType,
				GrowthStage: args.GrowthStage,
			},
		}))
	if err != nil {
		return "", err
	}

	d := resp.Msg.GetDecision()
	if d == nil || d.GetOutput() == nil {
		return "", fmt.Errorf("the irrigation service returned no decision for this field")
	}
	o := d.GetOutput()
	return encodeResult(map[string]any{
		"field_id":              d.GetFieldId(),
		"should_irrigate":       o.GetShouldIrrigate(),
		"recommended_depth_mm":  o.GetRecommendedDepthMm(),
		"water_quantity_liters": o.GetWaterQuantityLiters(),
		"duration_minutes":      o.GetDurationMinutes(),
		"et0_mm_day":            o.GetEt0MmDay(),
		"crop_coefficient":      o.GetCropCoefficient(),
		// "water_balance" or "heuristic". A decision from a heuristic and one
		// from a water balance deserve different confidence, and dropping this
		// would present them as the same thing.
		"method":    o.GetMethod(),
		"reasoning": o.GetReasoning(),
	})
}

func (t *irrigationTool) Citation(argumentsJSON, resultJSON string) domain.Citation {
	fieldID := argString(argsMap(argumentsJSON), "field_id")
	return domain.Citation{
		Kind:     domain.CitationIrrigation,
		Title:    "Irrigation decision for this field (irrigation-service)",
		Snippet:  resultJSON,
		SourceID: fieldID,
		URI:      appURI("smart-agriculture", "irrigation"),
		Locale:   domain.LocaleEN,
	}
}

// ── pest_risk ────────────────────────────────────────────────────────────────

type pestTool struct{ c *Clients }

func (t *pestTool) Name() string { return "pest_risk" }

func (t *pestTool) Description() string {
	return "Assess the current pest risk for a field from its weather and crop stage. " +
		"Returns a risk level, a 0-100 score and the treatment window. Use this before " +
		"recommending any pesticide application."
}

func (t *pestTool) InputSchema() map[string]any {
	return schema(map[string]any{
		"field_id":        stringProp("The field to assess. Required."),
		"farm_id":         stringProp("The farm the field belongs to, if known."),
		"crop_type":       stringProp("The crop growing in the field."),
		"pest_species_id": stringProp("A specific pest to assess, if the farmer named one."),
	}, "field_id")
}

func (t *pestTool) Call(ctx context.Context, argumentsJSON string) (string, error) {
	var args struct {
		FieldID       string `json:"field_id"`
		FarmID        string `json:"farm_id"`
		CropType      string `json:"crop_type"`
		PestSpeciesID string `json:"pest_species_id"`
	}
	if err := decodeArgs(argumentsJSON, &args); err != nil {
		return "", err
	}
	if args.FieldID == "" {
		return "", fmt.Errorf("field_id is required")
	}

	resp, err := t.c.Pest.PredictPestRisk(ctx, connect.NewRequest(&pestv1.PredictPestRiskRequest{
		FarmId:        args.FarmID,
		FieldId:       args.FieldID,
		CropType:      args.CropType,
		PestSpeciesId: args.PestSpeciesID,
	}))
	if err != nil {
		return "", err
	}

	p := resp.Msg.GetPrediction()
	if p == nil {
		return "", fmt.Errorf("the pest service returned no prediction for this field")
	}

	result := map[string]any{
		"field_id":        p.GetFieldId(),
		"pest_species_id": p.GetPestSpeciesId(),
		"risk_level":      p.GetRiskLevel().String(),
		"risk_score":      p.GetRiskScore(),
		"confidence_pct":  p.GetConfidencePct(),
		"crop_type":       p.GetCropType(),
	}
	if start := p.GetTreatmentWindowStart(); start != nil {
		result["treatment_window_start"] = start.AsTime().Format(time.RFC3339)
	}
	if end := p.GetTreatmentWindowEnd(); end != nil {
		result["treatment_window_end"] = end.AsTime().Format(time.RFC3339)
	}

	// Rates and safety intervals are passed through as strings, exactly as the
	// service returned them, and never converted or rounded here. A pesticide
	// rate is the single figure in this service most likely to harm someone if
	// it is wrong; parsing "1.5 ml/litre" into a number and re-rendering it is
	// two chances to change it, and the groundedness check can only verify a
	// quantity in the answer against the characters that appear in this JSON.
	var treatments []map[string]any
	for _, rec := range p.GetRecommendedTreatments() {
		if strings.TrimSpace(rec.GetProductName()) == "" {
			continue
		}
		treatments = append(treatments, map[string]any{
			"product_name":       rec.GetProductName(),
			"treatment_type":     rec.GetTreatmentType().String(),
			"application_rate":   rec.GetApplicationRate(),
			"application_method": rec.GetApplicationMethod(),
			"timing":             rec.GetTiming(),
			"safety_interval":    rec.GetSafetyInterval(),
		})
	}
	if len(treatments) > 0 {
		result["recommended_treatments"] = treatments
	}

	return encodeResult(result)
}

func (t *pestTool) Citation(argumentsJSON, resultJSON string) domain.Citation {
	fieldID := argString(argsMap(argumentsJSON), "field_id")
	return domain.Citation{
		Kind:     domain.CitationPestRisk,
		Title:    "Pest risk for this field (pest-prediction-service)",
		Snippet:  resultJSON,
		SourceID: fieldID,
		URI:      appURI("crop-intelligence", "pest-risk"),
		Locale:   domain.LocaleEN,
	}
}

// ── field_record ─────────────────────────────────────────────────────────────

type fieldTool struct{ c *Clients }

func (t *fieldTool) Name() string { return "field_record" }

func (t *fieldTool) Description() string {
	return "Look up a field's own record: its area, soil type, irrigation type, current " +
		"crop, growth stage and planting date."
}

func (t *fieldTool) InputSchema() map[string]any {
	return schema(map[string]any{
		"field_id": stringProp("The field to look up. Required."),
	}, "field_id")
}

func (t *fieldTool) Call(ctx context.Context, argumentsJSON string) (string, error) {
	var args struct {
		FieldID string `json:"field_id"`
	}
	if err := decodeArgs(argumentsJSON, &args); err != nil {
		return "", err
	}
	if args.FieldID == "" {
		return "", fmt.Errorf("field_id is required")
	}

	resp, err := t.c.Field.GetField(ctx, connect.NewRequest(&fieldv1.GetFieldRequest{Id: args.FieldID}))
	if err != nil {
		return "", err
	}
	return encodeResult(fieldSummary(resp.Msg.GetField()))
}

func fieldSummary(f *fieldv1.Field) map[string]any {
	if f == nil {
		return map[string]any{}
	}
	out := map[string]any{
		"field_id":        f.GetId(),
		"name":            f.GetName(),
		"farm_id":         f.GetFarmId(),
		"area_hectares":   f.GetAreaHectares(),
		"soil_type":       f.GetSoilType().String(),
		"irrigation_type": f.GetIrrigationType().String(),
		"growth_stage":    f.GetGrowthStage().String(),
		"current_crop_id": f.GetCurrentCropId(),
	}
	if planted := f.GetPlantingDate(); planted != nil {
		out["planting_date"] = planted.AsTime().Format("2006-01-02")
		// Days after sowing, computed here rather than left to the model.
		// Almost every agronomic recommendation is keyed on it, and asking a
		// model to subtract two dates is asking for an arithmetic error inside
		// otherwise correct advice.
		out["days_after_sowing"] = int(time.Since(planted.AsTime()).Hours() / 24)
	}
	return out
}

func (t *fieldTool) Citation(argumentsJSON, resultJSON string) domain.Citation {
	fieldID := argString(argsMap(argumentsJSON), "field_id")
	return domain.Citation{
		Kind:     domain.CitationField,
		Title:    "Field record (field-service)",
		Snippet:  resultJSON,
		SourceID: fieldID,
		URI:      appURI("farm-management", "fields", fieldID),
		Locale:   domain.LocaleEN,
	}
}

// ── open_alerts ──────────────────────────────────────────────────────────────

type alertTool struct{ c *Clients }

func (t *alertTool) Name() string { return "open_alerts" }

func (t *alertTool) Description() string {
	return "List the open alerts raised on a field or farm — disease risk, weather, " +
		"sensor and irrigation warnings the platform has already generated."
}

func (t *alertTool) InputSchema() map[string]any {
	return schema(map[string]any{
		"field_id": stringProp("Limit to one field."),
		"farm_id":  stringProp("Limit to one farm."),
	})
}

func (t *alertTool) Call(ctx context.Context, argumentsJSON string) (string, error) {
	var args struct {
		FieldID string `json:"field_id"`
		FarmID  string `json:"farm_id"`
	}
	if err := decodeArgs(argumentsJSON, &args); err != nil {
		return "", err
	}

	resp, err := t.c.Alert.ListAlerts(ctx, connect.NewRequest(&alertv1.ListAlertsRequest{
		FieldId:  args.FieldID,
		FarmId:   args.FarmID,
		PageSize: 10,
	}))
	if err != nil {
		return "", err
	}
	return encodeResult(alertSummaries(resp.Msg.GetAlerts()))
}

func alertSummaries(alerts []*alertv1.Alert) []map[string]any {
	out := make([]map[string]any, 0, len(alerts))
	for _, a := range alerts {
		item := map[string]any{
			"id":       a.GetId(),
			"type":     a.GetType(),
			"title":    a.GetTitle(),
			"message":  a.GetMessage(),
			"severity": a.GetSeverity().String(),
			"status":   a.GetStatus().String(),
			"field_id": a.GetFieldId(),
		}
		if ts := a.GetTimestamp(); ts != nil {
			item["raised_at"] = ts.AsTime().Format(time.RFC3339)
		}
		out = append(out, item)
	}
	return out
}

func (t *alertTool) Citation(argumentsJSON, resultJSON string) domain.Citation {
	return domain.Citation{
		Kind:     domain.CitationAlert,
		Title:    "Open alerts (alert-service)",
		Snippet:  resultJSON,
		SourceID: argString(argsMap(argumentsJSON), "field_id"),
		URI:      appURI("alerts"),
		Locale:   domain.LocaleEN,
	}
}

// ── current_weather ──────────────────────────────────────────────────────────

type weatherTool struct{ c *Clients }

func (t *weatherTool) Name() string { return "current_weather" }

func (t *weatherTool) Description() string {
	return "The latest weather observation for a field: temperature, humidity, rainfall, " +
		"wind and soil moisture."
}

func (t *weatherTool) InputSchema() map[string]any {
	return schema(map[string]any{
		"field_id": stringProp("The field whose weather to read. Required."),
	}, "field_id")
}

func (t *weatherTool) Call(ctx context.Context, argumentsJSON string) (string, error) {
	var args struct {
		FieldID string `json:"field_id"`
	}
	if err := decodeArgs(argumentsJSON, &args); err != nil {
		return "", err
	}
	if args.FieldID == "" {
		return "", fmt.Errorf("field_id is required")
	}

	resp, err := t.c.Weather.GetCurrentWeather(ctx,
		connect.NewRequest(&weatherv1.GetCurrentWeatherRequest{FieldId: args.FieldID}))
	if err != nil {
		return "", err
	}
	return encodeResult(weatherSummary(resp.Msg.GetObservation()))
}

func weatherSummary(o *weatherv1.Observation) map[string]any {
	if o == nil {
		return map[string]any{}
	}
	out := map[string]any{
		"field_id":           o.GetFieldId(),
		"temperature_c":      o.GetTemperatureC(),
		"humidity_pct":       o.GetHumidityPct(),
		"precipitation_mm":   o.GetPrecipitationMm(),
		"wind_speed_ms":      o.GetWindSpeedMs(),
		"soil_moisture_m3m3": o.GetSoilMoistureM3M3(),
		"provider":           o.GetProvider().String(),
	}
	if at := o.GetObservedAt(); at != nil {
		// The observation time, not just the reading. A three-day-old
		// observation presented as "current" is how an assistant tells a
		// farmer it is dry during a downpour.
		out["observed_at"] = at.AsTime().Format(time.RFC3339)
		out["age_hours"] = int(time.Since(at.AsTime()).Hours())
	}
	return out
}

func (t *weatherTool) Citation(argumentsJSON, resultJSON string) domain.Citation {
	fieldID := argString(argsMap(argumentsJSON), "field_id")
	return domain.Citation{
		Kind:     domain.CitationWeather,
		Title:    "Latest weather observation (weather-service)",
		Snippet:  resultJSON,
		SourceID: fieldID,
		URI:      appURI("smart-agriculture", "weather"),
		Locale:   domain.LocaleEN,
	}
}

// ── recent_diagnoses ─────────────────────────────────────────────────────────

type diagnosisTool struct{ c *Clients }

func (t *diagnosisTool) Name() string { return "recent_diagnoses" }

func (t *diagnosisTool) Description() string {
	return "The most recent plant diagnoses submitted for a field, with the diseases, " +
		"nutrient deficiencies and pest damage the vision models found."
}

func (t *diagnosisTool) InputSchema() map[string]any {
	return schema(map[string]any{
		"field_id": stringProp("The field whose diagnoses to read. Required."),
		"farm_id":  stringProp("The farm, if known."),
	}, "field_id")
}

func (t *diagnosisTool) Call(ctx context.Context, argumentsJSON string) (string, error) {
	var args struct {
		FieldID string `json:"field_id"`
		FarmID  string `json:"farm_id"`
	}
	if err := decodeArgs(argumentsJSON, &args); err != nil {
		return "", err
	}
	if args.FieldID == "" {
		return "", fmt.Errorf("field_id is required")
	}

	resp, err := t.c.Diagnosis.ListDiagnoses(ctx, connect.NewRequest(&diagnosisv1.ListDiagnosesRequest{
		FieldId:  args.FieldID,
		FarmId:   args.FarmID,
		PageSize: 5,
		SortBy:   "created_at",
		SortDesc: true,
	}))
	if err != nil {
		return "", err
	}
	return encodeResult(diagnosisSummaries(resp.Msg.GetDiagnoses()))
}

func diagnosisSummaries(diagnoses []*diagnosisv1.DiagnosisRequest) []map[string]any {
	out := make([]map[string]any, 0, len(diagnoses))
	for _, d := range diagnoses {
		item := map[string]any{
			"id":       d.GetId(),
			"field_id": d.GetFieldId(),
			"status":   d.GetStatus().String(),
		}
		if at := d.GetCreatedAt(); at != nil {
			item["submitted_at"] = at.AsTime().Format(time.RFC3339)
		}
		if r := d.GetResult(); r != nil {
			item["summary"] = r.GetSummary()
			item["overall_health_score"] = r.GetOverallHealthScore()
			var diseases []map[string]any
			for _, disease := range r.GetDetectedDiseases() {
				diseases = append(diseases, map[string]any{
					"disease_name":     disease.GetDiseaseName(),
					"scientific_name":  disease.GetScientificName(),
					"confidence_score": disease.GetConfidenceScore(),
					"severity":         disease.GetSeverity().String(),
				})
			}
			if len(diseases) > 0 {
				item["detected_diseases"] = diseases
			}
			if recs := r.GetTreatmentRecommendations(); len(recs) > 0 {
				item["treatment_recommendations"] = recs
			}
		}
		out = append(out, item)
	}
	return out
}

func (t *diagnosisTool) Citation(argumentsJSON, resultJSON string) domain.Citation {
	fieldID := argString(argsMap(argumentsJSON), "field_id")
	return domain.Citation{
		Kind:     domain.CitationDiagnosis,
		Title:    "Recent diagnoses for this field (plant-diagnosis-service)",
		Snippet:  resultJSON,
		SourceID: fieldID,
		URI:      appURI("crop-intelligence", "diagnosis"),
		Locale:   domain.LocaleEN,
	}
}

// ── prescriptions ────────────────────────────────────────────────────────────

type prescriptionTool struct{ c *Clients }

func (t *prescriptionTool) Name() string { return "prescriptions" }

func (t *prescriptionTool) Description() string {
	return "The variable-rate prescriptions already generated for this tenant's fields, " +
		"with their crop, target yield and expected cost saving."
}

func (t *prescriptionTool) InputSchema() map[string]any {
	return schema(map[string]any{
		"field_id": stringProp("Limit to one field."),
	})
}

func (t *prescriptionTool) Call(ctx context.Context, argumentsJSON string) (string, error) {
	var args struct {
		FieldID string `json:"field_id"`
	}
	if err := decodeArgs(argumentsJSON, &args); err != nil {
		return "", err
	}

	resp, err := t.c.Prescription.ListPrescriptions(ctx,
		connect.NewRequest(&prescriptionv1.ListPrescriptionsRequest{PageSize: 20}))
	if err != nil {
		return "", err
	}

	// The service lists by type, not by field, so the field filter is applied
	// here. Asking for every prescription and letting the model pick would put
	// other fields' numbers in front of a question about this one, which is
	// exactly how a recommendation ends up quoting the wrong field's rate.
	out := make([]map[string]any, 0)
	for _, bundle := range resp.Msg.GetPrescriptions() {
		if args.FieldID != "" && bundle.GetFieldId() != args.FieldID {
			continue
		}
		out = append(out, map[string]any{
			"id":                     bundle.GetId(),
			"field_id":               bundle.GetFieldId(),
			"field_name":             bundle.GetFieldName(),
			"crop_type":              bundle.GetCropType(),
			"target_yield":           bundle.GetTargetYield(),
			"estimated_cost_savings": bundle.GetEstimatedCostSavings(),
			"estimated_yield_gain":   bundle.GetEstimatedYieldGain(),
			"created_at":             bundle.GetCreatedAt(),
		})
	}
	return encodeResult(out)
}

func (t *prescriptionTool) Citation(argumentsJSON, resultJSON string) domain.Citation {
	return domain.Citation{
		Kind:     domain.CitationPrescription,
		Title:    "Prescriptions (prescription-service)",
		Snippet:  resultJSON,
		SourceID: argString(argsMap(argumentsJSON), "field_id"),
		URI:      appURI("prescriptions"),
		Locale:   domain.LocaleEN,
	}
}
