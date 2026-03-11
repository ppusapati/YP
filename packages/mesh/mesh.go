package mesh

import (
	"context"
	"fmt"
	"math"
	"sync"
	"time"

	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/circuitbreaker"
	"p9e.in/samavaya/packages/loadbalancer"
	"p9e.in/samavaya/packages/registry"
)

// ServiceMesh provides service-to-service routing with policies, retries, and circuit breaking
type ServiceMesh struct {
	registry       registry.ServiceRegistry
	lb             loadbalancer.LoadBalancer
	breaker        *circuitbreaker.SimpleCircuitBreaker
	logger         p9log.Logger
	opts           Options
	policies       map[string]*RoutingPolicy
	policiesMu     sync.RWMutex
	policyCache    map[string]*RoutingPolicy
	policyCacheMu  sync.RWMutex

	stopChan chan struct{}
	wg       sync.WaitGroup
}

// New creates a new service mesh
func New(
	reg registry.ServiceRegistry,
	lb loadbalancer.LoadBalancer,
	breaker *circuitbreaker.SimpleCircuitBreaker,
	logger p9log.Logger,
	opts ...Option,
) *ServiceMesh {
	options := DefaultOptions()
	for _, opt := range opts {
		opt(&options)
	}

	m := &ServiceMesh{
		registry:    reg,
		lb:          lb,
		breaker:     breaker,
		logger:      logger,
		opts:        options,
		policies:    make(map[string]*RoutingPolicy),
		policyCache: make(map[string]*RoutingPolicy),
		stopChan:    make(chan struct{}),
	}

	return m
}

// Route selects an endpoint for the given service and applies all policies
func (m *ServiceMesh) Route(ctx context.Context, serviceName string) (*loadbalancer.Endpoint, error) {
	if serviceName == "" {
		return nil, fmt.Errorf("service name is required")
	}

	// Get routing policy
	policy, err := m.GetPolicy(ctx, serviceName)
	if err != nil {
		m.logger.Warn("failed to get policy, using default",
			"service_name", serviceName,
			"error", err,
		)
		policy = m.opts.DefaultPolicy
	}

	// Check circuit breaker
	circuitKey := "mesh:" + serviceName
	result, err := m.breaker.Check(ctx, circuitKey)
	if err != nil {
		return nil, fmt.Errorf("circuit breaker check failed: %w", err)
	}
	if !result.Allowed {
		m.logger.Warn("circuit breaker open",
			"service_name", serviceName,
			"reason", result.Reason,
		)
		return nil, fmt.Errorf("circuit breaker open: %s", result.Reason)
	}

	// Get instances from registry
	instances, err := m.registry.GetInstances(ctx, serviceName)
	if err != nil {
		m.breaker.RecordFailure(ctx, circuitKey)
		return nil, fmt.Errorf("failed to get service instances: %w", err)
	}
	if len(instances) == 0 {
		m.breaker.RecordFailure(ctx, circuitKey)
		return nil, fmt.Errorf("no instances available for service: %s", serviceName)
	}

	// Filter instances by policy constraints
	filtered := m.filterInstances(instances, policy)
	if len(filtered) == 0 {
		// Fallback to unfiltered if no instances match filters
		filtered = instances
	}

	// Select endpoint using load balancer
	endpoint, err := m.lb.Select(ctx, filtered)
	if err != nil {
		m.breaker.RecordFailure(ctx, circuitKey)
		return nil, fmt.Errorf("load balancer selection failed: %w", err)
	}

	return endpoint, nil
}

// RecordSuccess records a successful request
func (m *ServiceMesh) RecordSuccess(ctx context.Context, serviceName string, endpoint *loadbalancer.Endpoint, duration time.Duration) {
	// Update load balancer metrics
	m.lb.RecordMetrics(endpoint.Instance.ID, duration, true)

	// Update circuit breaker
	circuitKey := "mesh:" + serviceName
	m.breaker.RecordSuccess(ctx, circuitKey)

	m.logger.Debug("request successful",
		"service_name", serviceName,
		"instance_id", endpoint.Instance.ID,
		"duration_ms", duration.Milliseconds(),
	)
}

// RecordFailure records a failed request
func (m *ServiceMesh) RecordFailure(ctx context.Context, serviceName string, endpoint *loadbalancer.Endpoint, duration time.Duration) {
	// Update load balancer metrics
	m.lb.RecordMetrics(endpoint.Instance.ID, duration, false)

	// Update circuit breaker
	circuitKey := "mesh:" + serviceName
	m.breaker.RecordFailure(ctx, circuitKey)

	m.logger.Debug("request failed",
		"service_name", serviceName,
		"instance_id", endpoint.Instance.ID,
	)
}

// GetPolicy gets the routing policy for a service
func (m *ServiceMesh) GetPolicy(ctx context.Context, serviceName string) (*RoutingPolicy, error) {
	// Check cache first
	if m.opts.EnablePolicyCache {
		m.policyCacheMu.RLock()
		if policy, ok := m.policyCache[serviceName]; ok {
			m.policyCacheMu.RUnlock()
			return policy, nil
		}
		m.policyCacheMu.RUnlock()
	}

	// Get from policies map
	m.policiesMu.RLock()
	policy := m.policies[serviceName]
	m.policiesMu.RUnlock()

	// Use default if not found
	if policy == nil {
		policy = m.opts.DefaultPolicy
		if policy.ServiceName == "" {
			policy.ServiceName = serviceName
		}
	}

	// Cache it
	if m.opts.EnablePolicyCache {
		m.policyCacheMu.Lock()
		m.policyCache[serviceName] = policy
		m.policyCacheMu.Unlock()
	}

	return policy, nil
}

// SetPolicy sets the routing policy for a service
func (m *ServiceMesh) SetPolicy(ctx context.Context, policy *RoutingPolicy) error {
	if policy.ServiceName == "" {
		return fmt.Errorf("service name is required in policy")
	}

	m.policiesMu.Lock()
	m.policies[policy.ServiceName] = policy
	m.policiesMu.Unlock()

	// Invalidate cache
	m.policyCacheMu.Lock()
	delete(m.policyCache, policy.ServiceName)
	m.policyCacheMu.Unlock()

	m.logger.Info("policy updated",
		"service_name", policy.ServiceName,
		"algorithm", policy.LoadBalancingAlgorithm,
	)

	return nil
}

// Close closes the mesh and releases resources
func (m *ServiceMesh) Close() error {
	close(m.stopChan)
	m.wg.Wait()
	return nil
}

// Helper methods

// filterInstances filters instances based on policy constraints
func (m *ServiceMesh) filterInstances(instances []*registry.ServiceInstance, policy *RoutingPolicy) []*registry.ServiceInstance {
	var filtered []*registry.ServiceInstance

	for _, inst := range instances {
		// Check version constraint
		if policy.VersionConstraint != "" && inst.Version != policy.VersionConstraint {
			continue
		}

		// Check region preference
		if policy.Region != "" && inst.Region != policy.Region {
			continue
		}

		filtered = append(filtered, inst)
	}

	return filtered
}

// calculateBackoff calculates exponential backoff with jitter
func calculateBackoff(attempt int, policy RetryPolicy) time.Duration {
	// exponential backoff: initial * multiplier ^ (attempt - 1)
	backoff := float64(policy.InitialBackoff)
	for i := 0; i < attempt-1; i++ {
		backoff = backoff * policy.BackoffMultiplier
		if backoff > float64(policy.MaxBackoff) {
			backoff = float64(policy.MaxBackoff)
			break
		}
	}

	// Add jitter (random between 0 and backoff)
	jitter := time.Duration(math.Rand.Float64() * backoff)
	return time.Duration(backoff) + jitter
}

// isRetryable checks if an error should be retried
func isRetryable(errorCode string, policy RetryPolicy) bool {
	for _, retryableCode := range policy.RetryableErrors {
		if retryableCode == errorCode {
			return true
		}
	}
	return false
}
