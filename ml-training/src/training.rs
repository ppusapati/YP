use std::path::Path;

use burn::data::dataloader::batcher::Batcher;
use burn::optim::AdamWConfig;
use burn::prelude::*;
use burn::record::{CompactRecorder, Recorder};
use burn_autodiff::Autodiff;
use burn_ndarray::NdArray;

use crate::config::TaskConfig;
use crate::dataset::{PlantBatcher, Sample};
use crate::model::PlantCnn;

type TrainBackend = Autodiff<NdArray>;
type _InferBackend = NdArray;

pub struct TrainingResult {
    pub best_val_acc: f64,
    pub test_acc: f64,
    pub final_epoch: usize,
    pub model_path: String,
}

pub fn train(
    task: &str,
    task_config: &TaskConfig,
    train_samples: Vec<Sample>,
    val_samples: Vec<Sample>,
    test_samples: Vec<Sample>,
    num_classes: usize,
    output_dir: &Path,
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

    let batcher = PlantBatcher::new(task_config.input_size);
    let batch_size = task_config.batch_size;

    let mut best_val_acc = 0.0f64;
    let mut patience_counter = 0usize;
    let mut final_epoch = 0usize;

    for epoch in 1..=task_config.num_epochs {
        let (train_loss, train_acc) = train_epoch(
            &mut model,
            &mut optimizer,
            &train_samples,
            &batcher,
            batch_size,
            task_config.learning_rate,
            epoch,
        );

        let (val_loss, val_acc) = evaluate(&model, &val_samples, &batcher, batch_size);

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
    let best_model: PlantCnn<TrainBackend> = PlantCnn::new(num_classes, &device).load_record(best_record);

    let (test_loss, test_acc) = evaluate(&best_model, &test_samples, &batcher, batch_size);
    tracing::info!(
        test_loss = format!("{test_loss:.4}"),
        test_acc = format!("{test_acc:.4}"),
        "test evaluation complete"
    );

    let model_path = output_dir.join("best_model").to_string_lossy().to_string();

    Ok(TrainingResult {
        best_val_acc,
        test_acc,
        final_epoch,
        model_path,
    })
}

fn train_epoch(
    model: &mut PlantCnn<TrainBackend>,
    optimizer: &mut impl burn::optim::Optimizer<PlantCnn<TrainBackend>, TrainBackend>,
    samples: &[Sample],
    batcher: &PlantBatcher,
    batch_size: usize,
    lr: f64,
    _epoch: usize,
) -> (f64, f64) {
    let mut total_loss = 0.0;
    let mut correct = 0usize;
    let mut total = 0usize;

    for chunk in samples.chunks(batch_size) {
        let batch = batcher.batch(chunk.to_vec());
        let batch_len = chunk.len();

        let logits = model.forward(batch.images);
        let loss = burn::nn::loss::CrossEntropyLossConfig::new()
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

    let avg_loss = if total > 0 { total_loss / total as f64 } else { 0.0 };
    let accuracy = if total > 0 { correct as f64 / total as f64 } else { 0.0 };
    (avg_loss, accuracy)
}

fn evaluate(
    model: &PlantCnn<TrainBackend>,
    samples: &[Sample],
    batcher: &PlantBatcher,
    batch_size: usize,
) -> (f64, f64) {
    let mut total_loss = 0.0;
    let mut correct = 0usize;
    let mut total = 0usize;

    for chunk in samples.chunks(batch_size) {
        let batch = batcher.batch(chunk.to_vec());
        let batch_len = chunk.len();

        let logits = model.forward(batch.images);
        let loss = burn::nn::loss::CrossEntropyLossConfig::new()
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

    let avg_loss = if total > 0 { total_loss / total as f64 } else { 0.0 };
    let accuracy = if total > 0 { correct as f64 / total as f64 } else { 0.0 };
    (avg_loss, accuracy)
}
