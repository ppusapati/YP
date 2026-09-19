package registry

import (
	"context"
	"sync"
	"testing"
	"time"

	"p9e.in/samavaya/packages/p9log"
)

// MockBackend is a mock implementation of RegistryBackend for testing
type MockBackend struct {
	instances map[string]*ServiceInstance
	mu        sync.RWMutex
	closed    bool
}

// NewMockBackend creates a new mock backend
func NewMockBackend() *MockBackend {
	return &MockBackend{
		instances: make(map[string]*ServiceInstance),
	}
}

func (m *MockBackend) Register(ctx context.Context, instance *ServiceInstance) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.instances[instance.ID] = instance
	return nil
}

func (m *MockBackend) Deregister(ctx context.Context, instanceID string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	delete(m.instances, instanceID)
	return nil
}

func (m *MockBackend) GetInstance(ctx context.Context, instanceID string) (*ServiceInstance, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	if inst, ok := m.instances[instanceID]; ok {
		return inst, nil
	}
	return nil, nil
}

func (m *MockBackend) GetInstances(ctx context.Context, serviceName string) ([]*ServiceInstance, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	var result []*ServiceInstance
	for _, inst := range m.instances {
		if inst.ServiceName == serviceName && inst.Health == HealthUp {
			result = append(result, inst)
		}
	}
	return result, nil
}

func (m *MockBackend) GetInstancesByHealth(ctx context.Context, serviceName string, health HealthStatus) ([]*ServiceInstance, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	var result []*ServiceInstance
	for _, inst := range m.instances {
		if inst.ServiceName == serviceName && inst.Health == health {
			result = append(result, inst)
		}
	}
	return result, nil
}

func (m *MockBackend) GetAllInstances(ctx context.Context) ([]*ServiceInstance, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	var result []*ServiceInstance
	for _, inst := range m.instances {
		result = append(result, inst)
	}
	return result, nil
}

func (m *MockBackend) UpdateHealth(ctx context.Context, instanceID string, health HealthStatus) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if inst, ok := m.instances[instanceID]; ok {
		inst.Health = health
	}
	return nil
}

func (m *MockBackend) UpdateMetadata(ctx context.Context, instanceID string, metadata map[string]string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if inst, ok := m.instances[instanceID]; ok {
		inst.Metadata = metadata
	}
	return nil
}

func (m *MockBackend) Heartbeat(ctx context.Context, instanceID string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if inst, ok := m.instances[instanceID]; ok {
		inst.LastHeartbeat = time.Now()
	}
	return nil
}

func (m *MockBackend) CleanupStale(ctx context.Context, ttl time.Duration) (int, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	cutoff := time.Now().Add(-ttl)
	count := 0
	for id, inst := range m.instances {
		if inst.LastHeartbeat.Before(cutoff) {
			delete(m.instances, id)
			count++
		}
	}
	return count, nil
}

func (m *MockBackend) Close() error {
	m.closed = true
	return nil
}

// Tests

func TestRegister(t *testing.T) {
	backend := NewMockBackend()
	logger := &testLogger{}
	reg := New(backend, logger, WithAutoCleanup(false))
	defer reg.Close()

	instance := &ServiceInstance{
		ID:          "test-1",
		ServiceName: "test-service",
		Host:        "localhost",
		Port:        5001,
	}

	err := reg.Register(context.Background(), instance)
	if err != nil {
		t.Fatalf("Register failed: %v", err)
	}

	retrieved, err := reg.GetInstance(context.Background(), "test-1")
	if err != nil {
		t.Fatalf("GetInstance failed: %v", err)
	}
	if retrieved == nil {
		t.Fatal("Instance not found")
	}
	if retrieved.ServiceName != "test-service" {
		t.Errorf("Expected service name 'test-service', got '%s'", retrieved.ServiceName)
	}
}

func TestDeregister(t *testing.T) {
	backend := NewMockBackend()
	logger := &testLogger{}
	reg := New(backend, logger, WithAutoCleanup(false))
	defer reg.Close()

	instance := &ServiceInstance{
		ID:          "test-1",
		ServiceName: "test-service",
		Host:        "localhost",
		Port:        5001,
	}

	reg.Register(context.Background(), instance)

	err := reg.Deregister(context.Background(), "test-1")
	if err != nil {
		t.Fatalf("Deregister failed: %v", err)
	}

	retrieved, _ := reg.GetInstance(context.Background(), "test-1")
	if retrieved != nil {
		t.Fatal("Instance should be deregistered")
	}
}

func TestGetInstances(t *testing.T) {
	backend := NewMockBackend()
	logger := &testLogger{}
	reg := New(backend, logger, WithAutoCleanup(false))
	defer reg.Close()

	// Register multiple instances
	for i := 1; i <= 3; i++ {
		instance := &ServiceInstance{
			ID:          "test-" + string(rune(i)),
			ServiceName: "test-service",
			Host:        "localhost",
			Port:        5000 + i,
		}
		reg.Register(context.Background(), instance)
	}

	instances, err := reg.GetInstances(context.Background(), "test-service")
	if err != nil {
		t.Fatalf("GetInstances failed: %v", err)
	}
	if len(instances) != 3 {
		t.Errorf("Expected 3 instances, got %d", len(instances))
	}
}

func TestUpdateHealth(t *testing.T) {
	backend := NewMockBackend()
	logger := &testLogger{}
	reg := New(backend, logger, WithAutoCleanup(false))
	defer reg.Close()

	instance := &ServiceInstance{
		ID:          "test-1",
		ServiceName: "test-service",
		Host:        "localhost",
		Port:        5001,
		Health:      HealthUp,
	}

	reg.Register(context.Background(), instance)

	err := reg.UpdateHealth(context.Background(), "test-1", HealthDown)
	if err != nil {
		t.Fatalf("UpdateHealth failed: %v", err)
	}

	retrieved, _ := reg.GetInstance(context.Background(), "test-1")
	if retrieved.Health != HealthDown {
		t.Errorf("Expected health 'DOWN', got '%s'", retrieved.Health)
	}
}

func TestWatch(t *testing.T) {
	backend := NewMockBackend()
	logger := &testLogger{}
	reg := New(backend, logger, WithAutoCleanup(false))
	defer reg.Close()

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	events, err := reg.Watch(ctx, "test-service")
	if err != nil {
		t.Fatalf("Watch failed: %v", err)
	}

	// Register an instance in a goroutine
	go func() {
		time.Sleep(100 * time.Millisecond)
		instance := &ServiceInstance{
			ID:          "test-1",
			ServiceName: "test-service",
			Host:        "localhost",
			Port:        5001,
		}
		reg.Register(context.Background(), instance)
	}()

	// Wait for event
	select {
	case event := <-events:
		if event.Type != "registered" {
			t.Errorf("Expected 'registered' event, got '%s'", event.Type)
		}
	case <-time.After(5 * time.Second):
		t.Fatal("Timeout waiting for event")
	}
}

// Cancelling a watcher while the registry shuts down must not close the same
// channel twice.
//
// Watch used to unregister the channel and close it as two steps, with the
// lock released in between, while Close closed every channel still in the map.
// Interleaved, both closed the same channel and the process died with "close of
// closed channel" — not an error a caller can recover from, and it happened on
// the one path every service takes: shutdown.
//
// The failure was timing-dependent, about two runs in five, and the package's
// tests never ran in CI because `go test ./packages/...` from the repository
// root matches nothing. So the crash was live, intermittent, and invisible.
func TestWatcherCloseRacesShutdown(t *testing.T) {
	for i := 0; i < 200; i++ {
		backend := NewMockBackend()
		reg := New(backend, &testLogger{}, WithAutoCleanup(false))

		ctx, cancel := context.WithCancel(context.Background())
		ch, err := reg.Watch(ctx, "test-service")
		if err != nil {
			cancel()
			t.Fatalf("Watch: %v", err)
		}

		// Cancel and Close from two goroutines started together, so their
		// order is genuinely undecided rather than fixed by the test.
		var wg sync.WaitGroup
		start := make(chan struct{})
		wg.Add(2)
		go func() {
			defer wg.Done()
			<-start
			cancel()
		}()
		go func() {
			defer wg.Done()
			<-start
			_ = reg.Close()
		}()
		close(start)
		wg.Wait()

		// Whichever path won, the channel is closed exactly once and draining
		// it terminates.
		deadline := time.After(2 * time.Second)
		for {
			select {
			case _, ok := <-ch:
				if !ok {
					goto next
				}
			case <-deadline:
				t.Fatal("watcher channel was never closed")
			}
		}
	next:
	}
}

func TestHeartbeat(t *testing.T) {
	backend := NewMockBackend()
	logger := &testLogger{}
	reg := New(backend, logger, WithAutoCleanup(false))
	defer reg.Close()

	instance := &ServiceInstance{
		ID:          "test-1",
		ServiceName: "test-service",
		Host:        "localhost",
		Port:        5001,
	}

	reg.Register(context.Background(), instance)

	oldTime := time.Now().Add(-10 * time.Second)
	backend.mu.Lock()
	backend.instances["test-1"].LastHeartbeat = oldTime
	backend.mu.Unlock()

	err := reg.Heartbeat(context.Background(), "test-1")
	if err != nil {
		t.Fatalf("Heartbeat failed: %v", err)
	}

	retrieved, _ := reg.GetInstance(context.Background(), "test-1")
	if retrieved.LastHeartbeat.Before(oldTime.Add(5 * time.Second)) {
		t.Error("LastHeartbeat not updated")
	}
}

// Mock logger for testing
type testLogger struct{}

func (l *testLogger) Log(level p9log.Level, keyvals ...interface{}) error { return nil }
func (l *testLogger) Debug(keyvals ...interface{})                        {}
func (l *testLogger) Info(keyvals ...interface{})                         {}
func (l *testLogger) Warn(keyvals ...interface{})                         {}
func (l *testLogger) Error(keyvals ...interface{})                        {}
