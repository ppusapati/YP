// Package grpc re-exports field-service's inbound ConnectRPC adapter. See the
// application package for why this is an alias shim rather than a copy.
package grpc

import (
	internalgrpc "p9e.in/samavaya/agriculture/field-service/internal/adapters/inbound/grpc"
)

// FieldHandler is the ConnectRPC handler for the field service.
type FieldHandler = internalgrpc.FieldHandler

// NewFieldHandler creates the handler.
var NewFieldHandler = internalgrpc.NewFieldHandler
