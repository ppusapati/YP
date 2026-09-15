package modulith

import (
	"context"
	"net/http"

	"github.com/jackc/pgx/v5/pgxpool"
	"go.uber.org/zap"
)

// HandlerRegistration pairs a URL path prefix with an http.Handler,
// matching what ConnectRPC's generated New*ServiceHandler returns.
type HandlerRegistration struct {
	Path    string
	Handler http.Handler
}

// Module represents a self-contained domain module within the monolith.
// Each microservice becomes a Module when running as part of the monolith.
type Module interface {
	Name() string
	Init(ctx context.Context, deps ModuleDeps) error
	Handlers() []HandlerRegistration
	Close() error
}

// EventAwareModule is optionally implemented by modules that want to
// subscribe to in-process domain events.
type EventAwareModule interface {
	Module
	RegisterEventHandlers(bus *EventBus)
}

// ModuleDeps holds the shared infrastructure a module receives.
type ModuleDeps struct {
	Pool     *pgxpool.Pool
	Logger   *zap.Logger
	EventBus *EventBus
}
