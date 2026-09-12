package pipeline

import (
	"context"
	"fmt"
	"math"
	"sync"
	"time"

	"p9e.in/samavaya/packages/p9log"
)

// ETLJob defines the interface for Extract-Transform-Load jobs.
type ETLJob interface {
	// Name returns a unique identifier for the job.
	Name() string
	// Schedule returns a cron expression for when the job should run.
	Schedule() string
	// Extract pulls raw data from source systems.
	Extract(ctx context.Context) ([]RawRecord, error)
	// Transform applies business logic and converts raw records.
	Transform(ctx context.Context, records []RawRecord) ([]TransformedRecord, error)
	// Load writes transformed records to the destination store.
	Load(ctx context.Context, records []TransformedRecord) error
}

// RawRecord represents an unprocessed data record from a source system.
type RawRecord struct {
	TenantID  string
	FieldID   string
	Timestamp time.Time
	Data      map[string]interface{}
}

// TransformedRecord represents a processed record ready for loading.
type TransformedRecord struct {
	TenantID  string
	FieldID   string
	Timestamp time.Time
	Table     string
	Values    map[string]interface{}
}

// JobResult captures the outcome of an ETL job execution.
type JobResult struct {
	JobName       string
	StartedAt     time.Time
	CompletedAt   time.Time
	Duration      time.Duration
	RowsExtracted int
	RowsLoaded    int
	Errors        []error
	Success       bool
}

// RetryConfig controls exponential backoff behavior for ETL jobs.
type RetryConfig struct {
	MaxRetries     int
	InitialBackoff time.Duration
	MaxBackoff     time.Duration
	BackoffFactor  float64
}

// DefaultRetryConfig returns sensible retry defaults.
func DefaultRetryConfig() RetryConfig {
	return RetryConfig{
		MaxRetries:     3,
		InitialBackoff: 500 * time.Millisecond,
		MaxBackoff:     30 * time.Second,
		BackoffFactor:  2.0,
	}
}

// ETLRunner manages scheduling and execution of ETL jobs.
type ETLRunner struct {
	mu      sync.Mutex
	jobs    map[string]registeredJob
	log     p9log.Logger
	retry   RetryConfig
	running bool
	cancel  context.CancelFunc
}

type registeredJob struct {
	job      ETLJob
	interval time.Duration
}

// NewETLRunner creates a new runner with the given logger and retry config.
func NewETLRunner(log p9log.Logger, retry RetryConfig) *ETLRunner {
	return &ETLRunner{
		jobs:  make(map[string]registeredJob),
		log:   log,
		retry: retry,
	}
}

// RegisterJob adds a job to the runner. The schedule string is parsed as a
// Go duration (e.g. "1h", "24h", "15m") for simplicity; production systems
// may replace this with a full cron parser.
func (r *ETLRunner) RegisterJob(job ETLJob) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	if _, exists := r.jobs[job.Name()]; exists {
		return fmt.Errorf("pipeline: job %q already registered", job.Name())
	}

	interval, err := time.ParseDuration(job.Schedule())
	if err != nil {
		return fmt.Errorf("pipeline: invalid schedule %q for job %q: %w", job.Schedule(), job.Name(), err)
	}

	r.jobs[job.Name()] = registeredJob{job: job, interval: interval}
	return nil
}

// Start begins executing all registered jobs on their schedules.
// It blocks until ctx is cancelled or Stop is called.
func (r *ETLRunner) Start(ctx context.Context) {
	r.mu.Lock()
	if r.running {
		r.mu.Unlock()
		return
	}
	ctx, cancel := context.WithCancel(ctx)
	r.cancel = cancel
	r.running = true

	var wg sync.WaitGroup
	for _, rj := range r.jobs {
		wg.Add(1)
		go func(rj registeredJob) {
			defer wg.Done()
			r.runLoop(ctx, rj)
		}(rj)
	}
	r.mu.Unlock()

	wg.Wait()

	r.mu.Lock()
	r.running = false
	r.mu.Unlock()
}

// Stop signals all running jobs to cease.
func (r *ETLRunner) Stop() {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.cancel != nil {
		r.cancel()
	}
}

func (r *ETLRunner) runLoop(ctx context.Context, rj registeredJob) {
	ticker := time.NewTicker(rj.interval)
	defer ticker.Stop()

	// Run once immediately on start.
	r.executeWithRetry(ctx, rj.job)

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			r.executeWithRetry(ctx, rj.job)
		}
	}
}

// ExecuteJob runs a single job once with retry logic. Exported for ad-hoc use.
func (r *ETLRunner) ExecuteJob(ctx context.Context, jobName string) (*JobResult, error) {
	r.mu.Lock()
	rj, ok := r.jobs[jobName]
	r.mu.Unlock()
	if !ok {
		return nil, fmt.Errorf("pipeline: job %q not found", jobName)
	}
	return r.executeWithRetry(ctx, rj.job), nil
}

func (r *ETLRunner) executeWithRetry(ctx context.Context, job ETLJob) *JobResult {
	result := &JobResult{
		JobName:   job.Name(),
		StartedAt: time.Now(),
	}

	backoff := r.retry.InitialBackoff

	for attempt := 0; attempt <= r.retry.MaxRetries; attempt++ {
		if ctx.Err() != nil {
			result.Errors = append(result.Errors, ctx.Err())
			break
		}

		err := r.executeSingle(ctx, job, result)
		if err == nil {
			result.Success = true
			break
		}

		result.Errors = append(result.Errors, fmt.Errorf("attempt %d: %w", attempt+1, err))
		r.log.Warn("pipeline", "job", job.Name(), "attempt", attempt+1, "error", err.Error())

		if attempt < r.retry.MaxRetries {
			select {
			case <-time.After(backoff):
			case <-ctx.Done():
				result.Errors = append(result.Errors, ctx.Err())
				break
			}
			backoff = time.Duration(float64(backoff) * r.retry.BackoffFactor)
			if backoff > r.retry.MaxBackoff {
				backoff = r.retry.MaxBackoff
			}
		}
	}

	result.CompletedAt = time.Now()
	result.Duration = result.CompletedAt.Sub(result.StartedAt)
	return result
}

func (r *ETLRunner) executeSingle(ctx context.Context, job ETLJob, result *JobResult) error {
	records, err := job.Extract(ctx)
	if err != nil {
		return fmt.Errorf("extract: %w", err)
	}
	result.RowsExtracted = len(records)

	transformed, err := job.Transform(ctx, records)
	if err != nil {
		return fmt.Errorf("transform: %w", err)
	}

	if err := job.Load(ctx, transformed); err != nil {
		return fmt.Errorf("load: %w", err)
	}
	result.RowsLoaded = len(transformed)

	return nil
}

// ComputeBackoff calculates the backoff duration for a given attempt.
func ComputeBackoff(attempt int, cfg RetryConfig) time.Duration {
	d := float64(cfg.InitialBackoff) * math.Pow(cfg.BackoffFactor, float64(attempt))
	if time.Duration(d) > cfg.MaxBackoff {
		return cfg.MaxBackoff
	}
	return time.Duration(d)
}
