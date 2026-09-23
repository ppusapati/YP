// Calls go through the gateway's generated stubs. An earlier version sent
// `structpb.Struct` values over `conn.Invoke` with the method name written out
// by hand, which cannot work: a Struct serialises as a map entry list and
// bears no resemblance on the wire to the typed request the server decodes.
//
// Two of the three requests were also shaped wrong. EvaluateFieldRisk sent
// temperature, soil moisture and detection confidences flat, where the proto
// nests them under weather, soil_state and detections. GeneratePrescription
// was worse: it took seven arrays of per-cell agronomy data as parameters,
// built a list out of the NDVI one, and then sent none of them — the grid the
// prescription is computed from never left the process.
package ai

import (
	"context"
	"fmt"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/keepalive"
	"p9e.in/samavaya/packages/grpcdial"
	"p9e.in/samavaya/packages/ratelimit/algorithms"
	"p9e.in/samavaya/packages/ratelimit/grpclimit"

	"p9e.in/samavaya/packages/p9log"

	aipb "p9e.in/samavaya/agriculture/ai-gateway/api/v1"
)

type AIClient struct {
	conn   *grpc.ClientConn
	logger *p9log.Helper
}

func NewAIClient(addr string, logger *p9log.Helper) (*AIClient, error) {
	conn, err := grpc.NewClient(addr,
		grpcdial.TransportCredentials(),
		// Bound what this service will ask of the shared gateway, and give
		// every call a deadline. Nine services dial ai-gateway; at their
		// autoscaler ceilings that is seventy pods against two gateway
		// replicas, and the gateway's own guard is per-connection, so it
		// rises with the caller count instead of capping the total.
		grpclimit.WithAdaptiveConcurrency(grpclimit.Options{
			Limiter: algorithms.NewAdaptiveLimiter(),
			Name:    "ai-gateway",
			Timeout: 30 * time.Second,
		}),
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
	FieldID           string
	FarmID            string
	CropType          string
	TempCurrent       float64
	TempMinForecast   float64
	TempMaxForecast   float64
	PrecipitationMM   float64
	PrecipForecastMM  float64
	SoilMoisture      float64
	EtReferenceMM     float64
	CO2PPM            float64
	PestConfidence    float64
	PestSpecies       string
	DiseaseConfidence float64
	DiseaseName       string
	NutrientSeverity  float64
	NutrientType      string
	NDVICurrent       float64
	NDVIPrevious      float64
	GrowthExpected    float64
	GrowthActual      float64
}

func (c *AIClient) gateway() aipb.AIGatewayServiceClient {
	return aipb.NewAIGatewayServiceClient(c.conn)
}

// EvaluateFieldRisk scores a field's risk from its current conditions.
func (c *AIClient) EvaluateFieldRisk(ctx context.Context, requestID string, req *EvaluateFieldRiskRequest) (*FieldRiskResult, error) {
	resp, err := c.gateway().EvaluateFieldRisk(ctx, &aipb.EvaluateFieldRiskRequest{
		RequestId: requestID,
		FieldId:   req.FieldID,
		FarmId:    req.FarmID,
		CropType:  req.CropType,
		// Nested, not flat. Sent flat these never reached the scorer, which
		// reads them through weather/soil_state/detections and substitutes
		// defaults for whatever is absent — so the risk described a nominal
		// field rather than this one, with no error to show for it.
		Weather: &aipb.FieldWeather{
			TemperatureCurrent:      req.TempCurrent,
			TemperatureMinForecast:  req.TempMinForecast,
			TemperatureMaxForecast:  req.TempMaxForecast,
			PrecipitationMm:         req.PrecipitationMM,
			PrecipitationForecastMm: req.PrecipForecastMM,
			EtReferenceMm:           req.EtReferenceMM,
			Co2Ppm:                  req.CO2PPM,
		},
		SoilState: &aipb.FieldSoilState{SoilMoisture: req.SoilMoisture},
		Detections: &aipb.DetectionResults{
			PestConfidence:    req.PestConfidence,
			PestSpecies:       req.PestSpecies,
			DiseaseConfidence: req.DiseaseConfidence,
			DiseaseName:       req.DiseaseName,
			NutrientSeverity:  req.NutrientSeverity,
			NutrientType:      req.NutrientType,
		},
		Growth: &aipb.GrowthState{
			NdviCurrent:    req.NDVICurrent,
			NdviPrevious:   req.NDVIPrevious,
			GrowthExpected: req.GrowthExpected,
			GrowthActual:   req.GrowthActual,
		},
	})
	if err != nil {
		c.logger.Errorw("msg", "EvaluateFieldRisk RPC failed", "error", err)
		return nil, fmt.Errorf("evaluate field risk: %w", err)
	}

	result := &FieldRiskResult{
		OverallRisk:     resp.GetOverallRisk(),
		TemperatureRisk: resp.GetTemperatureRisk(),
		WaterRisk:       resp.GetWaterRisk(),
		PestRisk:        resp.GetPestRisk(),
		DiseaseRisk:     resp.GetDiseaseRisk(),
		NutrientRisk:    resp.GetNutrientRisk(),
		GrowthRisk:      resp.GetGrowthRisk(),
	}
	for _, a := range resp.GetAlerts() {
		result.Alerts = append(result.Alerts, FieldAlert{
			AlertType:       a.GetAlertType(),
			Severity:        a.GetSeverity(),
			Title:           a.GetTitle(),
			Message:         a.GetMessage(),
			Recommendations: a.GetRecommendations(),
			MetricValue:     a.GetMetricValue(),
			ThresholdValue:  a.GetThresholdValue(),
		})
	}
	return result, nil
}

// ComputeFieldAnalytics asks the gateway for a field's multi-season trends.
func (c *AIClient) ComputeFieldAnalytics(ctx context.Context, requestID, fieldID, farmID string, seasons []SeasonInput) (*FieldAnalyticsResult, error) {
	pbSeasons := make([]*aipb.SeasonRecord, 0, len(seasons))
	for _, s := range seasons {
		pbSeasons = append(pbSeasons, &aipb.SeasonRecord{
			CropType:             s.CropType,
			Season:               s.Season,
			Year:                 int32(s.Year),
			YieldKgPerHa:         s.YieldKgPerHa,
			StressDays:           uint32(s.StressDays),
			FrostEvents:          uint32(s.FrostEvents),
			HeatEvents:           uint32(s.HeatEvents),
			DroughtDays:          uint32(s.DroughtDays),
			TotalPrecipitationMm: s.TotalPrecipitationMM,
			MeanTemperature:      s.MeanTemperature,
			MeanNdvi:             s.MeanNDVI,
			PeakNdvi:             s.PeakNDVI,
			TotalThermalTime:     s.TotalThermalTime,
		})
	}

	resp, err := c.gateway().ComputeFieldAnalytics(ctx, &aipb.ComputeFieldAnalyticsRequest{
		RequestId: requestID,
		FieldId:   fieldID,
		FarmId:    farmID,
		Seasons:   pbSeasons,
	})
	if err != nil {
		c.logger.Errorw("msg", "ComputeFieldAnalytics RPC failed", "error", err)
		return nil, fmt.Errorf("compute field analytics: %w", err)
	}

	return &FieldAnalyticsResult{
		SeasonCount:             int(resp.GetSeasonCount()),
		YieldTrend:              resp.GetYieldTrend(),
		YieldTrendPctPerYear:    resp.GetYieldTrendPctPerYear(),
		MeanYield:               resp.GetMeanYield(),
		BestYield:               resp.GetBestYield(),
		WorstYield:              resp.GetWorstYield(),
		NDVITrend:               resp.GetNdviTrend(),
		MeanStressDaysPerSeason: resp.GetMeanStressDaysPerSeason(),
	}, nil
}

// PrescriptionZones is the per-cell agronomy data a prescription is computed
// from. Every one of these arrays used to be accepted and thrown away.
type PrescriptionZones struct {
	NDVI              []float64
	SoilNitrogen      []float64
	SoilPhosphorus    []float64
	SoilPotassium     []float64
	SoilPH            []float64
	SoilMoisture      []float64
	SoilOrganicMatter []float64
}

// GeneratePrescription asks the gateway for variable-rate prescription maps.
func (c *AIClient) GeneratePrescription(
	ctx context.Context,
	requestID, fieldID string,
	gridRows, gridCols int,
	cellSizeM float64,
	zones PrescriptionZones,
	cropType string,
	targetYield float64,
	prescriptionTypes []string,
) (*PrescriptionResult, error) {
	resp, err := c.gateway().GeneratePrescription(ctx, &aipb.GeneratePrescriptionRequest{
		RequestId: requestID,
		FieldId:   fieldID,
		Grid: &aipb.PrescriptionGrid{
			Rows:      int32(gridRows),
			Cols:      int32(gridCols),
			CellSizeM: cellSizeM,
		},
		// The arrays that never used to be sent. Without them the gateway has
		// no per-cell data to vary a rate against, so every "variable rate"
		// map it returned was uniform by construction.
		ZoneInput: &aipb.PrescriptionZoneInput{
			Ndvi:              zones.NDVI,
			SoilNitrogen:      zones.SoilNitrogen,
			SoilPhosphorus:    zones.SoilPhosphorus,
			SoilPotassium:     zones.SoilPotassium,
			SoilPh:            zones.SoilPH,
			SoilMoisture:      zones.SoilMoisture,
			SoilOrganicMatter: zones.SoilOrganicMatter,
		},
		CropRequirements: &aipb.PrescriptionCropRequirements{
			CropType:        cropType,
			TargetYieldKgHa: targetYield,
		},
		PrescriptionTypes: prescriptionTypes,
	})
	if err != nil {
		c.logger.Errorw("msg", "GeneratePrescription RPC failed", "error", err)
		return nil, fmt.Errorf("generate prescription: %w", err)
	}

	result := &PrescriptionResult{
		EstimatedCostSavingsPct: resp.GetEstimatedCostSavingsPct(),
		EstimatedYieldGainPct:   resp.GetEstimatedYieldGainPct(),
	}
	for _, p := range resp.GetPrescriptions() {
		result.Prescriptions = append(result.Prescriptions, PrescriptionMapResult{
			PrescriptionType: p.GetPrescriptionType(),
			Rates:            p.GetRates(),
			Unit:             p.GetUnit(),
			TotalAmount:      p.GetTotalAmount(),
		})
	}
	return result, nil
}

// SeasonInput is one season's record for the analytics call.
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

// FieldAnalyticsResult is the gateway's multi-season summary for a field.
type FieldAnalyticsResult struct {
	SeasonCount             int
	YieldTrend              string
	YieldTrendPctPerYear    float64
	MeanYield               float64
	BestYield               float64
	WorstYield              float64
	NDVITrend               string
	MeanStressDaysPerSeason float64
}

// PrescriptionResult is a set of variable-rate maps for a field.
type PrescriptionResult struct {
	Prescriptions           []PrescriptionMapResult
	EstimatedCostSavingsPct float64
	EstimatedYieldGainPct   float64
}

// PrescriptionMapResult is one prescription map: a rate per grid cell.
type PrescriptionMapResult struct {
	PrescriptionType string
	Rates            []float64
	Unit             string
	TotalAmount      float64
}
