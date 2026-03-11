"""
Production inference pipeline for plant classification.

Provides the PlantClassifier class for loading trained models and
running inference on single images or batches.
"""

from __future__ import annotations

import logging
from dataclasses import dataclass
from pathlib import Path
from typing import Optional, Union

import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
from PIL import Image

from .model import PlantClassificationModel, PLANTVILLAGE_CLASSES, NUM_CLASSES
from .transforms import get_val_transforms, get_tta_transforms

logger = logging.getLogger(__name__)


@dataclass
class ClassificationResult:
    """Result of a single plant classification inference."""

    species_name: str
    confidence: float
    class_index: int
    top_k: list[tuple[str, float]]  # List of (class_name, probability)

    def to_dict(self) -> dict:
        return {
            "species_name": self.species_name,
            "confidence": self.confidence,
            "class_index": self.class_index,
            "top_k": [
                {"name": name, "probability": prob} for name, prob in self.top_k
            ],
        }


class PlantClassifier:
    """Production plant classification inference engine.

    Args:
        model_path: Path to the saved model checkpoint.
        device: Device to run inference on.
        class_names: Class name list (defaults to PlantVillage 38 classes).
        image_size: Input image size.
        use_tta: Whether to use test-time augmentation.
    """

    def __init__(
        self,
        model_path: str | Path,
        device: Optional[torch.device] = None,
        class_names: Optional[list[str]] = None,
        image_size: int = 224,
        use_tta: bool = False,
    ):
        self.device = device or torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.class_names = class_names or PLANTVILLAGE_CLASSES
        self.image_size = image_size
        self.use_tta = use_tta

        # Load model
        self.model = self._load_model(model_path)
        self.model.eval()

        # Transforms
        self.val_transform = get_val_transforms(image_size)
        self.tta_transforms = get_tta_transforms(image_size) if use_tta else None

        logger.info(
            f"PlantClassifier initialized on {self.device} "
            f"(TTA={'enabled' if use_tta else 'disabled'})"
        )

    def _load_model(self, model_path: str | Path) -> PlantClassificationModel:
        """Load model from checkpoint."""
        model_path = Path(model_path)

        model = PlantClassificationModel(
            num_classes=len(self.class_names),
            pretrained=False,
        ).to(self.device)

        checkpoint = torch.load(model_path, map_location=self.device, weights_only=False)

        if "model_state_dict" in checkpoint:
            model.load_state_dict(checkpoint["model_state_dict"])
        else:
            model.load_state_dict(checkpoint)

        logger.info(f"Model loaded from {model_path}")
        return model

    def _preprocess_image(self, image: Union[str, Path, Image.Image, np.ndarray]) -> np.ndarray:
        """Convert input to a numpy array (H, W, 3) in RGB.

        Args:
            image: File path, PIL Image, or numpy array.

        Returns:
            Numpy array (H, W, 3) uint8 in RGB.
        """
        if isinstance(image, (str, Path)):
            image = Image.open(image).convert("RGB")

        if isinstance(image, Image.Image):
            return np.array(image)

        if isinstance(image, np.ndarray):
            if image.ndim == 2:
                image = np.stack([image] * 3, axis=-1)
            if image.shape[2] == 4:
                image = image[:, :, :3]
            return image

        raise ValueError(f"Unsupported image type: {type(image)}")

    def _apply_transform(self, image_np: np.ndarray, transform) -> torch.Tensor:
        """Apply an albumentations transform and return a tensor."""
        result = transform(image=image_np)
        return result["image"]

    @torch.no_grad()
    def classify(
        self,
        image: Union[str, Path, Image.Image, np.ndarray],
        top_k: int = 5,
    ) -> ClassificationResult:
        """Classify a single plant image.

        Args:
            image: Input image (path, PIL Image, or numpy array).
            top_k: Number of top predictions to return.

        Returns:
            ClassificationResult with species name, confidence, and top-k results.
        """
        image_np = self._preprocess_image(image)

        if self.use_tta and self.tta_transforms is not None:
            # Test-time augmentation: average predictions across augmented views
            all_probs = []
            for transform in self.tta_transforms:
                tensor = self._apply_transform(image_np, transform)
                tensor = tensor.unsqueeze(0).to(self.device)
                logits = self.model(tensor)
                probs = F.softmax(logits, dim=1)
                all_probs.append(probs)

            avg_probs = torch.stack(all_probs).mean(dim=0).squeeze(0)
        else:
            tensor = self._apply_transform(image_np, self.val_transform)
            tensor = tensor.unsqueeze(0).to(self.device)
            logits = self.model(tensor)
            avg_probs = F.softmax(logits, dim=1).squeeze(0)

        # Top-k results
        top_k_clamped = min(top_k, len(self.class_names))
        top_probs, top_indices = avg_probs.topk(top_k_clamped)

        top_k_results = [
            (self.class_names[idx.item()], prob.item())
            for prob, idx in zip(top_probs, top_indices)
        ]

        best_idx = top_indices[0].item()
        best_prob = top_probs[0].item()

        return ClassificationResult(
            species_name=self.class_names[best_idx],
            confidence=best_prob,
            class_index=best_idx,
            top_k=top_k_results,
        )

    @torch.no_grad()
    def classify_batch(
        self,
        images: list[Union[str, Path, Image.Image, np.ndarray]],
        top_k: int = 5,
        batch_size: int = 32,
    ) -> list[ClassificationResult]:
        """Classify a batch of plant images.

        Args:
            images: List of input images.
            top_k: Number of top predictions per image.
            batch_size: Processing batch size.

        Returns:
            List of ClassificationResult objects.
        """
        results = []

        for batch_start in range(0, len(images), batch_size):
            batch_images = images[batch_start : batch_start + batch_size]

            tensors = []
            for img in batch_images:
                image_np = self._preprocess_image(img)
                tensor = self._apply_transform(image_np, self.val_transform)
                tensors.append(tensor)

            batch_tensor = torch.stack(tensors).to(self.device)
            logits = self.model(batch_tensor)
            probs = F.softmax(logits, dim=1)

            for i in range(probs.size(0)):
                sample_probs = probs[i]
                top_k_clamped = min(top_k, len(self.class_names))
                top_probs, top_indices = sample_probs.topk(top_k_clamped)

                top_k_results = [
                    (self.class_names[idx.item()], prob.item())
                    for prob, idx in zip(top_probs, top_indices)
                ]

                best_idx = top_indices[0].item()
                best_prob = top_probs[0].item()

                results.append(
                    ClassificationResult(
                        species_name=self.class_names[best_idx],
                        confidence=best_prob,
                        class_index=best_idx,
                        top_k=top_k_results,
                    )
                )

        return results

    @torch.no_grad()
    def extract_features(
        self,
        image: Union[str, Path, Image.Image, np.ndarray],
    ) -> np.ndarray:
        """Extract feature vector from an image (useful for similarity search).

        Args:
            image: Input image.

        Returns:
            Feature vector of shape (2048,).
        """
        image_np = self._preprocess_image(image)
        tensor = self._apply_transform(image_np, self.val_transform)
        tensor = tensor.unsqueeze(0).to(self.device)

        features = self.model.extract_features(tensor)
        return features.squeeze(0).cpu().numpy()
