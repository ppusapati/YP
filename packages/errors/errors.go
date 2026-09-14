package errors

import (
	"errors"
	"fmt"

	"connectrpc.com/connect"

	erro "p9e.in/samavaya/packages/api/v1/errors"

	"google.golang.org/genproto/googleapis/rpc/errdetails"
	"google.golang.org/grpc/status"
)

const (
	// UnknownCode is unknown code for error info.
	UnknownCode = 500
	// UnknownReason is unknown reason for error info.
	UnknownReason = ""
	// SupportPackageIsVersion1 this constant should not be referenced by any other code.
	SupportPackageIsVersion1 = true
)

// Error is a status error.
type Error struct {
	erro.Status
	cause error
}

func (e *Error) Error() string {
	return fmt.Sprintf("error: code = %d reason = %s message = %s metadata = %v cause = %v", e.Code, e.Reason, e.Message, e.Metadata, e.cause)
}

// Unwrap provides compatibility for Go 1.13 error chains.
func (e *Error) Unwrap() error { return e.cause }

// Is matches each error in the chain with the target value.
func (e *Error) Is(err error) bool {
	if se := new(Error); errors.As(err, &se) {
		return se.Code == e.Code && se.Reason == e.Reason
	}
	return false
}

// WithCause with the underlying cause of the error.
func (e *Error) WithCause(cause error) *Error {
	err := Clone(e)
	err.cause = cause
	return err
}

// WithMetadata with an MD formed by the mapping of key, value.
func (e *Error) WithMetadata(md map[string]string) *Error {
	err := Clone(e)
	err.Metadata = md
	return err
}

// GRPCStatus returns the Status represented by se.
func (e *Error) GRPCStatus() *status.Status {
	s, _ := status.New(ToGRPCCode(int(e.Code)), e.Message).
		WithDetails(&errdetails.ErrorInfo{
			Reason:   e.Reason,
			Metadata: e.Metadata,
		})
	return s
}

// New returns an error object for the code, message.
func New(code int, reason, message string) *Error {
	return &Error{
		Status: erro.Status{
			Code:    int32(code),
			Message: message,
			Reason:  reason,
		},
	}
}

// Newf New(code fmt.Sprintf(format, a...))
func Newf(code int, reason, format string, a ...interface{}) *Error {
	return New(code, reason, fmt.Sprintf(format, a...))
}

// Errorf returns an error object for the code, message and error info.
func Errorf(code int, reason, format string, a ...interface{}) error {
	return New(code, reason, fmt.Sprintf(format, a...))
}

// Code returns the http code for an error.
// It supports wrapped errors.
func Code(err error) int {
	if err == nil {
		return 200 //nolint:gomnd
	}
	return int(FromError(err).Code)
}

// Reason returns the reason for a particular error.
// It supports wrapped errors.
func Reason(err error) string {
	if err == nil {
		return UnknownReason
	}
	return FromError(err).Reason
}

// Clone deep clone error to a new error.
func Clone(err *Error) *Error {
	if err == nil {
		return nil
	}
	metadata := make(map[string]string, len(err.Metadata))
	for k, v := range err.Metadata {
		metadata[k] = v
	}
	return &Error{
		cause: err.cause,
		Status: erro.Status{
			Code:     err.Code,
			Reason:   err.Reason,
			Message:  err.Message,
			Metadata: metadata,
		},
	}
}

// FromError try to convert an error to *Error.
// It supports wrapped errors.
func FromError(err error) *Error {
	if err == nil {
		return nil
	}
	if se := new(Error); errors.As(err, &se) {
		return se
	}
	gs, ok := status.FromError(err)
	if !ok {
		return New(UnknownCode, UnknownReason, err.Error())
	}
	ret := New(
		FromGRPCCode(gs.Code()),
		UnknownReason,
		gs.Message(),
	)
	for _, detail := range gs.Details() {
		switch d := detail.(type) {
		case *errdetails.ErrorInfo:
			ret.Reason = d.Reason
			return ret.WithMetadata(d.Metadata)
		}
	}
	return ret
}

// Wrap wraps an error with context message.
func Wrap(err error, message string) error {
	if err == nil {
		return nil
	}
	return fmt.Errorf("%s: %w", message, err)
}

// Wrapf wraps an error with a formatted context message.
func Wrapf(err error, format string, args ...interface{}) error {
	if err == nil {
		return nil
	}
	return fmt.Errorf("%s: %w", fmt.Sprintf(format, args...), err)
}

// InvalidArgumentf creates an InvalidArgument error with a formatted message.
func InvalidArgumentf(format string, args ...interface{}) *Error {
	msg := format
	if len(args) > 0 {
		msg = fmt.Sprintf(format, args...)
	}
	return New(400, "INVALID_ARGUMENT", msg)
}

// ToConnectError converts an error into a *connect.Error carrying the right
// code, a clean message, and the reason as structured detail.
//
// The conversion has to be explicit. *Error implements GRPCStatus(), and this
// function used to return it unchanged on the assumption that ConnectRPC would
// read the code from there. It does not: connect-go's wrapIfUncoded looks only
// for a *connect.Error via errors.As and wraps anything else in CodeUnknown. So
// returning *Error unchanged sent every domain error to the client as
// `unknown` / HTTP 500, with *Error.Error()'s debug formatting — "error: code =
// 404 reason = ... metadata = map[] cause = <nil>" — as the message the caller
// sees.
//
// The cause chain is preserved through Unwrap, so a logging interceptor
// upstream can still recover the original error and its cause even though the
// client is shown only the message.
func ToConnectError(err error) error {
	if err == nil {
		return nil
	}
	// Already coded — an interceptor's own error, or an error converted
	// earlier in the chain. Converting twice would replace a precise code with
	// whatever the round trip through HTTP numbers produces.
	var already *connect.Error
	if errors.As(err, &already) {
		return already
	}

	se := FromError(err)
	msg := se.Message
	if msg == "" {
		// Better a machine-readable reason than an empty message.
		msg = se.Reason
	}

	ce := connect.NewError(
		connect.Code(ToGRPCCode(int(se.Code))),
		&wireError{msg: msg, cause: err},
	)

	// The reason is what a client branches on; the numeric code only says what
	// kind of thing went wrong. Carried as an ErrorInfo detail, which is the
	// same shape GRPCStatus() puts it in, and mirrored into metadata so a
	// browser client that cannot decode details can still read it.
	if se.Reason != "" {
		if detail, derr := connect.NewErrorDetail(&errdetails.ErrorInfo{
			Reason:   se.Reason,
			Metadata: se.Metadata,
		}); derr == nil {
			ce.AddDetail(detail)
		}
		ce.Meta().Set("x-error-reason", se.Reason)
	}
	return ce
}

// wireError carries a clean message to the client while keeping the original
// error reachable through Unwrap for server-side logging.
type wireError struct {
	msg   string
	cause error
}

func (e *wireError) Error() string { return e.msg }
func (e *wireError) Unwrap() error { return e.cause }
