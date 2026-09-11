package modulith

import (
	"context"
	"fmt"
	"net/http"
	"sync"

	"go.uber.org/zap"
)

// Registry holds all registered modules and orchestrates their lifecycle.
type Registry struct {
	modules     []Module
	initialized int
	logger      *zap.Logger
	mu          sync.RWMutex
}

func NewRegistry(logger *zap.Logger) *Registry {
	return &Registry{logger: logger}
}

func (r *Registry) Register(m Module) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.modules = append(r.modules, m)
	r.logger.Info("module registered", zap.String("module", m.Name()))
}

// InitAll calls Init on every module in registration order.
// On failure, it closes already-initialized modules in reverse order.
func (r *Registry) InitAll(ctx context.Context, deps ModuleDeps) error {
	r.mu.RLock()
	defer r.mu.RUnlock()

	for i, m := range r.modules {
		r.logger.Info("initializing module", zap.String("module", m.Name()))
		if err := m.Init(ctx, deps); err != nil {
			r.closeUpTo(i)
			return fmt.Errorf("module %s init: %w", m.Name(), err)
		}
		r.initialized = i + 1
		if em, ok := m.(EventAwareModule); ok {
			em.RegisterEventHandlers(deps.EventBus)
		}
	}
	return nil
}

func (r *Registry) closeUpTo(n int) {
	for i := n - 1; i >= 0; i-- {
		m := r.modules[i]
		r.logger.Info("closing module (rollback)", zap.String("module", m.Name()))
		if err := m.Close(); err != nil {
			r.logger.Warn("module close error",
				zap.String("module", m.Name()), zap.Error(err))
		}
	}
}

// MountAll registers every module's ConnectRPC handlers on the mux.
func (r *Registry) MountAll(mux *http.ServeMux) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	for _, m := range r.modules {
		for _, h := range m.Handlers() {
			r.logger.Info("mounting handler",
				zap.String("module", m.Name()),
				zap.String("path", h.Path))
			mux.Handle(h.Path, h.Handler)
		}
	}
}

// CloseAll calls Close on initialized modules in reverse order.
func (r *Registry) CloseAll() {
	r.mu.RLock()
	defer r.mu.RUnlock()

	r.closeUpTo(r.initialized)
	r.initialized = 0
}

// Modules returns the list of registered module names.
func (r *Registry) Modules() []string {
	r.mu.RLock()
	defer r.mu.RUnlock()
	names := make([]string, len(r.modules))
	for i, m := range r.modules {
		names[i] = m.Name()
	}
	return names
}
