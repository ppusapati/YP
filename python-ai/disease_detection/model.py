"""
Disease Detection Model using EfficientNet-B4 backbone.

Multi-task architecture with:
- Multi-label classification head for identifying multiple simultaneous diseases
- U-Net style segmentation decoder for disease localization
"""

from __future__ import annotations

from typing import Optional

import torch
import torch.nn as nn
import torch.nn.functional as F
import torchvision.models as models


DISEASE_CLASSES = [
    "Apple___Apple_scab",
    "Apple___Black_rot",
    "Apple___Cedar_apple_rust",
    "Apple___healthy",
    "Blueberry___healthy",
    "Cherry___Powdery_mildew",
    "Cherry___healthy",
    "Corn___Cercospora_leaf_spot",
    "Corn___Common_rust",
    "Corn___Northern_Leaf_Blight",
    "Corn___healthy",
    "Grape___Black_rot",
    "Grape___Esca_Black_Measles",
    "Grape___Leaf_blight_Isariopsis",
    "Grape___healthy",
    "Orange___Haunglongbing",
    "Peach___Bacterial_spot",
    "Peach___healthy",
    "Pepper___Bacterial_spot",
    "Pepper___healthy",
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
    "Tomato___Spider_mites",
    "Tomato___Target_Spot",
    "Tomato___Yellow_Leaf_Curl_Virus",
    "Tomato___Tomato_mosaic_virus",
    "Tomato___healthy",
]

NUM_DISEASE_CLASSES = len(DISEASE_CLASSES)


class SqueezeExcitation(nn.Module):
    """Squeeze-and-Excitation block for channel attention."""

    def __init__(self, channels: int, reduction: int = 16):
        super().__init__()
        mid = max(channels // reduction, 8)
        self.fc1 = nn.Conv2d(channels, mid, 1)
        self.fc2 = nn.Conv2d(mid, channels, 1)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        scale = F.adaptive_avg_pool2d(x, 1)
        scale = F.relu(self.fc1(scale), inplace=True)
        scale = torch.sigmoid(self.fc2(scale))
        return x * scale


class DecoderBlock(nn.Module):
    """U-Net decoder block with skip connections."""

    def __init__(
        self,
        in_channels: int,
        skip_channels: int,
        out_channels: int,
    ):
        super().__init__()
        self.upsample = nn.ConvTranspose2d(
            in_channels, in_channels, kernel_size=2, stride=2
        )
        self.conv1 = nn.Conv2d(
            in_channels + skip_channels, out_channels, kernel_size=3, padding=1, bias=False
        )
        self.bn1 = nn.BatchNorm2d(out_channels)
        self.conv2 = nn.Conv2d(
            out_channels, out_channels, kernel_size=3, padding=1, bias=False
        )
        self.bn2 = nn.BatchNorm2d(out_channels)
        self.se = SqueezeExcitation(out_channels)
        self.relu = nn.ReLU(inplace=True)

    def forward(self, x: torch.Tensor, skip: Optional[torch.Tensor] = None) -> torch.Tensor:
        x = self.upsample(x)

        if skip is not None:
            # Handle size mismatch from encoder
            if x.shape[2:] != skip.shape[2:]:
                x = F.interpolate(x, size=skip.shape[2:], mode="bilinear", align_corners=False)
            x = torch.cat([x, skip], dim=1)

        x = self.relu(self.bn1(self.conv1(x)))
        x = self.relu(self.bn2(self.conv2(x)))
        x = self.se(x)
        return x


class SegmentationDecoder(nn.Module):
    """U-Net style segmentation decoder using EfficientNet encoder features."""

    def __init__(
        self,
        encoder_channels: list[int],
        decoder_channels: list[int] = (256, 128, 64, 32, 16),
        num_classes: int = 1,
    ):
        super().__init__()

        # Decoder blocks (from deepest to shallowest)
        self.blocks = nn.ModuleList()
        in_ch = encoder_channels[0]  # Deepest encoder output

        for i, out_ch in enumerate(decoder_channels):
            skip_ch = encoder_channels[i + 1] if i + 1 < len(encoder_channels) else 0
            self.blocks.append(DecoderBlock(in_ch, skip_ch, out_ch))
            in_ch = out_ch

        # Final segmentation head
        self.final_conv = nn.Sequential(
            nn.Conv2d(decoder_channels[-1], decoder_channels[-1], 3, padding=1, bias=False),
            nn.BatchNorm2d(decoder_channels[-1]),
            nn.ReLU(inplace=True),
            nn.Conv2d(decoder_channels[-1], num_classes, 1),
        )

    def forward(
        self,
        features: list[torch.Tensor],
        target_size: tuple[int, int],
    ) -> torch.Tensor:
        """Forward pass through decoder.

        Args:
            features: List of encoder feature maps from deepest to shallowest.
            target_size: Target output spatial dimensions (H, W).

        Returns:
            Segmentation logits of shape (N, num_classes, H, W).
        """
        x = features[0]  # Deepest feature map

        for i, block in enumerate(self.blocks):
            skip = features[i + 1] if i + 1 < len(features) else None
            x = block(x, skip)

        x = self.final_conv(x)

        # Resize to target
        if x.shape[2:] != target_size:
            x = F.interpolate(x, size=target_size, mode="bilinear", align_corners=False)

        return x


class DiseaseDetectionModel(nn.Module):
    """Multi-task disease detection model.

    Architecture:
        - EfficientNet-B4 encoder (pretrained)
        - Multi-label classification head
        - U-Net style segmentation decoder for disease localization

    Args:
        num_classes: Number of disease classes.
        pretrained: Whether to use ImageNet pretrained weights.
        dropout: Dropout rate for classification head.
        segmentation_classes: Number of segmentation classes (1 for binary disease mask).
    """

    def __init__(
        self,
        num_classes: int = NUM_DISEASE_CLASSES,
        pretrained: bool = True,
        dropout: float = 0.3,
        segmentation_classes: int = 1,
    ):
        super().__init__()
        self.num_classes = num_classes
        self.segmentation_classes = segmentation_classes

        # Load EfficientNet-B4
        weights = models.EfficientNet_B4_Weights.IMAGENET1K_V1 if pretrained else None
        efficientnet = models.efficientnet_b4(weights=weights)

        # Extract encoder stages for skip connections
        # EfficientNet-B4 features structure:
        # features[0]: Conv stem -> 48 channels
        # features[1]: MBConv stage 1 -> 24 channels
        # features[2]: MBConv stage 2 -> 32 channels
        # features[3]: MBConv stage 3 -> 56 channels
        # features[4]: MBConv stage 4 -> 112 channels
        # features[5]: MBConv stage 5 -> 160 channels
        # features[6]: MBConv stage 6 -> 272 channels
        # features[7]: MBConv stage 7 -> 448 channels
        # features[8]: Conv head -> 1792 channels
        self.encoder_stages = nn.ModuleList([
            nn.Sequential(efficientnet.features[0], efficientnet.features[1]),  # stride 2
            efficientnet.features[2],   # stride 4
            efficientnet.features[3],   # stride 8
            nn.Sequential(efficientnet.features[4], efficientnet.features[5]),  # stride 16
            nn.Sequential(efficientnet.features[6], efficientnet.features[7], efficientnet.features[8]),  # stride 32
        ])

        # Encoder channel dimensions (from deepest to shallowest)
        self.encoder_channels = [1792, 160, 56, 32, 24]

        # Classification head
        self.avgpool = nn.AdaptiveAvgPool2d(1)
        self.classifier = nn.Sequential(
            nn.Dropout(p=dropout),
            nn.Linear(1792, 512),
            nn.BatchNorm1d(512),
            nn.ReLU(inplace=True),
            nn.Dropout(p=dropout * 0.5),
            nn.Linear(512, num_classes),
        )

        # Segmentation decoder
        self.decoder = SegmentationDecoder(
            encoder_channels=self.encoder_channels,
            decoder_channels=[256, 128, 64, 32, 16],
            num_classes=segmentation_classes,
        )

    def encode(self, x: torch.Tensor) -> list[torch.Tensor]:
        """Extract multi-scale encoder features.

        Args:
            x: Input tensor of shape (N, 3, H, W).

        Returns:
            List of feature maps from deepest to shallowest.
        """
        features = []
        for stage in self.encoder_stages:
            x = stage(x)
            features.append(x)

        # Reverse so deepest is first
        features.reverse()
        return features

    def forward(
        self,
        x: torch.Tensor,
        return_segmentation: bool = True,
    ) -> dict[str, torch.Tensor]:
        """Forward pass.

        Args:
            x: Input tensor of shape (N, 3, H, W).
            return_segmentation: Whether to compute the segmentation mask.

        Returns:
            Dict with:
                'classification': Logits of shape (N, num_classes)
                'segmentation': (optional) Mask logits of shape (N, seg_classes, H, W)
        """
        input_size = x.shape[2:]

        # Encoder
        features = self.encode(x)

        # Classification from deepest features
        cls_features = self.avgpool(features[0])
        cls_features = torch.flatten(cls_features, 1)
        classification = self.classifier(cls_features)

        result = {"classification": classification}

        if return_segmentation:
            segmentation = self.decoder(features, target_size=input_size)
            result["segmentation"] = segmentation

        return result


class DiceLoss(nn.Module):
    """Dice loss for segmentation tasks."""

    def __init__(self, smooth: float = 1e-6):
        super().__init__()
        self.smooth = smooth

    def forward(self, predictions: torch.Tensor, targets: torch.Tensor) -> torch.Tensor:
        predictions = torch.sigmoid(predictions)
        predictions = predictions.flatten(1)
        targets = targets.flatten(1)

        intersection = (predictions * targets).sum(dim=1)
        union = predictions.sum(dim=1) + targets.sum(dim=1)

        dice = (2.0 * intersection + self.smooth) / (union + self.smooth)
        return 1.0 - dice.mean()


class CombinedLoss(nn.Module):
    """Combined classification and segmentation loss.

    Loss = alpha * BCE(classification) + beta * (CE(seg) + Dice(seg))

    Args:
        alpha: Weight for classification loss.
        beta: Weight for segmentation loss.
        label_smoothing: Label smoothing for classification BCE.
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

        self.cls_loss = nn.BCEWithLogitsLoss(
            pos_weight=None,
        )
        self.seg_ce_loss = nn.BCEWithLogitsLoss()
        self.seg_dice_loss = DiceLoss()
        self.label_smoothing = label_smoothing

    def forward(
        self,
        cls_logits: torch.Tensor,
        cls_targets: torch.Tensor,
        seg_logits: Optional[torch.Tensor] = None,
        seg_targets: Optional[torch.Tensor] = None,
    ) -> dict[str, torch.Tensor]:
        # Apply label smoothing to classification targets
        if self.label_smoothing > 0:
            cls_targets_smooth = cls_targets * (1 - self.label_smoothing) + self.label_smoothing / 2
        else:
            cls_targets_smooth = cls_targets

        cls_loss = self.cls_loss(cls_logits, cls_targets_smooth)

        result = {"classification_loss": cls_loss}
        total_loss = self.alpha * cls_loss

        if seg_logits is not None and seg_targets is not None:
            seg_ce = self.seg_ce_loss(seg_logits, seg_targets)
            seg_dice = self.seg_dice_loss(seg_logits, seg_targets)
            seg_loss = seg_ce + seg_dice

            result["segmentation_ce_loss"] = seg_ce
            result["segmentation_dice_loss"] = seg_dice
            result["segmentation_loss"] = seg_loss
            total_loss = total_loss + self.beta * seg_loss

        result["total_loss"] = total_loss
        return result
