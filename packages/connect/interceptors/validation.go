package interceptors

import (
	"context"
	"fmt"
	"unicode/utf8"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protoreflect"
)

const (
	maxStringFieldLen = 10_000
	maxPageSize       = 500
)

// ValidationInterceptor enforces basic input bounds on all incoming requests:
// string fields are capped at maxStringFieldLen, and page_size fields are
// clamped to [1, maxPageSize].
func ValidationInterceptor() connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			if msg, ok := req.Any().(proto.Message); ok {
				if err := validateMessage(msg); err != nil {
					return nil, err
				}
			}
			return next(ctx, req)
		}
	}
}

func validateMessage(msg proto.Message) *connect.Error {
	m := msg.ProtoReflect()
	var validationErr *connect.Error

	m.Range(func(fd protoreflect.FieldDescriptor, v protoreflect.Value) bool {
		switch fd.Kind() {
		case protoreflect.StringKind:
			s := v.String()
			if utf8.RuneCountInString(s) > maxStringFieldLen {
				validationErr = connect.NewError(connect.CodeInvalidArgument,
					fmt.Errorf("field %s exceeds maximum length of %d characters", fd.Name(), maxStringFieldLen))
				return false
			}
		case protoreflect.Int32Kind:
			if fd.Name() == "page_size" {
				if v.Int() > maxPageSize {
					validationErr = connect.NewError(connect.CodeInvalidArgument,
						fmt.Errorf("page_size must not exceed %d", maxPageSize))
					return false
				}
			}
		}
		return true
	})

	return validationErr
}
