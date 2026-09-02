package main

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"go.uber.org/zap"
	"golang.org/x/crypto/bcrypt"

	"p9e.in/samavaya/packages/authz"
	"p9e.in/samavaya/packages/database/migrate"

	"github.com/golang-jwt/jwt/v5"
)

const (
	accessTokenTTL  = 15 * time.Minute
	refreshTokenTTL = 7 * 24 * time.Hour
)

func main() {
	zapLogger, err := zap.NewProduction()
	if err != nil {
		log.Fatalf("failed to create logger: %v", err)
	}
	defer zapLogger.Sync() //nolint:errcheck

	if err := authz.InitJWTFromEnv(); err != nil {
		log.Fatalf("JWT not configured: %v", err)
	}

	dsn := envOr("DATABASE_URL", "postgres://localhost:5432/auth_service?sslmode=disable")
	port := envOr("PORT", "8080")

	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		log.Fatalf("failed to connect to database: %v", err)
	}
	defer pool.Close()

	if err := pool.Ping(ctx); err != nil {
		log.Fatalf("database ping failed: %v", err)
	}

	migrateCtx, migrateCancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer migrateCancel()
	if err := migrate.Up(migrateCtx, pool, os.DirFS(envOr("MIGRATIONS_DIR", "migrations")), zapLogger); err != nil {
		log.Fatalf("migration failed: %v", err)
	}

	h := &authHandler{pool: pool, logger: zapLogger}

	mux := http.NewServeMux()
	mux.HandleFunc("/auth/login", h.handleLogin)
	mux.HandleFunc("/auth/refresh", h.handleRefresh)
	mux.HandleFunc("/auth/me", h.handleMe)
	mux.HandleFunc("/auth/logout", h.handleLogout)
	mux.HandleFunc("/health", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"status":"ok"}`))
	})
	mux.HandleFunc("/ready", func(w http.ResponseWriter, _ *http.Request) {
		if err := pool.Ping(context.Background()); err != nil {
			w.WriteHeader(http.StatusServiceUnavailable)
			return
		}
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"status":"ready"}`))
	})

	srv := &http.Server{
		Addr:              ":" + port,
		Handler:           mux,
		ReadHeaderTimeout: 10 * time.Second,
	}

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		zapLogger.Info("auth-service starting", zap.String("port", port))
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("server error: %v", err)
		}
	}()

	<-quit
	zapLogger.Info("shutting down auth-service")

	shutCtx, shutCancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer shutCancel()
	if err := srv.Shutdown(shutCtx); err != nil {
		log.Printf("graceful shutdown error: %v", err)
	}
}

type authHandler struct {
	pool   *pgxpool.Pool
	logger *zap.Logger
}

// POST /auth/login  { "email": "...", "password": "..." }
func (h *authHandler) handleLogin(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	var req struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid request body"})
		return
	}
	if req.Email == "" || req.Password == "" {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "email and password are required"})
		return
	}

	var userID, tenantID, name, role, passwordHash string
	err := h.pool.QueryRow(r.Context(),
		"SELECT id, tenant_id, name, role, password_hash FROM users WHERE email = $1 AND is_active = true",
		req.Email,
	).Scan(&userID, &tenantID, &name, &role, &passwordHash)
	if err != nil {
		writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "invalid credentials"})
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(passwordHash), []byte(req.Password)); err != nil {
		writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "invalid credentials"})
		return
	}

	accessToken, err := h.issueAccessToken(userID, tenantID, role)
	if err != nil {
		h.logger.Error("failed to sign access token", zap.Error(err))
		writeJSON(w, http.StatusInternalServerError, map[string]string{"error": "internal error"})
		return
	}

	refreshToken, err := h.createSession(r.Context(), userID, r.RemoteAddr, r.UserAgent())
	if err != nil {
		h.logger.Error("failed to create session", zap.Error(err))
		writeJSON(w, http.StatusInternalServerError, map[string]string{"error": "internal error"})
		return
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"token": map[string]interface{}{
			"access_token":  accessToken,
			"refresh_token": refreshToken,
			"expires_at":    time.Now().Add(accessTokenTTL).Unix(),
		},
		"user": map[string]interface{}{
			"id":        strings.TrimSpace(userID),
			"tenant_id": strings.TrimSpace(tenantID),
			"name":      name,
			"email":     req.Email,
			"role":      role,
		},
	})
}

// POST /auth/refresh  { "refresh_token": "..." }
func (h *authHandler) handleRefresh(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	var req struct {
		RefreshToken string `json:"refresh_token"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.RefreshToken == "" {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "refresh_token is required"})
		return
	}

	var sessionID, userID, tenantID, role string
	var expiresAt time.Time
	err := h.pool.QueryRow(r.Context(), `
		SELECT s.id, s.user_id, u.tenant_id, u.role, s.expires_at
		FROM sessions s JOIN users u ON u.id = s.user_id
		WHERE s.refresh_token = $1 AND s.is_revoked = false AND u.is_active = true
	`, req.RefreshToken).Scan(&sessionID, &userID, &tenantID, &role, &expiresAt)
	if err != nil {
		writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "invalid refresh token"})
		return
	}

	if time.Now().After(expiresAt) {
		_, _ = h.pool.Exec(r.Context(), "UPDATE sessions SET is_revoked = true WHERE id = $1", sessionID)
		writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "refresh token expired"})
		return
	}

	accessToken, err := h.issueAccessToken(strings.TrimSpace(userID), strings.TrimSpace(tenantID), strings.TrimSpace(role))
	if err != nil {
		h.logger.Error("failed to sign access token", zap.Error(err))
		writeJSON(w, http.StatusInternalServerError, map[string]string{"error": "internal error"})
		return
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"token": map[string]interface{}{
			"access_token": accessToken,
			"expires_at":   time.Now().Add(accessTokenTTL).Unix(),
		},
	})
}

// GET /auth/me  (Authorization: Bearer <access_token>)
func (h *authHandler) handleMe(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		writeJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	claims, err := extractBearerClaims(r)
	if err != nil {
		writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "unauthorized"})
		return
	}

	var email, name, role string
	err = h.pool.QueryRow(r.Context(),
		"SELECT email, name, role FROM users WHERE id = $1 AND is_active = true",
		claims.UserID,
	).Scan(&email, &name, &role)
	if err != nil {
		writeJSON(w, http.StatusNotFound, map[string]string{"error": "user not found"})
		return
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"id":        strings.TrimSpace(claims.UserID),
		"tenant_id": strings.TrimSpace(claims.TenantID),
		"name":      name,
		"email":     email,
		"role":      role,
	})
}

// POST /auth/logout  (Authorization: Bearer <access_token>)
func (h *authHandler) handleLogout(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	claims, err := extractBearerClaims(r)
	if err != nil {
		writeJSON(w, http.StatusOK, map[string]string{"status": "logged_out"})
		return
	}

	_, _ = h.pool.Exec(r.Context(),
		"UPDATE sessions SET is_revoked = true WHERE user_id = $1 AND is_revoked = false",
		claims.UserID,
	)

	writeJSON(w, http.StatusOK, map[string]string{"status": "logged_out"})
}

func (h *authHandler) issueAccessToken(userID, tenantID, role string) (string, error) {
	now := time.Now()
	claims := &authz.CustomClaims{
		UserID:   userID,
		TenantID: tenantID,
		Role:     role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(now.Add(accessTokenTTL)),
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now),
		},
	}
	return authz.SignJWT(claims)
}

func (h *authHandler) createSession(ctx context.Context, userID, ipAddr, userAgent string) (string, error) {
	sessionID := generateULID()
	refreshToken := generateRefreshToken()
	expiresAt := time.Now().Add(refreshTokenTTL)

	_, err := h.pool.Exec(ctx,
		"INSERT INTO sessions (id, user_id, refresh_token, ip_address, user_agent, expires_at) VALUES ($1, $2, $3, $4, $5, $6)",
		sessionID, userID, refreshToken, ipAddr, userAgent, expiresAt,
	)
	if err != nil {
		return "", err
	}
	return refreshToken, nil
}

func extractBearerClaims(r *http.Request) (*authz.CustomClaims, error) {
	auth := r.Header.Get("Authorization")
	if !strings.HasPrefix(auth, "Bearer ") {
		return nil, authz.ErrJWTNotConfigured
	}
	return authz.ParseJWT(strings.TrimPrefix(auth, "Bearer "))
}

func generateULID() string {
	b := make([]byte, 13)
	_, _ = rand.Read(b)
	return hex.EncodeToString(b)[:26]
}

func generateRefreshToken() string {
	b := make([]byte, 32)
	_, _ = rand.Read(b)
	return hex.EncodeToString(b)
}

func writeJSON(w http.ResponseWriter, status int, v interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func envOr(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
