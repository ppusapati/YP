"""
Multi-task training pipeline for disease detection.

Trains classification and segmentation heads jointly with
combined CrossEntropy + Dice loss.
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

from .model import DiseaseDetectionModel, CombinedLoss, NUM_DISEASE_CLASSES
from ..utils.metrics import multilabel_accuracy, dice_coefficient

logger = logging.getLogger(__name__)


@dataclass
class DiseaseTrainConfig:
    """Training configuration for disease detection."""

    # Data
    data_root: str = "data/disease"
    image_size: int = 256
    batch_size: int = 16
    num_workers: int = 4
    val_fraction: float = 0.15
    has_masks: bool = True

    # Model
    num_classes: int = NUM_DISEASE_CLASSES
    pretrained: bool = True
    dropout: float = 0.3
    segmentation_classes: int = 1

    # Training
    num_epochs: int = 100
    learning_rate: float = 5e-4
    weight_decay: float = 1e-4

    # Loss weights
    cls_loss_weight: float = 1.0
    seg_loss_weight: float = 0.5
    label_smoothing: float = 0.05

    # Scheduler
    warmup_epochs: int = 5
    min_lr: float = 1e-6

    # Mixed precision
    use_amp: bool = True

    # Early stopping
    patience: int = 20
    min_delta: float = 1e-4

    # Checkpointing
    checkpoint_dir: str = "checkpoints/disease_detection"

    # Misc
    random_seed: int = 42
    log_interval: int = 25


@dataclass
class DiseaseTrainState:
    """Mutable training state."""

    epoch: int = 0
    global_step: int = 0
    best_val_f1: float = 0.0
    best_val_dice: float = 0.0
    epochs_without_improvement: int = 0
    history: list[dict] = field(default_factory=list)


class DiseaseDetectionTrainer:
    """Multi-task training pipeline for disease detection.

    Trains both classification and segmentation heads jointly.
    Classification loss: BCE with logits
    Segmentation loss: BCE + Dice

    Args:
        config: Training configuration.
        device: Device to train on.
    """

    def __init__(
        self,
        config: Optional[DiseaseTrainConfig] = None,
        device: Optional[torch.device] = None,
    ):
        self.config = config or DiseaseTrainConfig()
        self.device = device or torch.device("cuda" if torch.cuda.is_available() else "cpu")

        self.model: Optional[DiseaseDetectionModel] = None
        self.optimizer: Optional[AdamW] = None
        self.scheduler = None
        self.scaler: Optional[GradScaler] = None
        self.criterion: Optional[CombinedLoss] = None

        self.state = DiseaseTrainState()
        Path(self.config.checkpoint_dir).mkdir(parents=True, exist_ok=True)

    def setup_model(self, pos_weights: Optional[np.ndarray] = None) -> None:
        """Initialize model, optimizer, scheduler, and loss function.

        Args:
            pos_weights: Optional positive class weights for BCE loss.
        """
        self.model = DiseaseDetectionModel(
            num_classes=self.config.num_classes,
            pretrained=self.config.pretrained,
            dropout=self.config.dropout,
            segmentation_classes=self.config.segmentation_classes,
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

        self.criterion = CombinedLoss(
            alpha=self.config.cls_loss_weight,
            beta=self.config.seg_loss_weight,
            label_smoothing=self.config.label_smoothing,
        )

        if self.config.use_amp and self.device.type == "cuda":
            self.scaler = GradScaler()

        total_params = sum(p.numel() for p in self.model.parameters())
        logger.info(f"Disease model initialized: {total_params:,} parameters")

    def train_epoch(self, train_loader: DataLoader) -> dict:
        """Run one training epoch.

        Args:
            train_loader: Training data loader.

        Returns:
            Dict of training metrics.
        """
        self.model.train()
        total_cls_loss = 0.0
        total_seg_loss = 0.0
        total_loss = 0.0
        total_samples = 0
        num_seg_samples = 0
        epoch_start = time.time()

        for batch_idx, batch in enumerate(train_loader):
            images = batch["image"].to(self.device, non_blocking=True)
            labels = torch.tensor(
                np.stack([b for b in batch["labels"]]), dtype=torch.float32
            ).to(self.device) if isinstance(batch["labels"], list) else batch["labels"].float().to(self.device)
            masks = batch["mask"].to(self.device, non_blocking=True) if "mask" in batch else None
            has_mask = batch.get("has_mask", None)

            self.optimizer.zero_grad(set_to_none=True)

            if self.scaler is not None:
                with autocast():
                    outputs = self.model(images, return_segmentation=masks is not None)
                    cls_logits = outputs["classification"]
                    seg_logits = outputs.get("segmentation", None)

                    # Only compute segmentation loss for samples with masks
                    seg_logits_masked = None
                    seg_targets_masked = None
                    if seg_logits is not None and has_mask is not None:
                        mask_indices = [i for i, hm in enumerate(has_mask) if hm]
                        if mask_indices:
                            idx = torch.tensor(mask_indices, device=self.device)
                            seg_logits_masked = seg_logits[idx]
                            seg_targets_masked = masks[idx]

                    losses = self.criterion(
                        cls_logits, labels,
                        seg_logits_masked, seg_targets_masked,
                    )

                self.scaler.scale(losses["total_loss"]).backward()
                self.scaler.unscale_(self.optimizer)
                nn.utils.clip_grad_norm_(self.model.parameters(), max_norm=1.0)
                self.scaler.step(self.optimizer)
                self.scaler.update()
            else:
                outputs = self.model(images, return_segmentation=masks is not None)
                cls_logits = outputs["classification"]
                seg_logits = outputs.get("segmentation", None)

                seg_logits_masked = None
                seg_targets_masked = None
                if seg_logits is not None and has_mask is not None:
                    mask_indices = [i for i, hm in enumerate(has_mask) if hm]
                    if mask_indices:
                        idx = torch.tensor(mask_indices, device=self.device)
                        seg_logits_masked = seg_logits[idx]
                        seg_targets_masked = masks[idx]

                losses = self.criterion(
                    cls_logits, labels,
                    seg_logits_masked, seg_targets_masked,
                )
                losses["total_loss"].backward()
                nn.utils.clip_grad_norm_(self.model.parameters(), max_norm=1.0)
                self.optimizer.step()

            bs = images.size(0)
            total_loss += losses["total_loss"].item() * bs
            total_cls_loss += losses["classification_loss"].item() * bs
            if "segmentation_loss" in losses:
                seg_count = len(mask_indices) if mask_indices else 0
                total_seg_loss += losses["segmentation_loss"].item() * seg_count
                num_seg_samples += seg_count
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
            "train_seg_loss": total_seg_loss / max(num_seg_samples, 1),
            "epoch_time": time.time() - epoch_start,
        }

    @torch.no_grad()
    def validate(self, val_loader: DataLoader) -> dict:
        """Run validation.

        Args:
            val_loader: Validation data loader.

        Returns:
            Dict of validation metrics.
        """
        self.model.eval()
        total_loss = 0.0
        all_cls_preds = []
        all_cls_labels = []
        all_dice_scores = []
        total_samples = 0

        for batch in val_loader:
            images = batch["image"].to(self.device, non_blocking=True)
            labels = torch.tensor(
                np.stack([b for b in batch["labels"]]), dtype=torch.float32
            ).to(self.device) if isinstance(batch["labels"], list) else batch["labels"].float().to(self.device)
            masks = batch["mask"].to(self.device, non_blocking=True) if "mask" in batch else None
            has_mask = batch.get("has_mask", None)

            if self.scaler is not None:
                with autocast():
                    outputs = self.model(images, return_segmentation=True)
            else:
                outputs = self.model(images, return_segmentation=True)

            cls_logits = outputs["classification"]
            seg_logits = outputs.get("segmentation", None)

            # Classification metrics
            cls_probs = torch.sigmoid(cls_logits)
            all_cls_preds.append(cls_probs.cpu())
            all_cls_labels.append(labels.cpu())

            # Segmentation metrics
            if seg_logits is not None and has_mask is not None:
                mask_indices = [i for i, hm in enumerate(has_mask) if hm]
                if mask_indices:
                    idx = torch.tensor(mask_indices, device=self.device)
                    seg_pred = torch.sigmoid(seg_logits[idx])
                    seg_target = masks[idx]
                    dice = dice_coefficient(seg_pred, seg_target)
                    all_dice_scores.append(dice.item())

            total_samples += images.size(0)

        all_cls_preds = torch.cat(all_cls_preds, dim=0)
        all_cls_labels = torch.cat(all_cls_labels, dim=0)

        exact_match, sample_acc, sample_prec, sample_rec = multilabel_accuracy(
            all_cls_preds, all_cls_labels
        )

        # Compute F1
        if sample_prec + sample_rec > 0:
            sample_f1 = 2 * sample_prec * sample_rec / (sample_prec + sample_rec)
        else:
            sample_f1 = 0.0

        avg_dice = float(np.mean(all_dice_scores)) if all_dice_scores else 0.0

        return {
            "val_exact_match": exact_match,
            "val_sample_accuracy": sample_acc,
            "val_precision": sample_prec,
            "val_recall": sample_rec,
            "val_f1": sample_f1,
            "val_dice": avg_dice,
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
            "best_val_dice": self.state.best_val_dice,
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
        self.state.best_val_dice = checkpoint["best_val_dice"]
        logger.info(f"Loaded checkpoint from epoch {self.state.epoch}")

    def train(self, train_loader: DataLoader, val_loader: DataLoader) -> list[dict]:
        """Run the full training loop.

        Args:
            train_loader: Training data loader.
            val_loader: Validation data loader.

        Returns:
            Training history.
        """
        logger.info(f"Starting disease detection training for {self.config.num_epochs} epochs")

        for epoch in range(self.state.epoch, self.config.num_epochs):
            self.state.epoch = epoch
            lr = self.optimizer.param_groups[0]["lr"]
            logger.info(f"Epoch {epoch + 1}/{self.config.num_epochs} (lr={lr:.2e})")

            train_metrics = self.train_epoch(train_loader)
            val_metrics = self.validate(val_loader)
            self.scheduler.step()

            # Check improvement
            is_best = False
            combined_score = val_metrics["val_f1"] + val_metrics["val_dice"]
            best_combined = self.state.best_val_f1 + self.state.best_val_dice

            if combined_score > best_combined + self.config.min_delta:
                self.state.best_val_f1 = val_metrics["val_f1"]
                self.state.best_val_dice = val_metrics["val_dice"]
                self.state.epochs_without_improvement = 0
                is_best = True
            else:
                self.state.epochs_without_improvement += 1

            epoch_metrics = {**train_metrics, **val_metrics}
            self.state.history.append(epoch_metrics)

            logger.info(
                f"  Train Loss: {train_metrics['train_total_loss']:.4f} "
                f"(cls: {train_metrics['train_cls_loss']:.4f}, "
                f"seg: {train_metrics['train_seg_loss']:.4f})"
            )
            logger.info(
                f"  Val F1: {val_metrics['val_f1']:.4f}, "
                f"Dice: {val_metrics['val_dice']:.4f}, "
                f"Prec: {val_metrics['val_precision']:.4f}, "
                f"Rec: {val_metrics['val_recall']:.4f}"
            )

            self.save_checkpoint(val_metrics, is_best=is_best)

            if self.state.epochs_without_improvement >= self.config.patience:
                logger.info(f"Early stopping after {self.config.patience} epochs")
                break

        logger.info(
            f"Training complete. Best F1: {self.state.best_val_f1:.4f}, "
            f"Best Dice: {self.state.best_val_dice:.4f}"
        )

        history_path = Path(self.config.checkpoint_dir) / "training_history.json"
        with open(history_path, "w") as f:
            json.dump(self.state.history, f, indent=2)

        return self.state.history
