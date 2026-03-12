"""
Production inference pipeline for pest detection.

Returns detected pest species, confidence levels, risk assessment,
and treatment recommendations.
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

from .model import PestDetectionModel, PEST_CLASSES, NUM_PEST_CLASSES
from .transforms import get_val_transforms

logger = logging.getLogger(__name__)

# Treatment recommendations per pest type
TREATMENT_RECOMMENDATIONS = {
    "Aphid": "Apply neem oil spray or introduce ladybugs as biological control. For severe infestations, use imidacloprid.",
    "Armyworm": "Apply Bt (Bacillus thuringiensis) for larvae. Use pheromone traps for monitoring adult moths.",
    "Beetle_Colorado_Potato": "Hand-pick adults, apply spinosad or neem. Rotate crops to break lifecycle.",
    "Beetle_Flea": "Use row covers for seedlings. Apply diatomaceous earth or pyrethrin spray.",
    "Beetle_Japanese": "Apply milky spore to soil for grubs. Use neem oil or carbaryl for adults.",
    "Bollworm": "Apply Bt sprays targeting larvae. Use pheromone traps for monitoring.",
    "Borer_Corn": "Apply Bt at egg hatch. Use Trichogramma wasps as biological control.",
    "Borer_Stem": "Remove and destroy infested stems. Apply systemic insecticide at planting.",
    "Caterpillar": "Apply Bt (Bacillus thuringiensis). Hand-pick if infestation is small.",
    "Cutworm": "Use cardboard collars around seedling stems. Apply Bt or spinosad to soil surface.",
    "Grasshopper": "Apply Nosema locustae bait for biological control. Use carbaryl for severe outbreaks.",
    "Leafhopper": "Apply kaolin clay spray as deterrent. Use insecticidal soap or pyrethrin.",
    "Leafminer": "Remove affected leaves. Apply spinosad or neem oil. Introduce parasitic wasps.",
    "Mealybug": "Apply isopropyl alcohol directly. Use insecticidal soap. Introduce Cryptolaemus beetles.",
    "Mite_Spider": "Increase humidity, apply miticide. Introduce predatory mites (Phytoseiulus persimilis).",
    "Moth_Codling": "Use pheromone traps. Apply Cydia pomonella granulosis virus. Thin fruit to reduce damage.",
    "Nematode_Root_Knot": "Solarize soil. Plant resistant varieties. Apply beneficial nematodes.",
    "Scale_Insect": "Apply horticultural oil spray. Use systemic insecticide. Introduce parasitic wasps.",
    "Slug": "Use iron phosphate bait. Set beer traps. Apply diatomaceous earth barriers.",
    "Thrips": "Apply spinosad or insecticidal soap. Use blue sticky traps for monitoring.",
    "Weevil": "Apply beneficial nematodes to soil. Use pyrethrin spray. Rotate crops.",
    "Whitefly": "Use yellow sticky traps. Apply insecticidal soap. Introduce Encarsia formosa wasps.",
}


def _risk_from_confidence(confidence: float, pest_count: int) -> str:
    """Determine risk level from detection confidence and pest count."""
    if pest_count == 0:
        return "NONE"
    score = confidence * (1 + 0.2 * min(pest_count - 1, 4))
    if score < 0.3:
        return "LOW"
    elif score < 0.55:
        return "MODERATE"
    elif score < 0.8:
        return "HIGH"
    else:
        return "CRITICAL"


@dataclass
class DetectedPest:
    """Result for a single detected pest."""

    pest_name: str
    confidence: float
    risk_level: str
    treatment: str


@dataclass
class PestDetectionResult:
    """Complete pest detection result for one image."""

    pests: list[DetectedPest]
    has_pest: bool
    overall_risk: str
    overall_confidence: float
    bbox: Optional[list[float]]  # [x1, y1, x2, y2] normalized

    def to_dict(self) -> dict:
        return {
            "has_pest": self.has_pest,
            "overall_risk": self.overall_risk,
            "overall_confidence": self.overall_confidence,
            "bbox": self.bbox,
            "pests": [
                {
                    "name": p.pest_name,
                    "confidence": p.confidence,
                    "risk_level": p.risk_level,
                    "treatment": p.treatment,
                }
                for p in self.pests
            ],
        }


class PestDetector:
    """Production pest detection inference engine.

    Args:
        model_path: Path to saved model checkpoint.
        device: Device for inference.
        class_names: Pest class names.
        image_size: Input image size.
        confidence_threshold: Minimum confidence for pest detection.
        with_bbox: Whether model includes bbox head.
    """

    def __init__(
        self,
        model_path: str | Path,
        device: Optional[torch.device] = None,
        class_names: Optional[list[str]] = None,
        image_size: int = 320,
        confidence_threshold: float = 0.3,
        with_bbox: bool = False,
    ):
        self.device = device or torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.class_names = class_names or PEST_CLASSES
        self.image_size = image_size
        self.confidence_threshold = confidence_threshold
        self.with_bbox = with_bbox

        self.model = self._load_model(model_path)
        self.model.eval()

        self.transform = get_val_transforms(image_size)

        logger.info(
            f"PestDetector initialized on {self.device}, "
            f"threshold={confidence_threshold}"
        )

    def _load_model(self, model_path: str | Path) -> PestDetectionModel:
        """Load model from checkpoint."""
        model = PestDetectionModel(
            num_classes=len(self.class_names),
            pretrained=False,
            with_bbox=self.with_bbox,
        ).to(self.device)

        checkpoint = torch.load(
            str(model_path), map_location=self.device, weights_only=False
        )
        state_dict = checkpoint.get("model_state_dict", checkpoint)
        model.load_state_dict(state_dict)
        logger.info(f"Model loaded from {model_path}")
        return model

    def _preprocess(self, image: Union[str, Path, Image.Image, np.ndarray]) -> torch.Tensor:
        """Preprocess input image."""
        if isinstance(image, (str, Path)):
            image = Image.open(image).convert("RGB")
        if isinstance(image, Image.Image):
            image_np = np.array(image)
        else:
            image_np = image.copy()

        if image_np.ndim == 2:
            image_np = np.stack([image_np] * 3, axis=-1)

        transformed = self.transform(image=image_np)
        tensor = transformed["image"].unsqueeze(0).to(self.device)
        return tensor

    @torch.no_grad()
    def detect(
        self,
        image: Union[str, Path, Image.Image, np.ndarray],
    ) -> PestDetectionResult:
        """Detect pests in a single image.

        Args:
            image: Input image.

        Returns:
            PestDetectionResult with all detected pests.
        """
        tensor = self._preprocess(image)
        outputs = self.model(tensor)

        cls_probs = torch.sigmoid(outputs["classification"]).squeeze(0).cpu().numpy()

        bbox = None
        if "bbox" in outputs:
            bbox = outputs["bbox"].squeeze(0).cpu().numpy().tolist()

        # Build pest results
        pests = []
        no_pest_idx = self.class_names.index("No_Pest") if "No_Pest" in self.class_names else -1

        for idx, prob in enumerate(cls_probs):
            if idx == no_pest_idx:
                continue
            if prob >= self.confidence_threshold:
                pest_name = self.class_names[idx]
                risk = _risk_from_confidence(float(prob), 1)
                treatment = TREATMENT_RECOMMENDATIONS.get(pest_name, "Consult local agricultural extension.")

                pests.append(
                    DetectedPest(
                        pest_name=pest_name,
                        confidence=float(prob),
                        risk_level=risk,
                        treatment=treatment,
                    )
                )

        pests.sort(key=lambda p: p.confidence, reverse=True)

        has_pest = len(pests) > 0
        if no_pest_idx >= 0:
            no_pest_prob = float(cls_probs[no_pest_idx])
            if no_pest_prob > 0.7 and not has_pest:
                has_pest = False

        # Overall risk
        if pests:
            risk_order = {"NONE": 0, "LOW": 1, "MODERATE": 2, "HIGH": 3, "CRITICAL": 4}
            overall_risk_val = max(risk_order.get(p.risk_level, 0) for p in pests)
            risk_map = {v: k for k, v in risk_order.items()}
            overall_risk = risk_map.get(overall_risk_val, "LOW")
            # Adjust risk based on number of pest types
            combined_risk = _risk_from_confidence(
                max(p.confidence for p in pests), len(pests)
            )
            if risk_order.get(combined_risk, 0) > risk_order.get(overall_risk, 0):
                overall_risk = combined_risk
            overall_confidence = max(p.confidence for p in pests)
        else:
            overall_risk = "NONE"
            overall_confidence = float(cls_probs[no_pest_idx]) if no_pest_idx >= 0 else 0.0

        return PestDetectionResult(
            pests=pests,
            has_pest=has_pest,
            overall_risk=overall_risk,
            overall_confidence=overall_confidence,
            bbox=bbox if has_pest else None,
        )

    @torch.no_grad()
    def detect_batch(
        self,
        images: list[Union[str, Path, Image.Image, np.ndarray]],
        batch_size: int = 16,
    ) -> list[PestDetectionResult]:
        """Detect pests in a batch of images.

        Args:
            images: List of input images.
            batch_size: Processing batch size.

        Returns:
            List of PestDetectionResult objects.
        """
        results = []

        for batch_start in range(0, len(images), batch_size):
            batch_images = images[batch_start : batch_start + batch_size]
            tensors = []

            for img in batch_images:
                tensor = self._preprocess(img).squeeze(0)
                tensors.append(tensor)

            batch_tensor = torch.stack(tensors).to(self.device)
            outputs = self.model(batch_tensor)

            cls_probs = torch.sigmoid(outputs["classification"]).cpu().numpy()
            bboxes = outputs["bbox"].cpu().numpy() if "bbox" in outputs else None

            no_pest_idx = self.class_names.index("No_Pest") if "No_Pest" in self.class_names else -1

            for i in range(len(batch_images)):
                pests = []
                for idx, prob in enumerate(cls_probs[i]):
                    if idx == no_pest_idx:
                        continue
                    if prob >= self.confidence_threshold:
                        pest_name = self.class_names[idx]
                        risk = _risk_from_confidence(float(prob), 1)
                        treatment = TREATMENT_RECOMMENDATIONS.get(pest_name, "Consult local agricultural extension.")
                        pests.append(
                            DetectedPest(
                                pest_name=pest_name,
                                confidence=float(prob),
                                risk_level=risk,
                                treatment=treatment,
                            )
                        )

                pests.sort(key=lambda p: p.confidence, reverse=True)
                has_pest = len(pests) > 0
                bbox = bboxes[i].tolist() if bboxes is not None and has_pest else None

                if pests:
                    overall_risk = _risk_from_confidence(
                        max(p.confidence for p in pests), len(pests)
                    )
                    overall_confidence = max(p.confidence for p in pests)
                else:
                    overall_risk = "NONE"
                    overall_confidence = float(cls_probs[i][no_pest_idx]) if no_pest_idx >= 0 else 0.0

                results.append(
                    PestDetectionResult(
                        pests=pests,
                        has_pest=has_pest,
                        overall_risk=overall_risk,
                        overall_confidence=overall_confidence,
                        bbox=bbox,
                    )
                )

        return results
