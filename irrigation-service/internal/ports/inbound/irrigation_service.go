// Package inbound defines the primary ports for the irrigation-service.
package inbound

import (
	"context"
	"time"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
)

// IrrigationService is the primary port for all irrigation business operations.
type IrrigationService interface {
	CreateIrrigation(ctx context.Context, entity *domain.Irrigation) (*domain.Irrigation, error)
	GetIrrigation(ctx context.Context, uuid string) (*domain.Irrigation, error)
	ListIrrigations(ctx context.Context, params domain.ListIrrigationParams) ([]domain.Irrigation, int32, error)
	UpdateIrrigation(ctx context.Context, entity *domain.Irrigation) (*domain.Irrigation, error)
	DeleteIrrigation(ctx context.Context, uuid string) error

	CreateZone(ctx context.Context, zone *domain.IrrigationZone) (*domain.IrrigationZone, error)
	GetZone(ctx context.Context, uuid string) (*domain.IrrigationZone, error)
	ListZonesByField(ctx context.Context, fieldID string, pageSize, offset int32) ([]domain.IrrigationZone, int32, error)
	ListZonesByFarm(ctx context.Context, farmID string, pageSize, offset int32) ([]domain.IrrigationZone, int32, error)

	CreateController(ctx context.Context, ctrl *domain.WaterController) (*domain.WaterController, error)
	GetController(ctx context.Context, uuid string) (*domain.WaterController, error)
	ListControllersByZone(ctx context.Context, zoneID string, pageSize, offset int32) ([]domain.WaterController, int32, error)
	UpdateControllerStatus(ctx context.Context, uuid string, status domain.ControllerStatus) (*domain.WaterController, error)

	CreateSchedule(ctx context.Context, sched *domain.IrrigationSchedule) (*domain.IrrigationSchedule, error)
	GetSchedule(ctx context.Context, uuid string) (*domain.IrrigationSchedule, error)
	ListSchedulesByZone(ctx context.Context, zoneID string, pageSize, offset int32) ([]domain.IrrigationSchedule, int32, error)
	ListSchedulesByField(ctx context.Context, fieldID string, pageSize, offset int32) ([]domain.IrrigationSchedule, int32, error)
	UpdateSchedule(ctx context.Context, sched *domain.IrrigationSchedule) (*domain.IrrigationSchedule, error)
	CancelSchedule(ctx context.Context, uuid string) error

	TriggerIrrigation(ctx context.Context, scheduleID string) (*domain.IrrigationEvent, error)
	GetEvent(ctx context.Context, uuid string) (*domain.IrrigationEvent, error)
	ListEventsBySchedule(ctx context.Context, scheduleID string, pageSize, offset int32) ([]domain.IrrigationEvent, int32, error)

	RequestDecision(ctx context.Context, decision *domain.IrrigationDecision) (*domain.IrrigationDecision, error)

	GetWaterUsage(ctx context.Context, zoneID string, start, end time.Time) ([]domain.WaterUsageLog, error)
}
