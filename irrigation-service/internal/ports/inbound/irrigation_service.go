// Package inbound defines the primary ports for the irrigation-service.
package inbound

import (
	"context"
	"time"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/models"
)

// IrrigationService is the primary port for all irrigation business operations.
type IrrigationService interface {
	CreateZone(ctx context.Context, zone *models.IrrigationZone) (*models.IrrigationZone, error)
	GetZone(ctx context.Context, uuid string) (*models.IrrigationZone, error)
	ListZonesByField(ctx context.Context, fieldID string, pageSize, offset int32) ([]models.IrrigationZone, int32, error)
	ListZonesByFarm(ctx context.Context, farmID string, pageSize, offset int32) ([]models.IrrigationZone, int32, error)

	CreateController(ctx context.Context, ctrl *models.WaterController) (*models.WaterController, error)
	GetController(ctx context.Context, uuid string) (*models.WaterController, error)
	ListControllersByZone(ctx context.Context, zoneID string, pageSize, offset int32) ([]models.WaterController, int32, error)
	UpdateControllerStatus(ctx context.Context, uuid string, status models.ControllerStatus) (*models.WaterController, error)

	CreateSchedule(ctx context.Context, sched *models.IrrigationSchedule) (*models.IrrigationSchedule, error)
	GetSchedule(ctx context.Context, uuid string) (*models.IrrigationSchedule, error)
	ListSchedulesByZone(ctx context.Context, zoneID string, pageSize, offset int32) ([]models.IrrigationSchedule, int32, error)
	ListSchedulesByField(ctx context.Context, fieldID string, pageSize, offset int32) ([]models.IrrigationSchedule, int32, error)
	UpdateSchedule(ctx context.Context, sched *models.IrrigationSchedule) (*models.IrrigationSchedule, error)
	CancelSchedule(ctx context.Context, uuid string) error

	TriggerIrrigation(ctx context.Context, scheduleID string) (*models.IrrigationEvent, error)
	GetEvent(ctx context.Context, uuid string) (*models.IrrigationEvent, error)
	ListEventsBySchedule(ctx context.Context, scheduleID string, pageSize, offset int32) ([]models.IrrigationEvent, int32, error)

	RequestDecision(ctx context.Context, decision *models.IrrigationDecision) (*models.IrrigationDecision, error)

	GetWaterUsage(ctx context.Context, zoneID string, start, end time.Time) ([]models.WaterUsageLog, error)
}
