package metrics

import (
	"context"
	"testing"

	"p9e.in/samavaya/packages/p9log"
)

func TestCollectorCounter(t *testing.T) {
	logger := p9log.NoOp()
	collector := NewCollector("test", logger)

	counter := collector.Counter("requests_total", "Total requests", []string{"service"})
	counter.WithLabelValues("payment").Inc()
	counter.WithLabelValues("auth").Add(5)

	snapshot, _ := collector.GetSnapshot(context.Background())
	if len(snapshot.Metrics) == 0 {
		t.Fatal("Expected metrics in snapshot")
	}
}

func TestCollectorGauge(t *testing.T) {
	logger := p9log.NoOp()
	collector := NewCollector("test", logger)

	gauge := collector.Gauge("connections", "Active connections", []string{"service"})
	gauge.WithLabelValues("payment").Set(42)

	snapshot, _ := collector.GetSnapshot(context.Background())
	if len(snapshot.Metrics) == 0 {
		t.Fatal("Expected metrics in snapshot")
	}
}

func TestCollectorHistogram(t *testing.T) {
	logger := p9log.NoOp()
	collector := NewCollector("test", logger)

	histogram := collector.Histogram("request_duration_ms", "Request latency", []string{"service"})
	histogram.WithLabelValues("payment").Observe(150.5)
	histogram.WithLabelValues("auth").Observe(50.2)

	snapshot, _ := collector.GetSnapshot(context.Background())
	if len(snapshot.Metrics) == 0 {
		t.Fatal("Expected metrics in snapshot")
	}
}

// Asking twice for the same metric returns the same metric.
//
// This was the second crash in the same code and it had no test at all: the
// cache stored an unlabelled prometheus.Counter, and the early-return path
// asserted it to a prometheus.CounterVec — an interface to a struct it could
// never hold, so the assertion panicked. Histogram and Summary were worse: they
// cached a literal nil and asserted on that.
//
// Two callers must also share one metric rather than register a duplicate, or
// the counts the exporter reports are split across registrations that neither
// caller knows about.
func TestCollectorReturnsTheSameMetricTwice(t *testing.T) {
	logger := p9log.NoOp()
	collector := NewCollector("test", logger)

	counterA := collector.Counter("requests_total", "Total requests", []string{"service"})
	counterB := collector.Counter("requests_total", "Total requests", []string{"service"})
	if counterA != counterB {
		t.Error("Counter returned a different vector the second time")
	}

	gaugeA := collector.Gauge("connections", "Active connections", []string{"service"})
	gaugeB := collector.Gauge("connections", "Active connections", []string{"service"})
	if gaugeA != gaugeB {
		t.Error("Gauge returned a different vector the second time")
	}

	histA := collector.Histogram("latency_ms", "Latency", []string{"service"})
	histB := collector.Histogram("latency_ms", "Latency", []string{"service"})
	if histA != histB {
		t.Error("Histogram returned a different vector the second time")
	}

	sumA := collector.Summary("payload_bytes", "Payload size", []string{"service"})
	sumB := collector.Summary("payload_bytes", "Payload size", []string{"service"})
	if sumA != sumB {
		t.Error("Summary returned a different vector the second time")
	}

	// And the shared vector is the one the registry gathers from: increments
	// through the second handle have to show up in the first's snapshot.
	counterB.WithLabelValues("payment").Add(3)

	snapshot, err := collector.GetSnapshot(context.Background())
	if err != nil {
		t.Fatalf("GetSnapshot: %v", err)
	}

	var found bool
	for _, m := range snapshot.Metrics {
		if m.Name == "test_requests_total" && m.Labels["service"] == "payment" {
			found = true
			if m.Value != 3 {
				t.Errorf("counter value = %v, want 3", m.Value)
			}
		}
	}
	if !found {
		t.Error("the counter incremented through the second handle is not in the snapshot")
	}
}

func TestCollectorSummary(t *testing.T) {
	logger := p9log.NoOp()
	collector := NewCollector("test", logger)

	summary := collector.Summary("payload_bytes", "Payload size", []string{"service"})
	summary.WithLabelValues("payment").Observe(1024)

	snapshot, _ := collector.GetSnapshot(context.Background())
	if len(snapshot.Metrics) == 0 {
		t.Fatal("Expected metrics in snapshot")
	}
}

func BenchmarkCollectorCounter(b *testing.B) {
	logger := p9log.NoOp()
	collector := NewCollector("bench", logger)

	counter := collector.Counter("requests", "Total requests", []string{})
	counterVec := counter.WithLabelValues()

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		counterVec.Inc()
	}
}

func BenchmarkCollectorHistogram(b *testing.B) {
	logger := p9log.NoOp()
	collector := NewCollector("bench", logger)

	histogram := collector.Histogram("latency", "Request latency", []string{})
	histogramVec := histogram.WithLabelValues()

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		histogramVec.Observe(float64(i % 1000))
	}
}
