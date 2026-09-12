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

        let pred_data: Vec<i32> = preds.into_data().to_vec().unwrap();
        let label_data: Vec<i32> = batch.labels.into_data().to_vec().unwrap();

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
