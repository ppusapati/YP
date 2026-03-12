"""
Nutrient deficiency-specific image transforms.

Tailored augmentations for detecting subtle color changes
associated with nutrient deficiencies.
"""

from __future__ import annotations

import albumentations as A
from albumentations.pytorch import ToTensorV2

IMAGENET_MEAN = (0.485, 0.456, 0.406)
IMAGENET_STD = (0.229, 0.224, 0.225)

DEFAULT_IMAGE_SIZE = 224


def get_train_transforms(image_size: int = DEFAULT_IMAGE_SIZE) -> A.Compose:
    """Get training transforms for nutrient deficiency detection.

    Nutrient deficiency symptoms often manifest as subtle color changes
    (yellowing, browning, purpling). Augmentations are designed to
    preserve these color signals while increasing robustness.

    Args:
        image_size: Target image size.

    Returns:
        Albumentations Compose transform.
    """
    transform = A.Compose(
        [
            A.RandomResizedCrop(
                height=image_size,
                width=image_size,
                scale=(0.7, 1.0),
                ratio=(0.85, 1.15),
            ),
            A.HorizontalFlip(p=0.5),
            A.VerticalFlip(p=0.1),
            A.Rotate(limit=25, p=0.4, border_mode=0),

            # Moderate color augmentation (preserve deficiency signals)
            A.ColorJitter(
                brightness=0.2,
                contrast=0.2,
                saturation=0.15,
                hue=0.03,  # Minimal hue shift to preserve deficiency colors
                p=0.6,
            ),

            # CLAHE to enhance subtle color differences
            A.CLAHE(clip_limit=3.0, tile_grid_size=(8, 8), p=0.3),

            # Gentle noise
            A.OneOf(
                [
                    A.GaussNoise(var_limit=(5, 20), p=1.0),
                    A.ISONoise(color_shift=(0.01, 0.03), p=1.0),
                ],
                p=0.2,
            ),

            A.OneOf(
                [
                    A.GaussianBlur(blur_limit=(3, 5), p=1.0),
                    A.Sharpen(alpha=(0.1, 0.3), lightness=(0.9, 1.1), p=1.0),
                ],
                p=0.2,
            ),

            # Mild cutout
            A.CoarseDropout(
                max_holes=5,
                max_height=image_size // 10,
                max_width=image_size // 10,
                fill_value=0,
                p=0.2,
            ),

            A.Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
            ToTensorV2(),
        ]
    )
    transform.albumentations = True
    return transform


def get_val_transforms(image_size: int = DEFAULT_IMAGE_SIZE) -> A.Compose:
    """Get validation transforms for nutrient deficiency detection.

    Args:
        image_size: Target image size.

    Returns:
        Albumentations Compose transform.
    """
    resize_size = int(image_size * 1.14)

    transform = A.Compose(
        [
            A.Resize(height=resize_size, width=resize_size),
            A.CenterCrop(height=image_size, width=image_size),
            A.Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
            ToTensorV2(),
        ]
    )
    transform.albumentations = True
    return transform
