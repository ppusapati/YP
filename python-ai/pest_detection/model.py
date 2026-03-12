"""
Pest Detection Model using MobileNetV3-Large backbone.

Lightweight architecture optimized for edge deployment on field devices.
Supports multi-label pest classification with optional bounding box
regression for pest localization.
"""

from __future__ import annotations

from typing import Optional

import torch
import torch.nn as nn
import torch.nn.functional as F
import torchvision.models as models


PEST_CLASSES = [
    "Aphid",
    "Armyworm",
    "Beetle_Colorado_Potato",
    "Beetle_Flea",
    "Beetle_Japanese",
    "Bollworm",
    "Borer_Corn",
    "Borer_Stem",
    "Caterpillar",
    "Cutworm",
    "Grasshopper",
    "Leafhopper",
    "Leafminer",
    "Mealybug",
    "Mite_Spider",
    "Moth_Codling",
    "Nematode_Root_Knot",
    "Scale_Insect",
    "Slug",
    "Thrips",
    "Weevil",
    "Whitefly",
    "No_Pest",
]

NUM_PEST_CLASSES = len(PEST_CLASSES)


class AttentionPool(nn.Module):
    """Attention-weighted global pooling for better pest feature aggregation."""

    def __init__(self, in_features: int):
        super().__init__()
        self.attention = nn.Sequential(
            nn.Linear(in_features, in_features // 4),
            nn.ReLU(inplace=True),
            nn.Linear(in_features // 4, 1),
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        # x: (N, C, H, W)
        n, c, h, w = x.shape
        # Reshape to (N, H*W, C)
        x_flat = x.view(n, c, h * w).permute(0, 2, 1)
        # Compute attention weights: (N, H*W, 1)
        attn_weights = self.attention(x_flat)
        attn_weights = F.softmax(attn_weights, dim=1)
        # Weighted sum: (N, C)
        pooled = (x_flat * attn_weights).sum(dim=1)
        return pooled


class PestDetectionModel(nn.Module):
    """Pest detection model using MobileNetV3-Large.

    Architecture:
        - MobileNetV3-Large backbone (pretrained, optimized for mobile)
        - Attention-weighted global pooling
        - Multi-label classification head for pest identification
        - Optional bounding box regression head for localization

    Args:
        num_classes: Number of pest classes.
        pretrained: Whether to use ImageNet pretrained weights.
        dropout: Dropout rate for classification head.
        with_bbox: Whether to include bounding box regression head.
    """

    def __init__(
        self,
        num_classes: int = NUM_PEST_CLASSES,
        pretrained: bool = True,
        dropout: float = 0.2,
        with_bbox: bool = False,
    ):
        super().__init__()
        self.num_classes = num_classes
        self.with_bbox = with_bbox

        # MobileNetV3-Large backbone
        weights = models.MobileNet_V3_Large_Weights.IMAGENET1K_V2 if pretrained else None
        mobilenet = models.mobilenet_v3_large(weights=weights)

        self.features = mobilenet.features
        self.feature_dim = 960  # MobileNetV3-Large last conv output channels

        # Attention pooling
        self.pool = AttentionPool(self.feature_dim)

        # Classification head
        self.classifier = nn.Sequential(
            nn.Linear(self.feature_dim, 512),
            nn.BatchNorm1d(512),
            nn.Hardswish(inplace=True),
            nn.Dropout(p=dropout),
            nn.Linear(512, 256),
            nn.BatchNorm1d(256),
            nn.Hardswish(inplace=True),
            nn.Dropout(p=dropout * 0.5),
            nn.Linear(256, num_classes),
        )

        # Optional bbox regression head (predicts normalized [x1, y1, x2, y2])
        if with_bbox:
            self.bbox_head = nn.Sequential(
                nn.Linear(self.feature_dim, 256),
                nn.ReLU(inplace=True),
                nn.Dropout(p=dropout),
                nn.Linear(256, 4),
                nn.Sigmoid(),
            )

    def extract_features(self, x: torch.Tensor) -> torch.Tensor:
        """Extract feature vector from input images.

        Args:
            x: Input tensor of shape (N, 3, H, W).

        Returns:
            Feature tensor of shape (N, 960).
        """
        x = self.features(x)
        x = self.pool(x)
        return x

    def forward(self, x: torch.Tensor) -> dict[str, torch.Tensor]:
        """Forward pass.

        Args:
            x: Input tensor of shape (N, 3, H, W).

        Returns:
            Dict with:
                'classification': Logits of shape (N, num_classes)
                'bbox': (optional) Bounding boxes of shape (N, 4)
        """
        features = self.extract_features(x)
        classification = self.classifier(features)

        result = {"classification": classification}

        if self.with_bbox and hasattr(self, "bbox_head"):
            bbox = self.bbox_head(features)
            result["bbox"] = bbox

        return result


class PestDetectionLoss(nn.Module):
    """Combined loss for pest detection.

    Loss = alpha * BCE(classification) + beta * SmoothL1(bbox)

    Args:
        alpha: Weight for classification loss.
        beta: Weight for bbox regression loss.
        label_smoothing: Label smoothing factor.
    """

    def __init__(
        self,
        alpha: float = 1.0,
        beta: float = 0.5,
        label_smoothing: float = 0.05,
    ):
        super().__init__()
        self.alpha = alpha
        self.beta = beta
        self.cls_loss = nn.BCEWithLogitsLoss()
        self.bbox_loss = nn.SmoothL1Loss()
        self.label_smoothing = label_smoothing

    def forward(
        self,
        cls_logits: torch.Tensor,
        cls_targets: torch.Tensor,
        bbox_pred: Optional[torch.Tensor] = None,
        bbox_targets: Optional[torch.Tensor] = None,
    ) -> dict[str, torch.Tensor]:
        if self.label_smoothing > 0:
            cls_targets_smooth = cls_targets * (1 - self.label_smoothing) + self.label_smoothing / 2
        else:
            cls_targets_smooth = cls_targets

        cls_loss = self.cls_loss(cls_logits, cls_targets_smooth)
        result = {"classification_loss": cls_loss}
        total = self.alpha * cls_loss

        if bbox_pred is not None and bbox_targets is not None:
            bbox_loss = self.bbox_loss(bbox_pred, bbox_targets)
            result["bbox_loss"] = bbox_loss
            total = total + self.beta * bbox_loss

        result["total_loss"] = total
        return result
