package pipeline

import (
	"context"
	"errors"
	"sync/atomic"
	"testing"
	"time"

	"p9e.in/samavaya/packages/p9log"
)

// stubJob is a controllable ETLJob for testing.
type stubJob struct {
	name        string
	schedule    string
	extractFn   func(ctx context.Context) ([]RawRecord, error)
	transformFn func(ctx context.Context, records []RawRecord) ([]TransformedRecord, error)
	loadFn      func(ctx context.Context, records []TransformedRecord) error
}

func (s *stubJob) Name() string     { return s.name }
func (s *stubJob) Schedule() string { return s.schedule }

func (s *stubJob) Extract(ctx context.Context) ([]RawRecord, error) {
	if s.extractFn != nil {
		return s.extractFn(ctx)
	}
	return []RawRecord{{TenantID: "t1", FieldID: "f1", Data: map[string]interface{}{"v": 1}}}, nil
}

func (s *stubJob) Transform(ctx context.Context, records []RawRecord) ([]TransformedRecord, error) {
	if s.transformFn != nil {
		return s.transformFn(ctx, records)
	}
	out := make([]TransformedRecord, len(records))
	for i, r := range records {
		out[i] = TransformedRecord{TenantID: r.TenantID, FieldID: r.FieldID, Table: "test", Values: r.Data}
	}
	return out, nil
}

func (s *stubJob) Load(ctx context.Context, records []TransformedRecord) error {
	if s.loadFn != nil {
		return s.loadFn(ctx, records)
	}
	return nil
}

func newTestRunner() *ETLRunner {
	return NewETLRunner(p9log.DefaultLogger, RetryConfig{
		MaxRetries:     2,
		InitialBackoff: 1 * time.Millisecond,
		MaxBackoff:     10 * time.Millisecond,
		BackoffFactor:  2.0,
	})
}

func TestETLRunner_RegisterAndExecute(t *testing.T) {
	runner := newTestRunner()
	job := &stubJob{name: "test-job", schedule: "1h"}

	if err := runner.RegisterJob(job); err != nil {
		t.Fatalf("RegisterJob failed: %v", err)
	}

	// Duplicate registration should fail.
	if err := runner.RegisterJob(job); err == nil {
		t.Fatal("expected error for duplicate registration")
	}

	ctx := context.Background()
	result, err := runner.ExecuteJob(ctx, "test-job")
	if err != nil {
		t.Fatalf("ExecuteJob failed: %v", err)
	}
	if !result.Success {
		t.Fatalf("expected success, got errors: %v", result.Errors)
	}
	if result.RowsExtracted != 1 {
		t.Errorf("expected 1 row extracted, got %d", result.RowsExtracted)
	}
	if result.RowsLoaded != 1 {
		t.Errorf("expected 1 row loaded, got %d", result.RowsLoaded)
	}
	if result.Duration <= 0 {
		t.Error("expected positive duration")
	}
}

func TestETLRunner_ExecuteJob_NotFound(t *testing.T) {
	runner := newTestRunner()
	_, err := runner.ExecuteJob(context.Background(), "nonexistent")
	if err == nil {
		t.Fatal("expected error for missing job")
	}
}

func TestETLRunner_RetryOnExtractFailure(t *testing.T) {
	runner := newTestRunner()
	var attempts atomic.Int32

	job := &stubJob{
		name:     "flaky-extract",
		schedule: "1h",
		extractFn: func(ctx context.Context) ([]RawRecord, error) {
			n := attempts.Add(1)
			if n < 3 {
				return nil, errors.New("transient error")
			}
			return []RawRecord{{TenantID: "t1"}}, nil
		},
	}

	if err := runner.RegisterJob(job); err != nil {
		t.Fatalf("RegisterJob: %v", err)
	}

	result, err := runner.ExecuteJob(context.Background(), "flaky-extract")
	if err != nil {
		t.Fatalf("ExecuteJob: %v", err)
	}
	if !result.Success {
		t.Fatalf("expected success after retries, errors: %v", result.Errors)
	}
	if int(attempts.Load()) != 3 {
		t.Errorf("expected 3 attempts, got %d", attempts.Load())
	}
}

func TestETLRunner_RetryExhausted(t *testing.T) {
	runner := newTestRunner()

	job := &stubJob{
		name:     "always-fail",
		schedule: "1h",
		extractFn: func(ctx context.Context) ([]RawRecord, error) {
			return nil, errors.New("permanent error")
		},
	}

	if err := runner.RegisterJob(job); err != nil {
		t.Fatalf("RegisterJob: %v", err)
	}

	result, err := runner.ExecuteJob(context.Background(), "always-fail")
	if err != nil {
		t.Fatalf("ExecuteJob: %v", err)
	}
	if result.Success {
		t.Fatal("expected failure when retries exhausted")
	}
	if len(result.Errors) == 0 {
		t.Fatal("expected errors to be recorded")
	}
}

func TestETLRunner_ContextCancellation(t *testing.T) {
	runner := newTestRunner()

	job := &stubJob{
		name:     "slow-job",
		schedule: "1h",
		extractFn: func(ctx context.Context) ([]RawRecord, error) {
			select {
			case <-ctx.Done():
				return nil, ctx.Err()
			case <-time.After(5 * time.Second):
				return []RawRecord{}, nil
			}
		},
	}

	if err := runner.RegisterJob(job); err != nil {
		t.Fatalf("RegisterJob: %v", err)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 50*time.Millisecond)
	defer cancel()

	result, err := runner.ExecuteJob(ctx, "slow-job")
	if err != nil {
		t.Fatalf("ExecuteJob: %v", err)
	}
	if result.Success {
		t.Fatal("expected failure due to context cancellation")
	}
}

func TestETLRunner_TransformFailure(t *testing.T) {
	runner := newTestRunner()

	job := &stubJob{
		name:     "transform-fail",
		schedule: "1h",
		transformFn: func(ctx context.Context, records []RawRecord) ([]TransformedRecord, error) {
			return nil, errors.New("transform error")
		},
	}

	if err := runner.RegisterJob(job); err != nil {
		t.Fatalf("RegisterJob: %v", err)
	}

	result, _ := runner.ExecuteJob(context.Background(), "transform-fail")
	if result.Success {
		t.Fatal("expected failure on transform error")
	}
}

func TestETLRunner_LoadFailure(t *testing.T) {
	runner := newTestRunner()

	job := &stubJob{
		name:     "load-fail",
		schedule: "1h",
		loadFn: func(ctx context.Context, records []TransformedRecord) error {
			return errors.New("load error")
		},
	}

	if err := runner.RegisterJob(job); err != nil {
		t.Fatalf("RegisterJob: %v", err)
	}

	result, _ := runner.ExecuteJob(context.Background(), "load-fail")
	if result.Success {
		t.Fatal("expected failure on load error")
	}
}

func TestETLRunner_InvalidSchedule(t *testing.T) {
	runner := newTestRunner()
	job := &stubJob{name: "bad-schedule", schedule: "not-a-duration"}

	err := runner.RegisterJob(job)
	if err == nil {
		t.Fatal("expected error for invalid schedule")
	}
}

func TestETLRunner_StartStop(t *testing.T) {
	runner := newTestRunner()
	var runs atomic.Int32

	job := &stubJob{
		name:     "periodic",
		schedule: "10ms",
		extractFn: func(ctx context.Context) ([]RawRecord, error) {
			runs.Add(1)
			return []RawRecord{}, nil
		},
	}

	if err := runner.RegisterJob(job); err != nil {
		t.Fatalf("RegisterJob: %v", err)
	}

	go func() {
		time.Sleep(60 * time.Millisecond)
		runner.Stop()
	}()

	runner.Start(context.Background())

	if runs.Load() < 2 {
		t.Errorf("expected at least 2 runs, got %d", runs.Load())
	}
}

func TestComputeBackoff(t *testing.T) {
	cfg := RetryConfig{
		InitialBackoff: 100 * time.Millisecond,
		MaxBackoff:     5 * time.Second,
		BackoffFactor:  2.0,
	}

	b0 := ComputeBackoff(0, cfg)
	if b0 != 100*time.Millisecond {
		t.Errorf("attempt 0: expected 100ms, got %v", b0)
	}

	b1 := ComputeBackoff(1, cfg)
	if b1 != 200*time.Millisecond {
		t.Errorf("attempt 1: expected 200ms, got %v", b1)
	}

	// Should be capped at MaxBackoff.
	b10 := ComputeBackoff(10, cfg)
	if b10 != 5*time.Second {
		t.Errorf("attempt 10: expected 5s cap, got %v", b10)
	}
}

func TestJobResult_Fields(t *testing.T) {
	result := &JobResult{
		JobName:       "test",
		StartedAt:     time.Now(),
		RowsExtracted: 100,
		RowsLoaded:    95,
		Errors:        []error{errors.New("partial failure")},
		Success:       false,
	}

	if result.JobName != "test" {
		t.Errorf("unexpected job name: %s", result.JobName)
	}
	if result.RowsExtracted != 100 {
		t.Errorf("unexpected extracted count: %d", result.RowsExtracted)
	}
}
