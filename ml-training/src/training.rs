use std::path::Path;

use crate::config::{AugmentationConfig, TaskConfig};
use crate::dataset::{PlantBatcher, Sample};
use crate::model::PlantCnn;
use burn::data::dataloader::batcher::Batcher;
use burn::optim::AdamWConfig;
use burn::prelude::*;
use burn::record::{CompactRecorder, Recorder};

use crate::backend::TrainBackend;

pub struct TrainingResult {
    pub best_val_acc: f64,
    pub test_acc: f64,
    pub final_epoch: usize,
    pub model_path: String,
    /// Training samples the best model confidently disagrees with.
    pub label_noise: Vec<NoisySample>,
}

/// A training sample whose label the trained model contradicts with high
/// confidence — the confident-learning signal for review.
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct NoisySample {
    pub id: String,
    pub label: String,
    pub predicted: String,
    pub predicted_prob: f32,
    pub label_prob: f32,
    pub provenance: String,
}

/// Flag samples where p(predicted) >= `confident` and p(label) <= `doubtful`.
pub const NOISE_CONFIDENT_PROB: f32 = 0.9;
pub const NOISE_DOUBTFUL_PROB: f32 = 0.1;

/// Options controlling the loss.
#[derive(Debug, Clone, Default)]
pub struct LossOptions {
    /// Per-class weights (mean 1); empty disables weighting.
    pub class_weights: Vec<f32>,
    /// Label smoothing in [0, 1); 0 disables.
    pub label_smoothing: f64,
}

pub fn loss_config(opts: &LossOptions) -> burn::nn::loss::CrossEntropyLossConfig {
    let mut cfg = burn::nn::loss::CrossEntropyLossConfig::new();
    if !opts.class_weights.is_empty() {
        cfg = cfg.with_weights(Some(opts.class_weights.clone()));
    }
    if opts.label_smoothing > 0.0 {
        cfg = cfg.with_smoothing(Some(opts.label_smoothing as f32));
    }
    cfg
}

pub fn train(
    task: &str,
    task_config: &TaskConfig,
    train_samples: Vec<Sample>,
    val_samples: Vec<Sample>,
    test_samples: Vec<Sample>,
    num_classes: usize,
    output_dir: &Path,
    loss_opts: &LossOptions,
    idx_to_label: &std::collections::HashMap<usize, String>,
    augmentation: Option<&AugmentationConfig>,
) -> anyhow::Result<TrainingResult> {
    let device = <TrainBackend as Backend>::Device::default();

    let model: PlantCnn<TrainBackend> = PlantCnn::new(num_classes, &device);
    tracing::info!(
        task = task,
        num_classes = num_classes,
        train = train_samples.len(),
        val = val_samples.len(),
        test = test_samples.len(),
        "starting training"
    );

    let mut model = model;
    let mut optimizer = AdamWConfig::new()
        .with_weight_decay(task_config.weight_decay as f32)
        .init();

    // Validation/test/noise detection see plain preprocessing; only training
    // batches are augmented, re-seeded each epoch.
    let batcher = PlantBatcher::new(task_config.input_size);
    let train_batcher = match augmentation {
        Some(cfg) => batcher.clone().with_augmentation(cfg),
        None => batcher.clone(),
    };
    let batch_size = task_config.batch_size;

    let mut best_val_acc = 0.0f64;
    let mut patience_counter = 0usize;
    let mut final_epoch = 0usize;

    for epoch in 1..=task_config.num_epochs {
        let (train_loss, train_acc) = train_epoch(
            &mut model,
            &mut optimizer,
            &train_samples,
            &train_batcher.for_epoch(epoch as u64),
            batch_size,
            task_config.learning_rate,
            epoch,
            loss_opts,
        );

        let (val_loss, val_acc) = evaluate(&model, &val_samples, &batcher, batch_size, loss_opts);

        tracing::info!(
            epoch = epoch,
            train_loss = format!("{train_loss:.4}"),
            train_acc = format!("{train_acc:.4}"),
            val_loss = format!("{val_loss:.4}"),
            val_acc = format!("{val_acc:.4}"),
            "epoch complete"
        );

        if val_acc > best_val_acc {
            best_val_acc = val_acc;
            patience_counter = 0;
            final_epoch = epoch;

            std::fs::create_dir_all(output_dir)?;
            let recorder = CompactRecorder::new();
            recorder
                .record(model.clone().into_record(), output_dir.join("best_model"))
                .map_err(|e| anyhow::anyhow!("failed to save model: {e}"))?;

            tracing::info!(val_acc = format!("{val_acc:.4}"), "new best model saved");
        } else {
            patience_counter += 1;
            if patience_counter >= task_config.early_stopping_patience {
                tracing::info!(epoch = epoch, "early stopping triggered");
                break;
            }
        }
    }

    let best_record = CompactRecorder::new()
        .load(output_dir.join("best_model"), &device)
        .map_err(|e| anyhow::anyhow!("failed to load best model: {e}"))?;
    let best_model: PlantCnn<TrainBackend> =
        PlantCnn::new(num_classes, &device).load_record(best_record);

    let (test_loss, test_acc) =
        evaluate(&best_model, &test_samples, &batcher, batch_size, loss_opts);
    tracing::info!(
        test_loss = format!("{test_loss:.4}"),
        test_acc = format!("{test_acc:.4}"),
        "test evaluation complete"
    );

    let label_noise = detect_label_noise(
        &best_model,
        &train_samples,
        &batcher,
        batch_size,
        idx_to_label,
    );
    if !label_noise.is_empty() {
        tracing::warn!(
            suspects = label_noise.len(),
            "training labels the model confidently contradicts; see label_noise_report.json"
        );
    }

    let model_path = output_dir.join("best_model").to_string_lossy().to_string();

    Ok(TrainingResult {
        best_val_acc,
        test_acc,
        final_epoch,
        model_path,
        label_noise,
    })
}

/// Confident-learning style check: samples the trained model assigns a high
/// probability to a different class than their label are likely mislabelled
/// and are surfaced for human review.
pub fn detect_label_noise(
    model: &PlantCnn<TrainBackend>,
    samples: &[Sample],
    batcher: &PlantBatcher,
    batch_size: usize,
    idx_to_label: &std::collections::HashMap<usize, String>,
) -> Vec<NoisySample> {
    let mut out = Vec::new();
    for chunk in samples.chunks(batch_size.max(1)) {
        let batch = batcher.batch(chunk.to_vec());
        let logits = model.forward(batch.images);
        let [n, k] = logits.dims();
        let probs: Vec<f32> = burn::tensor::activation::softmax(logits, 1)
            .into_data()
            .to_vec()
            .unwrap();
        for (row, sample) in chunk.iter().enumerate().take(n) {
            let p = &probs[row * k..(row + 1) * k];
            let (pred, pred_prob) = p.iter().enumerate().fold(
                (0usize, f32::MIN),
                |acc, (i, &v)| if v > acc.1 { (i, v) } else { acc },
            );
            let label_prob = p.get(sample.label_idx).copied().unwrap_or(0.0);
            if pred != sample.label_idx
                && pred_prob >= NOISE_CONFIDENT_PROB
                && label_prob <= NOISE_DOUBTFUL_PROB
            {
                out.push(NoisySample {
                    id: sample.id.clone(),
                    label: sample.label.clone(),
                    predicted: idx_to_label
                        .get(&pred)
                        .cloned()
                        .unwrap_or_else(|| format!("class_{pred}")),
                    predicted_prob: pred_prob,
                    label_prob,
                    provenance: sample.provenance.clone(),
                });
            }
        }
    }
    out.sort_by(|a, b| {
        b.predicted_prob
            .partial_cmp(&a.predicted_prob)
            .unwrap_or(std::cmp::Ordering::Equal)
    });
    out
}

fn train_epoch(
    model: &mut PlantCnn<TrainBackend>,
    optimizer: &mut impl burn::optim::Optimizer<PlantCnn<TrainBackend>, TrainBackend>,
    samples: &[Sample],
    batcher: &PlantBatcher,
    batch_size: usize,
    lr: f64,
    _epoch: usize,
    loss_opts: &LossOptions,
) -> (f64, f64) {
    let mut total_loss = 0.0;
    let mut correct = 0usize;
    let mut total = 0usize;

    for chunk in samples.chunks(batch_size) {
        let batch = batcher.batch(chunk.to_vec());
        let batch_len = chunk.len();

        let logits = model.forward(batch.images);
        let loss = loss_config(loss_opts)
            .init(&logits.device())
            .forward(logits.clone(), batch.labels.clone());

        let loss_val: f64 = loss.clone().into_scalar().elem();
        total_loss += loss_val * batch_len as f64;

        let predictions = logits.argmax(1).squeeze::<1>(1);
        let matches = predictions.equal(batch.labels);
        let batch_correct: i32 = matches.int().sum().into_scalar().elem();
        correct += batch_correct as usize;
        total += batch_len;

        let grads = loss.backward();
        let grads = burn::optim::GradientsParams::from_grads(grads, model);
        *model = optimizer.step(lr, model.clone(), grads);
    }

    let avg_loss = if total > 0 {
        total_loss / total as f64
    } else {
        0.0
    };
    let accuracy = if total > 0 {
        correct as f64 / total as f64
    } else {
        0.0
    };
    (avg_loss, accuracy)
}

fn evaluate(
    model: &PlantCnn<TrainBackend>,
    samples: &[Sample],
    batcher: &PlantBatcher,
    batch_size: usize,
    loss_opts: &LossOptions,
) -> (f64, f64) {
    let mut total_loss = 0.0;
    let mut correct = 0usize;
    let mut total = 0usize;

    for chunk in samples.chunks(batch_size) {
        let batch = batcher.batch(chunk.to_vec());
        let batch_len = chunk.len();

        let logits = model.forward(batch.images);
        let loss = loss_config(loss_opts)
            .init(&logits.device())
            .forward(logits.clone(), batch.labels.clone());

        let loss_val: f64 = loss.into_scalar().elem();
        total_loss += loss_val * batch_len as f64;

        let predictions = logits.argmax(1).squeeze::<1>(1);
        let matches = predictions.equal(batch.labels);
        let batch_correct: i32 = matches.int().sum().into_scalar().elem();
        correct += batch_correct as usize;
        total += batch_len;
    }

    let avg_loss = if total > 0 {
        total_loss / total as f64
    } else {
        0.0
    };
    let accuracy = if total > 0 {
        correct as f64 / total as f64
    } else {
        0.0
    };
    (avg_loss, accuracy)
}
