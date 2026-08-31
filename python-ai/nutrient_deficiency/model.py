"""
Nutrient Deficiency Detection Model using DenseNet-121 backbone.

Detects 8 nutrient deficiencies (N, P, K, Ca, Mg, Fe, Zn, B) with
multi-label output and per-nutrient severity scoring.
"""

from __future__ import annotations

import torch
import torch.nn as nn
import torchvision.models as models
from typing import Optional


NUTRIENT_DEFICIENCIES = [
    "Nitrogen",
    "Phosphorus",
    "Potassium",
    "Calcium",
    "Magnesium",
    "Sulfur",
    "Iron",
    "Zinc",
    "Manganese",
    "Boron",
]

NUM_NUTRIENTS = len(NUTRIENT_DEFICIENCIES)

# Severity levels encoded as ordinal scores 0-3
SEVERITY_LEVELS = ["None", "Low", "Moderate", "High"]
NUM_SEVERITY = len(SEVERITY_LEVELS)

# Supplementation recommendations per nutrient
SUPPLEMENTATION_MAP = {
    "Nitrogen": "Apply urea (46-0-0) at 50-100 kg/ha or ammonium nitrate. Consider foliar spray with 2% urea solution for quick response.",
    "Phosphorus": "Apply superphosphate (0-20-0) at 40-80 kg P2O5/ha. Maintain soil pH 6.0-7.0 for optimal P availability.",
    "Potassium": "Apply potassium chloride (0-0-60) at 50-100 kg K2O/ha or potassium sulfate for chloride-sensitive crops.",
    "Calcium": "Apply gypsum (CaSO4) at 1-2 t/ha or lime if pH adjustment needed. Foliar CaCl2 at 0.5% for acute deficiency.",
    "Magnesium": "Apply Epsom salt (MgSO4) at 20-50 kg/ha. Foliar spray with 2% MgSO4 for quick correction.",
    "Sulfur": "Apply gypsum (CaSO4) at 100-200 kg/ha or elemental sulfur at 20-40 kg/ha. Ammonium sulfate provides both N and S.",
    "Iron": "Apply iron chelate (Fe-EDDHA) at 5-10 kg/ha. Foliar spray with 0.5% FeSO4 + 0.25% citric acid.",
    "Zinc": "Apply zinc sulfate (ZnSO4) at 10-25 kg/ha. Foliar spray with 0.5% ZnSO4 for rapid correction.",
    "Manganese": "Apply manganese sulfate (MnSO4) at 5-15 kg/ha. Foliar spray with 0.5% MnSO4. Maintain soil pH below 6.5 for Mn availability.",
    "Boron": "Apply borax at 1-2 kg/ha (caution: narrow range between deficiency and toxicity). Foliar spray with 0.1% borax.",
}


class SeverityHead(nn.Module):
    """Per-nutrient severity scoring head.

    Outputs ordinal severity scores for each nutrient deficiency.
    Uses ordinal regression approach where each severity level
    is a cumulative threshold.
    """

    def __init__(self, in_features: int, num_nutrients: int, num_severity: int = NUM_SEVERITY):
        super().__init__()
        self.num_nutrients = num_nutrients
        self.num_severity = num_severity

        # Shared feature transform
        self.shared = nn.Sequential(
            nn.Linear(in_features, 256),
            nn.BatchNorm1d(256),
            nn.ReLU(inplace=True),
            nn.Dropout(0.3),
        )

        # Per-nutrient severity heads (ordinal regression thresholds)
        self.severity_heads = nn.ModuleList([
            nn.Linear(256, num_severity) for _ in range(num_nutrients)
        ])

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        """Forward pass.

        Args:
            x: Feature tensor of shape (N, in_features).

        Returns:
            Severity logits of shape (N, num_nutrients, num_severity).
        """
        shared = self.shared(x)

        severity_logits = []
        for head in self.severity_heads:
            severity_logits.append(head(shared))

        return torch.stack(severity_logits, dim=1)


class NutrientDeficiencyModel(nn.Module):
    """Nutrient deficiency detection model using DenseNet-121.

    Architecture:
        - DenseNet-121 backbone (pretrained on ImageNet)
        - Multi-label classification head (detects which nutrients are deficient)
        - Severity scoring head (ordinal regression per nutrient)

    Args:
        num_nutrients: Number of nutrient deficiency types.
        pretrained: Whether to use ImageNet pretrained weights.
        dropout: Dropout rate.
    """

    def __init__(
        self,
        num_nutrients: int = NUM_NUTRIENTS,
        pretrained: bool = True,
        dropout: float = 0.3,
    ):
        super().__init__()
        self.num_nutrients = num_nutrients

        # Load DenseNet-121 backbone
        weights = models.DenseNet121_Weights.IMAGENET1K_V1 if pretrained else None
        densenet = models.densenet121(weights=weights)

        # DenseNet feature extractor
        self.features = densenet.features
        self.feature_dim = 1024  # DenseNet-121 output channels

        # Global pooling
        self.avgpool = nn.AdaptiveAvgPool2d(1)

        # Multi-label detection head
        self.detection_head = nn.Sequential(
            nn.Linear(self.feature_dim, 512),
            nn.BatchNorm1d(512),
            nn.ReLU(inplace=True),
            nn.Dropout(dropout),
            nn.Linear(512, 256),
            nn.BatchNorm1d(256),
            nn.ReLU(inplace=True),
            nn.Dropout(dropout * 0.5),
            nn.Linear(256, num_nutrients),
        )

        # Severity scoring head
        self.severity_head = SeverityHead(
            in_features=self.feature_dim,
            num_nutrients=num_nutrients,
        )

    def extract_features(self, x: torch.Tensor) -> torch.Tensor:
        """Extract feature vector.

        Args:
            x: Input images of shape (N, 3, H, W).

        Returns:
            Features of shape (N, 1024).
        """
        x = self.features(x)
        x = nn.functional.relu(x, inplace=True)
        x = self.avgpool(x)
        x = torch.flatten(x, 1)
        return x

    def forward(self, x: torch.Tensor) -> dict[str, torch.Tensor]:
        """Forward pass.

        Args:
            x: Input images of shape (N, 3, H, W).

        Returns:
            Dict with:
                'detection': Multi-label logits of shape (N, num_nutrients)
                'severity': Severity logits of shape (N, num_nutrients, num_severity)
        """
        features = self.extract_features(x)

        detection = self.detection_head(features)
        severity = self.severity_head(features)

        return {
            "detection": detection,
            "severity": severity,
        }


class NutrientDeficiencyLoss(nn.Module):
    """Combined loss for nutrient deficiency detection.

    Loss = alpha * BCE(detection) + beta * CE(severity)

    Args:
        alpha: Weight for detection loss.
        beta: Weight for severity loss.
        pos_weight: Optional positive class weights for BCE.
    """

    def __init__(
        self,
        alpha: float = 1.0,
        beta: float = 0.5,
        pos_weight: Optional[torch.Tensor] = None,
    ):
        super().__init__()
        self.alpha = alpha
        self.beta = beta
        self.detection_loss = nn.BCEWithLogitsLoss(pos_weight=pos_weight)
        self.severity_loss = nn.CrossEntropyLoss(ignore_index=-1)

    def forward(
        self,
        detection_logits: torch.Tensor,
        detection_targets: torch.Tensor,
        severity_logits: torch.Tensor,
        severity_targets: torch.Tensor,
    ) -> dict[str, torch.Tensor]:
        """Compute combined loss.

        Args:
            detection_logits: (N, num_nutrients)
            detection_targets: (N, num_nutrients) binary
            severity_logits: (N, num_nutrients, num_severity)
            severity_targets: (N, num_nutrients) integer severity levels

        Returns:
            Dict with loss components and total.
        """
        det_loss = self.detection_loss(detection_logits, detection_targets)

        # Flatten severity for cross-entropy
        batch_size, num_nutrients, num_severity = severity_logits.shape
        sev_logits_flat = severity_logits.reshape(-1, num_severity)
        sev_targets_flat = severity_targets.reshape(-1).long()

        sev_loss = self.severity_loss(sev_logits_flat, sev_targets_flat)

        total = self.alpha * det_loss + self.beta * sev_loss

        return {
            "detection_loss": det_loss,
            "severity_loss": sev_loss,
            "total_loss": total,
        }
