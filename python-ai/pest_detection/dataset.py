"""
Pest Detection Dataset supporting multi-label classification
with optional bounding box annotations.
"""

from __future__ import annotations

import json
import logging
from pathlib import Path
from typing import Optional, Callable

import cv2
import numpy as np
from torch.utils.data import Dataset, Subset
from sklearn.model_selection import StratifiedShuffleSplit

from .model import PEST_CLASSES, NUM_PEST_CLASSES

logger = logging.getLogger(__name__)


class PestDataset(Dataset):
    """Dataset for pest detection with classification and bbox labels.

    Supports two directory structures:

    Structure 1 (classification only):
        root/
            images/
                img_001.jpg
                ...
            labels.json   # {"img_001.jpg": {"classes": [0, 1, 0, ...], "bbox": [x1, y1, x2, y2]}}

    Structure 2 (class directory):
        root/
            Aphid/
                img_001.jpg
            Armyworm/
                img_002.jpg
            ...

    Args:
        root: Path to dataset root directory.
        transform: Optional transform for images (albumentations).
        class_names: Pest class names.
        with_bbox: Whether bounding box annotations are available.
    """

    def __init__(
        self,
        root: str | Path,
        transform: Optional[Callable] = None,
        class_names: Optional[list[str]] = None,
        with_bbox: bool = False,
    ):
        self.root = Path(root)
        self.transform = transform
        self.class_names = class_names or PEST_CLASSES
        self.num_classes = len(self.class_names)
        self.with_bbox = with_bbox

        self.images_dir = self.root / "images"
        self.labels_path = self.root / "labels.json"

        self.samples: list[dict] = []
        self._load_samples()

        logger.info(
            f"Loaded PestDataset: {len(self.samples)} samples, "
            f"{self.num_classes} classes, bbox={'yes' if with_bbox else 'no'}"
        )

    def _load_samples(self) -> None:
        """Load sample list from labels file or directory structure."""
        if not self.labels_path.exists():
            self._load_from_directories()
            return

        with open(self.labels_path) as f:
            labels_data = json.load(f)

        for filename, annotation in labels_data.items():
            img_path = self.images_dir / filename
            if not img_path.exists():
                continue

            if isinstance(annotation, dict):
                classes = np.array(annotation["classes"], dtype=np.float32)
                bbox = np.array(annotation.get("bbox", [0, 0, 1, 1]), dtype=np.float32) if self.with_bbox else None
            else:
                classes = np.array(annotation, dtype=np.float32)
                bbox = None

            sample = {
                "image_path": img_path,
                "labels": classes,
                "bbox": bbox,
            }
            self.samples.append(sample)

    def _load_from_directories(self) -> None:
        """Load samples from class-per-directory structure."""
        valid_extensions = {".jpg", ".jpeg", ".png", ".bmp"}

        for class_idx, class_name in enumerate(self.class_names):
            class_dir = self.root / class_name
            if not class_dir.is_dir():
                continue

            for img_path in sorted(class_dir.iterdir()):
                if img_path.suffix.lower() not in valid_extensions:
                    continue

                labels = np.zeros(self.num_classes, dtype=np.float32)
                labels[class_idx] = 1.0

                self.samples.append({
                    "image_path": img_path,
                    "labels": labels,
                    "bbox": None,
                })

    def __len__(self) -> int:
        return len(self.samples)

    def __getitem__(self, index: int) -> dict:
        """Get a single sample.

        Returns:
            Dict with keys:
                'image': Tensor (3, H, W)
                'labels': ndarray (num_classes,) multi-hot
                'bbox': ndarray (4,) normalized [x1, y1, x2, y2] or None
        """
        sample = self.samples[index]

        image = cv2.imread(str(sample["image_path"]))
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

        if self.transform is not None:
            transformed = self.transform(image=image)
            image = transformed["image"]

        result = {
            "image": image,
            "labels": sample["labels"].copy(),
        }

        if sample["bbox"] is not None:
            result["bbox"] = sample["bbox"].copy()
        else:
            result["bbox"] = np.array([0.0, 0.0, 1.0, 1.0], dtype=np.float32)

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
        pos_weight = np.where(freq > 0, (1 - freq) / freq, 1.0)
        return pos_weight.astype(np.float32)


def create_pest_train_val(
    root: str | Path,
    train_transform: Optional[Callable] = None,
    val_transform: Optional[Callable] = None,
    val_fraction: float = 0.15,
    random_seed: int = 42,
    with_bbox: bool = False,
) -> tuple[Subset, Subset]:
    """Create training and validation datasets with stratified split.

    Args:
        root: Path to the dataset root.
        train_transform: Transform for training.
        val_transform: Transform for validation.
        val_fraction: Fraction for validation.
        random_seed: Random seed.
        with_bbox: Whether bbox annotations are available.

    Returns:
        Tuple of (train_subset, val_subset).
    """
    full_train = PestDataset(root=root, transform=train_transform, with_bbox=with_bbox)
    full_val = PestDataset(root=root, transform=val_transform, with_bbox=with_bbox)

    primary_labels = full_train.get_primary_labels()

    splitter = StratifiedShuffleSplit(
        n_splits=1, test_size=val_fraction, random_state=random_seed
    )
    train_idx, val_idx = next(splitter.split(np.zeros(len(primary_labels)), primary_labels))

    return Subset(full_train, train_idx.tolist()), Subset(full_val, val_idx.tolist())
