package helpers_service

import (
	"context"
	"errors"
	"time"

	pbr "p9e.in/samavaya/packages/api/v1/response"
	helpers_utils "p9e.in/samavaya/packages/helpers/utils"
	"p9e.in/samavaya/packages/metrics"
	"p9e.in/samavaya/packages/models"
	"p9e.in/samavaya/packages/tracing"
)

// DeleteEntity handles entity deletion with tracing and metrics
func DeleteEntity[T models.Entity](
	ctx context.Context,
	id string,
	tracer *tracing.TracingProvider,
	metrics metrics.MetricsProvider,
	repoGetByIDFunc func(context.Context, string) (models.Entity, error),
	repoDeleteFunc func(context.Context, string) (T, error),
) (*pbr.BaseResponse, error) {
	var zeroValue T
	entityType := helpers_utils.GetTypeName[T]()
	ctx, span := tracer.StartSpan(ctx, "Delete"+entityType)
	defer span.End()

	if id == "" {
		err := errors.New("ID is missing")
		tracer.AddSpanError(ctx, err)
		return helpers_utils.ErrorResponse(ctx, "Invalid request: missing ID", zeroValue, pbr.CanonicalReason_INVALID_REQUEST)
	}

	tags := map[string]string{"operation": entityType + "_deletion", "id": id}
	tracer.AddSpanTags(ctx, tags)

	startTime := time.Now()

	entity, err := fetchEntity(ctx, id, repoGetByIDFunc)
	if err != nil {
		tracer.AddSpanError(ctx, err)
		return helpers_utils.ErrorResponse(ctx, entityType+" not found", zeroValue, pbr.CanonicalReason_NOT_FOUND)
	}

	_, e := repoDeleteFunc(ctx, entity.GetID())
	recordMetric(metrics, entityType, "Delete", startTime, e == nil)

	if e != nil {
		tracer.AddSpanError(ctx, e)
		return helpers_utils.ErrorResponse(ctx, "Failed to delete "+entityType, zeroValue, pbr.CanonicalReason_FORBIDDEN_OPERATION)
	}

	return helpers_utils.SuccessResponse(ctx, entityType+" deleted successfully", entity, pbr.CanonicalReason_DELETED_SUCCESSFULLY)
}
