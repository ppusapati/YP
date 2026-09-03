package helpers_service

import (
	"context"
	"time"

	pbr "p9e.in/samavaya/packages/api/v1/response"
	hu "p9e.in/samavaya/packages/helpers/utils"
	"p9e.in/samavaya/packages/metrics"
	"p9e.in/samavaya/packages/models"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/tracing"

	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/fieldmaskpb"
)

// UpdateEntity handles entity update with tracing, metrics, and field masks
func UpdateEntity[T models.Entity, P proto.Message](
	ctx context.Context,
	req P,
	id string,
	updateMask *fieldmaskpb.FieldMask,
	convertFunc func(P) T,
	toProtoFunc func(T) P,
	tracer *tracing.TracingProvider,
	metrics metrics.MetricsProvider,
	repoGetByIDFunc func(context.Context, string) (T, error),
	repoUpdateFunc func(context.Context, hu.UpdateRequest[T]) (T, error),
) (*pbr.BaseResponse, error) {
	var zeroValue T
	entityType := hu.GetTypeName[T]()

	ctx, span := tracer.StartSpan(ctx, "Update"+entityType)
	defer span.End()
	tracer.AddSpanTags(ctx, map[string]string{"operation": entityType + "_update"})

	if err := hu.ValidateProto(req); err != nil {
		return hu.ErrorResponse(ctx, entityType+" validation failed", zeroValue, pbr.CanonicalReason_VALIDATION_FAILED)
	}

	existingEntity, err := fetchEntity(ctx, id, repoGetByIDFunc)
	if err != nil {
		return hu.ErrorResponse(ctx, entityType+" not found", zeroValue, pbr.CanonicalReason_NOT_FOUND)
	}

	if updateMask != nil {
		hu.ApplyFieldMask(updateMask, toProtoFunc(existingEntity), req)
	}

	var fieldMaskPaths []string
	if updateMask != nil {
		fieldMaskPaths = updateMask.Paths
	}
	dbModel := convertFunc(req)

	secCtx := p9context.GetSecurityContextOrDefault(ctx)
	updateReq := hu.UpdateRequest[T]{
		Entity:    dbModel,
		FieldMask: fieldMaskPaths,
		UpdatedBy: secCtx.Username,
		UpdatedAt: time.Now(),
	}

	startTime := time.Now()
	updatedEntity, err := repoUpdateFunc(ctx, updateReq)
	recordMetric(metrics, entityType, "Update", startTime, err == nil)

	if err != nil {
		return hu.ErrorResponse(ctx, "Failed to update "+entityType, zeroValue, pbr.CanonicalReason_UPDATE_FAILED)
	}

	return hu.SuccessResponse(ctx, entityType+" updated successfully", updatedEntity, pbr.CanonicalReason_UPDATED_SUCCESSFULLY)
}
