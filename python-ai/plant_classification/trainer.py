"""
Training pipeline for plant classification model.

Supports mixed precision training, learning rate scheduling,
early stopping, checkpointing, and comprehensive metric tracking.
"""

from __future__ import annotations

import json
import logging
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

import numpy as np
import torch
import torch.nn as nn
from torch.cuda.amp import GradScaler, autocast
from torch.optim import AdamW
from torch.optim.lr_scheduler import CosineAnnealingWarmRestarts, LinearLR, SequentialLR
from torch.utils.data import DataLoader, WeightedRandomSampler

from .model import PlantClassificationModel, NUM_CLASSES
from ..utils.metrics import accuracy, top_k_accuracy, precision_recall_f1, confusion_matrix

logger = logging.getLogger(__name__)


@dataclass
class TrainConfig:
    """Training configuration."""

    # Data
    data_root: str = "data/plantvillage"
    image_size: int = 224
    batch_size: int = 32
    num_workers: int = 4
    val_fraction: float = 0.15

    # Model
    num_classes: int = NUM_CLASSES
    pretrained: bool = True
    dropout: float = 0.3
    freeze_backbone_epochs: int = 5

    # Training
    num_epochs: int = 100
    learning_rate: float = 1e-3
    backbone_lr_scale: float = 0.1
    weight_decay: float = 1e-4
    label_smoothing: float = 0.1

    # Scheduler
    warmup_epochs: int = 5
    cosine_t0: int = 10
    cosine_t_mult: int = 2
    min_lr: float = 1e-6

    # Mixed precision
    use_amp: bool = True

    # Early stopping
    patience: int = 15
    min_delta: float = 1e-4

    # Checkpointing
    checkpoint_dir: str = "checkpoints/plant_classification"
    save_top_k: int = 3

    # Misc
    random_seed: int = 42
    log_interval: int = 50
    use_weighted_sampler: bool = True


@dataclass
class TrainState:
    """Mutable training state."""

    epoch: int = 0
    global_step: int = 0
    best_val_accuracy: float = 0.0
    best_val_f1: float = 0.0
    epochs_without_improvement: int = 0
    training_history: list[dict] = field(default_factory=list)


class PlantClassificationTrainer:
    """Full training pipeline for plant classification.

    Args:
        config: Training configuration.
        device: Device to train on.
    """

    def __init__(
        self,
        config: Optional[TrainConfig] = None,
        device: Optional[torch.device] = None,
    ):
        self.config = config or TrainConfig()
        self.device = device or torch.device("cuda" if torch.cuda.is_available() else "cpu")

        self.model: Optional[PlantClassificationModel] = None
        self.optimizer: Optional[AdamW] = None
        self.scheduler: Optional[SequentialLR] = None
        self.scaler: Optional[GradScaler] = None
        self.criterion: Optional[nn.CrossEntropyLoss] = None

        self.state = TrainState()

        # Ensure checkpoint directory exists
        Path(self.config.checkpoint_dir).mkdir(parents=True, exist_ok=True)

    def setup_model(self) -> None:
        """Initialize model, optimizer, scheduler, and loss."""
        self.model = PlantClassificationModel(
            num_classes=self.config.num_classes,
            pretrained=self.config.pretrained,
            dropout=self.config.dropout,
            freeze_backbone=True,
        ).to(self.device)

        # Optimizer with differential learning rates
        param_groups = self.model.get_trainable_params()
        optimizer_params = []
        for group in param_groups:
            optimizer_params.append({
                "params": group["params"],
                "lr": self.config.learning_rate * group["lr_scale"],
            })
        self.optimizer = AdamW(
            optimizer_params,
            weight_decay=self.config.weight_decay,
        )

        # Learning rate scheduler: warmup + cosine annealing with warm restarts
        warmup_scheduler = LinearLR(
            self.optimizer,
            start_factor=0.01,
            end_factor=1.0,
            total_iters=self.config.warmup_epochs,
        )
        cosine_scheduler = CosineAnnealingWarmRestarts(
            self.optimizer,
            T_0=self.config.cosine_t0,
            T_mult=self.config.cosine_t_mult,
            eta_min=self.config.min_lr,
        )
        self.scheduler = SequentialLR(
            self.optimizer,
            schedulers=[warmup_scheduler, cosine_scheduler],
            milestones=[self.config.warmup_epochs],
        )

        # Loss with label smoothing
        self.criterion = nn.CrossEntropyLoss(label_smoothing=self.config.label_smoothing)

        # Mixed precision scaler
        if self.config.use_amp and self.device.type == "cuda":
            self.scaler = GradScaler()

        total_params = sum(p.numel() for p in self.model.parameters())
        trainable_params = sum(p.numel() for p in self.model.parameters() if p.requires_grad)
        logger.info(
            f"Model initialized: {total_params:,} total params, "
            f"{trainable_params:,} trainable params"
        )

    def create_dataloaders(
        self,
        train_dataset,
        val_dataset,
    ) -> tuple[DataLoader, DataLoader]:
        """Create training and validation data loaders.

        Args:
            train_dataset: Training dataset.
            val_dataset: Validation dataset.

        Returns:
            Tuple of (train_loader, val_loader).
        """
        # Weighted sampler for class imbalance
        sampler = None
        shuffle = True
        if self.config.use_weighted_sampler:
            # Get labels from the subset
            if hasattr(train_dataset, "dataset"):
                base_dataset = train_dataset.dataset
                indices = train_dataset.indices
                all_labels = base_dataset.get_labels()
                labels = [all_labels[i] for i in indices]
            else:
                labels = train_dataset.get_labels()

            class_counts = np.bincount(labels, minlength=self.config.num_classes)
            class_weights = np.where(class_counts > 0, 1.0 / class_counts, 0.0)
            sample_weights = [class_weights[l] for l in labels]

            sampler = WeightedRandomSampler(
                weights=sample_weights,
                num_samples=len(sample_weights),
                replacement=True,
            )
            shuffle = False

        train_loader = DataLoader(
            train_dataset,
            batch_size=self.config.batch_size,
            shuffle=shuffle,
            sampler=sampler,
            num_workers=self.config.num_workers,
            pin_memory=True,
            drop_last=True,
            persistent_workers=self.config.num_workers > 0,
        )

        val_loader = DataLoader(
            val_dataset,
            batch_size=self.config.batch_size * 2,
            shuffle=False,
            num_workers=self.config.num_workers,
            pin_memory=True,
            persistent_workers=self.config.num_workers > 0,
        )

        return train_loader, val_loader

    def train_epoch(self, train_loader: DataLoader) -> dict:
        """Run one training epoch.

        Args:
            train_loader: Training data loader.

        Returns:
            Dict with training metrics for this epoch.
        """
        self.model.train()
        total_loss = 0.0
        total_correct = 0
        total_samples = 0
        epoch_start = time.time()

        for batch_idx, (images, labels) in enumerate(train_loader):
            images = images.to(self.device, non_blocking=True)
            labels = labels.to(self.device, non_blocking=True)

            self.optimizer.zero_grad(set_to_none=True)

            if self.scaler is not None:
                with autocast():
                    logits = self.model(images)
                    loss = self.criterion(logits, labels)

                self.scaler.scale(loss).backward()
                self.scaler.unscale_(self.optimizer)
                nn.utils.clip_grad_norm_(self.model.parameters(), max_norm=1.0)
                self.scaler.step(self.optimizer)
                self.scaler.update()
            else:
                logits = self.model(images)
                loss = self.criterion(logits, labels)
                loss.backward()
                nn.utils.clip_grad_norm_(self.model.parameters(), max_norm=1.0)
                self.optimizer.step()

            batch_size = labels.size(0)
            total_loss += loss.item() * batch_size
            total_correct += (logits.argmax(dim=1) == labels).sum().item()
            total_samples += batch_size
            self.state.global_step += 1

            if (batch_idx + 1) % self.config.log_interval == 0:
                running_acc = total_correct / total_samples
                running_loss = total_loss / total_samples
                logger.info(
                    f"  Batch {batch_idx + 1}/{len(train_loader)} - "
                    f"Loss: {running_loss:.4f}, Acc: {running_acc:.4f}"
                )

        epoch_time = time.time() - epoch_start
        avg_loss = total_loss / total_samples
        avg_acc = total_correct / total_samples

        return {
            "train_loss": avg_loss,
            "train_accuracy": avg_acc,
            "epoch_time": epoch_time,
        }

    @torch.no_grad()
    def validate(self, val_loader: DataLoader) -> dict:
        """Run validation.

        Args:
            val_loader: Validation data loader.

        Returns:
            Dict with validation metrics.
        """
        self.model.eval()
        total_loss = 0.0
        all_preds = []
        all_labels = []

        for images, labels in val_loader:
            images = images.to(self.device, non_blocking=True)
            labels = labels.to(self.device, non_blocking=True)

            if self.scaler is not None:
                with autocast():
                    logits = self.model(images)
                    loss = self.criterion(logits, labels)
            else:
                logits = self.model(images)
                loss = self.criterion(logits, labels)

            total_loss += loss.item() * labels.size(0)
            all_preds.append(logits.cpu())
            all_labels.append(labels.cpu())

        all_preds = torch.cat(all_preds, dim=0)
        all_labels = torch.cat(all_labels, dim=0)

        avg_loss = total_loss / all_labels.size(0)
        acc = accuracy(all_preds, all_labels)
        top5_acc = top_k_accuracy(all_preds, all_labels, k=5)
        prec, rec, f1 = precision_recall_f1(
            all_preds, all_labels, self.config.num_classes, average="macro"
        )
        cm = confusion_matrix(all_preds, all_labels, self.config.num_classes)

        return {
            "val_loss": avg_loss,
            "val_accuracy": acc,
            "val_top5_accuracy": top5_acc,
            "val_precision": prec,
            "val_recall": rec,
            "val_f1": f1,
            "confusion_matrix": cm,
        }

    def save_checkpoint(self, metrics: dict, is_best: bool = False) -> None:
        """Save a training checkpoint.

        Args:
            metrics: Current metrics dict.
            is_best: Whether this is the best model so far.
        """
        checkpoint = {
            "epoch": self.state.epoch,
            "global_step": self.state.global_step,
            "model_state_dict": self.model.state_dict(),
            "optimizer_state_dict": self.optimizer.state_dict(),
            "scheduler_state_dict": self.scheduler.state_dict(),
            "best_val_accuracy": self.state.best_val_accuracy,
            "best_val_f1": self.state.best_val_f1,
            "config": self.config.__dict__,
            "metrics": {k: v for k, v in metrics.items() if k != "confusion_matrix"},
        }

        if self.scaler is not None:
            checkpoint["scaler_state_dict"] = self.scaler.state_dict()

        ckpt_dir = Path(self.config.checkpoint_dir)

        # Save latest
        torch.save(checkpoint, ckpt_dir / "latest.pt")

        # Save periodic
        if (self.state.epoch + 1) % 10 == 0:
            torch.save(checkpoint, ckpt_dir / f"epoch_{self.state.epoch + 1}.pt")

        # Save best
        if is_best:
            torch.save(checkpoint, ckpt_dir / "best.pt")
            logger.info(f"Saved best model (val_acc={self.state.best_val_accuracy:.4f})")

    def load_checkpoint(self, path: str | Path) -> None:
        """Load a training checkpoint.

        Args:
            path: Path to the checkpoint file.
        """
        checkpoint = torch.load(path, map_location=self.device, weights_only=False)

        self.model.load_state_dict(checkpoint["model_state_dict"])
        self.optimizer.load_state_dict(checkpoint["optimizer_state_dict"])
        self.scheduler.load_state_dict(checkpoint["scheduler_state_dict"])

        if self.scaler is not None and "scaler_state_dict" in checkpoint:
            self.scaler.load_state_dict(checkpoint["scaler_state_dict"])

        self.state.epoch = checkpoint["epoch"]
        self.state.global_step = checkpoint["global_step"]
        self.state.best_val_accuracy = checkpoint["best_val_accuracy"]
        self.state.best_val_f1 = checkpoint["best_val_f1"]

        logger.info(f"Loaded checkpoint from epoch {self.state.epoch}")

    def train(self, train_loader: DataLoader, val_loader: DataLoader) -> dict:
        """Run the full training loop.

        Args:
            train_loader: Training data loader.
            val_loader: Validation data loader.

        Returns:
            Training history as a list of epoch metrics.
        """
        logger.info(f"Starting training for {self.config.num_epochs} epochs on {self.device}")
        logger.info(f"Config: {json.dumps(self.config.__dict__, indent=2, default=str)}")

        for epoch in range(self.state.epoch, self.config.num_epochs):
            self.state.epoch = epoch

            # Unfreeze backbone after initial epochs
            if epoch == self.config.freeze_backbone_epochs:
                logger.info(f"Unfreezing backbone at epoch {epoch}")
                self.model.unfreeze_backbone(from_layer=5)  # Unfreeze layer3 and layer4

                # Rebuild optimizer with backbone params
                param_groups = self.model.get_trainable_params()
                optimizer_params = []
                for group in param_groups:
                    optimizer_params.append({
                        "params": group["params"],
                        "lr": self.config.learning_rate * group["lr_scale"],
                    })
                self.optimizer = AdamW(
                    optimizer_params,
                    weight_decay=self.config.weight_decay,
                )

            logger.info(
                f"Epoch {epoch + 1}/{self.config.num_epochs} "
                f"(lr={self.optimizer.param_groups[0]['lr']:.2e})"
            )

            # Training
            train_metrics = self.train_epoch(train_loader)

            # Validation
            val_metrics = self.validate(val_loader)

            # Step scheduler
            self.scheduler.step()

            # Check for improvement
            is_best = False
            if val_metrics["val_accuracy"] > self.state.best_val_accuracy + self.config.min_delta:
                self.state.best_val_accuracy = val_metrics["val_accuracy"]
                self.state.best_val_f1 = val_metrics["val_f1"]
                self.state.epochs_without_improvement = 0
                is_best = True
            else:
                self.state.epochs_without_improvement += 1

            # Log epoch summary
            epoch_metrics = {**train_metrics, **{k: v for k, v in val_metrics.items() if k != "confusion_matrix"}}
            self.state.training_history.append(epoch_metrics)

            logger.info(
                f"  Train Loss: {train_metrics['train_loss']:.4f}, "
                f"Train Acc: {train_metrics['train_accuracy']:.4f}"
            )
            logger.info(
                f"  Val Loss: {val_metrics['val_loss']:.4f}, "
                f"Val Acc: {val_metrics['val_accuracy']:.4f}, "
                f"Val F1: {val_metrics['val_f1']:.4f}, "
                f"Top-5 Acc: {val_metrics['val_top5_accuracy']:.4f}"
            )

            # Save checkpoint
            self.save_checkpoint(val_metrics, is_best=is_best)

            # Early stopping
            if self.state.epochs_without_improvement >= self.config.patience:
                logger.info(
                    f"Early stopping after {self.config.patience} epochs without improvement"
                )
                break

        logger.info(
            f"Training complete. Best val accuracy: {self.state.best_val_accuracy:.4f}, "
            f"Best val F1: {self.state.best_val_f1:.4f}"
        )

        # Save training history
        history_path = Path(self.config.checkpoint_dir) / "training_history.json"
        with open(history_path, "w") as f:
            json.dump(self.state.training_history, f, indent=2)

        return self.state.training_history
