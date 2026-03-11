"""
Disease-specific image transforms.

Includes augmentations tailored for plant disease detection,
such as color perturbation to simulate varying disease presentations
and random erasing to improve robustness.
"""

from __future__ import annotations

import albumentations as A
from albumentations.pytorch import ToTensorV2

IMAGENET_MEAN = (0.485, 0.456, 0.406)
IMAGENET_STD = (0.229, 0.224, 0.225)

DEFAULT_IMAGE_SIZE = 256


def get_train_transforms(image_size: int = DEFAULT_IMAGE_SIZE) -> A.Compose:
    """Get disease detection training transforms.

    Disease-specific augmentations include:
        - Strong color perturbation (diseases vary in color appearance)
        - Channel shuffle (to be robust to color channel ordering)
        - Random erasing (cutout) to prevent overfitting to specific disease patches
        - Elastic transform for simulating leaf warping
        - CLAHE for handling varying lighting conditions

    Args:
        image_size: Target image size.

    Returns:
        Albumentations Compose with mask support.
    """
    transform = A.Compose(
        [
            A.RandomResizedCrop(
                height=image_size,
                width=image_size,
                scale=(0.6, 1.0),
                ratio=(0.8, 1.2),
            ),
            A.HorizontalFlip(p=0.5),
            A.VerticalFlip(p=0.3),
            A.Rotate(limit=45, p=0.5, border_mode=0),

            # Color augmentations (strong for disease variation)
            A.OneOf(
                [
                    A.ColorJitter(
                        brightness=0.4,
                        contrast=0.4,
                        saturation=0.4,
                        hue=0.1,
                        p=1.0,
                    ),
                    A.HueSaturationValue(
                        hue_shift_limit=20,
                        sat_shift_limit=40,
                        val_shift_limit=30,
                        p=1.0,
                    ),
                    A.RGBShift(
                        r_shift_limit=25,
                        g_shift_limit=25,
                        b_shift_limit=25,
                        p=1.0,
                    ),
                ],
                p=0.8,
            ),

            # Contrast enhancement
            A.OneOf(
                [
                    A.CLAHE(clip_limit=4.0, p=1.0),
                    A.RandomBrightnessContrast(
                        brightness_limit=0.2,
                        contrast_limit=0.3,
                        p=1.0,
                    ),
                    A.RandomGamma(gamma_limit=(70, 130), p=1.0),
                ],
                p=0.5,
            ),

            # Noise and blur
            A.OneOf(
                [
                    A.GaussianBlur(blur_limit=(3, 7), p=1.0),
                    A.GaussNoise(p=1.0),
                    A.MedianBlur(blur_limit=5, p=1.0),
                ],
                p=0.3,
            ),

            # Geometric distortions
            A.OneOf(
                [
                    A.ElasticTransform(
                        alpha=120,
                        sigma=120 * 0.05,
                        p=1.0,
                    ),
                    A.GridDistortion(p=1.0),
                    A.OpticalDistortion(
                        distort_limit=0.3,
                        shift_limit=0.1,
                        p=1.0,
                    ),
                ],
                p=0.3,
            ),

            # Random erasing (cutout)
            A.CoarseDropout(
                max_holes=12,
                max_height=image_size // 6,
                max_width=image_size // 6,
                min_holes=2,
                fill_value=0,
                p=0.4,
            ),

            # Channel manipulation
            A.ChannelShuffle(p=0.05),

            A.Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
            ToTensorV2(),
        ],
    )
    transform.albumentations = True
    return transform


def get_val_transforms(image_size: int = DEFAULT_IMAGE_SIZE) -> A.Compose:
    """Get disease detection validation transforms.

    Args:
        image_size: Target image size.

    Returns:
        Albumentations Compose with mask support.
    """
    resize_size = int(image_size * 1.1)

    transform = A.Compose(
        [
            A.Resize(height=resize_size, width=resize_size),
            A.CenterCrop(height=image_size, width=image_size),
            A.Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
            ToTensorV2(),
        ],
    )
    transform.albumentations = True
    return transform
