package providers

import (
	"fmt"

	"p9e.in/samavaya/agriculture/weather-service/internal/domain"
	"p9e.in/samavaya/agriculture/weather-service/internal/ports/outbound"
)

// Registry resolves a provider for a field location, falling back to a default.
type Registry struct {
	providers map[domain.Provider]outbound.WeatherProvider
	fallback  domain.Provider
}

// NewRegistry builds a registry; the first provider becomes the default.
func NewRegistry(ps ...outbound.WeatherProvider) *Registry {
	r := &Registry{providers: make(map[domain.Provider]outbound.WeatherProvider)}
	for _, p := range ps {
		if p == nil {
			continue
		}
		if r.fallback == "" {
			r.fallback = p.Name()
		}
		r.providers[p.Name()] = p
	}
	return r
}

// For returns the provider configured on the location or the default.
func (r *Registry) For(loc domain.FieldLocation) (outbound.WeatherProvider, error) {
	if loc.Provider != domain.ProviderUnspecified {
		if p, ok := r.providers[loc.Provider]; ok {
			return p, nil
		}
	}
	if p, ok := r.providers[r.fallback]; ok {
		return p, nil
	}
	return nil, fmt.Errorf("no weather provider configured")
}

// Default returns the fallback provider name.
func (r *Registry) Default() domain.Provider { return r.fallback }
