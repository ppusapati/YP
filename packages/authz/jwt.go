package authz

import (
	"errors"
	"fmt"
	"os"
	"sync"
	"time"

	"p9e.in/samavaya/packages/api/v1/config"

	"github.com/golang-jwt/jwt/v5"
)

// CustomClaims defines the structure embedded in JWT
type CustomClaims struct {
	UserID      string       `json:"sub"`
	TenantID    string       `json:"tenant_id"`
	CompanyID   string       `json:"company_id,omitempty"`
	BranchID    string       `json:"branch_id,omitempty"` // User's default branch, may be empty for company-scoped entities
	Role        string       `json:"role"`
	Permissions []Permission `json:"permissions"`
	SessionID   string       `json:"session_id,omitempty"` // Links to database session for revocation support
	jwt.RegisteredClaims
}

// JWTConfig holds JWT configuration
type JWTConfig struct {
	secret []byte
	issuer string
	mu     sync.RWMutex
}

var (
	jwtConfig     *JWTConfig
	jwtConfigOnce sync.Once

	// ErrJWTNotConfigured is returned when JWT secret is not configured
	ErrJWTNotConfigured = errors.New("JWT secret not configured: set JWT_SECRET environment variable or provide config")
)

// InitJWTFromConfig initializes JWT configuration from the security config.
// This should be called during application startup.
func InitJWTFromConfig(cfg *config.Security) error {
	if cfg == nil || cfg.Jwt == nil || cfg.Jwt.Secret == "" {
		return ErrJWTNotConfigured
	}

	jwtConfigOnce.Do(func() {
		jwtConfig = &JWTConfig{}
	})

	jwtConfig.mu.Lock()
	defer jwtConfig.mu.Unlock()

	jwtConfig.secret = []byte(cfg.Jwt.Secret)
	jwtConfig.issuer = cfg.Jwt.Issuer

	return nil
}

// InitJWTFromEnv initializes JWT configuration from environment variables.
// Environment variable: JWT_SECRET (required), JWT_ISSUER (optional)
func InitJWTFromEnv() error {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		return ErrJWTNotConfigured
	}

	jwtConfigOnce.Do(func() {
		jwtConfig = &JWTConfig{}
	})

	jwtConfig.mu.Lock()
	defer jwtConfig.mu.Unlock()

	jwtConfig.secret = []byte(secret)
	jwtConfig.issuer = os.Getenv("JWT_ISSUER")

	return nil
}

// getJWTSecret returns the configured JWT secret.
// It first checks if config was initialized, then falls back to environment variable.
func getJWTSecret() ([]byte, error) {
	if jwtConfig != nil {
		jwtConfig.mu.RLock()
		defer jwtConfig.mu.RUnlock()
		if len(jwtConfig.secret) > 0 {
			return jwtConfig.secret, nil
		}
	}

	// Fallback to environment variable
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		return nil, ErrJWTNotConfigured
	}

	return []byte(secret), nil
}

// ParseJWT parses the token and returns claims
func ParseJWT(tokenString string) (*CustomClaims, error) {
	secret, err := getJWTSecret()
	if err != nil {
		return nil, fmt.Errorf("failed to get JWT secret: %w", err)
	}

	token, err := jwt.ParseWithClaims(tokenString, &CustomClaims{}, func(token *jwt.Token) (interface{}, error) {
		// Validate the signing method
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return secret, nil
	})
	if err != nil {
		return nil, fmt.Errorf("failed to parse token: %w", err)
	}

	claims, ok := token.Claims.(*CustomClaims)
	if !ok || !token.Valid {
		return nil, errors.New("invalid token or claims")
	}

	if claims.ExpiresAt != nil && claims.ExpiresAt.Time.Before(time.Now()) {
		return nil, errors.New("token expired")
	}

	return claims, nil
}
