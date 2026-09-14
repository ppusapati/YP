//! Training data loading with human review, provenance, balance reporting,
//! stratified splitting, and content-hashed dataset snapshots.
//!
//! Samples are collected by the AI gateway as `{task}/manifest.jsonl` plus a
//! `labels/{id}.json` record per image. Reviewer decisions stored on those
//! records are applied here: corrections override the auto-label, rejections
//! drop the sample, and confirmations count as human-labelled.

use std::collections::{BTreeMap, HashMap};
use std::path::{Path, PathBuf};

use burn::data::dataloader::batcher::Batcher;
use burn::prelude::*;
use chrono::Utc;
use image::imageops::FilterType;
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};

use crate::augment::Augmenter;
use crate::config::{AugmentationConfig, DataConfig, ProvenanceWeights};

/// Where and when a sample was captured.
///
/// Kept so evaluation can slice metrics by region and season: a model that is
/// fine on average but poor in one district or one growing season is a model
/// that will be wrong exactly when a farmer relies on it.
#[derive(Debug, Clone, Default, PartialEq)]
pub struct Capture {
    pub latitude: f64,
    pub longitude: f64,
    /// RFC 3339 capture time from the manifest.
    pub timestamp: String,
}

impl Capture {
    fn has_location(&self) -> bool {
        // Null Island is the sentinel for "no location recorded".
        (self.latitude != 0.0 || self.longitude != 0.0)
            && self.latitude.abs() <= 90.0
            && self.longitude.abs() <= 180.0
    }

    /// One-degree grid cell, e.g. `18N 78E`. Roughly a district; fine enough
    /// to separate growing areas, coarse enough to keep slices populated.
    pub fn region(&self) -> String {
        if !self.has_location() {
            return String::new();
        }
        let lat = self.latitude.floor();
        let lon = self.longitude.floor();
        format!(
            "{}{} {}{}",
            lat.abs(),
            if lat >= 0.0 { "N" } else { "S" },
            lon.abs(),
            if lon >= 0.0 { "E" } else { "W" }
        )
    }

    /// Meteorological season, flipped below the equator. Empty when the
    /// timestamp cannot be parsed.
    pub fn season(&self) -> String {
        let Some(month) = self.month() else {
            return String::new();
        };
        // Shift the southern hemisphere by half a year.
        let month = if self.latitude < 0.0 {
            (month + 5) % 12 + 1
        } else {
            month
        };
        match month {
            12 | 1 | 2 => "winter",
            3..=5 => "spring",
            6..=8 => "summer",
            _ => "autumn",
        }
        .to_string()
    }

    fn month(&self) -> Option<u32> {
        use chrono::Datelike;
        chrono::DateTime::parse_from_rfc3339(self.timestamp.trim())
            .ok()
            .map(|dt| dt.month())
    }
}

#[derive(Debug, Clone, Default)]
pub struct Sample {
    pub id: String,
    pub image_path: PathBuf,
    pub label: String,
    pub label_idx: usize,
    pub confidence: f64,
    /// Trust weight from provenance (human > external API > local model).
    pub weight: f64,
    pub provenance: String,
    pub crop: String,
    pub reviewed: bool,
    pub capture: Capture,
}

impl Sample {
    /// Dimension → value pairs for evaluation slicing. Blank values are
    /// omitted so a missing field does not become a slice of its own.
    pub fn slice_keys(&self) -> std::collections::BTreeMap<String, String> {
        let mut out = std::collections::BTreeMap::new();
        for (dim, value) in [
            ("crop", self.crop.clone()),
            ("source", self.provenance.clone()),
            ("region", self.capture.region()),
            ("season", self.capture.season()),
        ] {
            if !value.trim().is_empty() {
                out.insert(dim.to_string(), value);
            }
        }
        out
    }
}

/// A sample after manifest + label-file loading, before label-map indexing.
#[derive(Debug, Clone, Default)]
pub struct RawSample {
    pub id: String,
    pub image_path: PathBuf,
    pub label: String,
    pub confidence: f64,
    pub weight: f64,
    pub provenance: String,
    pub crop: String,
    pub reviewed: bool,
    pub capture: Capture,
}

#[derive(Debug, Clone, Deserialize)]
struct ManifestEntry {
    id: String,
    image: String,
    #[allow(dead_code)]
    labels: Vec<String>,
    #[serde(default)]
    timestamp: String,
}

#[derive(Debug, Clone, Deserialize)]
struct LabelFile {
    labels: Vec<LabelEntry>,
    #[serde(default)]
    provenance: Option<String>,
    #[serde(default)]
    review: Option<ReviewEntry>,
    #[serde(default)]
    context: Option<ContextEntry>,
}

#[derive(Debug, Clone, Deserialize)]
struct LabelEntry {
    name: String,
    confidence: f64,
}

#[derive(Debug, Clone, Deserialize)]
struct ReviewEntry {
    decision: String,
    #[serde(default)]
    corrected_label: String,
}

#[derive(Debug, Clone, Deserialize, Default)]
struct ContextEntry {
    #[serde(default)]
    crop: String,
    #[serde(default)]
    latitude: f64,
    #[serde(default)]
    longitude: f64,
}

pub struct PlantDataset {
    samples: Vec<Sample>,
    input_size: usize,
}

impl PlantDataset {
    pub fn new(samples: Vec<Sample>, input_size: usize) -> Self {
        Self {
            samples,
            input_size,
        }
    }

    pub fn len(&self) -> usize {
        self.samples.len()
    }

    pub fn is_empty(&self) -> bool {
        self.samples.is_empty()
    }

    pub fn get(&self, index: usize) -> Option<(Vec<f32>, usize)> {
        let sample = self.samples.get(index)?;
        let tensor_data = load_and_preprocess(&sample.image_path, self.input_size).ok()?;
        Some((tensor_data, sample.label_idx))
    }
}

/// Turns samples into normalised NCHW batches. With an augmenter attached
/// (training only) each image gets a reproducible per-sample, per-epoch draw.
#[derive(Clone)]
pub struct PlantBatcher {
    input_size: usize,
    augmenter: Option<Augmenter>,
    epoch: u64,
}

impl PlantBatcher {
    /// Plain preprocessing: what validation, test, and inference see.
    pub fn new(input_size: usize) -> Self {
        Self {
            input_size,
            augmenter: None,
            epoch: 0,
        }
    }

    /// Enable field-photo augmentation for training batches.
    pub fn with_augmentation(mut self, cfg: &AugmentationConfig) -> Self {
        self.augmenter = Some(Augmenter::new(cfg));
        self
    }

    /// Same batcher with a different augmentation salt (call once per epoch).
    pub fn for_epoch(&self, epoch: u64) -> Self {
        Self {
            epoch,
            ..self.clone()
        }
    }

    pub fn is_augmenting(&self) -> bool {
        self.augmenter.is_some()
    }

    fn load(&self, sample: &Sample) -> anyhow::Result<Vec<f32>> {
        match &self.augmenter {
            Some(aug) => {
                let img = image::open(&sample.image_path)?;
                let augmented = aug.apply(&img, &sample.id, self.epoch);
                Ok(preprocess_rgb(&augmented, self.input_size))
            }
            None => load_and_preprocess(&sample.image_path, self.input_size),
        }
    }
}

#[derive(Debug, Clone)]
pub struct PlantBatch<B: Backend> {
    pub images: Tensor<B, 4>,
    pub labels: Tensor<B, 1, Int>,
}

impl<B: Backend> Batcher<Sample, PlantBatch<B>> for PlantBatcher {
    fn batch(&self, items: Vec<Sample>) -> PlantBatch<B> {
        let batch_size = items.len();
        let c = 3usize;
        let h = self.input_size;
        let w = self.input_size;

        let mut image_data = Vec::with_capacity(batch_size * c * h * w);
        let mut label_data = Vec::with_capacity(batch_size);

        for sample in &items {
            match self.load(sample) {
                Ok(pixels) => {
                    image_data.extend_from_slice(&pixels);
                    label_data.push(sample.label_idx as i32);
                }
                Err(e) => {
                    tracing::warn!(path = %sample.image_path.display(), "image load failed: {e}");
                    image_data.extend(vec![0.0f32; c * h * w]);
                    label_data.push(sample.label_idx as i32);
                }
            }
        }

        let device = B::Device::default();
        let images = Tensor::<B, 1>::from_floats(image_data.as_slice(), &device)
            .reshape([batch_size, c, h, w]);
        let labels = Tensor::<B, 1, Int>::from_ints(label_data.as_slice(), &device);

        PlantBatch { images, labels }
    }
}

/// Decode, resize, and ImageNet-normalise an image file into CHW floats.
/// This is the exact preprocessing the gateway's ONNX classifier reproduces.
pub fn load_and_preprocess(path: &Path, size: usize) -> anyhow::Result<Vec<f32>> {
    let img = image::open(path)?;
    Ok(preprocess_rgb(&img.to_rgb8(), size))
}

/// Resize an RGB image to `size`×`size` and ImageNet-normalise to CHW floats.
pub fn preprocess_rgb(rgb: &image::RgbImage, size: usize) -> Vec<f32> {
    preprocess_rgb_with(rgb, size, [0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
}

/// Resize and normalise with explicit per-channel mean/std, for backbones
/// trained with a different pixel convention.
pub fn preprocess_rgb_with(
    rgb: &image::RgbImage,
    size: usize,
    mean: [f32; 3],
    std: [f32; 3],
) -> Vec<f32> {
    let resized = image::imageops::resize(rgb, size as u32, size as u32, FilterType::Lanczos3);
    let rgb = &resized;

    let (w, h) = resized.dimensions();
    let mut channels = vec![0.0f32; 3 * (h as usize) * (w as usize)];

    for y in 0..h as usize {
        for x in 0..w as usize {
            let pixel = rgb.get_pixel(x as u32, y as u32);
            for c in 0..3 {
                let val = pixel[c] as f32 / 255.0;
                let normalized = (val - mean[c]) / std[c];
                channels[c * h as usize * w as usize + y * w as usize + x] = normalized;
            }
        }
    }

    channels
}

/// Read the manifest and every label record, applying reviewer decisions and
/// provenance weights. Unreviewed samples must meet `min_confidence`;
/// human-reviewed ones always qualify.
pub fn load_manifest(
    task_dir: &Path,
    min_confidence: f64,
    weights: &ProvenanceWeights,
) -> anyhow::Result<Vec<RawSample>> {
    let manifest_path = task_dir.join("manifest.jsonl");
    if !manifest_path.exists() {
        anyhow::bail!("no manifest found at {}", manifest_path.display());
    }

    let content = std::fs::read_to_string(&manifest_path)?;
    let mut results = Vec::new();
    let mut seen: HashMap<String, ()> = HashMap::new();

    for line in content.lines() {
        let line = line.trim();
        if line.is_empty() {
            continue;
        }
        let entry: ManifestEntry = match serde_json::from_str(line) {
            Ok(e) => e,
            Err(e) => {
                tracing::warn!(error = %e, "skipping malformed manifest line");
                continue;
            }
        };
        if seen.insert(entry.id.clone(), ()).is_some() {
            continue;
        }
        let image_path = PathBuf::from(&entry.image);
        if !image_path.exists() {
            continue;
        }

        let label_path = task_dir.join("labels").join(format!("{}.json", entry.id));
        let Ok(label_content) = std::fs::read_to_string(&label_path) else {
            continue;
        };
        let Ok(label_data) = serde_json::from_str::<LabelFile>(&label_content) else {
            continue;
        };
        let capture = Capture {
            latitude: label_data.context.as_ref().map_or(0.0, |c| c.latitude),
            longitude: label_data.context.as_ref().map_or(0.0, |c| c.longitude),
            timestamp: entry.timestamp.clone(),
        };
        let Some(raw) = resolve_sample(
            &entry.id,
            image_path,
            &label_data,
            min_confidence,
            weights,
            capture,
        ) else {
            continue;
        };
        results.push(raw);
    }

    Ok(results)
}

/// Apply review + provenance rules to one label record.
fn resolve_sample(
    id: &str,
    image_path: PathBuf,
    label_data: &LabelFile,
    min_confidence: f64,
    weights: &ProvenanceWeights,
    capture: Capture,
) -> Option<RawSample> {
    let crop = label_data
        .context
        .as_ref()
        .map(|c| c.crop.clone())
        .unwrap_or_default();
    let top = label_data.labels.iter().max_by(|a, b| {
        a.confidence
            .partial_cmp(&b.confidence)
            .unwrap_or(std::cmp::Ordering::Equal)
    });

    if let Some(review) = &label_data.review {
        match review.decision.as_str() {
            "rejected" => return None,
            "corrected" if !review.corrected_label.trim().is_empty() => {
                return Some(RawSample {
                    id: id.to_string(),
                    image_path,
                    label: review.corrected_label.trim().to_string(),
                    confidence: 1.0,
                    weight: weights.human,
                    provenance: "human".to_string(),
                    crop,
                    reviewed: true,
                    capture,
                });
            }
            "confirmed" => {
                let top = top?;
                return Some(RawSample {
                    id: id.to_string(),
                    image_path,
                    label: top.name.clone(),
                    confidence: top.confidence.max(0.99),
                    weight: weights.human,
                    provenance: "human".to_string(),
                    crop,
                    reviewed: true,
                    capture,
                });
            }
            _ => {}
        }
    }

    let top = top?;
    if top.confidence < min_confidence {
        return None;
    }
    let provenance = label_data
        .provenance
        .clone()
        .unwrap_or_else(|| "external_api".to_string());
    Some(RawSample {
        id: id.to_string(),
        image_path,
        label: top.name.clone(),
        confidence: top.confidence,
        weight: weights.for_provenance(&provenance),
        provenance,
        crop,
        reviewed: false,
        capture,
    })
}

pub fn build_label_map(raw: &[RawSample], min_per_class: usize) -> HashMap<String, usize> {
    let mut counts: HashMap<String, usize> = HashMap::new();
    for s in raw {
        *counts.entry(s.label.clone()).or_default() += 1;
    }
    let mut valid: Vec<String> = counts
        .into_iter()
        .filter(|(_, cnt)| *cnt >= min_per_class)
        .map(|(label, _)| label)
        .collect();
    valid.sort();
    valid
        .into_iter()
        .enumerate()
        .map(|(idx, label)| (label, idx))
        .collect()
}

// ---------------------------------------------------------------------------
// Class balance
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ClassStat {
    pub label: String,
    pub count: usize,
    pub weight_sum: f64,
    pub fraction: f64,
    pub reviewed: usize,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DatasetReport {
    pub task: String,
    pub loaded: usize,
    pub kept: usize,
    pub classes: Vec<ClassStat>,
    pub dropped_classes: Vec<(String, usize)>,
    /// Largest class count divided by smallest kept class count.
    pub imbalance_ratio: f64,
    pub provenance_counts: BTreeMap<String, usize>,
    pub crop_counts: BTreeMap<String, usize>,
    pub reviewed: usize,
    pub warnings: Vec<String>,
}

pub fn build_report(
    task: &str,
    raw: &[RawSample],
    label_map: &HashMap<String, usize>,
    min_per_class: usize,
) -> DatasetReport {
    let mut counts: BTreeMap<String, (usize, f64, usize)> = BTreeMap::new();
    let mut provenance_counts: BTreeMap<String, usize> = BTreeMap::new();
    let mut crop_counts: BTreeMap<String, usize> = BTreeMap::new();
    let mut reviewed = 0usize;
    let mut kept = 0usize;
    for s in raw {
        let e = counts.entry(s.label.clone()).or_insert((0, 0.0, 0));
        e.0 += 1;
        e.1 += s.weight;
        if s.reviewed {
            e.2 += 1;
        }
        if label_map.contains_key(&s.label) {
            kept += 1;
            *provenance_counts.entry(s.provenance.clone()).or_default() += 1;
            if !s.crop.is_empty() {
                *crop_counts.entry(s.crop.clone()).or_default() += 1;
            }
            if s.reviewed {
                reviewed += 1;
            }
        }
    }

    let mut classes = Vec::new();
    let mut dropped = Vec::new();
    for (label, (count, weight_sum, rev)) in &counts {
        if label_map.contains_key(label) {
            classes.push(ClassStat {
                label: label.clone(),
                count: *count,
                weight_sum: *weight_sum,
                fraction: if kept > 0 {
                    *count as f64 / kept as f64
                } else {
                    0.0
                },
                reviewed: *rev,
            });
        } else {
            dropped.push((label.clone(), *count));
        }
    }
    classes.sort_by(|a, b| b.count.cmp(&a.count));

    let max = classes.iter().map(|c| c.count).max().unwrap_or(0);
    let min = classes.iter().map(|c| c.count).min().unwrap_or(0);
    let imbalance_ratio = if min > 0 {
        max as f64 / min as f64
    } else {
        0.0
    };

    let mut warnings = Vec::new();
    if classes.len() < 2 {
        warnings.push(
            "fewer than two classes survive filtering; a classifier cannot be trained".into(),
        );
    }
    if imbalance_ratio > 10.0 {
        warnings.push(format!(
            "severe class imbalance ({imbalance_ratio:.1}x); class-weighted loss is applied but consider collecting more of the rare classes"
        ));
    }
    if !dropped.is_empty() {
        warnings.push(format!(
            "{} class(es) dropped for having fewer than {min_per_class} samples: {}",
            dropped.len(),
            dropped
                .iter()
                .map(|(l, c)| format!("{l}({c})"))
                .collect::<Vec<_>>()
                .join(", ")
        ));
    }
    let human = provenance_counts.get("human").copied().unwrap_or(0);
    if kept > 0 && (human as f64) / (kept as f64) < 0.05 {
        warnings.push(format!(
            "only {human} of {kept} samples are human-reviewed; labels are mostly API-derived"
        ));
    }

    DatasetReport {
        task: task.to_string(),
        loaded: raw.len(),
        kept,
        classes,
        dropped_classes: dropped,
        imbalance_ratio,
        provenance_counts,
        crop_counts,
        reviewed,
        warnings,
    }
}

pub fn print_report(report: &DatasetReport) {
    println!("Dataset report for {}", report.task);
    println!(
        "  loaded {} samples, kept {} across {} classes (imbalance {:.1}x, {} human-reviewed)",
        report.loaded,
        report.kept,
        report.classes.len(),
        report.imbalance_ratio,
        report.reviewed
    );
    for c in &report.classes {
        println!(
            "    {:<28} {:>6}  {:>5.1}%  reviewed={:<4} weight={:.1}",
            c.label,
            c.count,
            c.fraction * 100.0,
            c.reviewed,
            c.weight_sum
        );
    }
    if !report.provenance_counts.is_empty() {
        let p: Vec<String> = report
            .provenance_counts
            .iter()
            .map(|(k, v)| format!("{k}={v}"))
            .collect();
        println!("  provenance: {}", p.join(", "));
    }
    for w in &report.warnings {
        println!("  WARNING: {w}");
    }
}

/// Inverse-frequency class weights over provenance-weighted counts,
/// normalized to mean 1 so the loss scale is unchanged.
pub fn class_weights(samples: &[Sample], num_classes: usize) -> Vec<f32> {
    let mut sums = vec![0.0f64; num_classes];
    for s in samples {
        if s.label_idx < num_classes {
            sums[s.label_idx] += s.weight.max(1e-6);
        }
    }
    let total: f64 = sums.iter().sum();
    if total <= 0.0 || num_classes == 0 {
        return vec![1.0; num_classes];
    }
    let raw: Vec<f64> = sums
        .iter()
        .map(|&s| {
            if s > 0.0 {
                total / (num_classes as f64 * s)
            } else {
                1.0
            }
        })
        .collect();
    let mean = raw.iter().sum::<f64>() / num_classes as f64;
    raw.iter().map(|w| (w / mean) as f32).collect()
}

// ---------------------------------------------------------------------------
// Splitting and snapshots
// ---------------------------------------------------------------------------

fn unit_hash(id: &str) -> f64 {
    let mut h = Sha256::new();
    h.update(id.as_bytes());
    let digest = h.finalize();
    let bits = u64::from_le_bytes(digest[..8].try_into().unwrap()) >> 11;
    bits as f64 / (1u64 << 53) as f64
}

/// Split by class so every class is represented in each partition, using a
/// hash of the sample id so membership is stable across runs and unaffected
/// by manifest order.
pub fn stratified_split(
    samples: Vec<Sample>,
    val_frac: f64,
    test_frac: f64,
) -> (Vec<Sample>, Vec<Sample>, Vec<Sample>) {
    let mut by_class: BTreeMap<usize, Vec<Sample>> = BTreeMap::new();
    for s in samples {
        by_class.entry(s.label_idx).or_default().push(s);
    }
    let (mut train, mut val, mut test) = (Vec::new(), Vec::new(), Vec::new());
    for (_, mut group) in by_class {
        group.sort_by(|a, b| a.id.cmp(&b.id));
        let (mut g_train, mut g_val, mut g_test) = (Vec::new(), Vec::new(), Vec::new());
        for s in group {
            let u = unit_hash(&s.id);
            if u < test_frac {
                g_test.push(s);
            } else if u < test_frac + val_frac {
                g_val.push(s);
            } else {
                g_train.push(s);
            }
        }
        // Guarantee representation when the class is large enough to spare a sample.
        if g_train.len() >= 3 {
            if g_test.is_empty() && test_frac > 0.0 {
                g_test.push(g_train.pop().unwrap());
            }
            if g_val.is_empty() && val_frac > 0.0 && g_train.len() >= 2 {
                g_val.push(g_train.pop().unwrap());
            }
        }
        train.extend(g_train);
        val.extend(g_val);
        test.extend(g_test);
    }
    (train, val, test)
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DatasetSnapshot {
    /// SHA-256 over the sorted `id\tlabel` lines of every sample.
    pub id: String,
    pub task: String,
    pub created_at: String,
    pub n_samples: usize,
    pub n_train: usize,
    pub n_val: usize,
    pub n_test: usize,
    pub class_counts: BTreeMap<String, usize>,
    pub provenance_counts: BTreeMap<String, usize>,
    pub label_map: BTreeMap<String, usize>,
    pub train_ids: Vec<String>,
    pub val_ids: Vec<String>,
    pub test_ids: Vec<String>,
}

pub fn build_snapshot(
    task: &str,
    train: &[Sample],
    val: &[Sample],
    test: &[Sample],
    label_map: &HashMap<String, usize>,
) -> DatasetSnapshot {
    let all: Vec<&Sample> = train.iter().chain(val.iter()).chain(test.iter()).collect();
    let mut lines: Vec<String> = all
        .iter()
        .map(|s| format!("{}\t{}", s.id, s.label))
        .collect();
    lines.sort();
    let mut h = Sha256::new();
    for l in &lines {
        h.update(l.as_bytes());
        h.update(b"\n");
    }
    let mut class_counts = BTreeMap::new();
    let mut provenance_counts = BTreeMap::new();
    for s in &all {
        *class_counts.entry(s.label.clone()).or_default() += 1;
        *provenance_counts.entry(s.provenance.clone()).or_default() += 1;
    }
    let ids = |v: &[Sample]| {
        let mut ids: Vec<String> = v.iter().map(|s| s.id.clone()).collect();
        ids.sort();
        ids
    };
    DatasetSnapshot {
        id: format!("{:x}", h.finalize()),
        task: task.to_string(),
        created_at: Utc::now().to_rfc3339(),
        n_samples: all.len(),
        n_train: train.len(),
        n_val: val.len(),
        n_test: test.len(),
        class_counts,
        provenance_counts,
        label_map: label_map.iter().map(|(k, v)| (k.clone(), *v)).collect(),
        train_ids: ids(train),
        val_ids: ids(val),
        test_ids: ids(test),
    }
}

pub struct SplitDatasets {
    pub train: Vec<Sample>,
    pub val: Vec<Sample>,
    pub test: Vec<Sample>,
    pub label_map: HashMap<String, usize>,
    pub report: DatasetReport,
    pub snapshot: DatasetSnapshot,
}

pub fn prepare_datasets(
    task: &str,
    data_config: &DataConfig,
    base_dir: Option<&str>,
) -> anyhow::Result<SplitDatasets> {
    let base = PathBuf::from(base_dir.unwrap_or(&data_config.base_dir));
    let task_dir = base.join(task);

    let raw = load_manifest(
        &task_dir,
        data_config.min_confidence,
        &data_config.provenance_weights,
    )?;
    let label_map = build_label_map(&raw, data_config.min_samples_per_class);
    let report = build_report(task, &raw, &label_map, data_config.min_samples_per_class);

    let samples: Vec<Sample> = raw
        .into_iter()
        .filter_map(|r| {
            let idx = *label_map.get(&r.label)?;
            Some(Sample {
                id: r.id,
                image_path: r.image_path,
                label: r.label,
                label_idx: idx,
                confidence: r.confidence,
                weight: r.weight,
                capture: r.capture,
                provenance: r.provenance,
                crop: r.crop,
                reviewed: r.reviewed,
            })
        })
        .collect();

    if samples.is_empty() {
        anyhow::bail!("no valid samples for task '{task}' after filtering");
    }

    let (train, val, test) =
        stratified_split(samples, data_config.val_split, data_config.test_split);
    let snapshot = build_snapshot(task, &train, &val, &test, &label_map);

    Ok(SplitDatasets {
        train,
        val,
        test,
        label_map,
        report,
        snapshot,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    fn write_sample(dir: &Path, id: &str, label: &str, conf: f64, extra_json: &str) {
        let images = dir.join("images");
        let labels = dir.join("labels");
        std::fs::create_dir_all(&images).unwrap();
        std::fs::create_dir_all(&labels).unwrap();
        let img = images.join(format!("{id}.jpg"));
        std::fs::write(&img, b"not-a-real-image").unwrap();
        std::fs::write(
            labels.join(format!("{id}.json")),
            format!(
                r#"{{"id":"{id}","labels":[{{"name":"{label}","confidence":{conf}}},{{"name":"other","confidence":0.1}}]{extra_json}}}"#
            ),
        )
        .unwrap();
        use std::io::Write;
        let mut m = std::fs::OpenOptions::new()
            .create(true)
            .append(true)
            .open(dir.join("manifest.jsonl"))
            .unwrap();
        writeln!(
            m,
            r#"{{"id":"{id}","image":"{}","labels":["{label}"],"timestamp":"2026-01-01T00:00:00Z"}}"#,
            img.display()
        )
        .unwrap();
    }

    fn weights() -> ProvenanceWeights {
        ProvenanceWeights::default()
    }

    #[test]
    fn load_applies_reviews_and_provenance() {
        let dir = tempfile::tempdir().unwrap();
        let d = dir.path();
        write_sample(d, "a", "rust", 0.9, "");
        write_sample(d, "b", "rust", 0.4, "");
        write_sample(
            d,
            "c",
            "rust",
            0.3,
            r#","review":{"decision":"corrected","corrected_label":"blight"}"#,
        );
        write_sample(d, "d", "rust", 0.95, r#","review":{"decision":"rejected"}"#);
        write_sample(
            d,
            "e",
            "rust",
            0.5,
            r#","review":{"decision":"confirmed"},"context":{"crop":"wheat"}"#,
        );
        write_sample(d, "f", "rust", 0.8, r#","provenance":"local_model""#);

        let raw = load_manifest(d, 0.7, &weights()).unwrap();
        let by_id: HashMap<&str, &RawSample> = raw.iter().map(|r| (r.id.as_str(), r)).collect();

        assert!(by_id.contains_key("a"));
        assert!(
            !by_id.contains_key("b"),
            "below min_confidence and unreviewed"
        );
        assert!(!by_id.contains_key("d"), "rejected");

        let c = by_id["c"];
        assert_eq!(c.label, "blight");
        assert_eq!(c.provenance, "human");
        assert!(c.reviewed && c.confidence == 1.0 && c.weight == 1.0);

        let e = by_id["e"];
        assert_eq!(e.label, "rust");
        assert_eq!(e.crop, "wheat");
        assert!(e.reviewed, "confirmed bypasses the confidence threshold");

        let f = by_id["f"];
        assert_eq!(f.provenance, "local_model");
        assert!((f.weight - 0.3).abs() < 1e-9);
        assert!((by_id["a"].weight - 0.6).abs() < 1e-9);
    }

    #[test]
    fn manifest_duplicates_and_missing_images_are_skipped() {
        let dir = tempfile::tempdir().unwrap();
        let d = dir.path();
        write_sample(d, "a", "rust", 0.9, "");
        write_sample(d, "a", "rust", 0.9, ""); // duplicate manifest line
        write_sample(d, "z", "rust", 0.9, "");
        std::fs::remove_file(d.join("images").join("z.jpg")).unwrap();
        let raw = load_manifest(d, 0.5, &weights()).unwrap();
        assert_eq!(raw.len(), 1);
    }

    #[test]
    fn capture_derives_a_region_grid_cell() {
        let c = Capture {
            latitude: 18.52,
            longitude: 78.41,
            timestamp: String::new(),
        };
        assert_eq!(c.region(), "18N 78E");

        // Southern and western coordinates floor away from zero, so the cell
        // name stays the corner the point sits in.
        let sw = Capture {
            latitude: -23.7,
            longitude: -46.6,
            ..Default::default()
        };
        assert_eq!(sw.region(), "24S 47W");

        // No location recorded is not a region.
        assert_eq!(Capture::default().region(), "");
        // Out-of-range junk is rejected rather than bucketed.
        assert_eq!(
            Capture {
                latitude: 999.0,
                longitude: 12.0,
                ..Default::default()
            }
            .region(),
            ""
        );
    }

    #[test]
    fn capture_derives_a_season_from_the_timestamp() {
        let at = |ts: &str, lat: f64| {
            Capture {
                latitude: lat,
                longitude: 78.0,
                timestamp: ts.into(),
            }
            .season()
        };

        assert_eq!(at("2026-01-15T00:00:00Z", 18.5), "winter");
        assert_eq!(at("2026-04-15T00:00:00Z", 18.5), "spring");
        assert_eq!(at("2026-07-15T00:00:00Z", 18.5), "summer");
        assert_eq!(at("2026-10-15T00:00:00Z", 18.5), "autumn");

        // Below the equator the seasons are the opposite ones.
        assert_eq!(at("2026-01-15T00:00:00Z", -23.5), "summer");
        assert_eq!(at("2026-07-15T00:00:00Z", -23.5), "winter");
        assert_eq!(at("2026-04-15T00:00:00Z", -23.5), "autumn");
        assert_eq!(at("2026-10-15T00:00:00Z", -23.5), "spring");

        // Offsets are honoured, and unparseable stamps yield no slice.
        assert_eq!(at("2026-07-15T00:00:00+05:30", 18.5), "summer");
        assert_eq!(at("not a date", 18.5), "");
        assert_eq!(at("", 18.5), "");
    }

    #[test]
    fn slice_keys_skip_missing_metadata() {
        let mut s = sample("s1", "rust", 0, "external_api");
        s.crop = "wheat".into();
        s.capture = Capture {
            latitude: 18.5,
            longitude: 78.4,
            timestamp: "2026-07-15T00:00:00Z".into(),
        };
        let keys = s.slice_keys();
        assert_eq!(keys["crop"], "wheat");
        assert_eq!(keys["source"], "external_api");
        assert_eq!(keys["region"], "18N 78E");
        assert_eq!(keys["season"], "summer");

        // A sample with no crop or location contributes only what it has.
        let bare = sample("s2", "rust", 0, "human");
        let keys = bare.slice_keys();
        assert_eq!(keys.keys().collect::<Vec<_>>(), vec!["source"]);
    }

    fn sample(id: &str, label: &str, idx: usize, provenance: &str) -> Sample {
        Sample {
            id: id.into(),
            image_path: PathBuf::from("/x"),
            label: label.into(),
            label_idx: idx,
            confidence: 0.9,
            weight: ProvenanceWeights::default().for_provenance(provenance),
            provenance: provenance.into(),
            crop: String::new(),
            capture: Capture::default(),
            reviewed: provenance == "human",
        }
    }

    #[test]
    fn stratified_split_is_deterministic_and_covers_classes() {
        let mut samples = Vec::new();
        for i in 0..60 {
            samples.push(sample(&format!("r{i}"), "rust", 0, "external_api"));
        }
        for i in 0..12 {
            samples.push(sample(&format!("b{i}"), "blight", 1, "external_api"));
        }
        for i in 0..4 {
            samples.push(sample(&format!("m{i}"), "mildew", 2, "human"));
        }
        let (train, val, test) = stratified_split(samples.clone(), 0.15, 0.15);
        assert_eq!(train.len() + val.len() + test.len(), 76);
        for split in [&val, &test] {
            for idx in 0..3 {
                assert!(
                    split.iter().any(|s| s.label_idx == idx),
                    "class {idx} missing from a split"
                );
            }
        }
        let mut shuffled = samples.clone();
        shuffled.reverse();
        let (train2, _, _) = stratified_split(shuffled, 0.15, 0.15);
        let a: Vec<&str> = train.iter().map(|s| s.id.as_str()).collect();
        let mut b: Vec<&str> = train2.iter().map(|s| s.id.as_str()).collect();
        let mut a_sorted = a.clone();
        a_sorted.sort();
        b.sort();
        assert_eq!(a_sorted, b, "membership must not depend on input order");
        let frac = test.len() as f64 / 76.0;
        assert!(frac > 0.07 && frac < 0.25, "test fraction {frac}");
    }

    #[test]
    fn class_weights_favor_rare_classes() {
        let mut samples = Vec::new();
        for i in 0..90 {
            samples.push(sample(&format!("a{i}"), "a", 0, "external_api"));
        }
        for i in 0..10 {
            samples.push(sample(&format!("b{i}"), "b", 1, "external_api"));
        }
        let w = class_weights(&samples, 2);
        assert!(w[1] > w[0]);
        assert!(((w[0] + w[1]) / 2.0 - 1.0).abs() < 1e-6, "mean-normalized");
        assert!((w[1] / w[0] - 9.0).abs() < 1e-4);
        assert_eq!(class_weights(&[], 3), vec![1.0, 1.0, 1.0]);
    }

    #[test]
    fn report_and_snapshot() {
        let raw: Vec<RawSample> = (0..20)
            .map(|i| RawSample {
                id: format!("s{i}"),
                image_path: PathBuf::from("/x"),
                label: if i < 15 {
                    "rust".into()
                } else if i < 19 {
                    "blight".into()
                } else {
                    "rare".into()
                },
                confidence: 0.9,
                weight: 0.6,
                provenance: "external_api".into(),
                crop: "wheat".into(),
                capture: Capture::default(),
                reviewed: false,
            })
            .collect();
        let label_map = build_label_map(&raw, 2);
        assert_eq!(label_map.len(), 2);
        let report = build_report("disease", &raw, &label_map, 2);
        assert_eq!(report.loaded, 20);
        assert_eq!(report.kept, 19);
        assert_eq!(report.dropped_classes, vec![("rare".to_string(), 1)]);
        assert!((report.imbalance_ratio - 3.75).abs() < 1e-9);
        assert_eq!(report.crop_counts["wheat"], 19);
        assert!(report.warnings.iter().any(|w| w.contains("human-reviewed")));
        assert!(report.warnings.iter().any(|w| w.contains("dropped")));

        let samples: Vec<Sample> = raw
            .iter()
            .filter_map(|r| {
                Some(sample(
                    &r.id,
                    &r.label,
                    *label_map.get(&r.label)?,
                    &r.provenance,
                ))
            })
            .collect();
        let (train, val, test) = stratified_split(samples.clone(), 0.2, 0.2);
        let snap1 = build_snapshot("disease", &train, &val, &test, &label_map);
        assert_eq!(snap1.n_samples, 19);
        assert_eq!(snap1.class_counts["rust"], 15);
        let (t2, v2, te2) = stratified_split(samples, 0.2, 0.2);
        let snap2 = build_snapshot("disease", &t2, &v2, &te2, &label_map);
        assert_eq!(snap1.id, snap2.id, "snapshot id depends only on content");
        assert_eq!(snap1.id.len(), 64);
    }
}
