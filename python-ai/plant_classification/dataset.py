"""
PlantVillage Dataset for plant classification.

Supports loading from the standard PlantVillage directory structure
where images are organized by class in subdirectories.
"""

from __future__ import annotations

import logging
from pathlib import Path
from typing import Optional, Callable

import numpy as np
from PIL import Image
from torch.utils.data import Dataset, Subset
from sklearn.model_selection import StratifiedShuffleSplit

from .model import PLANTVILLAGE_CLASSES

logger = logging.getLogger(__name__)


class PlantVillageDataset(Dataset):
    """PyTorch Dataset for the PlantVillage dataset.

    Expected directory structure:
        root/
            Apple___Apple_scab/
                image001.jpg
                image002.jpg
                ...
            Apple___Black_rot/
                ...
            ...

    Args:
        root: Path to the root directory containing class subdirectories.
        transform: Optional callable transform to apply to images.
        class_names: Optional list of class names. Defaults to PLANTVILLAGE_CLASSES.
    """

    def __init__(
        self,
        root: str | Path,
        transform: Optional[Callable] = None,
        class_names: Optional[list[str]] = None,
    ):
        self.root = Path(root)
        self.transform = transform
        self.class_names = class_names or PLANTVILLAGE_CLASSES
        self.class_to_idx = {name: idx for idx, name in enumerate(self.class_names)}

        self.samples: list[tuple[Path, int]] = []
        self._load_samples()

        logger.info(
            f"Loaded PlantVillage dataset: {len(self.samples)} images, "
            f"{len(self.class_names)} classes from {self.root}"
        )

    def _load_samples(self) -> None:
        """Scan directory structure and build sample list."""
        valid_extensions = {".jpg", ".jpeg", ".png", ".bmp", ".tiff"}

        for class_name in self.class_names:
            class_dir = self.root / class_name
            if not class_dir.is_dir():
                logger.warning(f"Class directory not found: {class_dir}")
                continue

            class_idx = self.class_to_idx[class_name]
            for img_path in sorted(class_dir.iterdir()):
                if img_path.suffix.lower() in valid_extensions:
                    self.samples.append((img_path, class_idx))

    def __len__(self) -> int:
        return len(self.samples)

    def __getitem__(self, index: int) -> tuple:
        """Get a single sample.

        Args:
            index: Sample index.

        Returns:
            Tuple of (image, label) where image is a PIL Image or transformed tensor
            and label is an integer class index.
        """
        img_path, label = self.samples[index]

        image = Image.open(img_path).convert("RGB")

        if self.transform is not None:
            # Support both torchvision transforms and albumentations
            if hasattr(self.transform, "albumentations"):
                # Albumentations transform
                image_np = np.array(image)
                transformed = self.transform(image=image_np)
                image = transformed["image"]
            else:
                image = self.transform(image)

        return image, label

    def get_labels(self) -> list[int]:
        """Get all labels for stratified splitting."""
        return [label for _, label in self.samples]

    def get_class_weights(self) -> np.ndarray:
        """Compute inverse frequency class weights for balanced training.

        Returns:
            Array of shape (num_classes,) with class weights.
        """
        labels = np.array(self.get_labels())
        class_counts = np.bincount(labels, minlength=len(self.class_names))
        # Inverse frequency, normalized
        weights = np.where(class_counts > 0, 1.0 / class_counts, 0.0)
        weights = weights / weights.sum() * len(self.class_names)
        return weights.astype(np.float32)

    def get_sample_weights(self) -> np.ndarray:
        """Compute per-sample weights for WeightedRandomSampler.

        Returns:
            Array of shape (num_samples,) with per-sample weights.
        """
        class_weights = self.get_class_weights()
        labels = np.array(self.get_labels())
        return class_weights[labels]


def create_train_val_datasets(
    root: str | Path,
    train_transform: Optional[Callable] = None,
    val_transform: Optional[Callable] = None,
    val_fraction: float = 0.15,
    random_seed: int = 42,
    class_names: Optional[list[str]] = None,
) -> tuple[Subset, Subset]:
    """Create training and validation datasets with stratified split.

    Args:
        root: Path to the PlantVillage data directory.
        train_transform: Transform for training images.
        val_transform: Transform for validation images.
        val_fraction: Fraction of data for validation.
        random_seed: Random seed for reproducibility.
        class_names: Optional class name list.

    Returns:
        Tuple of (train_dataset, val_dataset) as Subset objects.
    """
    # Load full dataset without transforms first for splitting
    full_dataset = PlantVillageDataset(
        root=root,
        transform=None,
        class_names=class_names,
    )

    labels = full_dataset.get_labels()

    splitter = StratifiedShuffleSplit(
        n_splits=1,
        test_size=val_fraction,
        random_state=random_seed,
    )
    train_indices, val_indices = next(splitter.split(np.zeros(len(labels)), labels))

    # Create separate datasets with appropriate transforms
    train_full = PlantVillageDataset(
        root=root,
        transform=train_transform,
        class_names=class_names,
    )
    val_full = PlantVillageDataset(
        root=root,
        transform=val_transform,
        class_names=class_names,
    )

    train_dataset = Subset(train_full, train_indices.tolist())
    val_dataset = Subset(val_full, val_indices.tolist())

    logger.info(f"Train/val split: {len(train_dataset)}/{len(val_dataset)} samples")

    return train_dataset, val_dataset
