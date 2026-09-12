mod config;
mod dataset;
mod export;
mod model;
mod training;
mod validate;

use std::collections::HashMap;
use std::path::{Path, PathBuf};

use burn::prelude::*;
use burn::record::{CompactRecorder, Recorder};
use burn_ndarray::NdArray;
use clap::{Parser, Subcommand};
use tracing_subscriber::{fmt, EnvFilter};

use crate::config::TrainingConfig;
use crate::dataset::prepare_datasets;
use crate::model::{extract_weights, PlantCnn};

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
    }
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

    let result = training::train(
        task,
        task_config,
        splits.train,
        splits.val,
        splits.test,
        num_classes,
        &task_output,
    )?;

    let meta = serde_json::json!({
        "task": task,
        "num_classes": num_classes,
        "input_size": task_config.input_size,
        "best_val_acc": result.best_val_acc,
        "test_acc": result.test_acc,
        "final_epoch": result.final_epoch,
        "label_map": splits.label_map,
    });
    std::fs::write(
        task_output.join("training_meta.json"),
        serde_json::to_string_pretty(&meta)?,
    )?;

    println!("Training complete: val_acc={:.4} test_acc={:.4}", result.best_val_acc, result.test_acc);
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
    let meta: serde_json::Value =
        serde_json::from_str(&std::fs::read_to_string(&meta_path)?)?;
    let num_classes = meta["num_classes"].as_u64().unwrap() as usize;
    let _label_map: HashMap<String, usize> =
        serde_json::from_value(meta["label_map"].clone())?;

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
                    Ok(()) => {
                        match cmd_export(config, task, &task_dir, None) {
                            Ok(()) => {
                                results.push((task.to_string(), "success", 0.0));
                            }
                            Err(e) => {
                                println!("  FAILED: export — {e}");
                                results.push((task.to_string(), "export_failed", 0.0));
                            }
                        }
                    }
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
        let status = if count >= min_needed { "READY" } else { "collecting" };

        println!("  {task:<25} {count:>6} samples  ({status}, need >= {min_needed})");
    }

    Ok(())
}
