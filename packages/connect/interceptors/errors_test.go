package interceptors_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"connectrpc.com/connect"
	"google.golang.org/genproto/googleapis/rpc/errdetails"
	"google.golang.org/protobuf/types/known/emptypb"

	"p9e.in/samavaya/packages/connect/interceptors"
	pkgerrors "p9e.in/samavaya/packages/errors"
)

// These go over a real client and a real server rather than asserting on the
// converted value directly, because the bug being fixed was invisible at that
// level: the handler returned a perfectly good *errors.Error with a 404 on it,
// and connect-go discarded the code on the way out. Only the client can say
// what the client sees.

// serve stands up a one-method Connect server whose handler returns handlerErr,
// and returns a client for it.
func serve(t *testing.T, handlerErr error, opts ...connect.HandlerOption) *connect.Client[emptypb.Empty, emptypb.Empty] {
	t.Helper()

	const procedure = "/test.v1.Service/Method"
	handler := connect.NewUnaryHandler(
		procedure,
		func(context.Context, *connect.Request[emptypb.Empty]) (*connect.Response[emptypb.Empty], error) {
			return nil, handlerErr
		},
		opts...,
	)

	mux := http.NewServeMux()
	mux.Handle(procedure, handler)
	srv := httptest.NewServer(mux)
	t.Cleanup(srv.Close)

	return connect.NewClient[emptypb.Empty, emptypb.Empty](srv.Client(), srv.URL+procedure)
}

func call(t *testing.T, client *connect.Client[emptypb.Empty, emptypb.Empty]) error {
	t.Helper()
	_, err := client.CallUnary(context.Background(), connect.NewRequest(&emptypb.Empty{}))
	if err == nil {
		t.Fatal("expected an error from the handler")
	}
	return err
}

func withErrorInterceptor() connect.HandlerOption {
	return connect.WithInterceptors(interceptors.ErrorInterceptor())
}

func TestWithoutTheInterceptorDomainErrorsAreLostAsUnknown(t *testing.T) {
	// This is the behaviour being fixed, pinned so that a future change to
	// connect-go that makes the conversion unnecessary shows up here as a
	// failure rather than passing silently.
	client := serve(t, pkgerrors.NotFound("FARM_NOT_FOUND", "farm not found"))
	err := call(t, client)

	if got := connect.CodeOf(err); got != connect.CodeUnknown {
		t.Fatalf("code %v; connect-go now understands *errors.Error and the "+
			"interceptor may be redundant — check before removing it", got)
	}
	// And the message the caller sees is the internal debug formatting.
	if !strings.Contains(err.Error(), "metadata = map[]") {
		t.Errorf("unexpected raw message: %v", err)
	}
}

func TestNotFoundArrivesAsNotFound(t *testing.T) {
	client := serve(t, pkgerrors.NotFound("FARM_NOT_FOUND", "farm not found"), withErrorInterceptor())
	err := call(t, client)

	if got := connect.CodeOf(err); got != connect.CodeNotFound {
		t.Errorf("code %v, want not_found — a client retrying on 5xx would retry this forever", got)
	}
}

func TestTheClientSeesTheMessageNotTheDebugString(t *testing.T) {
	client := serve(t, pkgerrors.BadRequest("MISSING_FIELD_ID", "field_id is required"), withErrorInterceptor())
	err := call(t, client)

	msg := connect.CodeOf(err).String() // sanity: the code prefix
	_ = msg
	got := err.Error()
	if !strings.Contains(got, "field_id is required") {
		t.Errorf("message %q does not contain the handler's message", got)
	}
	// The old behaviour showed users "error: code = 400 reason = ...
	// metadata = map[] cause = <nil>", which is a debug string, not a message.
	for _, leak := range []string{"metadata = map[", "cause = <nil>", "reason = MISSING_FIELD_ID"} {
		if strings.Contains(got, leak) {
			t.Errorf("message %q leaks internal formatting (%q)", got, leak)
		}
	}
}

func TestEachStatusMapsToItsConnectCode(t *testing.T) {
	cases := []struct {
		name string
		err  error
		want connect.Code
	}{
		{"bad request", pkgerrors.BadRequest("INVALID_ARGUMENT", "bad"), connect.CodeInvalidArgument},
		{"unauthorized", pkgerrors.Unauthorized("NO_TOKEN", "no token"), connect.CodeUnauthenticated},
		{"forbidden", pkgerrors.Forbidden("WRONG_ROLE", "denied"), connect.CodePermissionDenied},
		{"not found", pkgerrors.NotFound("FARM_NOT_FOUND", "missing"), connect.CodeNotFound},
		{"conflict", pkgerrors.Conflict("FARM_NAME_EXISTS", "taken"), connect.CodeAborted},
		{"internal", pkgerrors.InternalServer("DB_ERROR", "boom"), connect.CodeInternal},
		{"unavailable", pkgerrors.ServiceUnavailable("UPSTREAM_DOWN", "later"), connect.CodeUnavailable},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			client := serve(t, tc.err, withErrorInterceptor())
			if got := connect.CodeOf(call(t, client)); got != tc.want {
				t.Errorf("code %v, want %v", got, tc.want)
			}
		})
	}
}

func TestTheReasonSurvivesAsStructuredDetail(t *testing.T) {
	// The numeric code says what kind of thing went wrong; the reason says
	// which thing. A client branching on "this particular farm name is taken"
	// needs the reason, and it must not have to parse the message for it.
	client := serve(t, pkgerrors.Conflict("FARM_NAME_EXISTS", "that name is taken"), withErrorInterceptor())
	err := call(t, client)

	var ce *connect.Error
	if !asConnectError(err, &ce) {
		t.Fatalf("not a connect error: %v", err)
	}

	var found string
	for _, d := range ce.Details() {
		msg, verr := d.Value()
		if verr != nil {
			continue
		}
		if info, ok := msg.(*errdetails.ErrorInfo); ok {
			found = info.GetReason()
		}
	}
	if found != "FARM_NAME_EXISTS" {
		t.Errorf("ErrorInfo reason %q, want FARM_NAME_EXISTS", found)
	}

	// Mirrored into metadata for clients that cannot decode details.
	if got := ce.Meta().Get("X-Error-Reason"); got != "FARM_NAME_EXISTS" {
		t.Errorf("x-error-reason metadata %q, want FARM_NAME_EXISTS", got)
	}
}

func TestMetadataOnTheDomainErrorReachesTheClient(t *testing.T) {
	base := pkgerrors.NotFound("FIELD_NOT_FOUND", "no such field").
		WithMetadata(map[string]string{"field_id": "f-42"})
	client := serve(t, base, withErrorInterceptor())
	err := call(t, client)

	var ce *connect.Error
	if !asConnectError(err, &ce) {
		t.Fatalf("not a connect error: %v", err)
	}
	for _, d := range ce.Details() {
		msg, verr := d.Value()
		if verr != nil {
			continue
		}
		if info, ok := msg.(*errdetails.ErrorInfo); ok {
			if info.GetMetadata()["field_id"] != "f-42" {
				t.Errorf("metadata %v lost field_id", info.GetMetadata())
			}
			return
		}
	}
	t.Error("no ErrorInfo detail on the error")
}

func TestAnExistingConnectErrorIsPassedThroughUnchanged(t *testing.T) {
	// Interceptors upstream — auth, authz, rate limiting — already produce
	// precise connect errors. Round-tripping one through the HTTP numbers
	// would turn CodeResourceExhausted into something less specific.
	original := connect.NewError(connect.CodeResourceExhausted, errString("rate limit exceeded"))
	client := serve(t, original, withErrorInterceptor())
	err := call(t, client)

	if got := connect.CodeOf(err); got != connect.CodeResourceExhausted {
		t.Errorf("code %v, want resource_exhausted preserved", got)
	}
	if !strings.Contains(err.Error(), "rate limit exceeded") {
		t.Errorf("message %q lost the original text", err.Error())
	}
}

func TestAPlainErrorBecomesInternal(t *testing.T) {
	// An error that is neither a domain error nor a connect error is a handler
	// returning something it never classified, which from the caller's side is
	// a server fault. The package already takes that position — errors.
	// UnknownCode is 500 — and mapping it to `internal` rather than `unknown`
	// puts it in the band clients already treat as retryable server trouble.
	client := serve(t, errString("something went wrong"), withErrorInterceptor())
	err := call(t, client)

	if got := connect.CodeOf(err); got != connect.CodeInternal {
		t.Errorf("code %v, want internal for an uncategorised error", got)
	}
	if !strings.Contains(err.Error(), "something went wrong") {
		t.Errorf("message %q lost the original text", err.Error())
	}
}

func TestSuccessIsUntouched(t *testing.T) {
	const procedure = "/test.v1.Service/Method"
	handler := connect.NewUnaryHandler(
		procedure,
		func(context.Context, *connect.Request[emptypb.Empty]) (*connect.Response[emptypb.Empty], error) {
			return connect.NewResponse(&emptypb.Empty{}), nil
		},
		withErrorInterceptor(),
	)
	mux := http.NewServeMux()
	mux.Handle(procedure, handler)
	srv := httptest.NewServer(mux)
	defer srv.Close()

	client := connect.NewClient[emptypb.Empty, emptypb.Empty](srv.Client(), srv.URL+procedure)
	if _, err := client.CallUnary(context.Background(), connect.NewRequest(&emptypb.Empty{})); err != nil {
		t.Errorf("a successful call returned %v", err)
	}
}

// errString is a plain error with no code attached.
type errString string

func (e errString) Error() string { return string(e) }

func asConnectError(err error, target **connect.Error) bool {
	ce, ok := err.(*connect.Error)
	if ok {
		*target = ce
	}
	return ok
}
