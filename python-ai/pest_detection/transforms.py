"""
Pest detection image transforms.

Augmentations tailored for pest detection, including small object
augmentation strategies and insect-specific color perturbations.
"""

from __future__ import annotations

import albumentations as A
from albumentations.pytorch import ToTensorV2

IMAGENET_MEAN = (0.485, 0.456, 0.406)
IMAGENET_STD = (0.229, 0.224, 0.225)

DEFAULT_IMAGE_SIZE = 320


def get_train_transforms(image_size: int = DEFAULT_IMAGE_SIZE) -> A.Compose:
    """Get pest detection training transforms.

    Pest-specific augmentations include:
        - Higher resolution (320px) for small pest detection
        - Aggressive scale variation (pests vary greatly in apparent size)
        - Strong blur augmentation (simulating field camera conditions)
        - CLAHE for enhancing pest visibility in shadows
        - Mosaic-style random crop for multi-scale training

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
                scale=(0.5, 1.0),
                ratio=(0.75, 1.33),
            ),
            A.HorizontalFlip(p=0.5),
            A.VerticalFlip(p=0.2),
            A.Rotate(limit=90, p=0.5, border_mode=0),

            # Color augmentations (insect coloring varies with species)
            A.OneOf(
                [
                    A.ColorJitter(
                        brightness=0.3,
                        contrast=0.3,
                        saturation=0.3,
                        hue=0.08,
                        p=1.0,
                    ),
                    A.HueSaturationValue(
                        hue_shift_limit=15,
                        sat_shift_limit=30,
                        val_shift_limit=25,
                        p=1.0,
                    ),
                ],
                p=0.7,
            ),

            # Contrast enhancement (pests often in shadows)
            A.OneOf(
                [
                    A.CLAHE(clip_limit=4.0, p=1.0),
                    A.RandomBrightnessContrast(
                        brightness_limit=0.2,
                        contrast_limit=0.3,
                        p=1.0,
                    ),
                ],
                p=0.4,
            ),

            # Noise and blur (field camera quality)
            A.OneOf(
                [
                    A.GaussianBlur(blur_limit=(3, 7), p=1.0),
                    A.MotionBlur(blur_limit=5, p=1.0),
                    A.GaussNoise(p=1.0),
                ],
                p=0.3,
            ),

            # Random erasing
            A.CoarseDropout(
                max_holes=6,
                max_height=image_size // 8,
                max_width=image_size // 8,
                min_holes=1,
                fill_value=0,
                p=0.3,
            ),

            A.Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
            ToTensorV2(),
        ]
    )
    transform.albumentations = True
    return transform


def get_val_transforms(image_size: int = DEFAULT_IMAGE_SIZE) -> A.Compose:
    """Get pest detection validation transforms.

    Args:
        image_size: Target image size.

    Returns:
        Albumentations Compose transform.
    """
    resize_size = int(image_size * 1.1)

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
