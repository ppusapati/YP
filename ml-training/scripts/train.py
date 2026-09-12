"""Train a vision model from data collected by the AI gateway.

Fine-tunes a pretrained EfficientNet on the labeled images collected via
external API calls, then exports the trained model to ONNX format for
deployment in the Rust inference engines.

Usage:
    python train.py --task disease --config ../configs/training_config.yaml
    python train.py --task pest --config ../configs/training_config.yaml
    python train.py --task classification
"""

import json
import os
from pathlib import Path

import click
import torch
import torch.nn as nn
import yaml
from torch.optim import AdamW
from torch.optim.lr_scheduler import CosineAnnealingLR
from torch.utils.tensorboard import SummaryWriter
from tqdm import tqdm

from dataset import create_dataloaders
from export_onnx import export_to_onnx


def build_model(architecture: str, num_classes: int) -> nn.Module:
    """Build a pretrained model for fine-tuning."""
    import torchvision.models as models

    if architecture == "efficientnet_b0":
        model = models.efficientnet_b0(weights=models.EfficientNet_B0_Weights.DEFAULT)
        model.classifier[1] = nn.Linear(model.classifier[1].in_features, num_classes)
    elif architecture == "efficientnet_b2":
        model = models.efficientnet_b2(weights=models.EfficientNet_B2_Weights.DEFAULT)
        model.classifier[1] = nn.Linear(model.classifier[1].in_features, num_classes)
    elif architecture == "mobilenet_v3_large":
        model = models.mobilenet_v3_large(
            weights=models.MobileNet_V3_Large_Weights.DEFAULT
        )
        model.classifier[3] = nn.Linear(model.classifier[3].in_features, num_classes)
    elif architecture == "resnet50":
        model = models.resnet50(weights=models.ResNet50_Weights.DEFAULT)
        model.fc = nn.Linear(model.fc.in_features, num_classes)
    else:
        raise ValueError(f"Unsupported architecture: {architecture}")

    return model


def train_one_epoch(
    model: nn.Module,
    loader,
    criterion,
    optimizer,
    device: torch.device,
    epoch: int,
) -> tuple[float, float]:
    model.train()
    total_loss = 0.0
    correct = 0
    total = 0

    pbar = tqdm(loader, desc=f"Train epoch {epoch}")
    for images, labels in pbar:
        images = images.to(device)
        labels = labels.to(device)

        optimizer.zero_grad()
        outputs = model(images)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()

        total_loss += loss.item() * images.size(0)
        _, predicted = outputs.max(1)
        correct += predicted.eq(labels).sum().item()
        total += labels.size(0)

        pbar.set_postfix(loss=loss.item(), acc=correct / total)

    return total_loss / total, correct / total


@torch.no_grad()
def evaluate(
    model: nn.Module,
    loader,
    criterion,
    device: torch.device,
) -> tuple[float, float]:
    model.eval()
    total_loss = 0.0
    correct = 0
    total = 0

    for images, labels in loader:
        images = images.to(device)
        labels = labels.to(device)

        outputs = model(images)
        loss = criterion(outputs, labels)

        total_loss += loss.item() * images.size(0)
        _, predicted = outputs.max(1)
        correct += predicted.eq(labels).sum().item()
        total += labels.size(0)

    return total_loss / total, correct / total


@click.command()
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
@click.option("--output-dir", default=None, help="Override output directory")
@click.option("--data-dir", default=None, help="Override data directory")
def main(task: str, config_path: str, output_dir: str, data_dir: str):
    with open(config_path) as f:
        config = yaml.safe_load(f)

    task_cfg = config["tasks"][task]
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    click.echo(f"Training {task} model on {device}")

    train_loader, val_loader, test_loader, label_map = create_dataloaders(
        task, config, base_dir=data_dir
    )
    num_classes = len(label_map)
    click.echo(f"Classes: {num_classes}, Train: {len(train_loader.dataset)}, "
               f"Val: {len(val_loader.dataset)}, Test: {len(test_loader.dataset)}")

    model = build_model(task_cfg["architecture"], num_classes).to(device)

    criterion = nn.CrossEntropyLoss(
        label_smoothing=task_cfg.get("label_smoothing", 0.1)
    )
    optimizer = AdamW(
        model.parameters(),
        lr=task_cfg["learning_rate"],
        weight_decay=task_cfg.get("weight_decay", 1e-4),
    )
    scheduler = CosineAnnealingLR(optimizer, T_max=task_cfg["num_epochs"])

    out = Path(output_dir or f"runs/{task}")
    out.mkdir(parents=True, exist_ok=True)
    writer = SummaryWriter(log_dir=str(out / "logs"))

    best_val_acc = 0.0
    patience_counter = 0
    patience = task_cfg.get("early_stopping_patience", 10)

    for epoch in range(1, task_cfg["num_epochs"] + 1):
        train_loss, train_acc = train_one_epoch(
            model, train_loader, criterion, optimizer, device, epoch
        )
        val_loss, val_acc = evaluate(model, val_loader, criterion, device)
        scheduler.step()

        writer.add_scalars("loss", {"train": train_loss, "val": val_loss}, epoch)
        writer.add_scalars("accuracy", {"train": train_acc, "val": val_acc}, epoch)
        writer.add_scalar("lr", scheduler.get_last_lr()[0], epoch)

        click.echo(
            f"Epoch {epoch}/{task_cfg['num_epochs']} — "
            f"Train: loss={train_loss:.4f} acc={train_acc:.4f} — "
            f"Val: loss={val_loss:.4f} acc={val_acc:.4f}"
        )

        if val_acc > best_val_acc:
            best_val_acc = val_acc
            patience_counter = 0
            checkpoint = {
                "epoch": epoch,
                "model_state_dict": model.state_dict(),
                "optimizer_state_dict": optimizer.state_dict(),
                "val_acc": val_acc,
                "label_map": label_map,
                "config": task_cfg,
            }
            torch.save(checkpoint, out / "best_model.pt")
            click.echo(f"  New best model saved (val_acc={val_acc:.4f})")
        else:
            patience_counter += 1
            if patience_counter >= patience:
                click.echo(f"Early stopping at epoch {epoch}")
                break

    checkpoint = torch.load(out / "best_model.pt", weights_only=False)
    model.load_state_dict(checkpoint["model_state_dict"])

    test_loss, test_acc = evaluate(model, test_loader, criterion, device)
    click.echo(f"Test: loss={test_loss:.4f} acc={test_acc:.4f}")

    onnx_path = task_cfg.get("output_model", str(out / "model.onnx"))
    os.makedirs(os.path.dirname(onnx_path), exist_ok=True)
    export_to_onnx(
        model=model,
        input_size=task_cfg["input_size"],
        num_classes=num_classes,
        output_path=onnx_path,
        opset=config.get("export", {}).get("onnx_opset", 17),
        dynamic_batch=config.get("export", {}).get("dynamic_batch", True),
    )
    click.echo(f"ONNX model exported to {onnx_path}")

    meta = {
        "task": task,
        "architecture": task_cfg["architecture"],
        "num_classes": num_classes,
        "input_size": task_cfg["input_size"],
        "best_val_acc": best_val_acc,
        "test_acc": test_acc,
        "label_map": label_map,
        "onnx_path": onnx_path,
    }
    with open(out / "training_meta.json", "w") as f:
        json.dump(meta, f, indent=2)

    writer.close()
    click.echo("Training complete.")


if __name__ == "__main__":
    main()
