use std::collections::HashMap;
use std::path::{Path, PathBuf};

use burn::prelude::*;
use burn::record::{CompactRecorder, Recorder};
use burn_ndarray::NdArray;
use clap::{Parser, Subcommand};
use tracing_subscriber::{fmt, EnvFilter};

use yp_ml_training::config::TrainingConfig;
use yp_ml_training::dataset::{self, prepare_datasets};
use yp_ml_training::export;
use yp_ml_training::model::{extract_weights, PlantCnn};
use yp_ml_training::registry::ModelRegistry;
use yp_ml_training::tabular;
use yp_ml_training::training;
use yp_ml_training::validate;

type InferBackend = NdArray;

#[derive(Parser)]
#[command(name = "yp-ml-training", about = "YieldPoint ML training pipeline")]
struct Cli {
    #[command(subcommand)]
    command: Commands,

    #[arg(long, default_value = "configs/training_config.toml")]
    config: PathBuf,
}

#[derive(Subcommand)]
enum Commands {
    /// Train a model for a specific task
    Train {
        #[arg(long)]
        task: String,
        #[arg(long)]
        data_dir: Option<String>,
        #[arg(long, default_value = "runs")]
        output_dir: PathBuf,
    },
    /// Validate a trained model against the test set
    Validate {
        #[arg(long)]
        task: String,
        #[arg(long)]
        model_dir: PathBuf,
        #[arg(long)]
        data_dir: Option<String>,
    },
    /// Export a trained model to ONNX
    Export {
        #[arg(long)]
        task: String,
        #[arg(long)]
        model_dir: PathBuf,
        #[arg(long)]
        output: Option<PathBuf>,
    },
    /// Run the full pipeline: train → validate → export
    Pipeline {
        #[arg(long, default_value = "all")]
        tasks: String,
        #[arg(long)]
        data_dir: Option<String>,
        #[arg(long, default_value = "runs")]
        output_dir: PathBuf,
    },
    /// Check data collection status
    Status {
        #[arg(long)]
        data_dir: Option<String>,
    },
    /// Train a tabular (gradient-boosted) regression model, e.g. yield
    TrainTabular {
        /// Task name under [tabular.*] in the config (e.g. "yield")
        #[arg(long)]
        task: String,
        /// Override the CSV path from the config
        #[arg(long)]
        data: Option<PathBuf>,
        /// Override the artifact output path from the config
        #[arg(long)]
        output: Option<PathBuf>,
        /// Register the model in this registry directory when it passes the R² gate
        #[arg(long)]
        registry: Option<PathBuf>,
    },
}

fn main() -> anyhow::Result<()> {
    fmt()
        .with_env_filter(
            EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("info")),
        )
        .init();

    let cli = Cli::parse();
    let config = TrainingConfig::from_file(&cli.config)?;

    match cli.command {
        Commands::Train {
            task,
            data_dir,
            output_dir,
        } => cmd_train(&config, &task, data_dir.as_deref(), &output_dir),

        Commands::Validate {
            task,
            model_dir,
            data_dir,
        } => cmd_validate(&config, &task, &model_dir, data_dir.as_deref()),

        Commands::Export {
            task,
            model_dir,
            output,
        } => cmd_export(&config, &task, &model_dir, output.as_deref()),

        Commands::Pipeline {
            tasks,
            data_dir,
            output_dir,
        } => cmd_pipeline(&config, &tasks, data_dir.as_deref(), &output_dir),

        Commands::Status { data_dir } => cmd_status(&config, data_dir.as_deref()),

        Commands::TrainTabular {
            task,
            data,
            output,
            registry,
        } => cmd_train_tabular(
            &config,
            &cli.config,
            &task,
            data.as_deref(),
            output.as_deref(),
            registry.as_deref(),
        ),
    }
}

fn cmd_train_tabular(
    config: &TrainingConfig,
    config_path: &Path,
    task: &str,
    data: Option<&Path>,
    output: Option<&Path>,
    registry_dir: Option<&Path>,
) -> anyhow::Result<()> {
    let task_config = config.tabular.get(task).ok_or_else(|| {
        anyhow::anyhow!("unknown tabular task: {task} (add a [tabular.{task}] section)")
    })?;

    let csv_path = data
        .map(Path::to_path_buf)
        .unwrap_or_else(|| PathBuf::from(&task_config.data_csv));
    let dataset = tabular::load_csv(&csv_path, &task_config.target_column)?;
    println!("Loaded {} rows from {}", dataset.len(), csv_path.display());

    let out_path = output
        .map(Path::to_path_buf)
        .unwrap_or_else(|| PathBuf::from(&task_config.output_model));
    let (_model, result) = tabular::train_tabular(task, task_config, &dataset, &out_path)?;
    tabular::print_result(&result);

    if let Some(dir) = registry_dir {
        let config_hash = {
            let bytes = std::fs::read(config_path).unwrap_or_default();
            format!(
                "{:016x}",
                bytes
                    .iter()
                    .fold(0xcbf29ce484222325u64, |h, b| (h ^ *b as u64)
                        .wrapping_mul(0x100000001b3))
            )
        };
        let registry = ModelRegistry::new(dir)?;
        tabular::register(&registry, task, &result, &config_hash)?;
        println!(
            "Registered {} as staging in {}",
            result.version,
            dir.display()
        );
    }
    Ok(())
}

fn cmd_train(
    config: &TrainingConfig,
    task: &str,
    data_dir: Option<&str>,
    output_dir: &Path,
) -> anyhow::Result<()> {
    let task_config = config
        .tasks
        .get(task)
        .ok_or_else(|| anyhow::anyhow!("unknown task: {task}"))?;

    let splits = prepare_datasets(task, &config.data, data_dir)?;
    let num_classes = splits.label_map.len();
    let task_output = output_dir.join(task);
    std::fs::create_dir_all(&task_output)?;

    dataset::print_report(&splits.report);
    std::fs::write(
        task_output.join("dataset_report.json"),
        serde_json::to_string_pretty(&splits.report)?,
    )?;
    // Immutable record of exactly which samples (and labels) trained this run.
    std::fs::write(
        task_output.join("dataset_snapshot.json"),
        serde_json::to_string_pretty(&splits.snapshot)?,
    )?;
    println!(
        "Dataset snapshot {} ({} train / {} val / {} test)",
        &splits.snapshot.id[..12],
        splits.snapshot.n_train,
        splits.snapshot.n_val,
        splits.snapshot.n_test
    );

    let loss_opts = training::LossOptions {
        class_weights: dataset::class_weights(&splits.train, num_classes),
        label_smoothing: task_config.label_smoothing,
    };
    let idx_to_label: HashMap<usize, String> = splits
        .label_map
        .iter()
        .map(|(k, v)| (*v, k.clone()))
        .collect();

    let result = training::train(
        task,
        task_config,
        splits.train,
        splits.val,
        splits.test,
        num_classes,
        &task_output,
        &loss_opts,
        &idx_to_label,
    )?;

    std::fs::write(
        task_output.join("label_noise_report.json"),
        serde_json::to_string_pretty(&result.label_noise)?,
    )?;
    if !result.label_noise.is_empty() {
        println!(
            "{} training labels look wrong (model confidently disagrees); see {}",
            result.label_noise.len(),
            task_output.join("label_noise_report.json").display()
        );
    }

    let meta = serde_json::json!({
        "task": task,
        "num_classes": num_classes,
        "input_size": task_config.input_size,
        "best_val_acc": result.best_val_acc,
        "test_acc": result.test_acc,
        "final_epoch": result.final_epoch,
        "label_map": splits.label_map,
        "dataset_snapshot": splits.snapshot.id,
        "training_samples": splits.snapshot.n_train,
        "class_weights": loss_opts.class_weights,
        "label_noise_suspects": result.label_noise.len(),
    });
    std::fs::write(
        task_output.join("training_meta.json"),
        serde_json::to_string_pretty(&meta)?,
    )?;

    println!(
        "Training complete: val_acc={:.4} test_acc={:.4}",
        result.best_val_acc, result.test_acc
    );
    Ok(())
}

fn cmd_validate(
    config: &TrainingConfig,
    task: &str,
    model_dir: &Path,
    data_dir: Option<&str>,
) -> anyhow::Result<()> {
    let task_config = config
        .tasks
        .get(task)
        .ok_or_else(|| anyhow::anyhow!("unknown task: {task}"))?;

    let splits = prepare_datasets(task, &config.data, data_dir)?;
    let num_classes = splits.label_map.len();
    let device = <InferBackend as Backend>::Device::default();

    let record = CompactRecorder::new()
        .load(model_dir.join("best_model"), &device)
        .map_err(|e| anyhow::anyhow!("failed to load model: {e}"))?;
    let model: PlantCnn<InferBackend> = PlantCnn::new(num_classes, &device).load_record(record);

    let report = validate::validate(
        &model,
        &splits.test,
        &splits.label_map,
        task_config.input_size,
        task_config.batch_size,
    );
    validate::print_report(&report);

    if report.accuracy < 0.70 {
        anyhow::bail!(
            "accuracy {:.4} is below deployment threshold (0.70)",
            report.accuracy
        );
    }
    println!("\nModel passes deployment threshold.");
    Ok(())
}

fn cmd_export(
    config: &TrainingConfig,
    task: &str,
    model_dir: &Path,
    output: Option<&Path>,
) -> anyhow::Result<()> {
    let task_config = config
        .tasks
        .get(task)
        .ok_or_else(|| anyhow::anyhow!("unknown task: {task}"))?;

    let meta_path = model_dir.join("training_meta.json");
    let meta: serde_json::Value = serde_json::from_str(&std::fs::read_to_string(&meta_path)?)?;
    let num_classes = meta["num_classes"].as_u64().unwrap() as usize;
    let label_map: HashMap<String, usize> = serde_json::from_value(meta["label_map"].clone())?;

    let device = <InferBackend as Backend>::Device::default();
    let record = CompactRecorder::new()
        .load(model_dir.join("best_model"), &device)
        .map_err(|e| anyhow::anyhow!("failed to load model: {e}"))?;
    let model: PlantCnn<InferBackend> = PlantCnn::new(num_classes, &device).load_record(record);

    let weights = extract_weights(&model);
    let onnx_path = output
        .map(|p| p.to_path_buf())
        .unwrap_or_else(|| PathBuf::from(&task_config.output_model));

    export::export_to_onnx(
        &weights,
        task_config.input_size,
        num_classes,
        config.export.onnx_opset,
        &onnx_path,
    )?;

    // The AI gateway serves a model directory as-is: model.onnx plus an
    // index-ordered labels.json and a version tag (the run directory name).
    if let Some(dir) = onnx_path.parent() {
        let mut labels = vec![String::new(); num_classes];
        for (name, idx) in &label_map {
            if *idx < num_classes {
                labels[*idx] = name.clone();
            }
        }
        if labels.iter().any(String::is_empty) {
            anyhow::bail!("label_map does not cover all {num_classes} classes");
        }
        std::fs::write(
            dir.join("labels.json"),
            serde_json::to_string_pretty(&labels)?,
        )?;
        let version = model_dir
            .file_name()
            .map(|n| format!("{task}-{}", n.to_string_lossy()))
            .unwrap_or_else(|| task.to_string());
        std::fs::write(dir.join("version.txt"), format!("{version}\n"))?;
        println!("Labels and version written to {}", dir.display());
    }

    println!("ONNX model exported to {}", onnx_path.display());
    Ok(())
}

fn cmd_pipeline(
    config: &TrainingConfig,
    tasks: &str,
    data_dir: Option<&str>,
    output_dir: &Path,
) -> anyhow::Result<()> {
    let task_list: Vec<&str> = if tasks == "all" {
        config.tasks.keys().map(|s| s.as_str()).collect()
    } else {
        tasks.split(',').map(|s| s.trim()).collect()
    };

    println!("{}", "=".repeat(60));
    println!("YieldPoint ML Training Pipeline (Rust)");
    println!("{}", "=".repeat(60));

    let base_dir = data_dir.unwrap_or(&config.data.base_dir);
    let mut results = Vec::new();

    for task in &task_list {
        println!("\n{}", "-".repeat(40));
        println!("Task: {task}");
        println!("{}", "-".repeat(40));

        let manifest = PathBuf::from(base_dir).join(task).join("manifest.jsonl");
        if !manifest.exists() {
            println!("  SKIP: no data collected yet");
            results.push((task.to_string(), "skipped", 0.0));
            continue;
        }

        let count = std::fs::read_to_string(&manifest)?
            .lines()
            .filter(|l| !l.trim().is_empty())
            .count();
        let min_needed = config.data.min_samples_per_class * 3;

        if count < min_needed {
            println!("  SKIP: only {count} samples (need >= {min_needed})");
            results.push((task.to_string(), "skipped", 0.0));
            continue;
        }

        println!("  Data: {count} samples");

        match cmd_train(config, task, data_dir, output_dir) {
            Ok(()) => {
                let task_dir = output_dir.join(task);

                match cmd_validate(config, task, &task_dir, data_dir) {
                    Ok(()) => match cmd_export(config, task, &task_dir, None) {
                        Ok(()) => {
                            results.push((task.to_string(), "success", 0.0));
                        }
                        Err(e) => {
                            println!("  FAILED: export — {e}");
                            results.push((task.to_string(), "export_failed", 0.0));
                        }
                    },
                    Err(e) => {
                        println!("  FAILED: validation — {e}");
                        results.push((task.to_string(), "validation_failed", 0.0));
                    }
                }
            }
            Err(e) => {
                println!("  FAILED: training — {e}");
                results.push((task.to_string(), "training_failed", 0.0));
            }
        }
    }

    println!("\n{}", "=".repeat(60));
    println!("Pipeline Summary");
    println!("{}", "=".repeat(60));
    for (task, status, _) in &results {
        println!("  {task}: {}", status.to_uppercase());
    }

    Ok(())
}

fn cmd_status(config: &TrainingConfig, data_dir: Option<&str>) -> anyhow::Result<()> {
    let base_dir = data_dir.unwrap_or(&config.data.base_dir);
    let base = PathBuf::from(base_dir);

    println!("Data collection status:");
    println!("{}", "-".repeat(50));

    for task in config.tasks.keys() {
        let manifest = base.join(task).join("manifest.jsonl");
        let count = if manifest.exists() {
            std::fs::read_to_string(&manifest)?
                .lines()
                .filter(|l| !l.trim().is_empty())
                .count()
        } else {
            0
        };

        let min_needed = config.data.min_samples_per_class * 3;
        let status = if count >= min_needed {
            "READY"
        } else {
            "collecting"
        };

        println!("  {task:<25} {count:>6} samples  ({status}, need >= {min_needed})");
    }

    Ok(())
}
