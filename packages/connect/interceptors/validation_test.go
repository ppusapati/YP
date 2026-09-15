package interceptors

import (
	"strings"
	"testing"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

func TestValidateMessage_ShortString(t *testing.T) {
	msg := wrapperspb.String("hello")
	err := validateMessage(msg)
	if err != nil {
		t.Errorf("short string should pass: %v", err)
	}
}

func TestValidateMessage_LongString(t *testing.T) {
	long := strings.Repeat("x", maxStringFieldLen+1)
	msg := wrapperspb.String(long)
	err := validateMessage(msg)
	if err == nil {
		t.Error("long string should fail validation")
	}
	if err != nil && err.Code() != connect.CodeInvalidArgument {
		t.Errorf("expected InvalidArgument, got %v", err.Code())
	}
}
