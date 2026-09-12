package websocket

import (
	"fmt"
	"net/http"

	"p9e.in/samavaya/packages/authz"
	"p9e.in/samavaya/packages/p9log"

	"github.com/google/uuid"
	"golang.org/x/net/websocket"
)

// Authenticator extracts and validates a JWT token from a WebSocket upgrade
// request. The token may be in the Authorization header or the "token" query
// parameter (common for browser-based WebSocket clients that cannot set
// headers).
type Authenticator func(r *http.Request) (*authz.InjectedUserInfo, error)

// DefaultAuthenticator returns an Authenticator that validates tokens using
// the authz.ParseJWT function. It looks for the token in:
//  1. Authorization: Bearer <token> header
//  2. ?token=<jwt> query parameter
func DefaultAuthenticator() Authenticator {
	return func(r *http.Request) (*authz.InjectedUserInfo, error) {
		token := ""

		// Try Authorization header first.
		if auth := r.Header.Get("Authorization"); len(auth) > 7 && auth[:7] == "Bearer " {
			token = auth[7:]
		}

		// Fall back to query parameter (browsers cannot set headers on WS).
		if token == "" {
			token = r.URL.Query().Get("token")
		}

		if token == "" {
			return nil, fmt.Errorf("websocket: no authentication token provided")
		}

		claims, err := authz.ParseJWT(token)
		if err != nil {
			return nil, fmt.Errorf("websocket: invalid token: %w", err)
		}

		permissions := make([]authz.Permission, len(claims.Permissions))
		copy(permissions, claims.Permissions)

		return &authz.InjectedUserInfo{
			UserID:      claims.UserID,
			TenantID:    claims.TenantID,
			CompanyID:   claims.CompanyID,
			BranchID:    claims.BranchID,
			Role:        claims.Role,
			Permissions: permissions,
			SessionID:   claims.SessionID,
		}, nil
	}
}

// HandlerConfig configures the WebSocket HTTP upgrade handler.
type HandlerConfig struct {
	// Hub is the WebSocket hub that manages client connections.
	Hub *Hub
	// Auth authenticates the upgrade request and returns user info.
	Auth Authenticator
	// Log is the logger instance.
	Log p9log.Logger
	// AllowedOrigins restricts which origins may connect. An empty slice
	// allows all origins.
	AllowedOrigins []string
}

// NewHandler returns an http.Handler that upgrades connections to WebSocket
// and registers them with the hub.
func NewHandler(cfg HandlerConfig) http.Handler {
	log := p9log.NewHelper(p9log.With(cfg.Log, "module", "ws-handler"))

	wsServer := &websocket.Server{
		Handshake: func(wsConfig *websocket.Config, r *http.Request) error {
			// Origin check.
			if len(cfg.AllowedOrigins) > 0 {
				origin := r.Header.Get("Origin")
				allowed := false
				for _, o := range cfg.AllowedOrigins {
					if o == "*" || o == origin {
						allowed = true
						break
					}
				}
				if !allowed {
					return fmt.Errorf("websocket: origin %q not allowed", origin)
				}
			}
			return nil
		},
		Handler: func(conn *websocket.Conn) {
			// Authenticate the request.
			r := conn.Request()
			userInfo, err := cfg.Auth(r)
			if err != nil {
				log.Warnf("authentication failed: %v", err)
				errMsg := NewErrorMessage("authentication failed")
				data, _ := errMsg.Encode()
				_, _ = conn.Write(data)
				conn.Close()
				return
			}

			clientID := uuid.New().String()
			client := NewClient(clientID, userInfo.UserID, userInfo.TenantID, cfg.Hub, conn, cfg.Log)

			cfg.Hub.Register(client)

			// Start the read and write pumps.
			go client.WritePump()
			client.ReadPump() // blocks until the connection closes
		},
	}

	return wsServer
}

// UpgradeHandler is a convenience wrapper that creates an HTTP handler function
// for WebSocket upgrades.
func UpgradeHandler(hub *Hub, auth Authenticator, log p9log.Logger) http.HandlerFunc {
	handler := NewHandler(HandlerConfig{
		Hub:  hub,
		Auth: auth,
		Log:  log,
	})
	return func(w http.ResponseWriter, r *http.Request) {
		handler.ServeHTTP(w, r)
	}
}
