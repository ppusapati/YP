package helpers_service

import (
	"context"
	"errors"
	"time"

	pbr "p9e.in/samavaya/packages/api/v1/response"
	hu "p9e.in/samavaya/packages/helpers/utils"
	"p9e.in/samavaya/packages/metrics"
	"p9e.in/samavaya/packages/models"
	"p9e.in/samavaya/packages/tracing"
)

// GetEntity fetches an entity by ID or by a named field
func GetEntity[T models.Entity, ProtoT any](
	ctx context.Context,
	id string,
	fieldName string, fieldValue any,
	tracer *tracing.TracingProvider,
	metrics metrics.MetricsProvider,
	repoGetByIDFunc func(context.Context, string) (T, error),
	repoGetByFieldFunc func(context.Context, string, interface{}) (T, error),
	convertFunc func(T) *ProtoT,
) (*pbr.BaseResponse, *ProtoT, error) {
	var zeroValue T
	entityType := hu.GetTypeName[T]()
	ctx, span := tracer.StartSpan(ctx, "Get"+entityType)
	defer span.End()

	if id == "" && (fieldName == "" || fieldValue == "") {
		err := errors.New("no valid identifier provided")
		tracer.AddSpanError(ctx, err)
		r, e := hu.ErrorResponse(ctx, "Invalid request: missing ID or field", zeroValue, pbr.CanonicalReason_INVALID_REQUEST)
		return r, nil, e
	}

	spanTags := map[string]string{"operation": entityType + "_fetch"}
	if id != "" {
		spanTags["id"] = id
	} else {
		spanTags["field"] = fieldName
		if strValue, ok := fieldValue.(string); ok {
			spanTags["value"] = strValue
		}
	}
	tracer.AddSpanTags(ctx, spanTags)

	startTime := time.Now()

	var entity T
	var err error
	if id != "" {
		entity, err = repoGetByIDFunc(ctx, id)
	} else {
		entity, err = repoGetByFieldFunc(ctx, fieldName, fieldValue)
	}
	if err != nil {
		tracer.AddSpanError(ctx, err)
		r, e := hu.ErrorResponse(ctx, entityType+" Not Found", zeroValue, pbr.CanonicalReason_NOT_FOUND)
		return r, nil, e
	}

	recordMetric(metrics, entityType, "Get Record", startTime, err == nil)
	protoEntity := convertFunc(entity)

	r, e := hu.SuccessResponse(ctx, entityType+" Found Successfully", entity, pbr.CanonicalReason_FOUND_SUCCESSFULLY)
	return r, protoEntity, e
}
