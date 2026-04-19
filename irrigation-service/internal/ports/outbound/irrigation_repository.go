// Package outbound defines the secondary ports for the irrigation-service.
package outbound

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
)

// IrrigationRepository is the secondary port for irrigation persistence.
type IrrigationRepository interface {
	CreateIrrigation(ctx context.Context, entity *domain.Irrigation) (*domain.Irrigation, error)
	GetIrrigationByUUID(ctx context.Context, uuid, tenantID string) (*domain.Irrigation, error)
	ListIrrigations(ctx context.Context, params domain.ListIrrigationParams) ([]domain.Irrigation, int32, error)
	UpdateIrrigation(ctx context.Context, entity *domain.Irrigation) (*domain.Irrigation, error)
	DeleteIrrigation(ctx context.Context, uuid, tenantID, deletedBy string) error
	CheckIrrigationExists(ctx context.Context, uuid, tenantID string) (bool, error)
	CheckIrrigationNameExists(ctx context.Context, name, tenantID string) (bool, error)
	WithTx(tx pgx.Tx) IrrigationRepository

	CreateZone(ctx context.Context, zone *domain.IrrigationZone) (*domain.IrrigationZone, error)
	GetZoneByUUID(ctx context.Context, uuid string) (*domain.IrrigationZone, error)
	ListZonesByField(ctx context.Context, fieldID string, pageSize, offset int32) ([]domain.IrrigationZone, int32, error)
	ListZonesByFarm(ctx context.Context, farmID string, pageSize, offset int32) ([]domain.IrrigationZone, int32, error)

	CreateController(ctx context.Context, ctrl *domain.WaterController) (*domain.WaterController, error)
	GetControllerByUUID(ctx context.Context, uuid string) (*domain.WaterController, error)
	ListControllersByZone(ctx context.Context, zoneID string, pageSize, offset int32) ([]domain.WaterController, int32, error)
	UpdateControllerStatus(ctx context.Context, uuid string, status domain.ControllerStatus) (*domain.WaterController, error)

	CreateSchedule(ctx context.Context, sched *domain.IrrigationSchedule) (*domain.IrrigationSchedule, error)
	GetScheduleByUUID(ctx context.Context, uuid string) (*domain.IrrigationSchedule, error)
	ListSchedulesByField(ctx context.Context, fieldID string, pageSize, offset int32) ([]domain.IrrigationSchedule, int32, error)
	ListSchedulesByZone(ctx context.Context, zoneID string, pageSize, offset int32) ([]domain.IrrigationSchedule, int32, error)
	UpdateSchedule(ctx context.Context, sched *domain.IrrigationSchedule) (*domain.IrrigationSchedule, error)
	UpdateScheduleStatus(ctx context.Context, uuid string, status domain.IrrigationStatus) (*domain.IrrigationSchedule, error)
	DeleteSchedule(ctx context.Context, uuid string) error

	CreateEvent(ctx context.Context, evt *domain.IrrigationEvent) (*domain.IrrigationEvent, error)
	GetEventByUUID(ctx context.Context, uuid string) (*domain.IrrigationEvent, error)
	ListEventsByZone(ctx context.Context, zoneID string, pageSize, offset int32) ([]domain.IrrigationEvent, int32, error)
	ListEventsByTimeRange(ctx context.Context, zoneID string, start, end time.Time) ([]domain.IrrigationEvent, error)
	UpdateEvent(ctx context.Context, evt *domain.IrrigationEvent) (*domain.IrrigationEvent, error)

	CreateDecision(ctx context.Context, decision *domain.IrrigationDecision) (*domain.IrrigationDecision, error)
	MarkDecisionApplied(ctx context.Context, uuid string) error

	CreateWaterUsageLog(ctx context.Context, log *domain.WaterUsageLog) (*domain.WaterUsageLog, error)
	ListWaterUsageLogs(ctx context.Context, zoneID string, start, end time.Time) ([]domain.WaterUsageLog, error)
	SumWaterUsageByZone(ctx context.Context, zoneID string, start, end time.Time) (float64, error)
}
