"""Validate an ONNX model against a test dataset and produce a classification
report before deploying to the Rust engines.

Usage:
    python validate_model.py --model /models/disease-detection-v1/model.onnx \
        --task disease --config ../configs/training_config.yaml
"""

import json

import click
import numpy as np
import onnxruntime as ort
import yaml
from sklearn.metrics import classification_report, confusion_matrix

from dataset import create_dataloaders


@click.command()
@click.option("--model", required=True, type=click.Path(exists=True))
@click.option(
    "--task",
    required=True,
    type=click.Choice(["disease", "pest", "nutrient_deficiency", "classification"]),
)
@click.option(
    "--config",
    "config_path",
    default="../configs/training_config.yaml",
    type=click.Path(exists=True),
)
@click.option("--data-dir", default=None)
@click.option("--output", default=None, help="Save report JSON to this path")
def main(model: str, task: str, config_path: str, data_dir: str, output: str):
    with open(config_path) as f:
        config = yaml.safe_load(f)

    _, _, test_loader, label_map = create_dataloaders(task, config, base_dir=data_dir)
    idx_to_label = {v: k for k, v in label_map.items()}

    session = ort.InferenceSession(model)
    input_name = session.get_inputs()[0].name

    all_preds = []
    all_labels = []

    for images, labels in test_loader:
        inputs = {input_name: images.numpy()}
        logits = session.run(None, inputs)[0]
        preds = np.argmax(logits, axis=1)
        all_preds.extend(preds.tolist())
        all_labels.extend(labels.tolist())

    target_names = [idx_to_label.get(i, f"class_{i}") for i in range(len(label_map))]
    report = classification_report(
        all_labels, all_preds, target_names=target_names, output_dict=True
    )
    cm = confusion_matrix(all_labels, all_preds)

    click.echo(
        classification_report(all_labels, all_preds, target_names=target_names)
    )
    click.echo(f"\nOverall accuracy: {report['accuracy']:.4f}")
    click.echo(f"Macro F1: {report['macro avg']['f1-score']:.4f}")

    if output:
        result = {
            "task": task,
            "model_path": model,
            "num_test_samples": len(all_labels),
            "accuracy": report["accuracy"],
            "macro_f1": report["macro avg"]["f1-score"],
            "per_class": {
                name: report.get(name, {}) for name in target_names
            },
            "confusion_matrix": cm.tolist(),
        }
        with open(output, "w") as f:
            json.dump(result, f, indent=2)
        click.echo(f"Report saved to {output}")

    min_accuracy = 0.70
    if report["accuracy"] < min_accuracy:
        click.echo(
            f"\nWARNING: Accuracy {report['accuracy']:.4f} is below "
            f"deployment threshold ({min_accuracy}). Do NOT deploy this model."
        )
        raise SystemExit(1)
    else:
        click.echo("\nModel passes deployment threshold. Ready for deployment.")


if __name__ == "__main__":
    main()
