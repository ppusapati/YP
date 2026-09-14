//! Run a trained model over samples and turn its outputs into an evaluation.
//!
//! This module is only the model-running half; every metric lives in
//! [`crate::eval`], which works on plain [`Prediction`] values so the maths can
//! be tested without a model or a backend.

use std::collections::HashMap;

use burn::data::dataloader::batcher::Batcher;

use crate::backend::InferBackend;
use crate::dataset::{PlantBatcher, Sample};
use crate::eval::{self, EvaluationReport, Prediction};
use crate::model::PlantCnn;

/// Class labels ordered by their index, so position `i` is class `i`.
pub fn labels_in_order(label_map: &HashMap<String, usize>) -> Vec<String> {
    // Size by the largest index, not the map length: a map with a gap in its
    // indices is malformed, but dropping the label past the end would silently
    // misalign every metric that follows.
    let width = label_map
        .values()
        .map(|&i| i + 1)
        .max()
        .unwrap_or(0)
        .max(label_map.len());
    let mut labels = vec![String::new(); width];
    for (name, &idx) in label_map {
        labels[idx] = name.clone();
    }
    for (i, label) in labels.iter_mut().enumerate() {
        if label.is_empty() {
            *label = format!("class_{i}");
        }
    }
    labels
}

/// Run the model over every sample, keeping full probability vectors.
///
/// Probabilities, not just the argmax, because calibration is measured on how
/// much confidence a model claims — an answer the predicted label alone cannot
/// give.
pub fn predict(
    model: &PlantCnn<InferBackend>,
    samples: &[Sample],
    input_size: usize,
    batch_size: usize,
) -> Vec<Prediction> {
    let batcher = PlantBatcher::new(input_size);
    let mut out = Vec::with_capacity(samples.len());

    for chunk in samples.chunks(batch_size.max(1)) {
        let batch = batcher.batch(chunk.to_vec());
        let logits = model.forward(batch.images);
        let [rows, classes] = logits.dims();
        let flat: Vec<f32> = logits.into_data().to_vec().unwrap();

        for (row, sample) in chunk.iter().enumerate().take(rows) {
            let probs = eval::softmax(&flat[row * classes..(row + 1) * classes]);
            out.push(Prediction {
                id: sample.id.clone(),
                actual: sample.label_idx,
                predicted: eval::argmax(&probs),
                probs,
                slices: sample.slice_keys(),
            });
        }
    }
    out
}

/// Run the model and build the full evaluation report.
pub fn evaluate(
    task: &str,
    model_version: &str,
    model: &PlantCnn<InferBackend>,
    samples: &[Sample],
    label_map: &HashMap<String, usize>,
    input_size: usize,
    batch_size: usize,
) -> EvaluationReport {
    let labels = labels_in_order(label_map);
    let predictions = predict(model, samples, input_size, batch_size);
    EvaluationReport::build(task, model_version, &predictions, &labels)
}

/// Print an evaluation to stdout.
pub fn print_report(report: &EvaluationReport) {
    println!("{}", report.render());
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::dataset::{Capture, Sample};
    use crate::model::PlantCnn;
    use burn_ndarray::NdArray;
    use std::path::PathBuf;

    fn make_samples(labels: &[(usize, &str)]) -> Vec<Sample> {
        labels
            .iter()
            .enumerate()
            .map(|(i, (idx, name))| Sample {
                id: format!("s{i}"),
                image_path: PathBuf::from(format!("/nonexistent/img_{i}.jpg")),
                label: name.to_string(),
                label_idx: *idx,
                confidence: 0.95,
                weight: 1.0,
                provenance: "external_api".to_string(),
                crop: "wheat".to_string(),
                reviewed: false,
                capture: Capture {
                    latitude: 18.5,
                    longitude: 78.4,
                    timestamp: "2026-07-01T00:00:00Z".to_string(),
                },
            })
            .collect()
    }

    fn label_map(names: &[&str]) -> HashMap<String, usize> {
        names
            .iter()
            .enumerate()
            .map(|(i, n)| (n.to_string(), i))
            .collect()
    }

    #[test]
    fn labels_come_back_in_index_order() {
        let map = label_map(&["blight", "healthy", "rust"]);
        assert_eq!(labels_in_order(&map), vec!["blight", "healthy", "rust"]);

        // A gap in the indices must not panic or silently shift labels.
        let mut sparse = HashMap::new();
        sparse.insert("a".to_string(), 0usize);
        sparse.insert("b".to_string(), 2usize);
        assert_eq!(labels_in_order(&sparse), vec!["a", "class_1", "b"]);
    }

    #[test]
    fn single_class_perfect_accuracy() {
        // With one output class, argmax is always 0, so every prediction
        // matches label_idx 0.
        let device = Default::default();
        let model: PlantCnn<NdArray> = PlantCnn::new(1, &device);
        let samples = make_samples(&[(0, "healthy"); 4]);

        let report = evaluate(
            "disease",
            "v1",
            &model,
            &samples,
            &label_map(&["healthy"]),
            32,
            2,
        );

        assert_eq!(report.n_samples, 4);
        assert!((report.accuracy - 1.0).abs() < f64::EPSILON);
        assert_eq!(report.per_class.len(), 1);
        assert_eq!(report.per_class[0].support, 4);
        assert!((report.per_class[0].f1 - 1.0).abs() < f64::EPSILON);
        assert!(report.top_confusions.is_empty());
    }

    #[test]
    fn predictions_carry_probabilities_and_slice_keys() {
        let device = Default::default();
        let model: PlantCnn<NdArray> = PlantCnn::new(3, &device);
        let samples = make_samples(&[(0, "healthy"), (1, "rust"), (2, "blight")]);

        let preds = predict(&model, &samples, 32, 2);
        assert_eq!(preds.len(), 3);
        for p in &preds {
            assert_eq!(p.probs.len(), 3);
            assert!((p.probs.iter().sum::<f64>() - 1.0).abs() < 1e-9);
            assert!(p.probs.iter().all(|v| (0.0..=1.0).contains(v)));
            assert_eq!(p.predicted, eval::argmax(&p.probs));
            // Slice metadata travels with the prediction.
            assert_eq!(p.slices.get("crop").map(String::as_str), Some("wheat"));
            assert_eq!(
                p.slices.get("source").map(String::as_str),
                Some("external_api")
            );
            assert_eq!(p.slices.get("season").map(String::as_str), Some("summer"));
            assert!(p.slices.contains_key("region"));
        }
        // Ids are preserved so a prediction can be traced back to its image.
        assert_eq!(preds[0].id, "s0");
    }

    #[test]
    fn report_structure_multi_class() {
        let device = Default::default();
        let model: PlantCnn<NdArray> = PlantCnn::new(3, &device);
        let samples = make_samples(&[
            (0, "healthy"),
            (0, "healthy"),
            (1, "rust"),
            (1, "rust"),
            (2, "blight"),
            (2, "blight"),
        ]);

        let report = evaluate(
            "disease",
            "v1",
            &model,
            &samples,
            &label_map(&["healthy", "rust", "blight"]),
            32,
            4,
        );

        assert_eq!(report.n_samples, 6);
        assert!((0.0..=1.0).contains(&report.accuracy));
        assert_eq!(report.per_class.len(), 3);
        assert_eq!(report.confusion.total(), 6);

        let total_support: usize = report.per_class.iter().map(|m| m.support).sum();
        assert_eq!(total_support, 6);

        for m in &report.per_class {
            assert!((0.0..=1.0).contains(&m.precision), "{} precision", m.label);
            assert!((0.0..=1.0).contains(&m.recall), "{} recall", m.label);
            assert!((0.0..=1.0).contains(&m.f1), "{} f1", m.label);
            assert_eq!(m.support, 2);
        }

        // Calibration is computed over the same samples.
        assert_eq!(report.calibration.n, 6);
        assert!(report.calibration.ece >= 0.0);
        assert!(report.suggested_temperature > 0.0);
    }

    #[test]
    fn validate_handles_multiple_batches() {
        let device = Default::default();
        let model: PlantCnn<NdArray> = PlantCnn::new(2, &device);
        let samples = make_samples(&[(0, "healthy"); 7]);

        // A batch size that does not divide the sample count must not drop the
        // remainder.
        let report = evaluate(
            "disease",
            "v1",
            &model,
            &samples,
            &label_map(&["healthy", "rust"]),
            32,
            3,
        );
        assert_eq!(report.n_samples, 7);
        assert_eq!(report.confusion.total(), 7);
    }

    #[test]
    fn empty_sample_set_is_reported_not_panicked() {
        let device = Default::default();
        let model: PlantCnn<NdArray> = PlantCnn::new(2, &device);

        let report = evaluate(
            "disease",
            "v1",
            &model,
            &[],
            &label_map(&["healthy", "rust"]),
            32,
            4,
        );
        assert_eq!(report.n_samples, 0);
        assert_eq!(report.accuracy, 0.0);
        assert!(report.slices.is_empty());
    }
}
