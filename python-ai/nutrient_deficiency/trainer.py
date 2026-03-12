"""
Training pipeline for nutrient deficiency detection model.

Trains both multi-label detection and severity scoring heads.
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

from .model import NutrientDeficiencyModel, NutrientDeficiencyLoss, NUM_NUTRIENTS
from ..utils.metrics import multilabel_accuracy

logger = logging.getLogger(__name__)


@dataclass
class NutrientTrainConfig:
    """Training configuration for nutrient deficiency detection."""

    # Data
    data_root: str = "data/nutrient"
    image_size: int = 224
    batch_size: int = 32
    num_workers: int = 4
    val_fraction: float = 0.15

    # Model
    num_nutrients: int = NUM_NUTRIENTS
    pretrained: bool = True
    dropout: float = 0.3

    # Training
    num_epochs: int = 80
    learning_rate: float = 5e-4
    weight_decay: float = 1e-4

    # Loss weights
    detection_weight: float = 1.0
    severity_weight: float = 0.5

    # Scheduler
    warmup_epochs: int = 5
    min_lr: float = 1e-6

    # Mixed precision
    use_amp: bool = True

    # Early stopping
    patience: int = 15
    min_delta: float = 1e-4

    # Checkpointing
    checkpoint_dir: str = "checkpoints/nutrient_deficiency"

    random_seed: int = 42
    log_interval: int = 25


@dataclass
class NutrientTrainState:
    """Mutable training state."""

    epoch: int = 0
    global_step: int = 0
    best_val_f1: float = 0.0
    best_val_severity_acc: float = 0.0
    epochs_without_improvement: int = 0
    history: list[dict] = field(default_factory=list)


class NutrientDeficiencyTrainer:
    """Training pipeline for nutrient deficiency detection.

    Args:
        config: Training configuration.
        device: Device to train on.
    """

    def __init__(
        self,
        config: Optional[NutrientTrainConfig] = None,
        device: Optional[torch.device] = None,
    ):
        self.config = config or NutrientTrainConfig()
        self.device = device or torch.device("cuda" if torch.cuda.is_available() else "cpu")

        self.model: Optional[NutrientDeficiencyModel] = None
        self.optimizer: Optional[AdamW] = None
        self.scheduler = None
        self.scaler: Optional[GradScaler] = None
        self.criterion: Optional[NutrientDeficiencyLoss] = None

        self.state = NutrientTrainState()
        Path(self.config.checkpoint_dir).mkdir(parents=True, exist_ok=True)

    def setup_model(self, pos_weights: Optional[np.ndarray] = None) -> None:
        """Initialize model, optimizer, scheduler, and loss."""
        self.model = NutrientDeficiencyModel(
            num_nutrients=self.config.num_nutrients,
            pretrained=self.config.pretrained,
            dropout=self.config.dropout,
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

        pw = torch.tensor(pos_weights).to(self.device) if pos_weights is not None else None
        self.criterion = NutrientDeficiencyLoss(
            alpha=self.config.detection_weight,
            beta=self.config.severity_weight,
            pos_weight=pw,
        )

        if self.config.use_amp and self.device.type == "cuda":
            self.scaler = GradScaler()

        total_params = sum(p.numel() for p in self.model.parameters())
        logger.info(f"Nutrient model initialized: {total_params:,} parameters")

    def train_epoch(self, train_loader: DataLoader) -> dict:
        """Run one training epoch."""
        self.model.train()
        total_loss = 0.0
        total_det_loss = 0.0
        total_sev_loss = 0.0
        total_samples = 0
        epoch_start = time.time()

        for batch_idx, batch in enumerate(train_loader):
            images = batch["image"].to(self.device, non_blocking=True)
            deficiencies = torch.tensor(
                np.stack([b for b in batch["deficiencies"]]), dtype=torch.float32
            ).to(self.device) if isinstance(batch["deficiencies"], list) else batch["deficiencies"].float().to(self.device)
            severity = torch.tensor(
                np.stack([b for b in batch["severity"]]), dtype=torch.long
            ).to(self.device) if isinstance(batch["severity"], list) else batch["severity"].long().to(self.device)

            self.optimizer.zero_grad(set_to_none=True)

            if self.scaler is not None:
                with autocast():
                    outputs = self.model(images)
                    losses = self.criterion(
                        outputs["detection"], deficiencies,
                        outputs["severity"], severity,
                    )

                self.scaler.scale(losses["total_loss"]).backward()
                self.scaler.unscale_(self.optimizer)
                nn.utils.clip_grad_norm_(self.model.parameters(), max_norm=1.0)
                self.scaler.step(self.optimizer)
                self.scaler.update()
            else:
                outputs = self.model(images)
                losses = self.criterion(
                    outputs["detection"], deficiencies,
                    outputs["severity"], severity,
                )
                losses["total_loss"].backward()
                nn.utils.clip_grad_norm_(self.model.parameters(), max_norm=1.0)
                self.optimizer.step()

            bs = images.size(0)
            total_loss += losses["total_loss"].item() * bs
            total_det_loss += losses["detection_loss"].item() * bs
            total_sev_loss += losses["severity_loss"].item() * bs
            total_samples += bs
            self.state.global_step += 1

            if (batch_idx + 1) % self.config.log_interval == 0:
                logger.info(
                    f"  Batch {batch_idx + 1}/{len(train_loader)} - "
                    f"Loss: {total_loss / total_samples:.4f}"
                )

        return {
            "train_total_loss": total_loss / total_samples,
            "train_det_loss": total_det_loss / total_samples,
            "train_sev_loss": total_sev_loss / total_samples,
            "epoch_time": time.time() - epoch_start,
        }

    @torch.no_grad()
    def validate(self, val_loader: DataLoader) -> dict:
        """Run validation."""
        self.model.eval()
        all_det_preds = []
        all_det_labels = []
        total_sev_correct = 0
        total_sev_samples = 0

        for batch in val_loader:
            images = batch["image"].to(self.device, non_blocking=True)
            deficiencies = torch.tensor(
                np.stack([b for b in batch["deficiencies"]]), dtype=torch.float32
            ).to(self.device) if isinstance(batch["deficiencies"], list) else batch["deficiencies"].float().to(self.device)
            severity = torch.tensor(
                np.stack([b for b in batch["severity"]]), dtype=torch.long
            ).to(self.device) if isinstance(batch["severity"], list) else batch["severity"].long().to(self.device)

            if self.scaler is not None:
                with autocast():
                    outputs = self.model(images)
            else:
                outputs = self.model(images)

            det_probs = torch.sigmoid(outputs["detection"])
            all_det_preds.append(det_probs.cpu())
            all_det_labels.append(deficiencies.cpu())

            # Severity accuracy (only for actually deficient nutrients)
            sev_preds = outputs["severity"].argmax(dim=2)  # (N, num_nutrients)
            deficiency_mask = deficiencies > 0.5
            if deficiency_mask.any():
                total_sev_correct += (sev_preds[deficiency_mask] == severity[deficiency_mask]).sum().item()
                total_sev_samples += deficiency_mask.sum().item()

        all_det_preds = torch.cat(all_det_preds, dim=0)
        all_det_labels = torch.cat(all_det_labels, dim=0)

        exact_match, sample_acc, sample_prec, sample_rec = multilabel_accuracy(
            all_det_preds, all_det_labels
        )

        if sample_prec + sample_rec > 0:
            sample_f1 = 2 * sample_prec * sample_rec / (sample_prec + sample_rec)
        else:
            sample_f1 = 0.0

        sev_acc = total_sev_correct / max(total_sev_samples, 1)

        return {
            "val_exact_match": exact_match,
            "val_sample_accuracy": sample_acc,
            "val_precision": sample_prec,
            "val_recall": sample_rec,
            "val_f1": sample_f1,
            "val_severity_accuracy": sev_acc,
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
            "best_val_severity_acc": self.state.best_val_severity_acc,
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
        self.state.best_val_severity_acc = checkpoint["best_val_severity_acc"]
        logger.info(f"Loaded checkpoint from epoch {self.state.epoch}")

    def train(self, train_loader: DataLoader, val_loader: DataLoader) -> list[dict]:
        """Run the full training loop."""
        logger.info(f"Starting nutrient deficiency training for {self.config.num_epochs} epochs")

        for epoch in range(self.state.epoch, self.config.num_epochs):
            self.state.epoch = epoch
            lr = self.optimizer.param_groups[0]["lr"]
            logger.info(f"Epoch {epoch + 1}/{self.config.num_epochs} (lr={lr:.2e})")

            train_metrics = self.train_epoch(train_loader)
            val_metrics = self.validate(val_loader)
            self.scheduler.step()

            is_best = False
            combined = val_metrics["val_f1"] + val_metrics["val_severity_accuracy"]
            best_combined = self.state.best_val_f1 + self.state.best_val_severity_acc

            if combined > best_combined + self.config.min_delta:
                self.state.best_val_f1 = val_metrics["val_f1"]
                self.state.best_val_severity_acc = val_metrics["val_severity_accuracy"]
                self.state.epochs_without_improvement = 0
                is_best = True
            else:
                self.state.epochs_without_improvement += 1

            epoch_metrics = {**train_metrics, **val_metrics}
            self.state.history.append(epoch_metrics)

            logger.info(
                f"  Train Loss: {train_metrics['train_total_loss']:.4f} "
                f"(det: {train_metrics['train_det_loss']:.4f}, "
                f"sev: {train_metrics['train_sev_loss']:.4f})"
            )
            logger.info(
                f"  Val F1: {val_metrics['val_f1']:.4f}, "
                f"Severity Acc: {val_metrics['val_severity_accuracy']:.4f}, "
                f"Prec: {val_metrics['val_precision']:.4f}, "
                f"Rec: {val_metrics['val_recall']:.4f}"
            )

            self.save_checkpoint(val_metrics, is_best=is_best)

            if self.state.epochs_without_improvement >= self.config.patience:
                logger.info(f"Early stopping after {self.config.patience} epochs")
                break

        logger.info(
            f"Training complete. Best F1: {self.state.best_val_f1:.4f}, "
            f"Best Severity Acc: {self.state.best_val_severity_acc:.4f}"
        )

        history_path = Path(self.config.checkpoint_dir) / "training_history.json"
        with open(history_path, "w") as f:
            json.dump(self.state.history, f, indent=2)

        return self.state.history
