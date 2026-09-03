package ai

import (
	"context"
	"fmt"
	"time"

	"google.golang.org/grpc"
	"p9e.in/samavaya/packages/grpcdial"
	"google.golang.org/grpc/keepalive"
	"google.golang.org/protobuf/types/known/structpb"

	"p9e.in/samavaya/packages/p9log"
)

const (
	methodEvaluateFieldRisk     = "/agriculture.ai.v1.AIGatewayService/EvaluateFieldRisk"
	methodComputeFieldAnalytics = "/agriculture.ai.v1.AIGatewayService/ComputeFieldAnalytics"
	methodGeneratePrescription  = "/agriculture.ai.v1.AIGatewayService/GeneratePrescription"
)

type AIClient struct {
	conn   *grpc.ClientConn
	logger *p9log.Helper
}

func NewAIClient(addr string, logger *p9log.Helper) (*AIClient, error) {
	conn, err := grpc.NewClient(addr,
		grpcdial.TransportCredentials(),
		grpc.WithKeepaliveParams(keepalive.ClientParameters{
			Time:                30 * time.Second,
			Timeout:             10 * time.Second,
			PermitWithoutStream: true,
		}),
	)
	if err != nil {
		return nil, fmt.Errorf("ai gateway dial: %w", err)
	}
	return &AIClient{conn: conn, logger: logger}, nil
}

func (c *AIClient) Close() error {
	if c.conn != nil {
		return c.conn.Close()
	}
	return nil
}

type FieldRiskResult struct {
	OverallRisk     float64
	TemperatureRisk float64
	WaterRisk       float64
	PestRisk        float64
	DiseaseRisk     float64
	NutrientRisk    float64
	GrowthRisk      float64
	Alerts          []FieldAlert
}

type FieldAlert struct {
	AlertType       string
	Severity        string
	Title           string
	Message         string
	Recommendations []string
	MetricValue     float64
	ThresholdValue  float64
}

type EvaluateFieldRiskRequest struct {
	FieldID              string
	FarmID               string
	CropType             string
	TempCurrent          float64
	TempMinForecast      float64
	TempMaxForecast      float64
	PrecipitationMM      float64
	PrecipForecastMM     float64
	SoilMoisture         float64
	EtReferenceMM        float64
	CO2PPM               float64
	PestConfidence       float64
	PestSpecies          string
	DiseaseConfidence    float64
	DiseaseName          string
	NutrientSeverity     float64
	NutrientType         string
	NDVICurrent          float64
	NDVIPrevious         float64
	GrowthExpected       float64
	GrowthActual         float64
}

func (c *AIClient) EvaluateFieldRisk(ctx context.Context, req *EvaluateFieldRiskRequest) (*FieldRiskResult, error) {
	in, err := structpb.NewStruct(map[string]interface{}{
		"field_id":                 req.FieldID,
		"farm_id":                  req.FarmID,
		"crop_type":                req.CropType,
		"temperature_current":      req.TempCurrent,
		"temperature_min_forecast": req.TempMinForecast,
		"temperature_max_forecast": req.TempMaxForecast,
		"precipitation_mm":         req.PrecipitationMM,
		"precipitation_forecast_mm": req.PrecipForecastMM,
		"soil_moisture":            req.SoilMoisture,
		"pest_confidence":          req.PestConfidence,
		"disease_confidence":       req.DiseaseConfidence,
	})
	if err != nil {
		return nil, fmt.Errorf("build request: %w", err)
	}

	out := &structpb.Struct{}
	if err := c.conn.Invoke(ctx, methodEvaluateFieldRisk, in, out); err != nil {
		c.logger.Errorf("EvaluateFieldRisk RPC failed: %v", err)
		return nil, fmt.Errorf("evaluate field risk: %w", err)
	}

	return parseFieldRiskResult(out), nil
}

func parseFieldRiskResult(s *structpb.Struct) *FieldRiskResult {
	f := s.GetFields()
	result := &FieldRiskResult{
		OverallRisk:     f["overall_risk"].GetNumberValue(),
		TemperatureRisk: f["temperature_risk"].GetNumberValue(),
		WaterRisk:       f["water_risk"].GetNumberValue(),
		PestRisk:        f["pest_risk"].GetNumberValue(),
		DiseaseRisk:     f["disease_risk"].GetNumberValue(),
		NutrientRisk:    f["nutrient_risk"].GetNumberValue(),
		GrowthRisk:      f["growth_risk"].GetNumberValue(),
	}

	if alertsList := f["alerts"].GetListValue(); alertsList != nil {
		for _, v := range alertsList.GetValues() {
			af := v.GetStructValue().GetFields()
			var recs []string
			if r := af["recommendations"].GetListValue(); r != nil {
				for _, rv := range r.GetValues() {
					recs = append(recs, rv.GetStringValue())
				}
			}
			result.Alerts = append(result.Alerts, FieldAlert{
				AlertType:       af["alert_type"].GetStringValue(),
				Severity:        af["severity"].GetStringValue(),
				Title:           af["title"].GetStringValue(),
				Message:         af["message"].GetStringValue(),
				Recommendations: recs,
				MetricValue:     af["metric_value"].GetNumberValue(),
				ThresholdValue:  af["threshold_value"].GetNumberValue(),
			})
		}
	}

	return result
}

type FieldAnalyticsResult struct {
	SeasonCount            int
	YieldTrend             string
	YieldTrendPctPerYear   float64
	MeanYield              float64
	BestYield              float64
	WorstYield             float64
	NDVITrend              string
	MeanStressDaysPerSeason float64
}

type SeasonInput struct {
	CropType             string
	Season               string
	Year                 int
	YieldKgPerHa         float64
	StressDays           int
	FrostEvents          int
	HeatEvents           int
	DroughtDays          int
	TotalPrecipitationMM float64
	MeanTemperature      float64
	MeanNDVI             float64
	PeakNDVI             float64
	TotalThermalTime     float64
}

func (c *AIClient) ComputeFieldAnalytics(ctx context.Context, fieldID, farmID string, seasons []SeasonInput) (*FieldAnalyticsResult, error) {
	seasonList := make([]interface{}, len(seasons))
	for i, s := range seasons {
		seasonList[i] = map[string]interface{}{
			"crop_type":              s.CropType,
			"season":                 s.Season,
			"year":                   float64(s.Year),
			"yield_kg_per_ha":        s.YieldKgPerHa,
			"stress_days":            float64(s.StressDays),
			"frost_events":           float64(s.FrostEvents),
			"heat_events":            float64(s.HeatEvents),
			"drought_days":           float64(s.DroughtDays),
			"total_precipitation_mm": s.TotalPrecipitationMM,
			"mean_temperature":       s.MeanTemperature,
			"mean_ndvi":              s.MeanNDVI,
			"peak_ndvi":              s.PeakNDVI,
			"total_thermal_time":     s.TotalThermalTime,
		}
	}

	in, err := structpb.NewStruct(map[string]interface{}{
		"field_id": fieldID,
		"farm_id":  farmID,
		"seasons":  seasonList,
	})
	if err != nil {
		return nil, fmt.Errorf("build request: %w", err)
	}

	out := &structpb.Struct{}
	if err := c.conn.Invoke(ctx, methodComputeFieldAnalytics, in, out); err != nil {
		c.logger.Errorf("ComputeFieldAnalytics RPC failed: %v", err)
		return nil, fmt.Errorf("compute field analytics: %w", err)
	}

	f := out.GetFields()
	return &FieldAnalyticsResult{
		SeasonCount:             int(f["season_count"].GetNumberValue()),
		YieldTrend:              f["yield_trend"].GetStringValue(),
		YieldTrendPctPerYear:    f["yield_trend_pct_per_year"].GetNumberValue(),
		MeanYield:               f["mean_yield"].GetNumberValue(),
		BestYield:               f["best_yield"].GetNumberValue(),
		WorstYield:              f["worst_yield"].GetNumberValue(),
		NDVITrend:               f["ndvi_trend"].GetStringValue(),
		MeanStressDaysPerSeason: f["mean_stress_days_per_season"].GetNumberValue(),
	}, nil
}

type PrescriptionResult struct {
	Prescriptions          []PrescriptionMapResult
	EstimatedCostSavingsPct float64
	EstimatedYieldGainPct   float64
}

type PrescriptionMapResult struct {
	PrescriptionType string
	Rates            []float64
	Unit             string
	TotalAmount      float64
}

func (c *AIClient) GeneratePrescription(ctx context.Context, fieldID string, gridRows, gridCols int, cellSizeM float64, ndvi, soilN, soilP, soilK, soilPH, soilMoisture, soilOM []float64, cropType string, targetYield float64) (*PrescriptionResult, error) {
	ndviIface := make([]interface{}, len(ndvi))
	for i, v := range ndvi {
		ndviIface[i] = v
	}

	in, err := structpb.NewStruct(map[string]interface{}{
		"field_id":  fieldID,
		"crop_type": cropType,
		"grid_rows": float64(gridRows),
		"grid_cols": float64(gridCols),
		"cell_size_m": cellSizeM,
		"target_yield_kg_ha": targetYield,
	})
	if err != nil {
		return nil, fmt.Errorf("build request: %w", err)
	}

	out := &structpb.Struct{}
	if err := c.conn.Invoke(ctx, methodGeneratePrescription, in, out); err != nil {
		c.logger.Errorf("GeneratePrescription RPC failed: %v", err)
		return nil, fmt.Errorf("generate prescription: %w", err)
	}

	f := out.GetFields()
	result := &PrescriptionResult{
		EstimatedCostSavingsPct: f["estimated_cost_savings_pct"].GetNumberValue(),
		EstimatedYieldGainPct:   f["estimated_yield_gain_pct"].GetNumberValue(),
	}

	if prescList := f["prescriptions"].GetListValue(); prescList != nil {
		for _, v := range prescList.GetValues() {
			pf := v.GetStructValue().GetFields()
			var rates []float64
			if r := pf["rates"].GetListValue(); r != nil {
				for _, rv := range r.GetValues() {
					rates = append(rates, rv.GetNumberValue())
				}
			}
			result.Prescriptions = append(result.Prescriptions, PrescriptionMapResult{
				PrescriptionType: pf["prescription_type"].GetStringValue(),
				Rates:            rates,
				Unit:             pf["unit"].GetStringValue(),
				TotalAmount:      pf["total_amount"].GetNumberValue(),
			})
		}
	}

	return result, nil
}
