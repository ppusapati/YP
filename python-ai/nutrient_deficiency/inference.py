"""
Production inference pipeline for nutrient deficiency detection.

Returns deficient nutrients, confidence scores, severity levels,
and recommended supplementation.
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

from .model import (
    NutrientDeficiencyModel,
    NUTRIENT_DEFICIENCIES,
    SEVERITY_LEVELS,
    SUPPLEMENTATION_MAP,
    NUM_NUTRIENTS,
)
from .transforms import get_val_transforms

logger = logging.getLogger(__name__)


@dataclass
class NutrientDeficiencyResult:
    """Result for a single detected nutrient deficiency."""

    nutrient: str
    confidence: float
    severity: str  # None, Low, Moderate, High
    severity_score: int  # 0-3
    recommendation: str


@dataclass
class NutrientAnalysisResult:
    """Complete nutrient analysis result for one image."""

    deficiencies: list[NutrientDeficiencyResult]
    is_healthy: bool
    summary: str

    def to_dict(self) -> dict:
        return {
            "is_healthy": self.is_healthy,
            "summary": self.summary,
            "deficiencies": [
                {
                    "nutrient": d.nutrient,
                    "confidence": d.confidence,
                    "severity": d.severity,
                    "severity_score": d.severity_score,
                    "recommendation": d.recommendation,
                }
                for d in self.deficiencies
            ],
        }


class NutrientAnalyzer:
    """Production nutrient deficiency analyzer.

    Args:
        model_path: Path to saved model checkpoint.
        device: Device for inference.
        nutrient_names: Nutrient deficiency names.
        image_size: Input image size.
        confidence_threshold: Detection threshold.
    """

    def __init__(
        self,
        model_path: str | Path,
        device: Optional[torch.device] = None,
        nutrient_names: Optional[list[str]] = None,
        image_size: int = 224,
        confidence_threshold: float = 0.35,
    ):
        self.device = device or torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.nutrient_names = nutrient_names or NUTRIENT_DEFICIENCIES
        self.image_size = image_size
        self.confidence_threshold = confidence_threshold

        self.model = self._load_model(model_path)
        self.model.eval()

        self.transform = get_val_transforms(image_size)

        logger.info(
            f"NutrientAnalyzer initialized on {self.device}, "
            f"threshold={confidence_threshold}"
        )

    def _load_model(self, model_path: str | Path) -> NutrientDeficiencyModel:
        """Load model from checkpoint."""
        model = NutrientDeficiencyModel(
            num_nutrients=len(self.nutrient_names),
            pretrained=False,
        ).to(self.device)

        checkpoint = torch.load(
            str(model_path), map_location=self.device, weights_only=False
        )
        state_dict = checkpoint.get("model_state_dict", checkpoint)
        model.load_state_dict(state_dict)
        logger.info(f"Model loaded from {model_path}")
        return model

    def _preprocess(self, image: Union[str, Path, Image.Image, np.ndarray]) -> torch.Tensor:
        """Preprocess input image to tensor."""
        if isinstance(image, (str, Path)):
            image = Image.open(image).convert("RGB")
        if isinstance(image, Image.Image):
            image_np = np.array(image)
        else:
            image_np = image.copy()

        if image_np.ndim == 2:
            image_np = np.stack([image_np] * 3, axis=-1)

        transformed = self.transform(image=image_np)
        return transformed["image"].unsqueeze(0).to(self.device)

    @torch.no_grad()
    def analyze(
        self,
        image: Union[str, Path, Image.Image, np.ndarray],
    ) -> NutrientAnalysisResult:
        """Analyze a single image for nutrient deficiencies.

        Args:
            image: Input image.

        Returns:
            NutrientAnalysisResult with detected deficiencies and recommendations.
        """
        tensor = self._preprocess(image)
        outputs = self.model(tensor)

        # Detection probabilities
        det_probs = torch.sigmoid(outputs["detection"]).squeeze(0).cpu().numpy()

        # Severity predictions
        sev_logits = outputs["severity"].squeeze(0)  # (num_nutrients, num_severity)
        sev_probs = F.softmax(sev_logits, dim=1).cpu().numpy()
        sev_predictions = sev_logits.argmax(dim=1).cpu().numpy()

        deficiencies = []

        for idx, prob in enumerate(det_probs):
            if prob >= self.confidence_threshold:
                nutrient_name = self.nutrient_names[idx]
                severity_idx = int(sev_predictions[idx])
                severity_name = SEVERITY_LEVELS[severity_idx] if severity_idx < len(SEVERITY_LEVELS) else "Unknown"

                recommendation = SUPPLEMENTATION_MAP.get(
                    nutrient_name,
                    f"Consult an agronomist for {nutrient_name} deficiency treatment."
                )

                deficiencies.append(
                    NutrientDeficiencyResult(
                        nutrient=nutrient_name,
                        confidence=float(prob),
                        severity=severity_name,
                        severity_score=severity_idx,
                        recommendation=recommendation,
                    )
                )

        # Sort by confidence
        deficiencies.sort(key=lambda d: d.confidence, reverse=True)

        is_healthy = len(deficiencies) == 0

        # Build summary
        if is_healthy:
            summary = "No nutrient deficiencies detected. Plant appears healthy."
        else:
            nutrient_list = ", ".join(d.nutrient for d in deficiencies)
            max_severity = max(d.severity for d in deficiencies) if deficiencies else "None"
            summary = (
                f"Detected {len(deficiencies)} nutrient deficiency(ies): {nutrient_list}. "
                f"Highest severity: {max_severity}."
            )

        return NutrientAnalysisResult(
            deficiencies=deficiencies,
            is_healthy=is_healthy,
            summary=summary,
        )

    @torch.no_grad()
    def analyze_batch(
        self,
        images: list[Union[str, Path, Image.Image, np.ndarray]],
        batch_size: int = 32,
    ) -> list[NutrientAnalysisResult]:
        """Analyze a batch of images for nutrient deficiencies.

        Args:
            images: List of input images.
            batch_size: Processing batch size.

        Returns:
            List of NutrientAnalysisResult objects.
        """
        results = []

        for batch_start in range(0, len(images), batch_size):
            batch_images = images[batch_start : batch_start + batch_size]

            tensors = []
            for img in batch_images:
                tensor = self._preprocess(img)
                tensors.append(tensor.squeeze(0))

            batch_tensor = torch.stack(tensors).to(self.device)
            outputs = self.model(batch_tensor)

            det_probs = torch.sigmoid(outputs["detection"]).cpu().numpy()
            sev_preds = outputs["severity"].argmax(dim=2).cpu().numpy()

            for i in range(len(batch_images)):
                deficiencies = []

                for idx, prob in enumerate(det_probs[i]):
                    if prob >= self.confidence_threshold:
                        nutrient_name = self.nutrient_names[idx]
                        severity_idx = int(sev_preds[i, idx])
                        severity_name = SEVERITY_LEVELS[severity_idx] if severity_idx < len(SEVERITY_LEVELS) else "Unknown"

                        recommendation = SUPPLEMENTATION_MAP.get(
                            nutrient_name,
                            f"Consult an agronomist for {nutrient_name} deficiency treatment."
                        )

                        deficiencies.append(
                            NutrientDeficiencyResult(
                                nutrient=nutrient_name,
                                confidence=float(prob),
                                severity=severity_name,
                                severity_score=severity_idx,
                                recommendation=recommendation,
                            )
                        )

                deficiencies.sort(key=lambda d: d.confidence, reverse=True)
                is_healthy = len(deficiencies) == 0

                if is_healthy:
                    summary = "No nutrient deficiencies detected."
                else:
                    nutrient_list = ", ".join(d.nutrient for d in deficiencies)
                    summary = f"Detected {len(deficiencies)} deficiency(ies): {nutrient_list}."

                results.append(
                    NutrientAnalysisResult(
                        deficiencies=deficiencies,
                        is_healthy=is_healthy,
                        summary=summary,
                    )
                )

        return results
