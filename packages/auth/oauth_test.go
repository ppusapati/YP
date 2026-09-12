package auth

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestEmailDomain(t *testing.T) {
	tests := []struct {
		email string
		want  string
	}{
		{"user@example.com", "example.com"},
		{"admin@yieldpoint.io", "yieldpoint.io"},
		{"nodomain", ""},
		{"", ""},
	}
	for _, tt := range tests {
		assert.Equal(t, tt.want, emailDomain(tt.email))
	}
}

func TestOIDCDiscovery(t *testing.T) {
	// Create a mock OIDC discovery server
	disc := OIDCDiscovery{
		Issuer:                "https://test.example.com",
		AuthorizationEndpoint: "https://test.example.com/authorize",
		TokenEndpoint:         "https://test.example.com/token",
		UserInfoEndpoint:      "https://test.example.com/userinfo",
		JWKSURI:               "https://test.example.com/.well-known/jwks.json",
	}

	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/.well-known/openid-configuration" {
			w.Header().Set("Content-Type", "application/json")
			json.NewEncoder(w).Encode(disc)
			return
		}
		http.NotFound(w, r)
	}))
	defer server.Close()

	provider := NewOIDCProvider(OAuthProviderConfig{
		Type:      ProviderCustom,
		ClientID:  "test-client-id",
		IssuerURL: server.URL,
	})

	err := provider.Discover(context.Background())
	require.NoError(t, err)

	assert.Equal(t, disc.Issuer, provider.discovery.Issuer)
	assert.Equal(t, disc.AuthorizationEndpoint, provider.discovery.AuthorizationEndpoint)
	assert.Equal(t, disc.JWKSURI, provider.discovery.JWKSURI)
}

func TestOIDCDiscovery_FailsOnBadURL(t *testing.T) {
	provider := NewOIDCProvider(OAuthProviderConfig{
		Type:      ProviderCustom,
		ClientID:  "test-client-id",
		IssuerURL: "http://localhost:1", // Nothing listening
	})

	err := provider.Discover(context.Background())
	assert.Error(t, err)
	assert.ErrorIs(t, err, ErrOAuthDiscoveryFailed)
}

func TestAuthURL(t *testing.T) {
	provider := &OIDCProvider{
		cfg: OAuthProviderConfig{
			Type:        ProviderGoogle,
			ClientID:    "my-client-id",
			RedirectURL: "https://app.example.com/callback",
			Scopes:      []string{"openid", "email", "profile"},
		},
	}
	provider.discovery = &OIDCDiscovery{
		AuthorizationEndpoint: "https://accounts.google.com/o/oauth2/v2/auth",
	}

	url, err := provider.AuthURL("random-state-123")
	require.NoError(t, err)
	assert.Contains(t, url, "client_id=my-client-id")
	assert.Contains(t, url, "state=random-state-123")
	assert.Contains(t, url, "response_type=code")
	assert.Contains(t, url, "scope=openid+email+profile")
}

func TestAuthURL_NoDiscovery(t *testing.T) {
	provider := &OIDCProvider{
		cfg: OAuthProviderConfig{
			Type:     ProviderGoogle,
			ClientID: "my-client-id",
		},
	}

	_, err := provider.AuthURL("state")
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "Discover()")
}

func TestNewGoogleProvider(t *testing.T) {
	p := NewGoogleProvider("client-id", "client-secret", "https://example.com/callback")
	assert.Equal(t, ProviderGoogle, p.Type())
	assert.Equal(t, "https://accounts.google.com", p.cfg.IssuerURL)
	assert.Equal(t, "client-id", p.cfg.ClientID)
}

func TestNewMicrosoftProvider(t *testing.T) {
	p := NewMicrosoftProvider("client-id", "client-secret", "https://example.com/callback", "my-tenant")
	assert.Equal(t, ProviderMicrosoft, p.Type())
	assert.Contains(t, p.cfg.IssuerURL, "my-tenant")
}

// mockUserStore implements UserStore for testing.
type mockUserStore struct {
	users      map[string]string // email -> userID
	ssoLinks   map[string]string // provider:providerID -> userID
	provisioned []ProvisionedUser
}

func newMockUserStore() *mockUserStore {
	return &mockUserStore{
		users:    make(map[string]string),
		ssoLinks: make(map[string]string),
	}
}

func (s *mockUserStore) FindByEmail(_ context.Context, email string) (string, error) {
	return s.users[email], nil
}

func (s *mockUserStore) FindBySSOIdentity(_ context.Context, provider OAuthProviderType, providerID string) (string, error) {
	key := string(provider) + ":" + providerID
	return s.ssoLinks[key], nil
}

func (s *mockUserStore) ProvisionUser(_ context.Context, user ProvisionedUser) (string, error) {
	id := "new-user-" + user.Email
	s.provisioned = append(s.provisioned, user)
	s.users[user.Email] = id
	key := string(user.Provider) + ":" + user.ProviderID
	s.ssoLinks[key] = id
	return id, nil
}

func (s *mockUserStore) LinkSSOIdentity(_ context.Context, userID string, identity SSOIdentity) error {
	key := string(identity.Provider) + ":" + identity.ProviderID
	s.ssoLinks[key] = userID
	return nil
}

func TestOAuthManager_RegisterAndGetProvider(t *testing.T) {
	manager := NewOAuthManager(newMockUserStore())

	provider := NewGoogleProvider("id", "secret", "https://example.com/callback")
	manager.RegisterProvider(provider)

	got, err := manager.GetProvider(ProviderGoogle)
	require.NoError(t, err)
	assert.Equal(t, ProviderGoogle, got.Type())
}

func TestOAuthManager_ProviderNotFound(t *testing.T) {
	manager := NewOAuthManager(newMockUserStore())

	_, err := manager.GetProvider(ProviderGoogle)
	assert.ErrorIs(t, err, ErrOAuthProviderNotFound)
}

func TestSSOIdentity_Fields(t *testing.T) {
	identity := SSOIdentity{
		Provider:   ProviderGoogle,
		ProviderID: "google-user-123",
		Email:      "user@example.com",
		Name:       "Test User",
		LinkedAt:   time.Now().UTC(),
	}

	assert.Equal(t, ProviderGoogle, identity.Provider)
	assert.Equal(t, "google-user-123", identity.ProviderID)
	assert.NotZero(t, identity.LinkedAt)
}

func TestParseRSAPublicKey(t *testing.T) {
	// A minimal valid JWK (small key for testing only)
	key := jwkKey{
		Kty: "RSA",
		Kid: "test-key",
		Use: "sig",
		// These are base64url-encoded values for a small test key
		N: "0vx7agoebGcQSuuPiLJXZptN9nndrQmbXEps2aiAFbWhM78LhWx4cbbfAAtVT86zwu1RK7aPFFxuhDR1L6tSoc_BJECPebWKRXjBZCiFV4n3oknjhMstn64tZ_2W-5JsGY4Hc5n9yBXArwl93lqt7_RN5w6Cf0h4QyQ5v-65YGjQR0_FDW2QvzqY368QQMicAtaSqzs8KJZgnYb9c7d0zgdAZHzu6qMQvRL5hajrn1n91CbOpbISD08qNLyrdkt-bFTWhAI4vMQFh6WeZu0fM4lFd2NcRwr3XPksINHaQ-G_xBniIqbw0Ls1jF44-csFCur-kEgU8awapJzKnqDKgw",
		E: "AQAB",
	}

	pub, err := parseRSAPublicKey(key)
	require.NoError(t, err)
	assert.NotNil(t, pub)
	assert.Equal(t, 65537, pub.E)
}
