package auth

import (
	"crypto/rand"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func testSecret() []byte {
	secret := make([]byte, 32)
	_, _ = rand.Read(secret)
	return secret
}

func TestNewCSRFProtection_SecretTooShort(t *testing.T) {
	_, err := NewCSRFProtection(CSRFConfig{Secret: []byte("short")})
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "at least 32 bytes")
}

func TestNewCSRFProtection_Defaults(t *testing.T) {
	csrf, err := NewCSRFProtection(CSRFConfig{Secret: testSecret()})
	require.NoError(t, err)
	assert.Equal(t, DefaultCSRFCookieName, csrf.cfg.CookieName)
	assert.Equal(t, DefaultCSRFHeaderName, csrf.cfg.HeaderName)
	assert.Equal(t, DefaultCSRFFieldName, csrf.cfg.FieldName)
	assert.Equal(t, 43200, csrf.cfg.MaxAge)
}

func TestGenerateAndValidateToken(t *testing.T) {
	csrf, err := NewCSRFProtection(DefaultCSRFConfig(testSecret()))
	require.NoError(t, err)

	token, err := csrf.GenerateToken()
	require.NoError(t, err)
	assert.NotEmpty(t, token)

	err = csrf.ValidateToken(token)
	assert.NoError(t, err)
}

func TestValidateToken_InvalidFormat(t *testing.T) {
	csrf, err := NewCSRFProtection(DefaultCSRFConfig(testSecret()))
	require.NoError(t, err)

	assert.ErrorIs(t, csrf.ValidateToken(""), ErrCSRFTokenInvalid)
	assert.ErrorIs(t, csrf.ValidateToken("onepart"), ErrCSRFTokenInvalid)
	assert.ErrorIs(t, csrf.ValidateToken("two.parts"), ErrCSRFTokenInvalid)
}

func TestValidateToken_Tampered(t *testing.T) {
	csrf, err := NewCSRFProtection(DefaultCSRFConfig(testSecret()))
	require.NoError(t, err)

	token, err := csrf.GenerateToken()
	require.NoError(t, err)

	// Tamper with the token
	tampered := token[:len(token)-2] + "XX"
	err = csrf.ValidateToken(tampered)
	assert.Error(t, err)
}

func TestValidateToken_DifferentSecret(t *testing.T) {
	csrf1, _ := NewCSRFProtection(DefaultCSRFConfig(testSecret()))
	csrf2, _ := NewCSRFProtection(DefaultCSRFConfig(testSecret()))

	token, _ := csrf1.GenerateToken()
	err := csrf2.ValidateToken(token)
	assert.ErrorIs(t, err, ErrCSRFTokenInvalid)
}

func TestValidateToken_Expired(t *testing.T) {
	cfg := DefaultCSRFConfig(testSecret())
	cfg.MaxAge = 1 // 1 second
	csrf, _ := NewCSRFProtection(cfg)

	token, _ := csrf.GenerateToken()
	time.Sleep(2 * time.Second)
	err := csrf.ValidateToken(token)
	assert.ErrorIs(t, err, ErrCSRFTokenExpired)
}

func TestMiddleware_SafeMethodSetsCookie(t *testing.T) {
	csrf, _ := NewCSRFProtection(DefaultCSRFConfig(testSecret()))

	handler := csrf.Middleware()(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))

	req := httptest.NewRequest(http.MethodGet, "/", nil)
	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, req)

	assert.Equal(t, http.StatusOK, rec.Code)

	// Should have set a CSRF cookie
	cookies := rec.Result().Cookies()
	found := false
	for _, c := range cookies {
		if c.Name == DefaultCSRFCookieName {
			found = true
			break
		}
	}
	assert.True(t, found, "CSRF cookie should be set on GET")
}

func TestMiddleware_UnsafeMethodWithoutToken(t *testing.T) {
	csrf, _ := NewCSRFProtection(DefaultCSRFConfig(testSecret()))

	handler := csrf.Middleware()(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))

	req := httptest.NewRequest(http.MethodPost, "/submit", nil)
	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, req)

	assert.Equal(t, http.StatusForbidden, rec.Code)
}

func TestMiddleware_UnsafeMethodWithValidToken(t *testing.T) {
	csrf, _ := NewCSRFProtection(DefaultCSRFConfig(testSecret()))

	token, _ := csrf.GenerateToken()

	handler := csrf.Middleware()(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))

	req := httptest.NewRequest(http.MethodPost, "/submit", nil)
	req.AddCookie(&http.Cookie{Name: DefaultCSRFCookieName, Value: token})
	req.Header.Set(DefaultCSRFHeaderName, token)

	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, req)

	assert.Equal(t, http.StatusOK, rec.Code)
}

func TestMiddleware_UnsafeMethodMismatchedTokens(t *testing.T) {
	csrf, _ := NewCSRFProtection(DefaultCSRFConfig(testSecret()))

	token1, _ := csrf.GenerateToken()
	token2, _ := csrf.GenerateToken()

	handler := csrf.Middleware()(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))

	req := httptest.NewRequest(http.MethodPost, "/submit", nil)
	req.AddCookie(&http.Cookie{Name: DefaultCSRFCookieName, Value: token1})
	req.Header.Set(DefaultCSRFHeaderName, token2)

	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, req)

	assert.Equal(t, http.StatusForbidden, rec.Code)
}

func TestMiddleware_SkipsConnectRPC(t *testing.T) {
	csrf, _ := NewCSRFProtection(DefaultCSRFConfig(testSecret()))
	called := false

	handler := csrf.Middleware()(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		called = true
		w.WriteHeader(http.StatusOK)
	}))

	// ConnectRPC request (has Connect-Protocol-Version header)
	req := httptest.NewRequest(http.MethodPost, "/farm.v1.FarmService/CreateFarm", nil)
	req.Header.Set("Connect-Protocol-Version", "1")

	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, req)

	assert.True(t, called, "ConnectRPC request should bypass CSRF")
	assert.Equal(t, http.StatusOK, rec.Code)
}

func TestMiddleware_SkipsCustomCheck(t *testing.T) {
	cfg := DefaultCSRFConfig(testSecret())
	cfg.SkipCheck = func(r *http.Request) bool {
		return r.URL.Path == "/webhook"
	}
	csrf, _ := NewCSRFProtection(cfg)
	called := false

	handler := csrf.Middleware()(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		called = true
		w.WriteHeader(http.StatusOK)
	}))

	req := httptest.NewRequest(http.MethodPost, "/webhook", nil)
	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, req)

	assert.True(t, called)
	assert.Equal(t, http.StatusOK, rec.Code)
}

func TestIsConnectRPC(t *testing.T) {
	tests := []struct {
		name string
		ct   string
		cpv  string
		want bool
	}{
		{"connect+proto", "application/connect+proto", "", true},
		{"connect+json", "application/connect+json", "", true},
		{"grpc", "application/grpc", "", true},
		{"connect-protocol-version", "application/json", "1", true},
		{"regular json", "application/json", "", false},
		{"form", "application/x-www-form-urlencoded", "", false},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r := httptest.NewRequest(http.MethodPost, "/", nil)
			r.Header.Set("Content-Type", tt.ct)
			if tt.cpv != "" {
				r.Header.Set("Connect-Protocol-Version", tt.cpv)
			}
			assert.Equal(t, tt.want, isConnectRPC(r))
		})
	}
}
