// Package grpc contains the inbound ConnectRPC adapter for the weather-service.
package grpc

import (
	"context"
	"time"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/timestamppb"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"

	pb "p9e.in/samavaya/agriculture/weather-service/api/v1"
	"p9e.in/samavaya/agriculture/weather-service/api/v1/weatherv1connect"
	"p9e.in/samavaya/agriculture/weather-service/internal/domain"
	"p9e.in/samavaya/agriculture/weather-service/internal/ports/inbound"
)

// WeatherHandler is the ConnectRPC inbound adapter.
type WeatherHandler struct {
	weatherv1connect.UnimplementedWeatherServiceHandler
	svc inbound.WeatherService
	log *p9log.Helper
}

// NewWeatherHandler creates a new ConnectRPC weather handler.
func NewWeatherHandler(svc inbound.WeatherService, log p9log.Logger) *WeatherHandler {
	return &WeatherHandler{
		svc: svc,
		log: p9log.NewHelper(p9log.With(log, "component", "WeatherHandler")),
	}
}

func (h *WeatherHandler) RegisterFieldLocation(ctx context.Context, req *connect.Request[pb.RegisterFieldLocationRequest]) (*connect.Response[pb.RegisterFieldLocationResponse], error) {
	h.log.Infow("msg", "RegisterFieldLocation", "tenant_id", p9context.TenantID(ctx), "field_id", req.Msg.GetFieldId())
	if req.Msg.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	loc, err := h.svc.RegisterFieldLocation(ctx, &domain.FieldLocation{
		FieldID:    req.Msg.GetFieldId(),
		FarmID:     req.Msg.GetFarmId(),
		Latitude:   req.Msg.GetLatitude(),
		Longitude:  req.Msg.GetLongitude(),
		ElevationM: req.Msg.GetElevationM(),
		Timezone:   req.Msg.GetTimezone(),
		Provider:   providerFromProto(req.Msg.GetProvider()),
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.RegisterFieldLocationResponse{Location: locationToProto(loc)}), nil
}

func (h *WeatherHandler) GetFieldLocation(ctx context.Context, req *connect.Request[pb.GetFieldLocationRequest]) (*connect.Response[pb.GetFieldLocationResponse], error) {
	loc, err := h.svc.GetFieldLocation(ctx, req.Msg.GetFieldId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.GetFieldLocationResponse{Location: locationToProto(loc)}), nil
}

func (h *WeatherHandler) ListFieldLocations(ctx context.Context, req *connect.Request[pb.ListFieldLocationsRequest]) (*connect.Response[pb.ListFieldLocationsResponse], error) {
	locs, total, err := h.svc.ListFieldLocations(ctx, domain.ListLocationsParams{
		FarmID: req.Msg.GetFarmId(), PageSize: req.Msg.GetPageSize(), PageOffset: req.Msg.GetPageOffset(),
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	out := make([]*pb.FieldLocation, 0, len(locs))
	for i := range locs {
		out = append(out, locationToProto(&locs[i]))
	}
	return connect.NewResponse(&pb.ListFieldLocationsResponse{Locations: out, TotalCount: int32(total)}), nil
}

func (h *WeatherHandler) GetCurrentWeather(ctx context.Context, req *connect.Request[pb.GetCurrentWeatherRequest]) (*connect.Response[pb.GetCurrentWeatherResponse], error) {
	obs, err := h.svc.GetCurrentWeather(ctx, req.Msg.GetFieldId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.GetCurrentWeatherResponse{Observation: observationToProto(obs)}), nil
}

func (h *WeatherHandler) GetForecast(ctx context.Context, req *connect.Request[pb.GetForecastRequest]) (*connect.Response[pb.GetForecastResponse], error) {
	fc, err := h.svc.GetForecast(ctx, req.Msg.GetFieldId(), int(req.Msg.GetDays()))
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	out := make([]*pb.DailyForecast, 0, len(fc))
	for i := range fc {
		out = append(out, forecastToProto(&fc[i]))
	}
	return connect.NewResponse(&pb.GetForecastResponse{Forecasts: out}), nil
}

func (h *WeatherHandler) ListObservations(ctx context.Context, req *connect.Request[pb.ListObservationsRequest]) (*connect.Response[pb.ListObservationsResponse], error) {
	obs, total, err := h.svc.ListObservations(ctx, domain.ListObservationsParams{
		FieldID:    req.Msg.GetFieldId(),
		Start:      tsToTime(req.Msg.GetStart()),
		End:        tsToTime(req.Msg.GetEnd()),
		PageSize:   req.Msg.GetPageSize(),
		PageOffset: req.Msg.GetPageOffset(),
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	out := make([]*pb.Observation, 0, len(obs))
	for i := range obs {
		out = append(out, observationToProto(&obs[i]))
	}
	return connect.NewResponse(&pb.ListObservationsResponse{Observations: out, TotalCount: int32(total)}), nil
}

func (h *WeatherHandler) GetAgroMetrics(ctx context.Context, req *connect.Request[pb.GetAgroMetricsRequest]) (*connect.Response[pb.GetAgroMetricsResponse], error) {
	daily, summary, err := h.svc.GetAgroMetrics(ctx, req.Msg.GetFieldId(), tsToTime(req.Msg.GetStart()), tsToTime(req.Msg.GetEnd()), req.Msg.GetBaseTempC(), req.Msg.GetCapTempC())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	out := make([]*pb.DailyAgroMetrics, 0, len(daily))
	for _, d := range daily {
		out = append(out, &pb.DailyAgroMetrics{
			FieldId:           d.FieldID,
			Date:              timestamppb.New(d.Date),
			TemperatureMinC:   d.TemperatureMinC,
			TemperatureMaxC:   d.TemperatureMaxC,
			TemperatureMeanC:  d.TemperatureMeanC,
			PrecipitationMm:   d.PrecipitationMM,
			Gdd:               d.GDD,
			Et0Mm:             d.ET0MM,
			ChillHours:        d.ChillHours,
			RainfallDeficitMm: d.RainfallDeficitMM,
			HumidityMeanPct:   d.HumidityMeanPct,
			SolarRadiationMj:  d.SolarRadiationMJ,
		})
	}
	return connect.NewResponse(&pb.GetAgroMetricsResponse{
		Daily: out,
		Summary: &pb.AgroMetricsSummary{
			CumulativeGdd:             summary.CumulativeGDD,
			CumulativeEt0Mm:           summary.CumulativeET0MM,
			CumulativePrecipitationMm: summary.CumulativePrecipitationMM,
			CumulativeChillHours:      summary.CumulativeChillHours,
			CumulativeDeficitMm:       summary.CumulativeDeficitMM,
			Days:                      int32(summary.Days),
			FrostDays:                 int32(summary.FrostDays),
			HeatStressDays:            int32(summary.HeatStressDays),
		},
	}), nil
}

func (h *WeatherHandler) RefreshFieldWeather(ctx context.Context, req *connect.Request[pb.RefreshFieldWeatherRequest]) (*connect.Response[pb.RefreshFieldWeatherResponse], error) {
	obsN, fcN, err := h.svc.RefreshFieldWeather(ctx, req.Msg.GetFieldId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.RefreshFieldWeatherResponse{ObservationsIngested: int32(obsN), ForecastsIngested: int32(fcN)}), nil
}

func (h *WeatherHandler) BackfillHistory(ctx context.Context, req *connect.Request[pb.BackfillHistoryRequest]) (*connect.Response[pb.BackfillHistoryResponse], error) {
	days, from, to, err := h.svc.BackfillHistory(ctx, req.Msg.GetFieldId(), int(req.Msg.GetYears()))
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	return connect.NewResponse(&pb.BackfillHistoryResponse{DaysIngested: int32(days), From: timestamppb.New(from), To: timestamppb.New(to)}), nil
}

func (h *WeatherHandler) ListWeatherAlerts(ctx context.Context, req *connect.Request[pb.ListWeatherAlertsRequest]) (*connect.Response[pb.ListWeatherAlertsResponse], error) {
	alerts, total, err := h.svc.ListWeatherAlerts(ctx, domain.ListAlertsParams{
		FieldID: req.Msg.GetFieldId(), ActiveOnly: req.Msg.GetActiveOnly(),
		PageSize: req.Msg.GetPageSize(), PageOffset: req.Msg.GetPageOffset(),
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}
	out := make([]*pb.WeatherAlert, 0, len(alerts))
	for _, a := range alerts {
		out = append(out, &pb.WeatherAlert{
			Id: a.ID, TenantId: a.TenantID, FieldId: a.FieldID,
			Type: alertTypeToProto(a.Type), Severity: severityToProto(a.Severity),
			Message: a.Message, Value: a.Value, Threshold: a.Threshold,
			ValidFrom: timestamppb.New(a.ValidFrom), ValidTo: timestamppb.New(a.ValidTo), CreatedAt: timestamppb.New(a.CreatedAt),
		})
	}
	return connect.NewResponse(&pb.ListWeatherAlertsResponse{Alerts: out, TotalCount: int32(total)}), nil
}

// ---------------------------------------------------------------------------
// Converters
// ---------------------------------------------------------------------------

func tsToTime(ts *timestamppb.Timestamp) time.Time {
	if ts == nil {
		return time.Time{}
	}
	return ts.AsTime()
}

func locationToProto(l *domain.FieldLocation) *pb.FieldLocation {
	out := &pb.FieldLocation{
		Id: l.ID, TenantId: l.TenantID, FieldId: l.FieldID, FarmId: l.FarmID,
		Latitude: l.Latitude, Longitude: l.Longitude, ElevationM: l.ElevationM, Timezone: l.Timezone,
		Provider:  providerToProto(l.Provider),
		CreatedAt: timestamppb.New(l.CreatedAt), UpdatedAt: timestamppb.New(l.UpdatedAt),
	}
	if l.LastPolledAt != nil {
		out.LastPolledAt = timestamppb.New(*l.LastPolledAt)
	}
	return out
}

func observationToProto(o *domain.Observation) *pb.Observation {
	return &pb.Observation{
		Id: o.ID, TenantId: o.TenantID, FieldId: o.FieldID, ObservedAt: timestamppb.New(o.ObservedAt),
		TemperatureC: o.TemperatureC, HumidityPct: o.HumidityPct, PrecipitationMm: o.PrecipitationMM,
		WindSpeedMs: o.WindSpeedMS, WindDirectionDeg: o.WindDirectionDeg, PressureHpa: o.PressureHPa,
		SolarRadiationWm2: o.SolarRadiationWM2, CloudCoverPct: o.CloudCoverPct, DewPointC: o.DewPointC,
		SoilTemperatureC: o.SoilTemperatureC, SoilMoistureM3M3: o.SoilMoistureM3M3, Provider: providerToProto(o.Provider),
	}
}

func forecastToProto(f *domain.DailyForecast) *pb.DailyForecast {
	return &pb.DailyForecast{
		Id: f.ID, TenantId: f.TenantID, FieldId: f.FieldID,
		ForecastDate: timestamppb.New(f.ForecastDate), IssuedAt: timestamppb.New(f.IssuedAt),
		TemperatureMinC: f.TemperatureMinC, TemperatureMaxC: f.TemperatureMaxC, TemperatureMeanC: f.TemperatureMeanC,
		PrecipitationMm: f.PrecipitationMM, PrecipitationProb: f.PrecipitationProb, HumidityMeanPct: f.HumidityMeanPct,
		WindSpeedMaxMs: f.WindSpeedMaxMS, SolarRadiationMj: f.SolarRadiationMJ, Et0Mm: f.ET0MM,
		Condition: f.Condition, Provider: providerToProto(f.Provider),
	}
}

func providerToProto(p domain.Provider) pb.WeatherProvider {
	switch p {
	case domain.ProviderOpenMeteo:
		return pb.WeatherProvider_WEATHER_PROVIDER_OPEN_METEO
	case domain.ProviderOpenWeather:
		return pb.WeatherProvider_WEATHER_PROVIDER_OPENWEATHER
	case domain.ProviderIMD:
		return pb.WeatherProvider_WEATHER_PROVIDER_IMD
	default:
		return pb.WeatherProvider_WEATHER_PROVIDER_UNSPECIFIED
	}
}

func providerFromProto(p pb.WeatherProvider) domain.Provider {
	switch p {
	case pb.WeatherProvider_WEATHER_PROVIDER_OPEN_METEO:
		return domain.ProviderOpenMeteo
	case pb.WeatherProvider_WEATHER_PROVIDER_OPENWEATHER:
		return domain.ProviderOpenWeather
	case pb.WeatherProvider_WEATHER_PROVIDER_IMD:
		return domain.ProviderIMD
	default:
		return domain.ProviderUnspecified
	}
}

func alertTypeToProto(t domain.AlertType) pb.WeatherAlertType {
	switch t {
	case domain.AlertTypeFrost:
		return pb.WeatherAlertType_WEATHER_ALERT_TYPE_FROST
	case domain.AlertTypeHeatStress:
		return pb.WeatherAlertType_WEATHER_ALERT_TYPE_HEAT_STRESS
	case domain.AlertTypeHeavyRainfall:
		return pb.WeatherAlertType_WEATHER_ALERT_TYPE_HEAVY_RAINFALL
	case domain.AlertTypeHighWind:
		return pb.WeatherAlertType_WEATHER_ALERT_TYPE_HIGH_WIND
	case domain.AlertTypeDrought:
		return pb.WeatherAlertType_WEATHER_ALERT_TYPE_DROUGHT
	default:
		return pb.WeatherAlertType_WEATHER_ALERT_TYPE_UNSPECIFIED
	}
}

func severityToProto(s domain.Severity) pb.AlertSeverity {
	switch s {
	case domain.SeverityInfo:
		return pb.AlertSeverity_ALERT_SEVERITY_INFO
	case domain.SeverityWarning:
		return pb.AlertSeverity_ALERT_SEVERITY_WARNING
	case domain.SeverityCritical:
		return pb.AlertSeverity_ALERT_SEVERITY_CRITICAL
	default:
		return pb.AlertSeverity_ALERT_SEVERITY_UNSPECIFIED
	}
}
