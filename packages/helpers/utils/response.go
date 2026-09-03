package helpers_utils

import (
	"context"
	"errors"

	pbr "p9e.in/samavaya/packages/api/v1/response"
	"p9e.in/samavaya/packages/middleware/localize"
	"p9e.in/samavaya/packages/models"

	"google.golang.org/protobuf/types/known/wrapperspb"
)

// CreateSuccessResponse constructs a BaseResponse for a successful operation.
func CreateSuccessResponse(ctx context.Context, reason pbr.CanonicalReason, message string,
	data map[string]interface{}, id string) (*pbr.BaseResponse, error) {
	if message == "" {
		message = reason.String()
	}
	return &pbr.BaseResponse{
		Status: &pbr.Status{
			Code:         int32(reason),
			Reason:       reason,
			DomainReason: reason.String(),
			Message:      localize.GetMsg(ctx, reason.String(), message, data, nil),
		},
		Id: wrapperspb.String(id),
	}, nil
}

// CreateErrorResponse constructs an error BaseResponse.
func CreateErrorResponse(ctx context.Context, reason pbr.CanonicalReason, message string, data map[string]interface{}) (*pbr.BaseResponse, error) {
	if message == "" {
		message = reason.String()
	}
	return &pbr.BaseResponse{
		Status: &pbr.Status{
			Code:         int32(reason),
			Reason:       reason,
			DomainReason: reason.String(),
			Message:      localize.GetMsg(ctx, reason.String(), message, data, nil),
		},
	}, errors.New(reason.String())
}

func ErrorResponse[T models.Entity](ctx context.Context, message string, entity T, messageCode pbr.CanonicalReason) (*pbr.BaseResponse, error) {
	return CreateErrorResponse(ctx, messageCode, message, map[string]interface{}{"Entity": entity})
}

func SuccessResponse[T models.Entity](ctx context.Context, message string, entity T, messageCode pbr.CanonicalReason) (*pbr.BaseResponse, error) {
	return CreateSuccessResponse(ctx, messageCode, message, nil, entity.GetID())
}

func SuccessArrayResponse[T []*models.Entity](ctx context.Context, message string, entity []*T, messageCode pbr.CanonicalReason) (*pbr.BaseResponse, error) {
	return CreateSuccessResponse(ctx, messageCode, message, nil, "")
}
