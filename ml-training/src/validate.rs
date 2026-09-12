use std::collections::HashMap;

use burn::data::dataloader::batcher::Batcher;
use burn_ndarray::NdArray;

use crate::dataset::{PlantBatcher, Sample};
use crate::model::PlantCnn;

type InferBackend = NdArray;

pub struct ValidationReport {
    pub accuracy: f64,
    pub num_samples: usize,
    pub per_class: HashMap<String, ClassMetrics>,
}

pub struct ClassMetrics {
    pub precision: f64,
    pub recall: f64,
    pub f1: f64,
    pub support: usize,
}

pub fn validate(
    model: &PlantCnn<InferBackend>,
    samples: &[Sample],
    label_map: &HashMap<String, usize>,
    input_size: usize,
    batch_size: usize,
) -> ValidationReport {
    let batcher = PlantBatcher::new(input_size);
    let idx_to_label: HashMap<usize, String> = label_map
        .iter()
        .map(|(k, &v)| (v, k.clone()))
        .collect();

    let num_classes = label_map.len();
    let mut confusion = vec![vec![0usize; num_classes]; num_classes];
    let mut correct = 0usize;
    let mut total = 0usize;

    for chunk in samples.chunks(batch_size) {
        let batch = batcher.batch(chunk.to_vec());
        let logits = model.forward(batch.images);
        let preds = logits.argmax(1).squeeze::<1>(1);

        let pred_data: Vec<i64> = preds.into_data().to_vec().unwrap();
        let label_data: Vec<i64> = batch.labels.into_data().to_vec().unwrap();

        for (pred, actual) in pred_data.iter().zip(label_data.iter()) {
            let p = *pred as usize;
            let a = *actual as usize;
            if p < num_classes && a < num_classes {
                confusion[a][p] += 1;
            }
            if p == a {
                correct += 1;
            }
            total += 1;
        }
    }

    let accuracy = if total > 0 { correct as f64 / total as f64 } else { 0.0 };

    let mut per_class = HashMap::new();
    for class_idx in 0..num_classes {
        let true_pos = confusion[class_idx][class_idx] as f64;
        let actual_total: f64 = confusion[class_idx].iter().sum::<usize>() as f64;
        let predicted_total: f64 = confusion.iter().map(|row| row[class_idx]).sum::<usize>() as f64;

        let precision = if predicted_total > 0.0 { true_pos / predicted_total } else { 0.0 };
        let recall = if actual_total > 0.0 { true_pos / actual_total } else { 0.0 };
        let f1 = if precision + recall > 0.0 {
            2.0 * precision * recall / (precision + recall)
        } else {
            0.0
        };

        let label = idx_to_label.get(&class_idx).cloned().unwrap_or_else(|| format!("class_{class_idx}"));
        per_class.insert(label, ClassMetrics {
            precision,
            recall,
            f1,
            support: actual_total as usize,
        });
    }

    ValidationReport {
        accuracy,
        num_samples: total,
        per_class,
    }
}

pub fn print_report(report: &ValidationReport) {
    println!("\n{:<30} {:>10} {:>10} {:>10} {:>10}", "Class", "Precision", "Recall", "F1", "Support");
    println!("{}", "-".repeat(72));

    let mut classes: Vec<_> = report.per_class.iter().collect();
    classes.sort_by_key(|(name, _)| name.clone());

    for (name, metrics) in &classes {
        println!(
            "{:<30} {:>10.4} {:>10.4} {:>10.4} {:>10}",
            name, metrics.precision, metrics.recall, metrics.f1, metrics.support
        );
    }

    println!("{}", "-".repeat(72));
    println!("Overall accuracy: {:.4} ({}/{})", report.accuracy, (report.accuracy * report.num_samples as f64) as usize, report.num_samples);

    let macro_f1: f64 = report.per_class.values().map(|m| m.f1).sum::<f64>() / report.per_class.len() as f64;
    println!("Macro F1: {macro_f1:.4}");
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::HashMap;
    use std::path::PathBuf;
    use burn_ndarray::NdArray;
    use crate::dataset::Sample;
    use crate::model::PlantCnn;

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
            })
            .collect()
    }

    #[test]
    fn single_class_perfect_accuracy() {
        // With 1 output class, argmax always returns 0, so all predictions
        // match label_idx 0 and accuracy is 1.0.
        let device = Default::default();
        let model: PlantCnn<NdArray> = PlantCnn::new(1, &device);

        let samples = make_samples(&[
            (0, "healthy"),
            (0, "healthy"),
            (0, "healthy"),
            (0, "healthy"),
        ]);
        let mut label_map = HashMap::new();
        label_map.insert("healthy".to_string(), 0usize);

        let report = validate(&model, &samples, &label_map, 32, 2);

        assert_eq!(report.num_samples, 4);
        assert!((report.accuracy - 1.0).abs() < f64::EPSILON);
        assert_eq!(report.per_class.len(), 1);

        let m = &report.per_class["healthy"];
        assert!((m.precision - 1.0).abs() < f64::EPSILON);
        assert!((m.recall - 1.0).abs() < f64::EPSILON);
        assert!((m.f1 - 1.0).abs() < f64::EPSILON);
        assert_eq!(m.support, 4);
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
        let mut label_map = HashMap::new();
        label_map.insert("healthy".to_string(), 0);
        label_map.insert("rust".to_string(), 1);
        label_map.insert("blight".to_string(), 2);

        let report = validate(&model, &samples, &label_map, 32, 4);

        assert_eq!(report.num_samples, 6);
        assert!(report.accuracy >= 0.0 && report.accuracy <= 1.0);
        assert_eq!(report.per_class.len(), 3);

        // Support values must sum to total samples
        let total_support: usize = report.per_class.values().map(|m| m.support).sum();
        assert_eq!(total_support, 6);

        for (name, m) in &report.per_class {
            assert!(m.precision >= 0.0 && m.precision <= 1.0, "{name} precision out of range");
            assert!(m.recall >= 0.0 && m.recall <= 1.0, "{name} recall out of range");
            assert!(m.f1 >= 0.0 && m.f1 <= 1.0, "{name} f1 out of range");
            assert!(m.support > 0, "{name} should have positive support");
        }
    }

    #[test]
    fn report_individual_class_support() {
        let device = Default::default();
        let model: PlantCnn<NdArray> = PlantCnn::new(2, &device);

        // 3 samples of class 0, 1 sample of class 1
        let samples = make_samples(&[
            (0, "a"),
            (0, "a"),
            (0, "a"),
            (1, "b"),
        ]);
        let mut label_map = HashMap::new();
        label_map.insert("a".to_string(), 0);
        label_map.insert("b".to_string(), 1);

        let report = validate(&model, &samples, &label_map, 32, 4);

        assert_eq!(report.num_samples, 4);
        assert_eq!(report.per_class["a"].support, 3);
        assert_eq!(report.per_class["b"].support, 1);
    }

    #[test]
    fn validate_handles_multiple_batches() {
        let device = Default::default();
        let model: PlantCnn<NdArray> = PlantCnn::new(1, &device);

        // 5 samples with batch_size=2 means 3 batches (2+2+1)
        let samples = make_samples(&[
            (0, "x"),
            (0, "x"),
            (0, "x"),
            (0, "x"),
            (0, "x"),
        ]);
        let mut label_map = HashMap::new();
        label_map.insert("x".to_string(), 0);

        let report = validate(&model, &samples, &label_map, 32, 2);
        assert_eq!(report.num_samples, 5);
        assert!((report.accuracy - 1.0).abs() < f64::EPSILON);
    }
}
