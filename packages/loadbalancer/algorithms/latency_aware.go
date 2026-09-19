package algorithms

import (
	"context"
	"fmt"
	"sync"
	"time"

	"p9e.in/samavaya/packages/loadbalancer"
	"p9e.in/samavaya/packages/quantile"
	"p9e.in/samavaya/packages/registry"
)

// LatencyAwareBalancer selects endpoints based on lowest latency
// Uses exponential weighted moving average for smooth latency tracking
type LatencyAwareBalancer struct {
	metrics map[string]*loadbalancer.EndpointMetrics
	conns   map[string]int64

	// samples holds the recent latencies each endpoint's percentiles are
	// computed from, keyed by instance ID.
	//
	// There were none. The percentiles were derived arithmetically from the
	// mean and the maximum, which is why they were not percentiles.
	samples map[string]*quantile.Window

	mu sync.RWMutex

	// Alpha for EWMA calculation (0.0-1.0, default 0.3)
	// Higher value gives more weight to recent measurements
	alpha float64

	// sampleSize is how many recent latencies each endpoint keeps.
	sampleSize int
}

// NewLatencyAwareBalancer creates a new latency-aware load balancer
func NewLatencyAwareBalancer() *LatencyAwareBalancer {
	return NewLatencyAwareBalancerWithSamples(loadbalancer.DefaultOptions().MaxLatencySamples)
}

// NewLatencyAwareBalancerWithSamples creates a balancer keeping sampleSize
// recent latencies per endpoint.
//
// `MaxLatencySamples` has been in loadbalancer.Options since the beginning,
// with a `WithMaxLatencySamples` setter beside it, and nothing ever read
// either: the percentiles were computed from the mean and the maximum, so
// there was no sample set for the option to size. This is the constructor that
// makes it mean something.
func NewLatencyAwareBalancerWithSamples(sampleSize int) *LatencyAwareBalancer {
	if sampleSize <= 0 {
		sampleSize = quantile.DefaultSize
	}
	return &LatencyAwareBalancer{
		metrics:    make(map[string]*loadbalancer.EndpointMetrics),
		conns:      make(map[string]int64),
		samples:    make(map[string]*quantile.Window),
		alpha:      0.3, // Default EWMA alpha
		sampleSize: sampleSize,
	}
}

// Select returns the endpoint with the lowest average latency
func (lab *LatencyAwareBalancer) Select(ctx context.Context, endpoints []*registry.ServiceInstance) (*loadbalancer.Endpoint, error) {
	if len(endpoints) == 0 {
		return nil, fmt.Errorf("no endpoints available")
	}

	lab.mu.RLock()
	defer lab.mu.RUnlock()

	var selected *loadbalancer.Endpoint
	minLatency := time.Duration(^uint64(0) >> 1) // Max duration

	for _, ep := range endpoints {
		metrics := lab.getOrCreateMetricsLocked(ep.ID)

		// Use average latency, fallback to max latency if no data
		latency := metrics.AvgLatency
		if latency == 0 {
			latency = metrics.MaxLatency
		}

		// If still no data, treat as fast
		if latency == 0 {
			latency = 1 * time.Millisecond
		}

		if latency < minLatency {
			minLatency = latency
			selected = &loadbalancer.Endpoint{
				Instance:          ep,
				Weight:            100,
				ActiveConnections: lab.conns[ep.ID],
				Metrics:           metrics,
			}
		}
	}

	if selected == nil && len(endpoints) > 0 {
		selected = &loadbalancer.Endpoint{
			Instance:          endpoints[0],
			Weight:            100,
			ActiveConnections: lab.conns[endpoints[0].ID],
			Metrics:           lab.getOrCreateMetricsLocked(endpoints[0].ID),
		}
	}

	return selected, nil
}

// RecordMetrics records metrics for an endpoint using EWMA
func (lab *LatencyAwareBalancer) RecordMetrics(instanceID string, latency time.Duration, success bool) {
	lab.mu.Lock()
	defer lab.mu.Unlock()

	metrics := lab.getOrCreateMetricsLocked(instanceID)

	metrics.TotalRequests++
	if success {
		metrics.SuccessCount++
	} else {
		metrics.FailureCount++
	}

	// Update min/max latency
	if latency < metrics.MinLatency || metrics.MinLatency == 0 {
		metrics.MinLatency = latency
	}
	if latency > metrics.MaxLatency {
		metrics.MaxLatency = latency
	}

	// Update exponential weighted moving average
	if metrics.AvgLatency == 0 {
		metrics.AvgLatency = latency
	} else {
		// EWMA = alpha * current + (1 - alpha) * previous
		ewma := float64(metrics.AvgLatency) * (1 - lab.alpha)
		ewma += float64(latency) * lab.alpha
		metrics.AvgLatency = time.Duration(ewma)
	}

	// Percentiles from the samples, not from the mean and the maximum.
	//
	// This read:
	//
	//	P50 = AvgLatency
	//	P95 = MaxLatency * 0.95
	//	P99 = MaxLatency * 0.99
	//
	// None of those is a percentile. A latency distribution is right-skewed, so
	// its mean sits above its median — which is the reason anyone asks for a
	// median rather than a mean in the first place. And multiplying the maximum
	// by a constant is an affine transform of one sample: p95 and p99 moved only
	// when the maximum moved, they stayed in fixed proportion to each other, and
	// since MaxLatency above only ever rises, a single slow call at startup
	// pinned both high for the life of the process. Select() routes on these.
	window := lab.samplesLocked(instanceID)
	window.Add(latency.Nanoseconds())
	metrics.P50Latency = time.Duration(window.Quantile(0.50))
	metrics.P95Latency = time.Duration(window.Quantile(0.95))
	metrics.P99Latency = time.Duration(window.Quantile(0.99))

	if metrics.TotalRequests > 0 {
		metrics.ErrorRate = float64(metrics.FailureCount) / float64(metrics.TotalRequests)
	}

	metrics.LastUpdate = time.Now()
}

// IncrementConnections increments the active connection count
func (lab *LatencyAwareBalancer) IncrementConnections(instanceID string) {
	lab.mu.Lock()
	defer lab.mu.Unlock()
	lab.conns[instanceID]++
}

// DecrementConnections decrements the active connection count
func (lab *LatencyAwareBalancer) DecrementConnections(instanceID string) {
	lab.mu.Lock()
	defer lab.mu.Unlock()
	if count, ok := lab.conns[instanceID]; ok && count > 0 {
		lab.conns[instanceID]--
	}
}

// Reset clears internal state
func (lab *LatencyAwareBalancer) Reset() {
	lab.mu.Lock()
	defer lab.mu.Unlock()

	lab.metrics = make(map[string]*loadbalancer.EndpointMetrics)
	lab.conns = make(map[string]int64)
	// The sample windows too. A reset that left them would carry the
	// percentiles that prompted the reset into the state after it.
	lab.samples = make(map[string]*quantile.Window)
}

// GetMetrics returns metrics for an endpoint
func (lab *LatencyAwareBalancer) GetMetrics(instanceID string) *loadbalancer.EndpointMetrics {
	lab.mu.RLock()
	defer lab.mu.RUnlock()
	return lab.metrics[instanceID]
}

// SetAlpha sets the EWMA alpha value (0.0-1.0)
func (lab *LatencyAwareBalancer) SetAlpha(alpha float64) {
	if alpha < 0.0 {
		alpha = 0.0
	}
	if alpha > 1.0 {
		alpha = 1.0
	}

	lab.mu.Lock()
	defer lab.mu.Unlock()
	lab.alpha = alpha
}

// Helper methods

func (lab *LatencyAwareBalancer) getOrCreateMetricsLocked(instanceID string) *loadbalancer.EndpointMetrics {
	if metrics, ok := lab.metrics[instanceID]; ok {
		return metrics
	}

	metrics := &loadbalancer.EndpointMetrics{
		LastUpdate: time.Now(),
	}
	lab.metrics[instanceID] = metrics
	return metrics
}

// samplesLocked returns the endpoint's latency window, creating it on first
// use. Callers hold lab.mu.
func (lab *LatencyAwareBalancer) samplesLocked(instanceID string) *quantile.Window {
	if w, ok := lab.samples[instanceID]; ok {
		return w
	}
	w := quantile.New(lab.sampleSize)
	lab.samples[instanceID] = w
	return w
}
