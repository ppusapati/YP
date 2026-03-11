"""
Plant Classification Model using ResNet50 backbone with custom classification head.

Supports 38 PlantVillage classes covering various plant species and their health states.
"""

from __future__ import annotations

import torch
import torch.nn as nn
import torchvision.models as models
from typing import Optional


# PlantVillage 38 class names
PLANTVILLAGE_CLASSES = [
    "Apple___Apple_scab",
    "Apple___Black_rot",
    "Apple___Cedar_apple_rust",
    "Apple___healthy",
    "Blueberry___healthy",
    "Cherry_(including_sour)___Powdery_mildew",
    "Cherry_(including_sour)___healthy",
    "Corn_(maize)___Cercospora_leaf_spot_Gray_leaf_spot",
    "Corn_(maize)___Common_rust_",
    "Corn_(maize)___Northern_Leaf_Blight",
    "Corn_(maize)___healthy",
    "Grape___Black_rot",
    "Grape___Esca_(Black_Measles)",
    "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)",
    "Grape___healthy",
    "Orange___Haunglongbing_(Citrus_greening)",
    "Peach___Bacterial_spot",
    "Peach___healthy",
    "Pepper,_bell___Bacterial_spot",
    "Pepper,_bell___healthy",
    "Potato___Early_blight",
    "Potato___Late_blight",
    "Potato___healthy",
    "Raspberry___healthy",
    "Soybean___healthy",
    "Squash___Powdery_mildew",
    "Strawberry___Leaf_scorch",
    "Strawberry___healthy",
    "Tomato___Bacterial_spot",
    "Tomato___Early_blight",
    "Tomato___Late_blight",
    "Tomato___Leaf_Mold",
    "Tomato___Septoria_leaf_spot",
    "Tomato___Spider_mites_Two-spotted_spider_mite",
    "Tomato___Target_Spot",
    "Tomato___Tomato_Yellow_Leaf_Curl_Virus",
    "Tomato___Tomato_mosaic_virus",
    "Tomato___healthy",
]

NUM_CLASSES = len(PLANTVILLAGE_CLASSES)


class PlantClassificationHead(nn.Module):
    """Custom classification head with dropout and multi-layer projection."""

    def __init__(self, in_features: int, num_classes: int, dropout: float = 0.3):
        super().__init__()
        self.head = nn.Sequential(
            nn.Linear(in_features, 512),
            nn.BatchNorm1d(512),
            nn.ReLU(inplace=True),
            nn.Dropout(p=dropout),
            nn.Linear(512, 256),
            nn.BatchNorm1d(256),
            nn.ReLU(inplace=True),
            nn.Dropout(p=dropout * 0.5),
            nn.Linear(256, num_classes),
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return self.head(x)


class PlantClassificationModel(nn.Module):
    """Plant classification model using ResNet50 backbone.

    Architecture:
        - ResNet50 backbone (pretrained on ImageNet)
        - Global Average Pooling
        - Custom classification head (2048 -> 512 -> 256 -> 38)
        - Supports fine-tuning with frozen/unfrozen backbone

    Args:
        num_classes: Number of output classes (default: 38 for PlantVillage).
        pretrained: Whether to use ImageNet pretrained weights.
        dropout: Dropout rate in classification head.
        freeze_backbone: Whether to freeze backbone weights initially.
    """

    def __init__(
        self,
        num_classes: int = NUM_CLASSES,
        pretrained: bool = True,
        dropout: float = 0.3,
        freeze_backbone: bool = False,
    ):
        super().__init__()
        self.num_classes = num_classes

        # Load ResNet50 backbone
        weights = models.ResNet50_Weights.IMAGENET1K_V2 if pretrained else None
        backbone = models.resnet50(weights=weights)

        # Extract feature layers (everything except the final FC)
        self.features = nn.Sequential(
            backbone.conv1,
            backbone.bn1,
            backbone.relu,
            backbone.maxpool,
            backbone.layer1,
            backbone.layer2,
            backbone.layer3,
            backbone.layer4,
        )
        self.avgpool = backbone.avgpool

        # Feature dimension from ResNet50
        self.feature_dim = 2048

        # Custom classification head
        self.classifier = PlantClassificationHead(
            in_features=self.feature_dim,
            num_classes=num_classes,
            dropout=dropout,
        )

        if freeze_backbone:
            self.freeze_backbone()

    def freeze_backbone(self) -> None:
        """Freeze all backbone parameters."""
        for param in self.features.parameters():
            param.requires_grad = False

    def unfreeze_backbone(self, from_layer: int = 0) -> None:
        """Unfreeze backbone parameters starting from a given layer.

        Args:
            from_layer: Index of the first layer to unfreeze (0-7).
                0 = conv1, 4 = layer1, 5 = layer2, 6 = layer3, 7 = layer4.
        """
        for i, child in enumerate(self.features.children()):
            if i >= from_layer:
                for param in child.parameters():
                    param.requires_grad = True

    def extract_features(self, x: torch.Tensor) -> torch.Tensor:
        """Extract feature vector from input images.

        Args:
            x: Input tensor of shape (N, 3, H, W).

        Returns:
            Feature tensor of shape (N, 2048).
        """
        x = self.features(x)
        x = self.avgpool(x)
        x = torch.flatten(x, 1)
        return x

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        """Forward pass.

        Args:
            x: Input tensor of shape (N, 3, H, W).

        Returns:
            Logits tensor of shape (N, num_classes).
        """
        features = self.extract_features(x)
        logits = self.classifier(features)
        return logits

    def get_trainable_params(self) -> list[dict]:
        """Get parameter groups with different learning rates.

        Returns:
            List of param group dicts for optimizer.
            Backbone params use 10x lower learning rate than head params.
        """
        backbone_params = []
        head_params = []

        for name, param in self.named_parameters():
            if not param.requires_grad:
                continue
            if name.startswith("features"):
                backbone_params.append(param)
            else:
                head_params.append(param)

        return [
            {"params": backbone_params, "lr_scale": 0.1},
            {"params": head_params, "lr_scale": 1.0},
        ]
