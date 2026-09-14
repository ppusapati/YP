//! Per-task heads trained on frozen backbone embeddings.
//!
//! With the backbone frozen, each image's embedding is fixed, so training a
//! head is a small dense problem: embed once (cached on disk), then fit a
//! one-hidden-layer MLP per task in seconds instead of hours. The trained
//! heads are spliced back onto the backbone by [`crate::compose`] so serving
//! all tasks costs a single forward pass.

use std::path::Path;

use burn::module::AutodiffModule;
use burn::nn::{Dropout, DropoutConfig, Linear, LinearConfig};
use burn::optim::{AdamWConfig, GradientsParams, Optimizer};
use burn::prelude::*;
use rand::seq::SliceRandom;
use rand::{Rng, SeedableRng};

use crate::augment::Augmenter;
use crate::backbone::{Backbone, EmbeddingCache};
use crate::backend::{InferBackend, TrainBackend};
use crate::compose::HeadSpec;
use crate::config::HeadConfig;
use crate::dataset::Sample;
use crate::training::{loss_config, LossOptions};

/// A classification head over a frozen embedding.
#[derive(Module, Debug)]
pub struct HeadMlp<B: Backend> {
    fc1: Linear<B>,
    fc2: Linear<B>,
    dropout: Dropout,
}

impl<B: Backend> HeadMlp<B> {
    pub fn new(
        embedding_dim: usize,
        hidden: usize,
        num_classes: usize,
        dropout: f64,
        device: &B::Device,
    ) -> Self {
        Self {
            fc1: LinearConfig::new(embedding_dim, hidden.max(1)).init(device),
            fc2: LinearConfig::new(hidden.max(1), num_classes).init(device),
            dropout: DropoutConfig::new(dropout.clamp(0.0, 0.95)).init(),
        }
    }

    pub fn forward(&self, x: Tensor<B, 2>) -> Tensor<B, 2> {
        let x = self.fc1.forward(x);
        let x = burn::tensor::activation::relu(x);
        let x = self.dropout.forward(x);
        self.fc2.forward(x)
    }

    /// Weights in `(weight [in, out], bias [out], fan_in, fan_out)` order,
    /// matching ONNX `Gemm` with `transB = 0`.
    pub fn layers(&self) -> Vec<(Vec<f32>, Vec<f32>, usize, usize)> {
        [&self.fc1, &self.fc2]
            .iter()
            .map(|linear| {
                let weight = linear.weight.val();
                let [fan_in, fan_out] = weight.dims();
                let w: Vec<f32> = weight.into_data().to_vec().unwrap();
                let b: Vec<f32> = match &linear.bias {
                    Some(bias) => bias.val().into_data().to_vec().unwrap(),
                    None => vec![0.0; fan_out],
                };
                (w, b, fan_in, fan_out)
            })
            .collect()
    }
}

/// A sample reduced to its embedding.
#[derive(Debug, Clone)]
pub struct EmbeddedSample {
    pub id: String,
    pub embedding: Vec<f32>,
    pub label_idx: usize,
}

/// Outcome of fitting one head.
#[derive(Debug, Clone)]
pub struct HeadTrainingResult {
    pub task: String,
    pub best_val_acc: f64,
    pub test_acc: f64,
    pub final_epoch: usize,
    pub n_train: usize,
    pub layers: Vec<(Vec<f32>, Vec<f32>, usize, usize)>,
}

impl HeadTrainingResult {
    pub fn into_head_spec(self, labels: Vec<String>) -> HeadSpec {
        HeadSpec {
            task: self.task,
            layers: self.layers,
            labels,
        }
    }
}

/// Embed every sample, reusing cached vectors and adding `augment_passes`
/// augmented copies per sample when an augmenter is supplied.
///
/// Augmented copies are materialised once rather than re-drawn per epoch: the
/// backbone pass dominates the cost, so a fixed enlarged set buys most of the
/// regularisation benefit at a fraction of the time.
pub fn embed_samples(
    backbone: &Backbone,
    samples: &[Sample],
    cache: &mut EmbeddingCache,
    augmenter: Option<&Augmenter>,
    augment_passes: u32,
) -> anyhow::Result<Vec<EmbeddedSample>> {
    let passes = if augmenter.is_some() {
        augment_passes
    } else {
        0
    };
    let mut out = Vec::with_capacity(samples.len() * (1 + passes as usize));
    let mut computed = 0usize;
    let mut failed = 0usize;

    for sample in samples {
        for pass in 0..=passes {
            let key = if pass == 0 {
                sample.id.clone()
            } else {
                format!("{}#{pass}", sample.id)
            };
            if let Some(embedding) = cache.get(&key) {
                out.push(EmbeddedSample {
                    id: key,
                    embedding: embedding.clone(),
                    label_idx: sample.label_idx,
                });
                continue;
            }

            let embedding = if pass == 0 {
                backbone.embed_file(&sample.image_path)
            } else {
                image::open(&sample.image_path)
                    .map_err(anyhow::Error::from)
                    .and_then(|img| {
                        let augmented = augmenter
                            .expect("augmenter present when passes > 0")
                            .apply(&img, &sample.id, pass as u64);
                        backbone.embed_rgb(&augmented)
                    })
            };

            match embedding {
                Ok(values) => {
                    computed += 1;
                    cache.insert(key.clone(), values.clone());
                    out.push(EmbeddedSample {
                        id: key,
                        embedding: values,
                        label_idx: sample.label_idx,
                    });
                }
                Err(e) => {
                    failed += 1;
                    tracing::warn!(
                        path = %sample.image_path.display(),
                        error = %e,
                        "skipping sample the backbone could not embed"
                    );
                }
            }
        }
    }

    tracing::info!(
        embeddings = out.len(),
        computed,
        cached = out.len().saturating_sub(computed),
        failed,
        "embeddings ready"
    );
    if out.is_empty() {
        anyhow::bail!("no samples could be embedded");
    }
    Ok(out)
}

/// Path of the embedding cache for a task and backbone.
pub fn cache_path(cache_dir: &Path, task: &str, backbone: &Backbone) -> std::path::PathBuf {
    cache_dir.join(format!("{task}-{}.embcache", backbone.cache_key()))
}

/// Fit one head on precomputed embeddings.
pub fn train_head(
    task: &str,
    cfg: &HeadConfig,
    num_classes: usize,
    train: &[EmbeddedSample],
    val: &[EmbeddedSample],
    test: &[EmbeddedSample],
    loss_opts: &LossOptions,
) -> anyhow::Result<HeadTrainingResult> {
    if train.is_empty() {
        anyhow::bail!("task {task}: no training embeddings");
    }
    let embedding_dim = train[0].embedding.len();
    if let Some(bad) = train.iter().find(|s| s.embedding.len() != embedding_dim) {
        anyhow::bail!(
            "task {task}: embedding width differs between samples ({} vs {})",
            bad.embedding.len(),
            embedding_dim
        );
    }

    let device = <TrainBackend as Backend>::Device::default();
    let mut model: HeadMlp<TrainBackend> = HeadMlp::new(
        embedding_dim,
        cfg.hidden_size,
        num_classes,
        cfg.dropout,
        &device,
    );
    let mut optimizer = AdamWConfig::new()
        .with_weight_decay(cfg.weight_decay as f32)
        .init();

    let batch_size = cfg.batch_size.max(1);
    let mut order: Vec<usize> = (0..train.len()).collect();
    let mut rng = rand::rngs::StdRng::seed_from_u64(hash_seed(task));

    let mut best_val_acc = -1.0f64;
    let mut best_model = model.clone();
    let mut final_epoch = 0usize;
    let mut patience = 0usize;

    tracing::info!(
        task,
        embedding_dim,
        num_classes,
        train = train.len(),
        val = val.len(),
        test = test.len(),
        backend = crate::backend::NAME,
        "training head on frozen embeddings"
    );

    for epoch in 1..=cfg.num_epochs.max(1) {
        order.shuffle(&mut rng);
        let mut total_loss = 0.0;
        let mut correct = 0usize;

        for chunk in order.chunks(batch_size) {
            let batch: Vec<&EmbeddedSample> = chunk.iter().map(|&i| &train[i]).collect();
            let (x, y) = to_tensors::<TrainBackend>(&batch, embedding_dim, &device);

            let logits = model.forward(x);
            let loss = loss_config(loss_opts)
                .init(&logits.device())
                .forward(logits.clone(), y.clone());
            let loss_value: f64 = loss.clone().into_scalar().elem();
            total_loss += loss_value * batch.len() as f64;
            correct += count_correct(logits, y);

            let grads = GradientsParams::from_grads(loss.backward(), &model);
            model = optimizer.step(cfg.learning_rate, model, grads);
        }

        // valid() drops autodiff and disables dropout for evaluation.
        let eval_model = model.valid();
        let val_acc = if val.is_empty() {
            correct as f64 / train.len() as f64
        } else {
            accuracy(&eval_model, val, embedding_dim, batch_size)
        };

        tracing::debug!(
            task,
            epoch,
            train_loss = format!("{:.4}", total_loss / train.len() as f64),
            train_acc = format!("{:.4}", correct as f64 / train.len() as f64),
            val_acc = format!("{val_acc:.4}"),
            "head epoch"
        );

        if val_acc > best_val_acc {
            best_val_acc = val_acc;
            best_model = model.clone();
            final_epoch = epoch;
            patience = 0;
        } else {
            patience += 1;
            if patience >= cfg.early_stopping_patience.max(1) {
                tracing::info!(task, epoch, "head early stopping");
                break;
            }
        }
    }

    let best = best_model.valid();
    let test_acc = if test.is_empty() {
        best_val_acc
    } else {
        accuracy(&best, test, embedding_dim, batch_size)
    };

    tracing::info!(
        task,
        best_val_acc = format!("{best_val_acc:.4}"),
        test_acc = format!("{test_acc:.4}"),
        epoch = final_epoch,
        "head trained"
    );

    Ok(HeadTrainingResult {
        task: task.to_string(),
        best_val_acc,
        test_acc,
        final_epoch,
        n_train: train.len(),
        layers: best.layers(),
    })
}

fn hash_seed(task: &str) -> u64 {
    task.bytes().fold(0xcbf29ce484222325u64, |h, b| {
        (h ^ b as u64).wrapping_mul(0x100000001b3)
    })
}

fn to_tensors<B: Backend>(
    batch: &[&EmbeddedSample],
    embedding_dim: usize,
    device: &B::Device,
) -> (Tensor<B, 2>, Tensor<B, 1, Int>) {
    let mut values = Vec::with_capacity(batch.len() * embedding_dim);
    let mut labels = Vec::with_capacity(batch.len());
    for sample in batch {
        values.extend_from_slice(&sample.embedding);
        labels.push(sample.label_idx as i32);
    }
    let x = Tensor::<B, 1>::from_floats(values.as_slice(), device)
        .reshape([batch.len(), embedding_dim]);
    let y = Tensor::<B, 1, Int>::from_ints(labels.as_slice(), device);
    (x, y)
}

fn count_correct<B: Backend>(logits: Tensor<B, 2>, labels: Tensor<B, 1, Int>) -> usize {
    let predictions = logits.argmax(1).squeeze::<1>(1);
    let matches: i32 = predictions.equal(labels).int().sum().into_scalar().elem();
    matches as usize
}

fn accuracy(
    model: &HeadMlp<InferBackend>,
    samples: &[EmbeddedSample],
    embedding_dim: usize,
    batch_size: usize,
) -> f64 {
    if samples.is_empty() {
        return 0.0;
    }
    let device = <InferBackend as Backend>::Device::default();
    let mut correct = 0usize;
    for chunk in samples.chunks(batch_size.max(1)) {
        let batch: Vec<&EmbeddedSample> = chunk.iter().collect();
        let (x, y) = to_tensors::<InferBackend>(&batch, embedding_dim, &device);
        correct += count_correct(model.forward(x), y);
    }
    correct as f64 / samples.len() as f64
}

/// Inverse-frequency class weights over embedded samples, mirroring the
/// weighting the from-scratch trainer applies.
pub fn class_weights(samples: &[EmbeddedSample], num_classes: usize) -> Vec<f32> {
    if num_classes == 0 || samples.is_empty() {
        return Vec::new();
    }
    let mut counts = vec![0.0f64; num_classes];
    for s in samples {
        if s.label_idx < num_classes {
            counts[s.label_idx] += 1.0;
        }
    }
    let present: Vec<f64> = counts.iter().copied().filter(|&c| c > 0.0).collect();
    if present.is_empty() {
        return Vec::new();
    }
    let mut weights: Vec<f64> = counts
        .iter()
        .map(|&c| if c > 0.0 { 1.0 / c } else { 0.0 })
        .collect();
    let mean = weights.iter().filter(|&&w| w > 0.0).sum::<f64>() / present.len() as f64;
    if mean > 0.0 {
        for w in &mut weights {
            *w /= mean;
        }
    }
    weights.iter().map(|&w| w as f32).collect()
}

/// Random draw helper shared by tests and any caller wanting reproducible
/// synthetic embeddings.
pub fn synthetic_embeddings(
    num_classes: usize,
    per_class: usize,
    dim: usize,
    seed: u64,
) -> Vec<EmbeddedSample> {
    let mut rng = rand::rngs::StdRng::seed_from_u64(seed);
    // One random prototype per class, plus noise: linearly separable enough
    // that a working trainer reaches high accuracy quickly.
    let prototypes: Vec<Vec<f32>> = (0..num_classes)
        .map(|_| (0..dim).map(|_| rng.gen_range(-1.0f32..1.0)).collect())
        .collect();
    let mut out = Vec::with_capacity(num_classes * per_class);
    for (label_idx, prototype) in prototypes.iter().enumerate() {
        for i in 0..per_class {
            let embedding = prototype
                .iter()
                .map(|&p| p + rng.gen_range(-0.25f32..0.25))
                .collect();
            out.push(EmbeddedSample {
                id: format!("c{label_idx}_{i}"),
                embedding,
                label_idx,
            });
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::augment::Augmenter;
    use crate::compose::synthetic::synthetic_backbone;
    use crate::config::{AugmentationConfig, BackboneConfig};

    fn head_cfg() -> HeadConfig {
        HeadConfig {
            hidden_size: 16,
            num_epochs: 40,
            batch_size: 16,
            learning_rate: 0.01,
            weight_decay: 0.0,
            dropout: 0.0,
            label_smoothing: 0.0,
            early_stopping_patience: 40,
            augment_passes: 0,
        }
    }

    fn split(samples: &[EmbeddedSample]) -> (Vec<EmbeddedSample>, Vec<EmbeddedSample>) {
        let cut = samples.len() * 3 / 4;
        (samples[..cut].to_vec(), samples[cut..].to_vec())
    }

    #[test]
    fn head_learns_separable_embeddings() {
        let mut samples = synthetic_embeddings(3, 40, 12, 11);
        // Interleave so the split covers every class.
        samples.sort_by_key(|s| s.id.chars().rev().collect::<String>());
        let (train, held_out) = split(&samples);

        let result = train_head(
            "disease",
            &head_cfg(),
            3,
            &train,
            &held_out,
            &held_out,
            &LossOptions::default(),
        )
        .unwrap();

        assert!(
            result.test_acc > 0.85,
            "expected the head to learn separable classes, got {:.3}",
            result.test_acc
        );
        assert_eq!(result.layers.len(), 2);
        assert_eq!(result.layers[0].2, 12, "fan-in must match embedding width");
        assert_eq!(result.layers[1].3, 3, "fan-out must match class count");
        assert_eq!(result.layers[0].0.len(), 12 * 16);
        assert_eq!(result.layers[1].1.len(), 3);
        assert!(result.final_epoch >= 1);
    }

    #[test]
    fn head_weights_compose_into_a_valid_spec() {
        let samples = synthetic_embeddings(2, 20, 8, 5);
        let result = train_head(
            "pest",
            &head_cfg(),
            2,
            &samples,
            &[],
            &[],
            &LossOptions::default(),
        )
        .unwrap();
        let spec = result.into_head_spec(vec!["none".into(), "aphid".into()]);
        assert_eq!(spec.num_classes(), 2);

        // Splicing onto a backbone with a matching embedding width must work.
        let backbone = synthetic_backbone(32, 8, 100);
        let composed = crate::compose::compose_bytes(&backbone, "embedding", &[spec]).unwrap();
        let graph = crate::compose::decode_model(&composed)
            .unwrap()
            .graph
            .unwrap();
        assert_eq!(graph.output[0].name, "logits_pest");
    }

    #[test]
    fn empty_training_set_is_rejected() {
        let err = train_head(
            "disease",
            &head_cfg(),
            2,
            &[],
            &[],
            &[],
            &LossOptions::default(),
        )
        .unwrap_err()
        .to_string();
        assert!(err.contains("no training embeddings"), "{err}");
    }

    #[test]
    fn ragged_embeddings_are_rejected() {
        let mut samples = synthetic_embeddings(2, 4, 6, 2);
        samples[3].embedding.push(0.0);
        let err = train_head(
            "disease",
            &head_cfg(),
            2,
            &samples,
            &[],
            &[],
            &LossOptions::default(),
        )
        .unwrap_err()
        .to_string();
        assert!(err.contains("embedding width differs"), "{err}");
    }

    #[test]
    fn class_weights_favour_rare_classes() {
        let mut samples = synthetic_embeddings(2, 1, 4, 1);
        samples.extend(synthetic_embeddings(1, 9, 4, 2).into_iter().map(|mut s| {
            s.label_idx = 0;
            s
        }));
        let w = class_weights(&samples, 2);
        assert_eq!(w.len(), 2);
        assert!(w[1] > w[0], "rare class should weigh more: {w:?}");
        assert!(class_weights(&[], 2).is_empty());
    }

    /// End-to-end: real image files → backbone embeddings → cache reuse.
    #[test]
    fn embedding_pipeline_uses_the_cache_and_augments() {
        let dir = tempfile::tempdir().unwrap();
        let onnx_path = dir.path().join("backbone.onnx");
        std::fs::write(&onnx_path, synthetic_backbone(32, 8, 10)).unwrap();

        let backbone = Backbone::load(&BackboneConfig {
            path: onnx_path.display().to_string(),
            embedding_output: "embedding".into(),
            ..Default::default()
        })
        .unwrap();
        assert_eq!(backbone.input_size(), 32);
        assert_eq!(backbone.embedding_dim(), 8);

        let mut samples = Vec::new();
        for i in 0..3 {
            let path = dir.path().join(format!("img{i}.png"));
            let img = image::RgbImage::from_fn(48, 40, |x, y| {
                image::Rgb([(x * 5 + i * 30) as u8, (y * 6) as u8, (x + y) as u8])
            });
            img.save(&path).unwrap();
            samples.push(Sample {
                id: format!("s{i}"),
                image_path: path,
                label: "a".into(),
                label_idx: 0,
                confidence: 1.0,
                weight: 1.0,
                provenance: "human".into(),
                crop: String::new(),
                reviewed: true,
            });
        }

        let aug = Augmenter::new(&AugmentationConfig {
            horizontal_flip: true,
            vertical_flip: false,
            rotation_limit: 10,
            brightness_range: [0.8, 1.2],
            random_crop_scale: [0.8, 1.0],
            contrast_range: [0.9, 1.1],
            gamma_range: [0.9, 1.1],
            color_cast: 0.05,
            background_prob: 0.0,
            motion_blur_prob: 0.0,
            motion_blur_max_len: 3,
            occlusion_prob: 0.0,
            occlusion_max_patches: 0,
            occlusion_max_frac: 0.0,
            noise_std: 0.0,
            seed: 3,
        });

        let cache_file = cache_path(dir.path(), "disease", &backbone);
        let mut cache = EmbeddingCache::load(&cache_file, backbone.embedding_dim());
        let embedded = embed_samples(&backbone, &samples, &mut cache, Some(&aug), 1).unwrap();
        // One plain embedding plus one augmented copy per sample.
        assert_eq!(embedded.len(), 6);
        assert!(embedded.iter().all(|e| e.embedding.len() == 8));
        let plain: Vec<&EmbeddedSample> = embedded.iter().filter(|e| !e.id.contains('#')).collect();
        let augmented: Vec<&EmbeddedSample> =
            embedded.iter().filter(|e| e.id.contains('#')).collect();
        assert_eq!(plain.len(), 3);
        assert_ne!(
            plain[0].embedding, augmented[0].embedding,
            "augmented copies must differ from the plain embedding"
        );

        cache.save(&cache_file).unwrap();
        assert!(cache_file.exists());

        // A second run reads the cache and returns identical vectors.
        let mut reloaded = EmbeddingCache::load(&cache_file, backbone.embedding_dim());
        assert_eq!(reloaded.len(), 6);
        let again = embed_samples(&backbone, &samples, &mut reloaded, Some(&aug), 1).unwrap();
        assert_eq!(again.len(), embedded.len());
        for (a, b) in again.iter().zip(&embedded) {
            assert_eq!(a.id, b.id);
            assert_eq!(a.embedding, b.embedding);
        }

        // Unreadable images are skipped rather than failing the run.
        let mut broken = samples.clone();
        broken.push(Sample {
            id: "broken".into(),
            image_path: dir.path().join("missing.png"),
            label: "a".into(),
            label_idx: 0,
            confidence: 1.0,
            weight: 1.0,
            provenance: "human".into(),
            crop: String::new(),
            reviewed: false,
        });
        let mut fresh = EmbeddingCache::new(backbone.embedding_dim());
        let partial = embed_samples(&backbone, &broken, &mut fresh, None, 0).unwrap();
        assert_eq!(partial.len(), 3);
    }
}
