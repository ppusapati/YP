package auth

import (
	"context"
	"crypto/rsa"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"math/big"
	"net/http"
	"strings"
	"sync"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// OAuth errors.
var (
	ErrOAuthProviderNotFound   = errors.New("oauth: provider not found")
	ErrOAuthDiscoveryFailed    = errors.New("oauth: OIDC discovery failed")
	ErrOAuthTokenInvalid       = errors.New("oauth: token validation failed")
	ErrOAuthEmailNotVerified   = errors.New("oauth: email not verified")
	ErrOAuthMissingEmail       = errors.New("oauth: email claim missing")
	ErrOAuthUnsupportedKeyType = errors.New("oauth: unsupported key type")
)

// OAuthProviderType identifies the SSO provider.
type OAuthProviderType string

const (
	ProviderGoogle    OAuthProviderType = "google"
	ProviderMicrosoft OAuthProviderType = "microsoft"
	ProviderCustom    OAuthProviderType = "custom"
)

// OAuthProviderConfig holds configuration for an OAuth2/OIDC provider.
type OAuthProviderConfig struct {
	// Type identifies the provider (google, microsoft, custom).
	Type OAuthProviderType

	// ClientID is the OAuth2 client ID.
	ClientID string

	// ClientSecret is the OAuth2 client secret.
	ClientSecret string

	// RedirectURL is the callback URL after authentication.
	RedirectURL string

	// IssuerURL is the OIDC issuer URL (e.g. "https://accounts.google.com").
	// Used for OIDC discovery.
	IssuerURL string

	// Scopes to request. Defaults to ["openid", "email", "profile"].
	Scopes []string

	// AllowedDomains restricts authentication to specific email domains.
	// Empty means all domains are allowed.
	AllowedDomains []string

	// AutoProvision controls whether new users are created on first SSO login.
	AutoProvision bool

	// DefaultRole assigned to auto-provisioned users.
	DefaultRole string
}

// OIDCDiscovery holds the parsed OIDC discovery document.
type OIDCDiscovery struct {
	Issuer                string `json:"issuer"`
	AuthorizationEndpoint string `json:"authorization_endpoint"`
	TokenEndpoint         string `json:"token_endpoint"`
	UserInfoEndpoint      string `json:"userinfo_endpoint"`
	JWKSURI               string `json:"jwks_uri"`
	SupportedScopes       []string `json:"scopes_supported"`
}

// OIDCClaims represents the claims from an OIDC ID token.
type OIDCClaims struct {
	Subject       string `json:"sub"`
	Email         string `json:"email"`
	EmailVerified bool   `json:"email_verified"`
	Name          string `json:"name"`
	GivenName     string `json:"given_name"`
	FamilyName    string `json:"family_name"`
	Picture       string `json:"picture"`
	Locale        string `json:"locale"`
	jwt.RegisteredClaims
}

// SSOIdentity represents a linked SSO identity for an existing user.
type SSOIdentity struct {
	Provider   OAuthProviderType `json:"provider"`
	ProviderID string            `json:"provider_id"` // The "sub" claim from the provider
	Email      string            `json:"email"`
	Name       string            `json:"name"`
	Picture    string            `json:"picture,omitempty"`
	LinkedAt   time.Time         `json:"linked_at"`
}

// ProvisionedUser holds the information for a newly provisioned SSO user.
type ProvisionedUser struct {
	Email      string
	Name       string
	GivenName  string
	FamilyName string
	Picture    string
	Provider   OAuthProviderType
	ProviderID string
	Role       string
}

// OAuthProvider defines the interface for SSO providers.
type OAuthProvider interface {
	// Type returns the provider type.
	Type() OAuthProviderType

	// AuthURL returns the URL to redirect the user to for authentication.
	AuthURL(state string) (string, error)

	// ValidateIDToken validates an OIDC ID token and returns the claims.
	ValidateIDToken(ctx context.Context, rawToken string) (*OIDCClaims, error)

	// GetUserInfo retrieves user info from the provider using an access token.
	GetUserInfo(ctx context.Context, accessToken string) (*OIDCClaims, error)

	// Config returns the provider configuration.
	Config() OAuthProviderConfig
}

// UserStore is the interface for user persistence during SSO operations.
type UserStore interface {
	// FindByEmail returns a user ID if one exists for the email, empty string otherwise.
	FindByEmail(ctx context.Context, email string) (string, error)

	// FindBySSOIdentity returns a user ID if one is linked to the SSO identity.
	FindBySSOIdentity(ctx context.Context, provider OAuthProviderType, providerID string) (string, error)

	// ProvisionUser creates a new user from SSO data and returns their ID.
	ProvisionUser(ctx context.Context, user ProvisionedUser) (string, error)

	// LinkSSOIdentity links an SSO identity to an existing user.
	LinkSSOIdentity(ctx context.Context, userID string, identity SSOIdentity) error
}

// OAuthManager manages multiple OAuth providers and handles user provisioning.
type OAuthManager struct {
	providers map[OAuthProviderType]OAuthProvider
	userStore UserStore
	mu        sync.RWMutex
}

// NewOAuthManager creates a new OAuth manager.
func NewOAuthManager(store UserStore) *OAuthManager {
	return &OAuthManager{
		providers: make(map[OAuthProviderType]OAuthProvider),
		userStore: store,
	}
}

// RegisterProvider adds an OAuth provider.
func (m *OAuthManager) RegisterProvider(provider OAuthProvider) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.providers[provider.Type()] = provider
}

// GetProvider returns a registered provider or an error.
func (m *OAuthManager) GetProvider(providerType OAuthProviderType) (OAuthProvider, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	p, ok := m.providers[providerType]
	if !ok {
		return nil, fmt.Errorf("%w: %s", ErrOAuthProviderNotFound, providerType)
	}
	return p, nil
}

// HandleSSOLogin processes an SSO login: validates the ID token, provisions or
// links the user, and returns the user ID.
func (m *OAuthManager) HandleSSOLogin(ctx context.Context, providerType OAuthProviderType, idToken string) (string, *OIDCClaims, error) {
	provider, err := m.GetProvider(providerType)
	if err != nil {
		return "", nil, err
	}

	claims, err := provider.ValidateIDToken(ctx, idToken)
	if err != nil {
		return "", nil, fmt.Errorf("oauth: token validation failed for %s: %w", providerType, err)
	}

	if claims.Email == "" {
		return "", nil, ErrOAuthMissingEmail
	}
	if !claims.EmailVerified {
		return "", nil, ErrOAuthEmailNotVerified
	}

	// Check allowed domains
	cfg := provider.Config()
	if len(cfg.AllowedDomains) > 0 {
		domain := emailDomain(claims.Email)
		allowed := false
		for _, d := range cfg.AllowedDomains {
			if strings.EqualFold(d, domain) {
				allowed = true
				break
			}
		}
		if !allowed {
			return "", nil, fmt.Errorf("oauth: email domain %q not allowed for provider %s", domain, providerType)
		}
	}

	// Try to find user by SSO identity
	userID, err := m.userStore.FindBySSOIdentity(ctx, providerType, claims.Subject)
	if err != nil {
		return "", nil, fmt.Errorf("oauth: failed to look up SSO identity: %w", err)
	}
	if userID != "" {
		return userID, claims, nil
	}

	// Try to find user by email (link existing account)
	userID, err = m.userStore.FindByEmail(ctx, claims.Email)
	if err != nil {
		return "", nil, fmt.Errorf("oauth: failed to look up user by email: %w", err)
	}
	if userID != "" {
		// Link SSO identity to existing account
		identity := SSOIdentity{
			Provider:   providerType,
			ProviderID: claims.Subject,
			Email:      claims.Email,
			Name:       claims.Name,
			Picture:    claims.Picture,
			LinkedAt:   time.Now().UTC(),
		}
		if err := m.userStore.LinkSSOIdentity(ctx, userID, identity); err != nil {
			return "", nil, fmt.Errorf("oauth: failed to link SSO identity: %w", err)
		}
		return userID, claims, nil
	}

	// Auto-provision new user if enabled
	if !cfg.AutoProvision {
		return "", nil, fmt.Errorf("oauth: no existing account for %s and auto-provisioning is disabled", claims.Email)
	}

	role := cfg.DefaultRole
	if role == "" {
		role = "viewer"
	}

	newUser := ProvisionedUser{
		Email:      claims.Email,
		Name:       claims.Name,
		GivenName:  claims.GivenName,
		FamilyName: claims.FamilyName,
		Picture:    claims.Picture,
		Provider:   providerType,
		ProviderID: claims.Subject,
		Role:       role,
	}

	userID, err = m.userStore.ProvisionUser(ctx, newUser)
	if err != nil {
		return "", nil, fmt.Errorf("oauth: failed to provision user: %w", err)
	}

	return userID, claims, nil
}

// --------------------------------------------------------------------------
// OIDC provider implementation
// --------------------------------------------------------------------------

// OIDCProvider implements OAuthProvider using OIDC discovery.
type OIDCProvider struct {
	cfg       OAuthProviderConfig
	discovery *OIDCDiscovery
	keys      *jwksCache
	client    *http.Client
	mu        sync.RWMutex
}

// NewOIDCProvider creates a new OIDC provider. Call Discover() to load
// the OIDC configuration before validating tokens.
func NewOIDCProvider(cfg OAuthProviderConfig) *OIDCProvider {
	client := &http.Client{Timeout: 10 * time.Second}
	return &OIDCProvider{
		cfg:    cfg,
		client: client,
		keys:   newJWKSCache(),
	}
}

// NewGoogleProvider creates an OIDCProvider pre-configured for Google.
func NewGoogleProvider(clientID, clientSecret, redirectURL string) *OIDCProvider {
	return NewOIDCProvider(OAuthProviderConfig{
		Type:         ProviderGoogle,
		ClientID:     clientID,
		ClientSecret: clientSecret,
		RedirectURL:  redirectURL,
		IssuerURL:    "https://accounts.google.com",
		Scopes:       []string{"openid", "email", "profile"},
	})
}

// NewMicrosoftProvider creates an OIDCProvider pre-configured for Microsoft.
func NewMicrosoftProvider(clientID, clientSecret, redirectURL, tenantID string) *OIDCProvider {
	issuer := "https://login.microsoftonline.com/" + tenantID + "/v2.0"
	return NewOIDCProvider(OAuthProviderConfig{
		Type:         ProviderMicrosoft,
		ClientID:     clientID,
		ClientSecret: clientSecret,
		RedirectURL:  redirectURL,
		IssuerURL:    issuer,
		Scopes:       []string{"openid", "email", "profile"},
	})
}

func (p *OIDCProvider) Type() OAuthProviderType   { return p.cfg.Type }
func (p *OIDCProvider) Config() OAuthProviderConfig { return p.cfg }

// Discover loads the OIDC discovery document from the issuer.
func (p *OIDCProvider) Discover(ctx context.Context) error {
	url := strings.TrimRight(p.cfg.IssuerURL, "/") + "/.well-known/openid-configuration"

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return fmt.Errorf("%w: %v", ErrOAuthDiscoveryFailed, err)
	}

	resp, err := p.client.Do(req)
	if err != nil {
		return fmt.Errorf("%w: %v", ErrOAuthDiscoveryFailed, err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("%w: unexpected status %d", ErrOAuthDiscoveryFailed, resp.StatusCode)
	}

	var disc OIDCDiscovery
	if err := json.NewDecoder(resp.Body).Decode(&disc); err != nil {
		return fmt.Errorf("%w: %v", ErrOAuthDiscoveryFailed, err)
	}

	p.mu.Lock()
	p.discovery = &disc
	p.mu.Unlock()

	return nil
}

// AuthURL returns the authorization URL for this provider.
func (p *OIDCProvider) AuthURL(state string) (string, error) {
	p.mu.RLock()
	disc := p.discovery
	p.mu.RUnlock()

	if disc == nil {
		return "", fmt.Errorf("oauth: OIDC discovery not performed; call Discover() first")
	}

	scopes := p.cfg.Scopes
	if len(scopes) == 0 {
		scopes = []string{"openid", "email", "profile"}
	}

	url := fmt.Sprintf("%s?client_id=%s&redirect_uri=%s&response_type=code&scope=%s&state=%s",
		disc.AuthorizationEndpoint,
		p.cfg.ClientID,
		p.cfg.RedirectURL,
		strings.Join(scopes, "+"),
		state,
	)

	return url, nil
}

// ValidateIDToken validates an OIDC ID token using the provider's JWKS keys.
func (p *OIDCProvider) ValidateIDToken(ctx context.Context, rawToken string) (*OIDCClaims, error) {
	p.mu.RLock()
	disc := p.discovery
	p.mu.RUnlock()

	if disc == nil {
		return nil, fmt.Errorf("oauth: OIDC discovery not performed; call Discover() first")
	}

	// Fetch JWKS if needed
	if err := p.keys.Refresh(ctx, disc.JWKSURI, p.client); err != nil {
		return nil, fmt.Errorf("oauth: failed to fetch JWKS: %w", err)
	}

	claims := &OIDCClaims{}
	token, err := jwt.ParseWithClaims(rawToken, claims, func(token *jwt.Token) (interface{}, error) {
		kid, ok := token.Header["kid"].(string)
		if !ok {
			return nil, fmt.Errorf("oauth: token missing kid header")
		}
		key, err := p.keys.GetKey(kid)
		if err != nil {
			return nil, err
		}
		return key, nil
	},
		jwt.WithIssuer(disc.Issuer),
		jwt.WithAudience(p.cfg.ClientID),
		jwt.WithExpirationRequired(),
	)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrOAuthTokenInvalid, err)
	}

	if !token.Valid {
		return nil, ErrOAuthTokenInvalid
	}

	return claims, nil
}

// GetUserInfo fetches user info from the OIDC userinfo endpoint.
func (p *OIDCProvider) GetUserInfo(ctx context.Context, accessToken string) (*OIDCClaims, error) {
	p.mu.RLock()
	disc := p.discovery
	p.mu.RUnlock()

	if disc == nil || disc.UserInfoEndpoint == "" {
		return nil, fmt.Errorf("oauth: userinfo endpoint not available")
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, disc.UserInfoEndpoint, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", "Bearer "+accessToken)

	resp, err := p.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("oauth: userinfo request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(io.LimitReader(resp.Body, 1024))
		return nil, fmt.Errorf("oauth: userinfo returned %d: %s", resp.StatusCode, string(body))
	}

	var claims OIDCClaims
	if err := json.NewDecoder(resp.Body).Decode(&claims); err != nil {
		return nil, fmt.Errorf("oauth: failed to decode userinfo: %w", err)
	}

	return &claims, nil
}

// --------------------------------------------------------------------------
// JWKS cache
// --------------------------------------------------------------------------

// jwkKey represents a single JSON Web Key.
type jwkKey struct {
	Kty string `json:"kty"`
	Kid string `json:"kid"`
	Use string `json:"use"`
	N   string `json:"n"`
	E   string `json:"e"`
	Alg string `json:"alg"`
}

type jwksResponse struct {
	Keys []jwkKey `json:"keys"`
}

type jwksCache struct {
	mu         sync.RWMutex
	keys       map[string]*rsa.PublicKey
	fetchedAt  time.Time
	ttl        time.Duration
}

func newJWKSCache() *jwksCache {
	return &jwksCache{
		keys: make(map[string]*rsa.PublicKey),
		ttl:  1 * time.Hour,
	}
}

// Refresh fetches JWKS from the URI if the cache is stale.
func (c *jwksCache) Refresh(ctx context.Context, jwksURI string, client *http.Client) error {
	c.mu.RLock()
	if time.Since(c.fetchedAt) < c.ttl && len(c.keys) > 0 {
		c.mu.RUnlock()
		return nil
	}
	c.mu.RUnlock()

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, jwksURI, nil)
	if err != nil {
		return err
	}

	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("jwks: unexpected status %d", resp.StatusCode)
	}

	var jwks jwksResponse
	if err := json.NewDecoder(resp.Body).Decode(&jwks); err != nil {
		return fmt.Errorf("jwks: decode failed: %w", err)
	}

	keys := make(map[string]*rsa.PublicKey, len(jwks.Keys))
	for _, k := range jwks.Keys {
		if k.Kty != "RSA" || k.Use != "sig" {
			continue
		}
		pub, err := parseRSAPublicKey(k)
		if err != nil {
			continue // skip invalid keys
		}
		keys[k.Kid] = pub
	}

	c.mu.Lock()
	c.keys = keys
	c.fetchedAt = time.Now()
	c.mu.Unlock()

	return nil
}

// GetKey returns the RSA public key for the given key ID.
func (c *jwksCache) GetKey(kid string) (*rsa.PublicKey, error) {
	c.mu.RLock()
	defer c.mu.RUnlock()

	key, ok := c.keys[kid]
	if !ok {
		return nil, fmt.Errorf("jwks: key %q not found", kid)
	}
	return key, nil
}

// parseRSAPublicKey converts a JWK to an rsa.PublicKey.
func parseRSAPublicKey(k jwkKey) (*rsa.PublicKey, error) {
	nBytes, err := base64.RawURLEncoding.DecodeString(k.N)
	if err != nil {
		return nil, fmt.Errorf("jwks: invalid N: %w", err)
	}

	eBytes, err := base64.RawURLEncoding.DecodeString(k.E)
	if err != nil {
		return nil, fmt.Errorf("jwks: invalid E: %w", err)
	}

	n := new(big.Int).SetBytes(nBytes)
	e := 0
	for _, b := range eBytes {
		e = e<<8 + int(b)
	}

	return &rsa.PublicKey{N: n, E: e}, nil
}

// emailDomain extracts the domain from an email address.
func emailDomain(email string) string {
	parts := strings.SplitN(email, "@", 2)
	if len(parts) != 2 {
		return ""
	}
	return parts[1]
}
