use std::collections::HashMap;
use std::path::{Path, PathBuf};

use burn::data::dataloader::batcher::Batcher;
use burn::prelude::*;
use image::imageops::FilterType;
use image::GenericImageView;
use rand::seq::SliceRandom;
use rand::SeedableRng;
use serde::Deserialize;

use crate::config::DataConfig;

#[derive(Debug, Clone)]
pub struct Sample {
    pub id: String,
    pub image_path: PathBuf,
    pub label: String,
    pub label_idx: usize,
    pub confidence: f64,
}

#[derive(Debug, Clone, Deserialize)]
struct ManifestEntry {
    id: String,
    image: String,
    labels: Vec<String>,
    timestamp: String,
}

#[derive(Debug, Clone, Deserialize)]
struct LabelFile {
    labels: Vec<LabelEntry>,
}

#[derive(Debug, Clone, Deserialize)]
struct LabelEntry {
    name: String,
    confidence: f64,
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

    pub fn get(&self, index: usize) -> Option<(Vec<f32>, usize)> {
        let sample = self.samples.get(index)?;
        let tensor_data = load_and_preprocess(&sample.image_path, self.input_size).ok()?;
        Some((tensor_data, sample.label_idx))
    }
}

#[derive(Clone)]
pub struct PlantBatcher {
    input_size: usize,
}

impl PlantBatcher {
    pub fn new(input_size: usize) -> Self {
        Self { input_size }
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
            match load_and_preprocess(&sample.image_path, self.input_size) {
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

fn load_and_preprocess(path: &Path, size: usize) -> anyhow::Result<Vec<f32>> {
    let img = image::open(path)?;
    let resized = img.resize_exact(size as u32, size as u32, FilterType::Lanczos3);
    let rgb = resized.to_rgb8();

    let (w, h) = resized.dimensions();
    let mut channels = vec![0.0f32; 3 * (h as usize) * (w as usize)];

    let mean = [0.485f32, 0.456, 0.406];
    let std = [0.229f32, 0.224, 0.225];

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

    Ok(channels)
}

pub fn load_manifest(
    task_dir: &Path,
    min_confidence: f64,
) -> anyhow::Result<Vec<(String, PathBuf, String, f64)>> {
    let manifest_path = task_dir.join("manifest.jsonl");
    if !manifest_path.exists() {
        anyhow::bail!("no manifest found at {}", manifest_path.display());
    }

    let content = std::fs::read_to_string(&manifest_path)?;
    let mut results = Vec::new();

    for line in content.lines() {
        let line = line.trim();
        if line.is_empty() {
            continue;
        }
        let entry: ManifestEntry = serde_json::from_str(line)?;
        let image_path = PathBuf::from(&entry.image);
        if !image_path.exists() {
            continue;
        }

        let label_path = task_dir.join("labels").join(format!("{}.json", entry.id));
        if let Ok(label_content) = std::fs::read_to_string(&label_path) {
            if let Ok(label_data) = serde_json::from_str::<LabelFile>(&label_content) {
                if let Some(top) = label_data.labels.first() {
                    if top.confidence >= min_confidence {
                        results.push((
                            entry.id,
                            image_path,
                            top.name.clone(),
                            top.confidence,
                        ));
                    }
                }
            }
        }
    }

    Ok(results)
}

pub fn build_label_map(
    raw: &[(String, PathBuf, String, f64)],
    min_per_class: usize,
) -> HashMap<String, usize> {
    let mut counts: HashMap<String, usize> = HashMap::new();
    for (_, _, label, _) in raw {
        *counts.entry(label.clone()).or_default() += 1;
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

pub struct SplitDatasets {
    pub train: Vec<Sample>,
    pub val: Vec<Sample>,
    pub test: Vec<Sample>,
    pub label_map: HashMap<String, usize>,
}

pub fn prepare_datasets(
    task: &str,
    data_config: &DataConfig,
    base_dir: Option<&str>,
) -> anyhow::Result<SplitDatasets> {
    let base = PathBuf::from(base_dir.unwrap_or(&data_config.base_dir));
    let task_dir = base.join(task);

    let raw = load_manifest(&task_dir, data_config.min_confidence)?;
    let label_map = build_label_map(&raw, data_config.min_samples_per_class);

    let mut samples: Vec<Sample> = raw
        .into_iter()
        .filter_map(|(id, path, label, confidence)| {
            let idx = *label_map.get(&label)?;
            Some(Sample {
                id,
                image_path: path,
                label,
                label_idx: idx,
                confidence,
            })
        })
        .collect();

    if samples.is_empty() {
        anyhow::bail!("no valid samples for task '{task}' after filtering");
    }

    let mut rng = rand::rngs::StdRng::seed_from_u64(42);
    samples.shuffle(&mut rng);

    let n = samples.len();
    let test_end = (n as f64 * data_config.test_split) as usize;
    let val_end = test_end + (n as f64 * data_config.val_split) as usize;

    let test = samples[..test_end].to_vec();
    let val = samples[test_end..val_end].to_vec();
    let train = samples[val_end..].to_vec();

    Ok(SplitDatasets {
        train,
        val,
        test,
        label_map,
    })
}
