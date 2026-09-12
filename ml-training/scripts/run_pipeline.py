"""End-to-end training pipeline: data preparation → training → export → validation.

Orchestrates the complete workflow for training custom ONNX models from
data collected by the AI gateway's external API integration.

Usage:
    python run_pipeline.py --tasks disease,pest,classification
    python run_pipeline.py --tasks all
"""

import json
import subprocess
import sys
from pathlib import Path

import click
import yaml

ALL_TASKS = ["disease", "pest", "nutrient_deficiency", "classification"]


def check_data_available(task: str, base_dir: str, min_samples: int) -> tuple[bool, int]:
    """Check if enough training data has been collected for a task."""
    manifest = Path(base_dir) / task / "manifest.jsonl"
    if not manifest.exists():
        return False, 0
    count = sum(1 for line in open(manifest) if line.strip())
    return count >= min_samples, count


@click.command()
@click.option(
    "--tasks",
    default="all",
    help="Comma-separated task names, or 'all'",
)
@click.option(
    "--config",
    "config_path",
    default="../configs/training_config.yaml",
    type=click.Path(exists=True),
)
@click.option("--data-dir", default=None)
@click.option("--skip-validation", is_flag=True, default=False)
@click.option("--deploy", is_flag=True, default=False, help="Copy models to deployment paths")
def main(tasks: str, config_path: str, data_dir: str, skip_validation: bool, deploy: bool):
    with open(config_path) as f:
        config = yaml.safe_load(f)

    task_list = ALL_TASKS if tasks == "all" else [t.strip() for t in tasks.split(",")]
    base_dir = data_dir or config["data"]["base_dir"]
    min_samples = config["data"].get("min_samples_per_class", 20) * 3

    click.echo("=" * 60)
    click.echo("YieldPoint ML Training Pipeline")
    click.echo("=" * 60)

    results = {}
    for task in task_list:
        click.echo(f"\n{'─' * 40}")
        click.echo(f"Task: {task}")
        click.echo(f"{'─' * 40}")

        ready, count = check_data_available(task, base_dir, min_samples)
        if not ready:
            click.echo(
                f"  SKIP: Only {count} samples collected "
                f"(need >= {min_samples}). Keep collecting data."
            )
            results[task] = {"status": "skipped", "reason": "insufficient_data", "samples": count}
            continue

        click.echo(f"  Data: {count} samples available")

        click.echo(f"  Training {task} model...")
        train_cmd = [
            sys.executable, "train.py",
            "--task", task,
            "--config", config_path,
        ]
        if data_dir:
            train_cmd.extend(["--data-dir", data_dir])

        ret = subprocess.run(train_cmd, cwd=str(Path(__file__).parent))
        if ret.returncode != 0:
            click.echo(f"  FAILED: Training failed for {task}")
            results[task] = {"status": "failed", "stage": "training"}
            continue

        if not skip_validation:
            model_path = config["tasks"][task]["output_model"]
            click.echo(f"  Validating {task} model...")
            val_cmd = [
                sys.executable, "validate_model.py",
                "--model", model_path,
                "--task", task,
                "--config", config_path,
                "--output", f"runs/{task}/validation_report.json",
            ]
            if data_dir:
                val_cmd.extend(["--data-dir", data_dir])

            ret = subprocess.run(val_cmd, cwd=str(Path(__file__).parent))
            if ret.returncode != 0:
                click.echo(f"  FAILED: Validation failed for {task} — model below threshold")
                results[task] = {"status": "failed", "stage": "validation"}
                continue

        results[task] = {"status": "success", "samples": count}
        click.echo(f"  {task} model ready for deployment.")

    click.echo(f"\n{'=' * 60}")
    click.echo("Pipeline Summary")
    click.echo(f"{'=' * 60}")
    for task, result in results.items():
        status = result["status"].upper()
        extra = ""
        if "samples" in result:
            extra = f" ({result['samples']} samples)"
        if "reason" in result:
            extra = f" — {result['reason']}"
        click.echo(f"  {task}: {status}{extra}")

    report_path = Path("runs/pipeline_report.json")
    report_path.parent.mkdir(parents=True, exist_ok=True)
    with open(report_path, "w") as f:
        json.dump(results, f, indent=2)


if __name__ == "__main__":
    main()
