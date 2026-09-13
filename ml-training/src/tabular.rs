//! Tabular regression training for yield models.
//!
//! Loads a feature CSV assembled from the warehouse (weather aggregates,
//! NDVI peak, soil, management, prior yields), trains a gradient-boosted
//! model from `yield-prediction-engine`, calibrates conformal intervals on a
//! held-out split, and writes a JSON artifact the AI gateway loads directly.

use std::path::Path;

use anyhow::{bail, Context};
use chrono::Utc;
use serde::{Deserialize, Serialize};
use tracing::info;

use yield_prediction_engine::{
    GbmParams, GbmValidation, GradientBoostedModel, YieldFeatures, FEATURE_NAMES,
};

use crate::config::TabularTaskConfig;
use crate::registry::{ModelMetadata, ModelMetrics, ModelRegistry, ModelStatus};

/// Parsed tabular dataset.
#[derive(Debug, Clone)]
pub struct TabularDataset {
    pub feature_names: Vec<String>,
    pub rows: Vec<Vec<f64>>,
    pub targets: Vec<f64>,
}

impl TabularDataset {
    pub fn len(&self) -> usize {
        self.rows.len()
    }

    pub fn is_empty(&self) -> bool {
        self.rows.is_empty()
    }
}

/// Load a CSV whose header names the columns. Feature columns are mapped onto
/// the engine's canonical [`FEATURE_NAMES`] order; missing optional columns
/// default to zero, extra columns are ignored, and malformed rows are skipped.
pub fn load_csv(path: &Path, target_column: &str) -> anyhow::Result<TabularDataset> {
    let content =
        std::fs::read_to_string(path).with_context(|| format!("read {}", path.display()))?;
    parse_csv(&content, target_column)
}

pub fn parse_csv(content: &str, target_column: &str) -> anyhow::Result<TabularDataset> {
    let mut lines = content.lines().filter(|l| !l.trim().is_empty());
    let header = lines.next().context("CSV is empty")?;
    let columns: Vec<String> = header.split(',').map(|c| c.trim().to_string()).collect();
    let target_idx = columns
        .iter()
        .position(|c| c == target_column)
        .with_context(|| format!("target column {target_column:?} not found in header"))?;

    let mut rows = Vec::new();
    let mut targets = Vec::new();
    let mut skipped = 0usize;
    for line in lines {
        let values: Vec<f64> = line
            .split(',')
            .map(|v| v.trim().parse::<f64>().unwrap_or(f64::NAN))
            .collect();
        if values.len() != columns.len() || values[target_idx].is_nan() {
            skipped += 1;
            continue;
        }
        match YieldFeatures::from_named(&columns, &values) {
            Some(f) => {
                let v = f.to_vec();
                if v.iter().any(|x| x.is_nan()) {
                    skipped += 1;
                    continue;
                }
                rows.push(v);
                targets.push(values[target_idx]);
            }
            None => skipped += 1,
        }
    }
    if skipped > 0 {
        info!(skipped, "skipped malformed rows");
    }
    if rows.is_empty() {
        bail!("no usable rows in dataset");
    }
    Ok(TabularDataset {
        feature_names: FEATURE_NAMES.iter().map(|s| s.to_string()).collect(),
        rows,
        targets,
    })
}

/// Deterministic three-way split (train / calibration / test) by row hash so
/// re-runs on the same data produce the same partitions.
pub fn split(
    ds: &TabularDataset,
    train_frac: f64,
    cal_frac: f64,
) -> (TabularDataset, TabularDataset, TabularDataset) {
    let mut parts = [
        TabularDataset {
            feature_names: ds.feature_names.clone(),
            rows: vec![],
            targets: vec![],
        },
        TabularDataset {
            feature_names: ds.feature_names.clone(),
            rows: vec![],
            targets: vec![],
        },
        TabularDataset {
            feature_names: ds.feature_names.clone(),
            rows: vec![],
            targets: vec![],
        },
    ];
    for (i, (row, t)) in ds.rows.iter().zip(&ds.targets).enumerate() {
        // Golden-ratio hash keeps assignment stable regardless of row order changes elsewhere.
        let u = ((i as u64).wrapping_mul(0x9E3779B97F4A7C15) >> 11) as f64 / (1u64 << 53) as f64;
        let bucket = if u < train_frac {
            0
        } else if u < train_frac + cal_frac {
            1
        } else {
            2
        };
        parts[bucket].rows.push(row.clone());
        parts[bucket].targets.push(*t);
    }
    let [train, cal, test] = parts;
    (train, cal, test)
}

/// Result of a tabular training run.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TabularTrainingResult {
    pub version: String,
    pub n_train: usize,
    pub n_calibration: usize,
    pub n_test: usize,
    pub validation: GbmValidation,
    pub interval_half_width: f64,
    pub interval_coverage: f64,
    pub feature_importance: Vec<(String, f64)>,
    pub artifact_path: String,
}

/// Train, calibrate, validate, and write the JSON artifact.
pub fn train_tabular(
    task: &str,
    cfg: &TabularTaskConfig,
    dataset: &TabularDataset,
    output: &Path,
) -> anyhow::Result<(GradientBoostedModel, TabularTrainingResult)> {
    let (train, cal, test) = split(dataset, 0.7, 0.15);
    if train.len() < 20 || cal.is_empty() || test.is_empty() {
        bail!(
            "dataset too small to split: train={} cal={} test={} (need >=20 train rows)",
            train.len(),
            cal.len(),
            test.len()
        );
    }

    let params = GbmParams {
        n_trees: cfg.n_trees,
        max_depth: cfg.max_depth,
        learning_rate: cfg.learning_rate,
        min_samples_leaf: cfg.min_samples_leaf,
        subsample: cfg.subsample,
        seed: 42,
    };
    info!(
        task,
        n_train = train.len(),
        n_cal = cal.len(),
        n_test = test.len(),
        ?params,
        "training tabular model"
    );

    let mut model = GradientBoostedModel::train(
        &train.rows,
        &train.targets,
        train.feature_names.clone(),
        params,
    )?;
    model.calibrate(&cal.rows, &cal.targets, cfg.interval_coverage)?;
    let validation = model.validate(&test.rows, &test.targets)?;
    model.version = format!("{task}-gbm-{}", Utc::now().format("%Y%m%dT%H%M%SZ"));

    if validation.r_squared < cfg.min_r_squared {
        bail!(
            "held-out R² {:.3} is below the configured minimum {:.3}; refusing to write artifact",
            validation.r_squared,
            cfg.min_r_squared
        );
    }

    if let Some(parent) = output.parent() {
        std::fs::create_dir_all(parent)?;
    }
    std::fs::write(output, model.to_json()?)
        .with_context(|| format!("write {}", output.display()))?;
    info!(path = %output.display(), r2 = validation.r_squared, rmse = validation.rmse, "wrote tabular model artifact");

    let result = TabularTrainingResult {
        version: model.version.clone(),
        n_train: train.len(),
        n_calibration: cal.len(),
        n_test: test.len(),
        validation,
        interval_half_width: model.interval_half_width().unwrap_or(0.0),
        interval_coverage: model.interval_coverage(),
        feature_importance: model.feature_importance(),
        artifact_path: output.display().to_string(),
    };
    Ok((model, result))
}

/// Register the trained model in the file-backed registry as a staging candidate.
pub fn register(
    registry: &ModelRegistry,
    task: &str,
    result: &TabularTrainingResult,
    config_hash: &str,
) -> anyhow::Result<()> {
    registry.register_model(ModelMetadata {
        model_name: format!("{task}-gbm"),
        version: result.version.clone(),
        task: task.to_string(),
        created_at: Utc::now(),
        metrics: ModelMetrics {
            accuracy: result.validation.r_squared,
            f1: 0.0,
            precision: 0.0,
            recall: 0.0,
            r_squared: Some(result.validation.r_squared),
            rmse: Some(result.validation.rmse),
            mae: Some(result.validation.mae),
        },
        training_config_hash: config_hash.to_string(),
        onnx_path: result.artifact_path.clone(),
        status: ModelStatus::Staging,
        dataset_snapshot: None,
        training_samples: Some(result.n_train),
    })
}

/// Print a human-readable summary.
pub fn print_result(result: &TabularTrainingResult) {
    println!("Tabular model {}", result.version);
    println!(
        "  rows: train={} calibration={} test={}",
        result.n_train, result.n_calibration, result.n_test
    );
    println!(
        "  held-out: R²={:.3} RMSE={:.1} MAE={:.1}",
        result.validation.r_squared, result.validation.rmse, result.validation.mae
    );
    println!(
        "  {:.0}% interval half-width: ±{:.1} kg/ha",
        result.interval_coverage * 100.0,
        result.interval_half_width
    );
    println!("  top features:");
    let mut imp = result.feature_importance.clone();
    imp.sort_by(|a, b| b.1.partial_cmp(&a.1).unwrap_or(std::cmp::Ordering::Equal));
    for (name, v) in imp.iter().take(8) {
        println!("    {name:<28} {:.3}", v);
    }
    println!("  artifact: {}", result.artifact_path);
}

#[cfg(test)]
mod tests {
    use super::*;

    fn synthetic_csv(n: usize) -> String {
        let mut s = String::from(
            "crop_code,avg_temperature_c,total_precipitation_mm,growing_degree_days,ph,nitrogen_kg_ha,extra_ignored,yield_kg_ha\n",
        );
        let mut seed: u64 = 7;
        let mut rnd = || {
            seed = seed
                .wrapping_mul(6364136223846793005)
                .wrapping_add(1442695040888963407);
            (seed >> 11) as f64 / (1u64 << 53) as f64
        };
        for _ in 0..n {
            let crop = (rnd() * 3.0).floor();
            let rain = 200.0 + rnd() * 800.0;
            let gdd = 1200.0 + rnd() * 1800.0;
            let ph = 5.0 + rnd() * 3.0;
            let n_kg = rnd() * 200.0;
            let y = 1500.0 * (crop + 1.0)
                + 6000.0 * (rain / 600.0).min(1.0) * (gdd / 2500.0).min(1.0)
                + 8.0 * n_kg
                + (rnd() - 0.5) * 200.0;
            s.push_str(&format!("{crop},22,{rain},{gdd},{ph},{n_kg},999,{y}\n"));
        }
        s
    }

    fn cfg(tmp: &Path) -> TabularTaskConfig {
        TabularTaskConfig {
            data_csv: String::new(),
            target_column: "yield_kg_ha".into(),
            n_trees: 120,
            max_depth: 4,
            learning_rate: 0.08,
            min_samples_leaf: 5,
            subsample: 0.8,
            interval_coverage: 0.9,
            min_r_squared: 0.5,
            output_model: tmp.join("yield.json").display().to_string(),
        }
    }

    #[test]
    fn parses_csv_with_optional_and_extra_columns() {
        let ds = parse_csv(&synthetic_csv(50), "yield_kg_ha").unwrap();
        assert_eq!(ds.len(), 50);
        assert_eq!(ds.feature_names.len(), FEATURE_NAMES.len());
        assert_eq!(ds.rows[0].len(), FEATURE_NAMES.len());
        // ndvi_peak (absent) defaults to zero.
        assert_eq!(ds.rows[0][FEATURE_NAMES.len() - 2], 0.0);
    }

    #[test]
    fn parse_errors() {
        assert!(parse_csv("", "y").is_err());
        assert!(parse_csv("a,b\n1,2\n", "y").is_err());
        let mut csv = synthetic_csv(3);
        csv.push_str("bad,row\n");
        assert_eq!(parse_csv(&csv, "yield_kg_ha").unwrap().len(), 3);
    }

    #[test]
    fn split_is_deterministic_and_complete() {
        let ds = parse_csv(&synthetic_csv(200), "yield_kg_ha").unwrap();
        let (a, b, c) = split(&ds, 0.7, 0.15);
        assert_eq!(a.len() + b.len() + c.len(), 200);
        assert!(
            a.len() > 120 && b.len() > 15 && c.len() > 15,
            "{} {} {}",
            a.len(),
            b.len(),
            c.len()
        );
        let (a2, _, _) = split(&ds, 0.7, 0.15);
        assert_eq!(a.rows, a2.rows);
    }

    #[test]
    fn trains_writes_and_registers() {
        let tmp = tempfile::tempdir().unwrap();
        let ds = parse_csv(&synthetic_csv(600), "yield_kg_ha").unwrap();
        let out = tmp.path().join("models").join("yield.json");
        let (model, result) = train_tabular("yield", &cfg(tmp.path()), &ds, &out).unwrap();

        assert!(
            result.validation.r_squared > 0.85,
            "r2 = {}",
            result.validation.r_squared
        );
        assert!(result.interval_half_width > 0.0);
        assert!(out.exists());
        let reloaded =
            GradientBoostedModel::from_json(&std::fs::read_to_string(&out).unwrap()).unwrap();
        assert_eq!(reloaded.version, model.version);
        assert!(
            (reloaded.predict(&ds.rows[0]).unwrap() - model.predict(&ds.rows[0]).unwrap()).abs()
                < 1e-9
        );

        let registry = ModelRegistry::new(&tmp.path().join("registry")).unwrap();
        register(&registry, "yield", &result, "abc").unwrap();
        let entry = registry.get_model("yield", &result.version).unwrap();
        assert_eq!(entry.status, ModelStatus::Staging);
        assert!(entry.metrics.r_squared.unwrap() > 0.85);
    }

    #[test]
    fn refuses_weak_model() {
        let tmp = tempfile::tempdir().unwrap();
        // Targets unrelated to features: R² should be ~0 and fail the gate.
        let mut csv = String::from(
            "crop_code,avg_temperature_c,total_precipitation_mm,growing_degree_days,yield_kg_ha\n",
        );
        let mut seed: u64 = 3;
        for i in 0..200 {
            seed = seed
                .wrapping_mul(6364136223846793005)
                .wrapping_add(1442695040888963407);
            let noise = (seed >> 11) as f64 / (1u64 << 53) as f64;
            csv.push_str(&format!(
                "{},20,{},{},{}\n",
                i % 3,
                300 + (i % 7) * 50,
                1500 + (i % 5) * 100,
                noise * 10_000.0
            ));
        }
        let ds = parse_csv(&csv, "yield_kg_ha").unwrap();
        let err =
            train_tabular("yield", &cfg(tmp.path()), &ds, &tmp.path().join("m.json")).unwrap_err();
        assert!(
            err.to_string().contains("below the configured minimum"),
            "{err}"
        );
        assert!(!tmp.path().join("m.json").exists());
    }
}
