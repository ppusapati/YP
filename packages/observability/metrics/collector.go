package metrics

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"

	"p9e.in/samavaya/packages/observability"
	"p9e.in/samavaya/packages/p9log"
)

// Collector collects and manages metrics.
//
// The caches hold the *Vec types, which is what a labelled metric is. They used
// to hold the unlabelled forms — prometheus.Counter rather than
// *prometheus.CounterVec — and the only way to put one in was
// `counter.WithLabelValues()` with no values at all, which panics on any vector
// that declares a label: "inconsistent label cardinality: expected 1 label
// values but got 0". Every call to Counter with labels crashed the process, and
// the second call for the same name crashed differently, on a type assertion
// from an interface to a struct it could never hold. Histogram and Summary
// cached a literal nil and asserted on it.
//
// So this package could not be used at all, and nothing said so because its own
// tests were never run: `go test ./packages/...` from the repository root
// matches nothing, packages/ being a separate module.
type Collector struct {
	counters   map[string]*prometheus.CounterVec
	gauges     map[string]*prometheus.GaugeVec
	histograms map[string]*prometheus.HistogramVec
	summaries  map[string]*prometheus.SummaryVec
	mu         sync.RWMutex
	logger     p9log.Logger
	registry   *prometheus.Registry
	namespace  string
	subsystem  string
}

// NewCollector creates a new metrics collector
func NewCollector(namespace string, logger p9log.Logger) *Collector {
	return &Collector{
		counters:   make(map[string]*prometheus.CounterVec),
		gauges:     make(map[string]*prometheus.GaugeVec),
		histograms: make(map[string]*prometheus.HistogramVec),
		summaries:  make(map[string]*prometheus.SummaryVec),
		logger:     logger,
		registry:   prometheus.NewRegistry(),
		namespace:  namespace,
	}
}

// Counter creates or gets a counter metric.
//
// Returns the vector itself rather than a copy of it, so that two callers
// asking for the same name get one metric and not two views that disagree about
// which registry they belong to.
func (c *Collector) Counter(name, help string, labels []string) *prometheus.CounterVec {
	c.mu.Lock()
	defer c.mu.Unlock()

	if existing, ok := c.counters[name]; ok {
		return existing
	}

	opts := prometheus.CounterOpts{
		Namespace: c.namespace,
		Name:      name,
		Help:      help,
	}

	counter := promauto.With(c.registry).NewCounterVec(opts, labels)
	c.counters[name] = counter

	c.logger.Log(p9log.LevelDebug, "msg", "created counter metric", "name", name)
	return counter
}

// Gauge creates or gets a gauge metric
func (c *Collector) Gauge(name, help string, labels []string) *prometheus.GaugeVec {
	c.mu.Lock()
	defer c.mu.Unlock()

	if existing, ok := c.gauges[name]; ok {
		return existing
	}

	opts := prometheus.GaugeOpts{
		Namespace: c.namespace,
		Name:      name,
		Help:      help,
	}

	gauge := promauto.With(c.registry).NewGaugeVec(opts, labels)
	c.gauges[name] = gauge

	c.logger.Log(p9log.LevelDebug, "msg", "created gauge metric", "name", name)
	return gauge
}

// Histogram creates or gets a histogram metric
func (c *Collector) Histogram(name, help string, labels []string) *prometheus.HistogramVec {
	c.mu.Lock()
	defer c.mu.Unlock()

	if existing, ok := c.histograms[name]; ok {
		return existing
	}

	opts := prometheus.HistogramOpts{
		Namespace: c.namespace,
		Name:      name,
		Help:      help,
		Buckets:   prometheus.DefBuckets,
	}

	histogram := promauto.With(c.registry).NewHistogramVec(opts, labels)
	c.histograms[name] = histogram

	c.logger.Log(p9log.LevelDebug, "msg", "created histogram metric", "name", name)
	return histogram
}

// Summary creates or gets a summary metric
func (c *Collector) Summary(name, help string, labels []string) *prometheus.SummaryVec {
	c.mu.Lock()
	defer c.mu.Unlock()

	if existing, ok := c.summaries[name]; ok {
		return existing
	}

	opts := prometheus.SummaryOpts{
		Namespace: c.namespace,
		Name:      name,
		Help:      help,
	}

	summary := promauto.With(c.registry).NewSummaryVec(opts, labels)
	c.summaries[name] = summary

	c.logger.Log(p9log.LevelDebug, "msg", "created summary metric", "name", name)
	return summary
}

// GetSnapshot returns a snapshot of all metrics
func (c *Collector) GetSnapshot(ctx context.Context) (*observability.MetricSnapshot, error) {
	c.mu.RLock()
	defer c.mu.RUnlock()

	snapshot := &observability.MetricSnapshot{
		Timestamp: time.Now(),
		Metrics:   make([]observability.Metric, 0),
	}

	// Get metrics from registry
	families, err := c.registry.Gather()
	if err != nil {
		return nil, fmt.Errorf("failed to gather metrics: %w", err)
	}

	// Convert to observability metrics
	for _, family := range families {
		for _, metric := range family.Metric {
			labels := make(map[string]string)
			for _, label := range metric.Label {
				labels[label.GetName()] = label.GetValue()
			}

			value := 0.0
			if metric.Counter != nil {
				value = metric.Counter.GetValue()
			} else if metric.Gauge != nil {
				value = metric.Gauge.GetValue()
			} else if metric.Histogram != nil {
				value = float64(metric.Histogram.GetSampleCount())
			} else if metric.Summary != nil {
				value = float64(metric.Summary.GetSampleCount())
			}

			var ts time.Time
			if metric.TimestampMs != nil {
				ts = time.Unix(0, *metric.TimestampMs*1e6)
			}

			snapshot.Metrics = append(snapshot.Metrics, observability.Metric{
				Name:      family.GetName(),
				Type:      observability.MetricType(family.GetType().String()),
				Value:     value,
				Labels:    labels,
				Timestamp: ts,
				Help:      family.GetHelp(),
			})
		}
	}

	return snapshot, nil
}

// GetRegistry returns the underlying Prometheus registry
func (c *Collector) GetRegistry() *prometheus.Registry {
	return c.registry
}
