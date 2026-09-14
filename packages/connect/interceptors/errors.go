package interceptors

import (
	"context"

	"connectrpc.com/connect"

	pkgerrors "p9e.in/samavaya/packages/errors"
)

// ErrorInterceptor translates the platform's domain errors into Connect errors
// on the way out of a handler.
//
// Without it, every domain error reaches the client as `unknown` / HTTP 500.
//
// The reason is worth stating precisely, because the code reads as though it
// already works. `*errors.Error` implements `GRPCStatus()`, and the comment on
// `errors.ToConnectError` says ConnectRPC picks the code up from there. It does
// not: connect-go's `wrapIfUncoded` looks only for a `*connect.Error` via
// `errors.As`, and wraps anything else in `CodeUnknown` (connect@v1.20.0,
// error.go). So a handler returning
//
//	errors.NotFound("FARM_NOT_FOUND", "farm not found")
//
// produced, on the wire:
//
//	code:    unknown          (HTTP 500, not 404)
//	message: error: code = 404 reason = FARM_NOT_FOUND message = farm not found
//	         metadata = map[] cause = <nil>
//
// — the wrong status, and `*Error.Error()`'s debug formatting shown to the
// caller as the message. Every retry policy keyed on 404, every client
// branching on "already exists", and every error message a user reads was
// affected.
//
// This is an interceptor rather than a fix to `ToConnectError` alone because
// most handlers return their domain error directly and never call that helper.
// Converting centrally fixes them all without editing any of them; the helper
// is fixed too, so the two paths agree.
func ErrorInterceptor() connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			resp, err := next(ctx, req)
			if err == nil {
				return resp, nil
			}
			return resp, pkgerrors.ToConnectError(err)
		}
	}
}
