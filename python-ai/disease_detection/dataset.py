"""
Disease Detection Dataset supporting both classification labels
and segmentation masks for disease localization.
"""

from __future__ import annotations

import json
import logging
from pathlib import Path
from typing import Optional, Callable

import cv2
import numpy as np
from PIL import Image
from torch.utils.data import Dataset, Subset
from sklearn.model_selection import StratifiedShuffleSplit

from .model import DISEASE_CLASSES, NUM_DISEASE_CLASSES

logger = logging.getLogger(__name__)


class DiseaseDataset(Dataset):
    """Dataset for disease detection with classification and segmentation labels.

    Supports two directory structures:

    Structure 1 (classification only):
        root/
            images/
                img_001.jpg
                ...
            labels.json   # {"img_001.jpg": [0, 1, 0, ...], ...}

    Structure 2 (classification + segmentation):
        root/
            images/
                img_001.jpg
                ...
            masks/
                img_001.png    # Binary mask (0/255)
                ...
            labels.json

    Args:
        root: Path to dataset root directory.
        transform: Optional transform for images (albumentations).
        class_names: Disease class names.
        has_masks: Whether segmentation masks are available.
        mask_size: Target size for segmentation masks.
    """

    def __init__(
        self,
        root: str | Path,
        transform: Optional[Callable] = None,
        class_names: Optional[list[str]] = None,
        has_masks: bool = True,
        mask_size: int = 256,
    ):
        self.root = Path(root)
        self.transform = transform
        self.class_names = class_names or DISEASE_CLASSES
        self.num_classes = len(self.class_names)
        self.has_masks = has_masks
        self.mask_size = mask_size

        self.images_dir = self.root / "images"
        self.masks_dir = self.root / "masks" if has_masks else None
        self.labels_path = self.root / "labels.json"

        self.samples: list[dict] = []
        self._load_samples()

        logger.info(
            f"Loaded DiseaseDataset: {len(self.samples)} samples, "
            f"{self.num_classes} classes, masks={'yes' if has_masks else 'no'}"
        )

    def _load_samples(self) -> None:
        """Load sample list from labels file."""
        if not self.labels_path.exists():
            # Fall back to directory-based structure (PlantVillage style)
            self._load_from_directories()
            return

        with open(self.labels_path) as f:
            labels_data = json.load(f)

        for filename, label_vec in labels_data.items():
            img_path = self.images_dir / filename
            if not img_path.exists():
                continue

            sample = {
                "image_path": img_path,
                "labels": np.array(label_vec, dtype=np.float32),
            }

            if self.has_masks and self.masks_dir is not None:
                mask_name = Path(filename).stem + ".png"
                mask_path = self.masks_dir / mask_name
                if mask_path.exists():
                    sample["mask_path"] = mask_path
                else:
                    sample["mask_path"] = None
            else:
                sample["mask_path"] = None

            self.samples.append(sample)

    def _load_from_directories(self) -> None:
        """Load samples from PlantVillage-style directory structure."""
        valid_extensions = {".jpg", ".jpeg", ".png", ".bmp"}

        for class_idx, class_name in enumerate(self.class_names):
            class_dir = self.root / class_name
            if not class_dir.is_dir():
                continue

            for img_path in sorted(class_dir.iterdir()):
                if img_path.suffix.lower() not in valid_extensions:
                    continue

                # Create one-hot label vector
                labels = np.zeros(self.num_classes, dtype=np.float32)
                labels[class_idx] = 1.0

                self.samples.append({
                    "image_path": img_path,
                    "labels": labels,
                    "mask_path": None,
                })

    def __len__(self) -> int:
        return len(self.samples)

    def __getitem__(self, index: int) -> dict:
        """Get a single sample.

        Returns:
            Dict with keys:
                'image': Tensor (3, H, W)
                'labels': Tensor (num_classes,) multi-hot
                'mask': Tensor (1, H, W) or None
                'has_mask': bool
        """
        sample = self.samples[index]

        # Load image
        image = cv2.imread(str(sample["image_path"]))
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

        # Load mask if available
        mask = None
        has_mask = False
        if sample["mask_path"] is not None:
            mask = cv2.imread(str(sample["mask_path"]), cv2.IMREAD_GRAYSCALE)
            mask = (mask > 127).astype(np.float32)
            has_mask = True

        # Apply transforms
        if self.transform is not None:
            if mask is not None:
                transformed = self.transform(image=image, mask=mask)
                image = transformed["image"]
                mask = transformed["mask"]
                if mask.ndim == 2:
                    mask = mask.unsqueeze(0)  # Add channel dim
            else:
                transformed = self.transform(image=image)
                image = transformed["image"]

        labels = sample["labels"].copy()

        result = {
            "image": image,
            "labels": labels,
            "has_mask": has_mask,
        }

        if mask is not None:
            result["mask"] = mask
        else:
            # Zero mask for samples without mask annotations (contributes zero to segmentation loss)
            import torch
            result["mask"] = torch.zeros(1, self.mask_size, self.mask_size)

        return result

    def get_primary_labels(self) -> list[int]:
        """Get primary (argmax) label for each sample for stratified splitting."""
        return [int(s["labels"].argmax()) for s in self.samples]

    def get_class_frequencies(self) -> np.ndarray:
        """Get per-class positive sample frequency."""
        all_labels = np.stack([s["labels"] for s in self.samples])
        return all_labels.mean(axis=0)

    def get_pos_weights(self) -> np.ndarray:
        """Compute positive class weights for BCEWithLogitsLoss."""
        freq = self.get_class_frequencies()
        # pos_weight = num_neg / num_pos
        pos_weight = np.where(freq > 0, (1 - freq) / freq, 1.0)
        return pos_weight.astype(np.float32)


def create_disease_train_val(
    root: str | Path,
    train_transform: Optional[Callable] = None,
    val_transform: Optional[Callable] = None,
    val_fraction: float = 0.15,
    random_seed: int = 42,
    has_masks: bool = True,
) -> tuple[Subset, Subset]:
    """Create training and validation datasets with stratified split.

    Args:
        root: Path to the dataset root.
        train_transform: Transform for training.
        val_transform: Transform for validation.
        val_fraction: Fraction for validation.
        random_seed: Random seed.
        has_masks: Whether masks are available.

    Returns:
        Tuple of (train_subset, val_subset).
    """
    full_train = DiseaseDataset(root=root, transform=train_transform, has_masks=has_masks)
    full_val = DiseaseDataset(root=root, transform=val_transform, has_masks=has_masks)

    primary_labels = full_train.get_primary_labels()

    splitter = StratifiedShuffleSplit(
        n_splits=1, test_size=val_fraction, random_state=random_seed
    )
    train_idx, val_idx = next(splitter.split(np.zeros(len(primary_labels)), primary_labels))

    return Subset(full_train, train_idx.tolist()), Subset(full_val, val_idx.tolist())
