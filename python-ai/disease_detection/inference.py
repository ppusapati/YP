"""
Production inference pipeline for disease detection.

Returns disease names, confidence, severity levels, affected area
percentage, and disease heatmap overlays.
"""

from __future__ import annotations

import logging
from dataclasses import dataclass
from pathlib import Path
from typing import Optional, Union

import cv2
import numpy as np
import torch
import torch.nn.functional as F
from PIL import Image

from .model import DiseaseDetectionModel, DISEASE_CLASSES, NUM_DISEASE_CLASSES
from .transforms import get_val_transforms
from ..utils.visualization import draw_heatmap_overlay, draw_disease_severity_bar

logger = logging.getLogger(__name__)


@dataclass
class DiseaseResult:
    """Result for a single detected disease."""

    disease_name: str
    confidence: float
    severity: str  # MILD, MODERATE, SEVERE, CRITICAL
    affected_area_percentage: float


@dataclass
class DiseaseDetectionResult:
    """Complete disease detection result for one image."""

    diseases: list[DiseaseResult]
    is_healthy: bool
    heatmap: Optional[np.ndarray]  # (H, W) float32 in [0, 1]
    overall_severity: str
    overall_confidence: float

    def to_dict(self) -> dict:
        return {
            "is_healthy": self.is_healthy,
            "overall_severity": self.overall_severity,
            "overall_confidence": self.overall_confidence,
            "diseases": [
                {
                    "name": d.disease_name,
                    "confidence": d.confidence,
                    "severity": d.severity,
                    "affected_area_percentage": d.affected_area_percentage,
                }
                for d in self.diseases
            ],
        }


def _severity_from_area(area_pct: float) -> str:
    """Determine severity from affected area percentage."""
    if area_pct < 5.0:
        return "MILD"
    elif area_pct < 20.0:
        return "MODERATE"
    elif area_pct < 50.0:
        return "SEVERE"
    else:
        return "CRITICAL"


def _severity_from_confidence(confidence: float) -> str:
    """Determine severity from classification confidence."""
    if confidence < 0.4:
        return "MILD"
    elif confidence < 0.65:
        return "MODERATE"
    elif confidence < 0.85:
        return "SEVERE"
    else:
        return "CRITICAL"


class DiseaseDetector:
    """Production disease detection inference engine.

    Args:
        model_path: Path to saved model checkpoint.
        device: Device for inference.
        class_names: Disease class names.
        image_size: Input image size.
        confidence_threshold: Minimum confidence for disease detection.
    """

    def __init__(
        self,
        model_path: str | Path,
        device: Optional[torch.device] = None,
        class_names: Optional[list[str]] = None,
        image_size: int = 256,
        confidence_threshold: float = 0.3,
    ):
        self.device = device or torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.class_names = class_names or DISEASE_CLASSES
        self.image_size = image_size
        self.confidence_threshold = confidence_threshold

        self.model = self._load_model(model_path)
        self.model.eval()

        self.transform = get_val_transforms(image_size)

        logger.info(
            f"DiseaseDetector initialized on {self.device}, "
            f"threshold={confidence_threshold}"
        )

    def _load_model(self, model_path: str | Path) -> DiseaseDetectionModel:
        """Load model from checkpoint."""
        model = DiseaseDetectionModel(
            num_classes=len(self.class_names),
            pretrained=False,
        ).to(self.device)

        checkpoint = torch.load(
            str(model_path), map_location=self.device, weights_only=False
        )
        state_dict = checkpoint.get("model_state_dict", checkpoint)
        model.load_state_dict(state_dict)
        logger.info(f"Model loaded from {model_path}")
        return model

    def _preprocess(self, image: Union[str, Path, Image.Image, np.ndarray]) -> tuple[torch.Tensor, np.ndarray]:
        """Preprocess input image.

        Returns:
            Tuple of (tensor for model, original image as numpy BGR).
        """
        if isinstance(image, (str, Path)):
            image = Image.open(image).convert("RGB")
        if isinstance(image, Image.Image):
            image_np = np.array(image)
        else:
            image_np = image.copy()

        # Ensure RGB
        if image_np.ndim == 2:
            image_np = np.stack([image_np] * 3, axis=-1)

        transformed = self.transform(image=image_np)
        tensor = transformed["image"].unsqueeze(0).to(self.device)

        # Convert to BGR for visualization
        image_bgr = cv2.cvtColor(image_np, cv2.COLOR_RGB2BGR)

        return tensor, image_bgr

    @torch.no_grad()
    def detect(
        self,
        image: Union[str, Path, Image.Image, np.ndarray],
        return_heatmap: bool = True,
    ) -> DiseaseDetectionResult:
        """Detect diseases in a single image.

        Args:
            image: Input image.
            return_heatmap: Whether to generate disease heatmap.

        Returns:
            DiseaseDetectionResult with all detected diseases.
        """
        tensor, original_bgr = self._preprocess(image)

        outputs = self.model(tensor, return_segmentation=return_heatmap)

        # Classification
        cls_probs = torch.sigmoid(outputs["classification"]).squeeze(0).cpu().numpy()

        # Segmentation heatmap
        heatmap = None
        affected_area_pct = 0.0
        if return_heatmap and "segmentation" in outputs:
            seg_logits = outputs["segmentation"].squeeze(0).squeeze(0)
            heatmap = torch.sigmoid(seg_logits).cpu().numpy()

            # Resize heatmap to original image size
            h, w = original_bgr.shape[:2]
            heatmap = cv2.resize(heatmap, (w, h), interpolation=cv2.INTER_LINEAR)

            # Calculate affected area percentage
            affected_area_pct = float((heatmap > 0.5).sum() / heatmap.size * 100)

        # Build disease results
        diseases = []
        healthy_idx = self.class_names.index("Healthy") if "Healthy" in self.class_names else -1

        for idx, prob in enumerate(cls_probs):
            if idx == healthy_idx:
                continue
            if prob >= self.confidence_threshold:
                # Use segmentation-based severity if available, otherwise confidence-based
                if heatmap is not None and affected_area_pct > 0:
                    severity = _severity_from_area(affected_area_pct)
                else:
                    severity = _severity_from_confidence(float(prob))

                diseases.append(
                    DiseaseResult(
                        disease_name=self.class_names[idx],
                        confidence=float(prob),
                        severity=severity,
                        affected_area_percentage=affected_area_pct,
                    )
                )

        # Sort by confidence
        diseases.sort(key=lambda d: d.confidence, reverse=True)

        # Determine overall health status
        is_healthy = len(diseases) == 0
        if healthy_idx >= 0:
            healthy_prob = float(cls_probs[healthy_idx])
            if healthy_prob > 0.7 and len(diseases) == 0:
                is_healthy = True

        # Overall severity
        if diseases:
            severities = {"MILD": 1, "MODERATE": 2, "SEVERE": 3, "CRITICAL": 4}
            max_severity_val = max(severities.get(d.severity, 0) for d in diseases)
            severity_map = {v: k for k, v in severities.items()}
            overall_severity = severity_map.get(max_severity_val, "MILD")
            overall_confidence = max(d.confidence for d in diseases)
        else:
            overall_severity = "MILD"
            overall_confidence = float(cls_probs[healthy_idx]) if healthy_idx >= 0 else 0.0

        return DiseaseDetectionResult(
            diseases=diseases,
            is_healthy=is_healthy,
            heatmap=heatmap,
            overall_severity=overall_severity,
            overall_confidence=overall_confidence,
        )

    def generate_overlay(
        self,
        image: Union[str, Path, Image.Image, np.ndarray],
        result: Optional[DiseaseDetectionResult] = None,
        alpha: float = 0.5,
    ) -> np.ndarray:
        """Generate a disease heatmap overlay visualization.

        Args:
            image: Input image.
            result: Pre-computed detection result (will compute if None).
            alpha: Heatmap overlay opacity.

        Returns:
            BGR image with heatmap overlay and severity bar.
        """
        if result is None:
            result = self.detect(image, return_heatmap=True)

        # Get original image
        if isinstance(image, (str, Path)):
            image = Image.open(image).convert("RGB")
        if isinstance(image, Image.Image):
            image_np = np.array(image)
        else:
            image_np = image.copy()

        image_bgr = cv2.cvtColor(image_np, cv2.COLOR_RGB2BGR)

        if result.heatmap is not None:
            overlay = draw_heatmap_overlay(image_bgr, result.heatmap, alpha=alpha)
        else:
            overlay = image_bgr.copy()

        # Add severity bar
        if result.diseases:
            top_disease = result.diseases[0]
            overlay = draw_disease_severity_bar(
                overlay,
                severity=result.overall_severity,
                affected_percentage=top_disease.affected_area_percentage,
            )

        return overlay

    @torch.no_grad()
    def detect_batch(
        self,
        images: list[Union[str, Path, Image.Image, np.ndarray]],
        batch_size: int = 16,
    ) -> list[DiseaseDetectionResult]:
        """Detect diseases in a batch of images.

        Args:
            images: List of input images.
            batch_size: Processing batch size.

        Returns:
            List of DiseaseDetectionResult objects.
        """
        results = []

        for batch_start in range(0, len(images), batch_size):
            batch_images = images[batch_start : batch_start + batch_size]
            tensors = []
            originals = []

            for img in batch_images:
                tensor, original_bgr = self._preprocess(img)
                tensors.append(tensor.squeeze(0))
                originals.append(original_bgr)

            batch_tensor = torch.stack(tensors).to(self.device)
            outputs = self.model(batch_tensor, return_segmentation=True)

            cls_probs = torch.sigmoid(outputs["classification"]).cpu().numpy()
            seg_maps = torch.sigmoid(outputs["segmentation"]).cpu().numpy()

            healthy_idx = self.class_names.index("Healthy") if "Healthy" in self.class_names else -1

            for i in range(len(batch_images)):
                heatmap = seg_maps[i, 0]
                h, w = originals[i].shape[:2]
                heatmap = cv2.resize(heatmap, (w, h), interpolation=cv2.INTER_LINEAR)
                affected_area_pct = float((heatmap > 0.5).sum() / heatmap.size * 100)

                diseases = []
                for idx, prob in enumerate(cls_probs[i]):
                    if idx == healthy_idx:
                        continue
                    if prob >= self.confidence_threshold:
                        if affected_area_pct > 0:
                            severity = _severity_from_area(affected_area_pct)
                        else:
                            severity = _severity_from_confidence(float(prob))
                        diseases.append(
                            DiseaseResult(
                                disease_name=self.class_names[idx],
                                confidence=float(prob),
                                severity=severity,
                                affected_area_percentage=affected_area_pct,
                            )
                        )

                diseases.sort(key=lambda d: d.confidence, reverse=True)
                is_healthy = len(diseases) == 0

                if diseases:
                    severities = {"MILD": 1, "MODERATE": 2, "SEVERE": 3, "CRITICAL": 4}
                    max_sev = max(severities.get(d.severity, 0) for d in diseases)
                    sev_map = {v: k for k, v in severities.items()}
                    overall_severity = sev_map.get(max_sev, "MILD")
                    overall_confidence = max(d.confidence for d in diseases)
                else:
                    overall_severity = "MILD"
                    overall_confidence = float(cls_probs[i][healthy_idx]) if healthy_idx >= 0 else 0.0

                results.append(
                    DiseaseDetectionResult(
                        diseases=diseases,
                        is_healthy=is_healthy,
                        heatmap=heatmap,
                        overall_severity=overall_severity,
                        overall_confidence=overall_confidence,
                    )
                )

        return results
