"""
Training pipeline for pest detection.

Trains the MobileNetV3-based multi-label classifier with
optional bounding box regression.
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
from torch.optim.lr_scheduler import CosineAnnealingLR, LinearLR, SequentialLR
from torch.utils.data import DataLoader

from .model import PestDetectionModel, PestDetectionLoss, NUM_PEST_CLASSES
from ..utils.metrics import multilabel_accuracy

logger = logging.getLogger(__name__)


@dataclass
class PestTrainConfig:
    """Training configuration for pest detection."""

    # Data
    data_root: str = "data/pest"
    image_size: int = 320
    batch_size: int = 32
    num_workers: int = 4
    val_fraction: float = 0.15
    with_bbox: bool = False

    # Model
    num_classes: int = NUM_PEST_CLASSES
    pretrained: bool = True
    dropout: float = 0.2

    # Training
    num_epochs: int = 80
    learning_rate: float = 3e-4
    weight_decay: float = 1e-4

    # Loss
    cls_loss_weight: float = 1.0
    bbox_loss_weight: float = 0.5
    label_smoothing: float = 0.05

    # Scheduler
    warmup_epochs: int = 5
    min_lr: float = 1e-6

    # Mixed precision
    use_amp: bool = True

    # Early stopping
    patience: int = 15
    min_delta: float = 1e-4

    # Checkpointing
    checkpoint_dir: str = "checkpoints/pest_detection"

    # Misc
    random_seed: int = 42
    log_interval: int = 25


@dataclass
class PestTrainState:
    """Mutable training state."""

    epoch: int = 0
    global_step: int = 0
    best_val_f1: float = 0.0
    epochs_without_improvement: int = 0
    history: list[dict] = field(default_factory=list)


class PestDetectionTrainer:
    """Training pipeline for pest detection.

    Args:
        config: Training configuration.
        device: Device to train on.
    """

    def __init__(
        self,
        config: Optional[PestTrainConfig] = None,
        device: Optional[torch.device] = None,
    ):
        self.config = config or PestTrainConfig()
        self.device = device or torch.device("cuda" if torch.cuda.is_available() else "cpu")

        self.model: Optional[PestDetectionModel] = None
        self.optimizer: Optional[AdamW] = None
        self.scheduler = None
        self.scaler: Optional[GradScaler] = None
        self.criterion: Optional[PestDetectionLoss] = None

        self.state = PestTrainState()
        Path(self.config.checkpoint_dir).mkdir(parents=True, exist_ok=True)

    def setup_model(self, pos_weights: Optional[np.ndarray] = None) -> None:
        """Initialize model, optimizer, scheduler, and loss function."""
        self.model = PestDetectionModel(
            num_classes=self.config.num_classes,
            pretrained=self.config.pretrained,
            dropout=self.config.dropout,
            with_bbox=self.config.with_bbox,
        ).to(self.device)

        self.optimizer = AdamW(
            self.model.parameters(),
            lr=self.config.learning_rate,
            weight_decay=self.config.weight_decay,
        )

        warmup = LinearLR(
            self.optimizer,
            start_factor=0.01,
            end_factor=1.0,
            total_iters=self.config.warmup_epochs,
        )
        cosine = CosineAnnealingLR(
            self.optimizer,
            T_max=self.config.num_epochs - self.config.warmup_epochs,
            eta_min=self.config.min_lr,
        )
        self.scheduler = SequentialLR(
            self.optimizer,
            schedulers=[warmup, cosine],
            milestones=[self.config.warmup_epochs],
        )

        self.criterion = PestDetectionLoss(
            alpha=self.config.cls_loss_weight,
            beta=self.config.bbox_loss_weight,
            label_smoothing=self.config.label_smoothing,
        )

        if self.config.use_amp and self.device.type == "cuda":
            self.scaler = GradScaler()

        total_params = sum(p.numel() for p in self.model.parameters())
        logger.info(f"Pest model initialized: {total_params:,} parameters")

    def train_epoch(self, train_loader: DataLoader) -> dict:
        """Run one training epoch."""
        self.model.train()
        total_cls_loss = 0.0
        total_bbox_loss = 0.0
        total_loss = 0.0
        total_samples = 0
        epoch_start = time.time()

        for batch_idx, batch in enumerate(train_loader):
            images = batch["image"].to(self.device, non_blocking=True)
            labels = torch.tensor(
                np.stack([b for b in batch["labels"]]), dtype=torch.float32
            ).to(self.device) if isinstance(batch["labels"], list) else batch["labels"].float().to(self.device)

            bbox_targets = None
            if self.config.with_bbox and "bbox" in batch:
                bbox_targets = batch["bbox"].float().to(self.device)

            self.optimizer.zero_grad(set_to_none=True)

            if self.scaler is not None:
                with autocast():
                    outputs = self.model(images)
                    cls_logits = outputs["classification"]
                    bbox_pred = outputs.get("bbox", None)

                    losses = self.criterion(
                        cls_logits, labels, bbox_pred, bbox_targets,
                    )

                self.scaler.scale(losses["total_loss"]).backward()
                self.scaler.unscale_(self.optimizer)
                nn.utils.clip_grad_norm_(self.model.parameters(), max_norm=1.0)
                self.scaler.step(self.optimizer)
                self.scaler.update()
            else:
                outputs = self.model(images)
                cls_logits = outputs["classification"]
                bbox_pred = outputs.get("bbox", None)

                losses = self.criterion(
                    cls_logits, labels, bbox_pred, bbox_targets,
                )
                losses["total_loss"].backward()
                nn.utils.clip_grad_norm_(self.model.parameters(), max_norm=1.0)
                self.optimizer.step()

            bs = images.size(0)
            total_loss += losses["total_loss"].item() * bs
            total_cls_loss += losses["classification_loss"].item() * bs
            if "bbox_loss" in losses:
                total_bbox_loss += losses["bbox_loss"].item() * bs
            total_samples += bs
            self.state.global_step += 1

            if (batch_idx + 1) % self.config.log_interval == 0:
                logger.info(
                    f"  Batch {batch_idx + 1}/{len(train_loader)} - "
                    f"Loss: {total_loss / total_samples:.4f}"
                )

        return {
            "train_total_loss": total_loss / total_samples,
            "train_cls_loss": total_cls_loss / total_samples,
            "train_bbox_loss": total_bbox_loss / max(total_samples, 1),
            "epoch_time": time.time() - epoch_start,
        }

    @torch.no_grad()
    def validate(self, val_loader: DataLoader) -> dict:
        """Run validation."""
        self.model.eval()
        all_cls_preds = []
        all_cls_labels = []

        for batch in val_loader:
            images = batch["image"].to(self.device, non_blocking=True)
            labels = torch.tensor(
                np.stack([b for b in batch["labels"]]), dtype=torch.float32
            ).to(self.device) if isinstance(batch["labels"], list) else batch["labels"].float().to(self.device)

            if self.scaler is not None:
                with autocast():
                    outputs = self.model(images)
            else:
                outputs = self.model(images)

            cls_probs = torch.sigmoid(outputs["classification"])
            all_cls_preds.append(cls_probs.cpu())
            all_cls_labels.append(labels.cpu())

        all_cls_preds = torch.cat(all_cls_preds, dim=0)
        all_cls_labels = torch.cat(all_cls_labels, dim=0)

        exact_match, sample_acc, sample_prec, sample_rec = multilabel_accuracy(
            all_cls_preds, all_cls_labels
        )

        sample_f1 = (
            2 * sample_prec * sample_rec / (sample_prec + sample_rec)
            if (sample_prec + sample_rec) > 0
            else 0.0
        )

        return {
            "val_exact_match": exact_match,
            "val_sample_accuracy": sample_acc,
            "val_precision": sample_prec,
            "val_recall": sample_rec,
            "val_f1": sample_f1,
        }

    def save_checkpoint(self, metrics: dict, is_best: bool = False) -> None:
        """Save training checkpoint."""
        checkpoint = {
            "epoch": self.state.epoch,
            "global_step": self.state.global_step,
            "model_state_dict": self.model.state_dict(),
            "optimizer_state_dict": self.optimizer.state_dict(),
            "scheduler_state_dict": self.scheduler.state_dict(),
            "best_val_f1": self.state.best_val_f1,
            "config": self.config.__dict__,
            "metrics": metrics,
        }
        if self.scaler is not None:
            checkpoint["scaler_state_dict"] = self.scaler.state_dict()

        ckpt_dir = Path(self.config.checkpoint_dir)
        torch.save(checkpoint, ckpt_dir / "latest.pt")
        if is_best:
            torch.save(checkpoint, ckpt_dir / "best.pt")
            logger.info(f"Saved best model (val_f1={self.state.best_val_f1:.4f})")

    def load_checkpoint(self, path: str | Path) -> None:
        """Load training checkpoint."""
        checkpoint = torch.load(path, map_location=self.device, weights_only=False)
        self.model.load_state_dict(checkpoint["model_state_dict"])
        self.optimizer.load_state_dict(checkpoint["optimizer_state_dict"])
        self.scheduler.load_state_dict(checkpoint["scheduler_state_dict"])
        if self.scaler is not None and "scaler_state_dict" in checkpoint:
            self.scaler.load_state_dict(checkpoint["scaler_state_dict"])
        self.state.epoch = checkpoint["epoch"]
        self.state.global_step = checkpoint["global_step"]
        self.state.best_val_f1 = checkpoint["best_val_f1"]
        logger.info(f"Loaded checkpoint from epoch {self.state.epoch}")

    def train(self, train_loader: DataLoader, val_loader: DataLoader) -> list[dict]:
        """Run the full training loop."""
        logger.info(f"Starting pest detection training for {self.config.num_epochs} epochs")

        for epoch in range(self.state.epoch, self.config.num_epochs):
            self.state.epoch = epoch
            lr = self.optimizer.param_groups[0]["lr"]
            logger.info(f"Epoch {epoch + 1}/{self.config.num_epochs} (lr={lr:.2e})")

            train_metrics = self.train_epoch(train_loader)
            val_metrics = self.validate(val_loader)
            self.scheduler.step()

            is_best = False
            if val_metrics["val_f1"] > self.state.best_val_f1 + self.config.min_delta:
                self.state.best_val_f1 = val_metrics["val_f1"]
                self.state.epochs_without_improvement = 0
                is_best = True
            else:
                self.state.epochs_without_improvement += 1

            epoch_metrics = {**train_metrics, **val_metrics}
            self.state.history.append(epoch_metrics)

            logger.info(
                f"  Train Loss: {train_metrics['train_total_loss']:.4f} "
                f"(cls: {train_metrics['train_cls_loss']:.4f})"
            )
            logger.info(
                f"  Val F1: {val_metrics['val_f1']:.4f}, "
                f"Prec: {val_metrics['val_precision']:.4f}, "
                f"Rec: {val_metrics['val_recall']:.4f}"
            )

            self.save_checkpoint(val_metrics, is_best=is_best)

            if self.state.epochs_without_improvement >= self.config.patience:
                logger.info(f"Early stopping after {self.config.patience} epochs")
                break

        logger.info(f"Training complete. Best F1: {self.state.best_val_f1:.4f}")

        history_path = Path(self.config.checkpoint_dir) / "training_history.json"
        with open(history_path, "w") as f:
            json.dump(self.state.history, f, indent=2)

        return self.state.history
