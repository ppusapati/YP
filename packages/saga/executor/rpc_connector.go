// Package executor provides RPC communication for saga steps
package executor

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"sync"
	"time"
)

// RpcConnectorImpl implements RPC connector for service communication
type RpcConnectorImpl struct {
	mu              sync.RWMutex
	serviceRegistry map[string]string    // serviceName -> endpoint
	clientCache     map[string]interface{} // endpoint -> cached client
}

// NewRpcConnectorImpl creates a new RPC connector instance
func NewRpcConnectorImpl() *RpcConnectorImpl {
	return &RpcConnectorImpl{
		serviceRegistry: make(map[string]string),
		clientCache:     make(map[string]interface{}),
	}
}

// InvokeHandler invokes a handler on a remote service via RPC
func (r *RpcConnectorImpl) InvokeHandler(
	ctx context.Context,
	endpoint string,
	handlerMethod string,
	request interface{},
) (interface{}, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	// 1. Validate inputs
	if endpoint == "" {
		return nil, fmt.Errorf("endpoint cannot be empty")
	}
	if handlerMethod == "" {
		return nil, fmt.Errorf("handler method cannot be empty")
	}

	// 2. Get or create client for endpoint
	client, err := r.getOrCreateClient(endpoint)
	if err != nil {
		return nil, fmt.Errorf("failed to get client for endpoint %s: %w", endpoint, err)
	}

	// 3. Invoke RPC method via ConnectRPC
	// In real implementation, this would use the generated client
	response, err := invokeRPCMethod(ctx, client, handlerMethod, request)
	if err != nil {
		return nil, fmt.Errorf("RPC invocation failed: %w", err)
	}

	return response, nil
}

// GetServiceEndpoint resolves a service endpoint from registry
func (r *RpcConnectorImpl) GetServiceEndpoint(serviceName string) (string, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	// 1. Look up service in registry
	endpoint, exists := r.serviceRegistry[serviceName]
	if !exists {
		return "", fmt.Errorf("service %s not registered in endpoint registry", serviceName)
	}

	// 2. Return endpoint
	return endpoint, nil
}

// RegisterService registers a service endpoint
func (r *RpcConnectorImpl) RegisterService(serviceName string, endpoint string) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	// 1. Validate inputs
	if serviceName == "" {
		return fmt.Errorf("service name cannot be empty")
	}
	if endpoint == "" {
		return fmt.Errorf("endpoint cannot be empty")
	}

	// 2. Check if already registered
	if existing, exists := r.serviceRegistry[serviceName]; exists {
		if existing != endpoint {
			return fmt.Errorf("service %s already registered with different endpoint: %s", serviceName, existing)
		}
		return nil // Already registered with same endpoint
	}

	// 3. Register service
	r.serviceRegistry[serviceName] = endpoint

	return nil
}

// getOrCreateClient gets or creates a client for an endpoint
func (r *RpcConnectorImpl) getOrCreateClient(endpoint string) (interface{}, error) {
	// Check if client already cached
	if cachedClient, exists := r.clientCache[endpoint]; exists {
		return cachedClient, nil
	}

	// Create new HTTP/JSON-RPC client for the endpoint
	client := newRPCClient(endpoint)

	// Cache the client
	r.clientCache[endpoint] = client

	return client, nil
}

// rpcClient wraps an HTTP client for JSON-RPC communication to a service endpoint
type rpcClient struct {
	endpoint   string
	httpClient *http.Client
}

// newRPCClient creates a new RPC client for the given endpoint
func newRPCClient(endpoint string) *rpcClient {
	return &rpcClient{
		endpoint: endpoint,
		httpClient: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

// invokeRPCMethod invokes an RPC method on a client via HTTP/JSON
func invokeRPCMethod(
	ctx context.Context,
	client interface{},
	methodName string,
	request interface{},
) (interface{}, error) {
	rc, ok := client.(*rpcClient)
	if !ok {
		return nil, fmt.Errorf("invalid client type: expected *rpcClient")
	}

	// 1. Marshal the request to JSON
	reqBody, err := json.Marshal(request)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	// 2. Build the HTTP request URL: endpoint/methodName
	url := fmt.Sprintf("%s/%s", rc.endpoint, methodName)
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(reqBody))
	if err != nil {
		return nil, fmt.Errorf("failed to create HTTP request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")

	// 3. Make the HTTP call
	resp, err := rc.httpClient.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("HTTP request to %s failed: %w", url, err)
	}
	defer resp.Body.Close()

	// 4. Read and unmarshal the response
	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response body: %w", err)
	}

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, fmt.Errorf("RPC call to %s returned status %d: %s", url, resp.StatusCode, string(respBody))
	}

	var result map[string]interface{}
	if err := json.Unmarshal(respBody, &result); err != nil {
		return nil, fmt.Errorf("failed to unmarshal response: %w", err)
	}

	return result, nil
}

// GetRegisteredServices returns all registered services (for debugging/testing)
func (r *RpcConnectorImpl) GetRegisteredServices() map[string]string {
	r.mu.RLock()
	defer r.mu.RUnlock()

	result := make(map[string]string)
	for k, v := range r.serviceRegistry {
		result[k] = v
	}

	return result
}

// ClearCache clears the client cache (for testing)
func (r *RpcConnectorImpl) ClearCache() {
	r.mu.Lock()
	defer r.mu.Unlock()

	r.clientCache = make(map[string]interface{})
}
