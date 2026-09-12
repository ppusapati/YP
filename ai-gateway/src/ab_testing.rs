//! A/B Testing Router — route inference requests between two models based on
//! a configurable traffic split, collecting comparison metrics.
//!
//! The router uses a thread-safe atomic counter for deterministic splitting:
//! requests 0..split_pct go to model A, the rest to model B. This ensures
//! reproducible traffic allocation without randomness.

use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Mutex;
use std::time::Instant;

use crate::config::ABTestConfig;

/// Which model variant a request is routed to.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ModelVariant {
    ModelA,
    ModelB,
}

/// Metrics collected for a single inference request in an A/B test.
#[derive(Debug, Clone)]
pub struct ABMetrics {
    pub variant: ModelVariant,
    pub latency_ms: f64,
    pub confidence: f64,
    pub request_id: String,
}

/// Accumulated comparison metrics for the A/B test.
#[derive(Debug, Clone, Default)]
pub struct ABTestSummary {
    pub model_a_count: u64,
    pub model_b_count: u64,
    pub model_a_avg_latency_ms: f64,
    pub model_b_avg_latency_ms: f64,
    pub model_a_avg_confidence: f64,
    pub model_b_avg_confidence: f64,
}

/// Routes inference requests to model A or B based on a traffic split.
///
/// Thread-safe: the request counter and metrics buffer use atomics and a mutex.
pub struct ABTestRouter {
    config: ABTestConfig,
    counter: AtomicU64,
    metrics: Mutex<Vec<ABMetrics>>,
}

impl ABTestRouter {
    /// Create a new router from an A/B test configuration.
    pub fn new(config: ABTestConfig) -> Self {
        Self {
            config,
            counter: AtomicU64::new(0),
            metrics: Mutex::new(Vec::new()),
        }
    }

    /// Determine which model variant should handle the next request.
    ///
    /// Uses modular arithmetic on an incrementing counter:
    /// `counter % 100 < traffic_split_pct` routes to model A.
    pub fn route(&self) -> ModelVariant {
        let n = self.counter.fetch_add(1, Ordering::Relaxed);
        if (n % 100) < self.config.traffic_split_pct as u64 {
            ModelVariant::ModelA
        } else {
            ModelVariant::ModelB
        }
    }

    /// Return the ONNX model path for the given variant.
    pub fn model_path(&self, variant: ModelVariant) -> &str {
        match variant {
            ModelVariant::ModelA => &self.config.model_a,
            ModelVariant::ModelB => &self.config.model_b,
        }
    }

    /// Record an inference result for comparison metrics.
    pub fn record_metric(&self, metric: ABMetrics) {
        if self.config.metrics_collection {
            if let Ok(mut buf) = self.metrics.lock() {
                buf.push(metric);
            }
        }
    }

    /// Start a latency timer; call `.elapsed()` on the returned `Instant`
    /// after inference completes.
    pub fn start_timer(&self) -> Instant {
        Instant::now()
    }

    /// Compute a summary of collected A/B test metrics.
    pub fn summary(&self) -> ABTestSummary {
        let buf = self.metrics.lock().unwrap();

        let (mut a_lat, mut b_lat) = (0.0f64, 0.0f64);
        let (mut a_conf, mut b_conf) = (0.0f64, 0.0f64);
        let (mut a_count, mut b_count) = (0u64, 0u64);

        for m in buf.iter() {
            match m.variant {
                ModelVariant::ModelA => {
                    a_lat += m.latency_ms;
                    a_conf += m.confidence;
                    a_count += 1;
                }
                ModelVariant::ModelB => {
                    b_lat += m.latency_ms;
                    b_conf += m.confidence;
                    b_count += 1;
                }
            }
        }

        ABTestSummary {
            model_a_count: a_count,
            model_b_count: b_count,
            model_a_avg_latency_ms: if a_count > 0 { a_lat / a_count as f64 } else { 0.0 },
            model_b_avg_latency_ms: if b_count > 0 { b_lat / b_count as f64 } else { 0.0 },
            model_a_avg_confidence: if a_count > 0 { a_conf / a_count as f64 } else { 0.0 },
            model_b_avg_confidence: if b_count > 0 { b_conf / b_count as f64 } else { 0.0 },
        }
    }

    /// Reset the counter and collected metrics.
    pub fn reset(&self) {
        self.counter.store(0, Ordering::Relaxed);
        if let Ok(mut buf) = self.metrics.lock() {
            buf.clear();
        }
    }

    /// Return the current request count.
    pub fn request_count(&self) -> u64 {
        self.counter.load(Ordering::Relaxed)
    }

    /// Access the underlying config.
    pub fn config(&self) -> &ABTestConfig {
        &self.config
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn test_config(split_pct: u8) -> ABTestConfig {
        ABTestConfig {
            model_a: "/models/disease-v1.onnx".to_string(),
            model_b: "/models/disease-v2.onnx".to_string(),
            traffic_split_pct: split_pct,
            metrics_collection: true,
        }
    }

    #[test]
    fn route_respects_traffic_split() {
        let router = ABTestRouter::new(test_config(70));

        let mut a_count = 0u64;
        let mut b_count = 0u64;

        // Route 200 requests (2 full cycles of 100).
        for _ in 0..200 {
            match router.route() {
                ModelVariant::ModelA => a_count += 1,
                ModelVariant::ModelB => b_count += 1,
            }
        }

        assert_eq!(a_count, 140, "70% of 200 = 140 to model A");
        assert_eq!(b_count, 60, "30% of 200 = 60 to model B");
    }

    #[test]
    fn route_all_to_model_a_when_split_100() {
        let router = ABTestRouter::new(test_config(100));

        for _ in 0..50 {
            assert_eq!(router.route(), ModelVariant::ModelA);
        }
    }

    #[test]
    fn route_all_to_model_b_when_split_0() {
        let router = ABTestRouter::new(test_config(0));

        for _ in 0..50 {
            assert_eq!(router.route(), ModelVariant::ModelB);
        }
    }

    #[test]
    fn model_path_returns_correct_paths() {
        let router = ABTestRouter::new(test_config(50));
        assert_eq!(router.model_path(ModelVariant::ModelA), "/models/disease-v1.onnx");
        assert_eq!(router.model_path(ModelVariant::ModelB), "/models/disease-v2.onnx");
    }

    #[test]
    fn record_and_summary() {
        let router = ABTestRouter::new(test_config(50));

        router.record_metric(ABMetrics {
            variant: ModelVariant::ModelA,
            latency_ms: 10.0,
            confidence: 0.9,
            request_id: "r1".to_string(),
        });
        router.record_metric(ABMetrics {
            variant: ModelVariant::ModelA,
            latency_ms: 20.0,
            confidence: 0.8,
            request_id: "r2".to_string(),
        });
        router.record_metric(ABMetrics {
            variant: ModelVariant::ModelB,
            latency_ms: 15.0,
            confidence: 0.95,
            request_id: "r3".to_string(),
        });

        let summary = router.summary();
        assert_eq!(summary.model_a_count, 2);
        assert_eq!(summary.model_b_count, 1);
        assert!((summary.model_a_avg_latency_ms - 15.0).abs() < f64::EPSILON);
        assert!((summary.model_b_avg_latency_ms - 15.0).abs() < f64::EPSILON);
        assert!((summary.model_a_avg_confidence - 0.85).abs() < f64::EPSILON);
        assert!((summary.model_b_avg_confidence - 0.95).abs() < f64::EPSILON);
    }

    #[test]
    fn summary_empty_when_no_metrics() {
        let router = ABTestRouter::new(test_config(50));
        let summary = router.summary();
        assert_eq!(summary.model_a_count, 0);
        assert_eq!(summary.model_b_count, 0);
        assert!((summary.model_a_avg_latency_ms).abs() < f64::EPSILON);
    }

    #[test]
    fn metrics_not_collected_when_disabled() {
        let mut config = test_config(50);
        config.metrics_collection = false;
        let router = ABTestRouter::new(config);

        router.record_metric(ABMetrics {
            variant: ModelVariant::ModelA,
            latency_ms: 10.0,
            confidence: 0.9,
            request_id: "r1".to_string(),
        });

        let summary = router.summary();
        assert_eq!(summary.model_a_count, 0, "metrics should not be collected");
    }

    #[test]
    fn reset_clears_counter_and_metrics() {
        let router = ABTestRouter::new(test_config(50));

        // Generate some state.
        for _ in 0..10 {
            router.route();
        }
        router.record_metric(ABMetrics {
            variant: ModelVariant::ModelA,
            latency_ms: 5.0,
            confidence: 0.7,
            request_id: "r1".to_string(),
        });

        assert_eq!(router.request_count(), 10);
        router.reset();
        assert_eq!(router.request_count(), 0);
        assert_eq!(router.summary().model_a_count, 0);
    }

    #[test]
    fn deterministic_split_first_100_requests() {
        let router = ABTestRouter::new(test_config(30));
        let mut variants = Vec::new();

        for _ in 0..100 {
            variants.push(router.route());
        }

        let a_count = variants.iter().filter(|&&v| v == ModelVariant::ModelA).count();
        let b_count = variants.iter().filter(|&&v| v == ModelVariant::ModelB).count();

        assert_eq!(a_count, 30, "exactly 30% to model A in first 100");
        assert_eq!(b_count, 70);

        // First 30 should be model A, rest model B.
        for v in &variants[..30] {
            assert_eq!(*v, ModelVariant::ModelA);
        }
        for v in &variants[30..] {
            assert_eq!(*v, ModelVariant::ModelB);
        }
    }

    #[test]
    fn thread_safety_concurrent_routing() {
        use std::sync::Arc;
        use std::thread;

        let router = Arc::new(ABTestRouter::new(test_config(50)));
        let mut handles = Vec::new();

        for _ in 0..4 {
            let r = router.clone();
            handles.push(thread::spawn(move || {
                for _ in 0..250 {
                    r.route();
                }
            }));
        }

        for h in handles {
            h.join().unwrap();
        }

        assert_eq!(router.request_count(), 1000);
    }

    #[test]
    fn ab_test_config_deserializes() {
        let toml_str = r#"
model_a = "/models/v1.onnx"
model_b = "/models/v2.onnx"
traffic_split_pct = 80
metrics_collection = true
"#;
        let config: ABTestConfig = toml::from_str(toml_str).unwrap();
        assert_eq!(config.model_a, "/models/v1.onnx");
        assert_eq!(config.model_b, "/models/v2.onnx");
        assert_eq!(config.traffic_split_pct, 80);
        assert!(config.metrics_collection);
    }
}
