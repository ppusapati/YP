"""
Image transforms for plant classification training and validation.

Uses albumentations for training augmentation and torchvision-compatible
normalization for both training and inference.
"""

from __future__ import annotations

import albumentations as A
from albumentations.pytorch import ToTensorV2

# ImageNet normalization values (used by pretrained ResNet50)
IMAGENET_MEAN = (0.485, 0.456, 0.406)
IMAGENET_STD = (0.229, 0.224, 0.225)

# Default image size for plant classification
DEFAULT_IMAGE_SIZE = 224


def get_train_transforms(image_size: int = DEFAULT_IMAGE_SIZE) -> A.Compose:
    """Get training transforms with data augmentation.

    Applies:
        - Random resized crop (scale 0.7-1.0)
        - Horizontal flip (50%)
        - Vertical flip (10%)
        - Random rotation (+/- 30 degrees)
        - Color jitter (brightness, contrast, saturation, hue)
        - Gaussian blur (light)
        - Coarse dropout (cutout-style regularization)
        - Normalize to ImageNet statistics
        - Convert to PyTorch tensor

    Args:
        image_size: Target image size (square).

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
                interpolation=1,  # INTER_LINEAR
            ),
            A.HorizontalFlip(p=0.5),
            A.VerticalFlip(p=0.1),
            A.Rotate(limit=30, p=0.5, border_mode=0),
            A.ColorJitter(
                brightness=0.3,
                contrast=0.3,
                saturation=0.3,
                hue=0.05,
                p=0.8,
            ),
            A.OneOf(
                [
                    A.GaussianBlur(blur_limit=(3, 5), p=1.0),
                    A.MedianBlur(blur_limit=3, p=1.0),
                ],
                p=0.2,
            ),
            A.OneOf(
                [
                    A.GaussNoise(p=1.0),
                    A.ISONoise(p=1.0),
                ],
                p=0.2,
            ),
            A.CoarseDropout(
                max_holes=8,
                max_height=image_size // 8,
                max_width=image_size // 8,
                min_holes=1,
                fill_value=0,
                p=0.3,
            ),
            A.ShiftScaleRotate(
                shift_limit=0.05,
                scale_limit=0.05,
                rotate_limit=0,
                p=0.3,
                border_mode=0,
            ),
            A.Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
            ToTensorV2(),
        ]
    )
    # Mark as albumentations for dataset compatibility
    transform.albumentations = True
    return transform


def get_val_transforms(image_size: int = DEFAULT_IMAGE_SIZE) -> A.Compose:
    """Get validation/inference transforms (deterministic).

    Applies:
        - Resize to slightly larger than target
        - Center crop to target size
        - Normalize to ImageNet statistics
        - Convert to PyTorch tensor

    Args:
        image_size: Target image size (square).

    Returns:
        Albumentations Compose transform.
    """
    resize_size = int(image_size * 1.14)  # ~256 for 224

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


def get_tta_transforms(image_size: int = DEFAULT_IMAGE_SIZE) -> list[A.Compose]:
    """Get test-time augmentation (TTA) transforms.

    Returns multiple transforms that produce different views of the same image.
    Predictions should be averaged across all views for more robust results.

    Args:
        image_size: Target image size (square).

    Returns:
        List of albumentations Compose transforms.
    """
    resize_size = int(image_size * 1.14)
    base_transforms = [
        A.Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
        ToTensorV2(),
    ]

    transforms_list = [
        # Original
        A.Compose([
            A.Resize(height=resize_size, width=resize_size),
            A.CenterCrop(height=image_size, width=image_size),
            *base_transforms,
        ]),
        # Horizontal flip
        A.Compose([
            A.Resize(height=resize_size, width=resize_size),
            A.CenterCrop(height=image_size, width=image_size),
            A.HorizontalFlip(p=1.0),
            *base_transforms,
        ]),
        # Slight rotation left
        A.Compose([
            A.Resize(height=resize_size, width=resize_size),
            A.CenterCrop(height=image_size, width=image_size),
            A.Rotate(limit=(10, 10), p=1.0, border_mode=0),
            *base_transforms,
        ]),
        # Slight rotation right
        A.Compose([
            A.Resize(height=resize_size, width=resize_size),
            A.CenterCrop(height=image_size, width=image_size),
            A.Rotate(limit=(-10, -10), p=1.0, border_mode=0),
            *base_transforms,
        ]),
        # Slightly brighter
        A.Compose([
            A.Resize(height=resize_size, width=resize_size),
            A.CenterCrop(height=image_size, width=image_size),
            A.RandomBrightnessContrast(
                brightness_limit=(0.1, 0.1), contrast_limit=0, p=1.0
            ),
            *base_transforms,
        ]),
    ]

    for t in transforms_list:
        t.albumentations = True

    return transforms_list


def get_inference_transforms(image_size: int = DEFAULT_IMAGE_SIZE) -> A.Compose:
    """Get inference transforms for production plant classification.

    Identical to validation transforms, optimized for single-image
    inference in deployment.

    Args:
        image_size: Target image size (square).

    Returns:
        Albumentations Compose transform.
    """
    return get_val_transforms(image_size)
