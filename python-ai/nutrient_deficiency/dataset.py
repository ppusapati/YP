"""
Dataset for nutrient deficiency detection with symptom-based labeling.

Supports multi-label nutrient deficiency annotations with severity levels.
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

from .model import NUTRIENT_DEFICIENCIES, NUM_NUTRIENTS, NUM_SEVERITY

logger = logging.getLogger(__name__)


class NutrientDataset(Dataset):
    """Dataset for nutrient deficiency detection.

    Expected directory structure:
        root/
            images/
                img_001.jpg
                ...
            annotations.json

    annotations.json format:
    {
        "img_001.jpg": {
            "deficiencies": [0, 1, 0, 0, 0, 1, 0, 0],   # multi-hot
            "severity": [0, 2, 0, 0, 0, 1, 0, 0]          # 0=None, 1=Low, 2=Moderate, 3=High
        },
        ...
    }

    Args:
        root: Path to dataset root.
        transform: Optional albumentations transform.
        nutrient_names: List of nutrient deficiency names.
    """

    def __init__(
        self,
        root: str | Path,
        transform: Optional[Callable] = None,
        nutrient_names: Optional[list[str]] = None,
    ):
        self.root = Path(root)
        self.transform = transform
        self.nutrient_names = nutrient_names or NUTRIENT_DEFICIENCIES
        self.num_nutrients = len(self.nutrient_names)

        self.images_dir = self.root / "images"
        self.annotations_path = self.root / "annotations.json"

        self.samples: list[dict] = []
        self._load_samples()

        logger.info(
            f"Loaded NutrientDataset: {len(self.samples)} samples, "
            f"{self.num_nutrients} nutrient types"
        )

    def _load_samples(self) -> None:
        """Load sample list from annotations file."""
        if not self.annotations_path.exists():
            # Fall back to directory-based loading
            self._load_from_directories()
            return

        with open(self.annotations_path) as f:
            annotations = json.load(f)

        for filename, ann in annotations.items():
            img_path = self.images_dir / filename
            if not img_path.exists():
                continue

            deficiencies = np.array(ann["deficiencies"], dtype=np.float32)
            severity = np.array(ann["severity"], dtype=np.int64)

            self.samples.append({
                "image_path": img_path,
                "deficiencies": deficiencies,
                "severity": severity,
            })

    def _load_from_directories(self) -> None:
        """Fall back to directory-based structure.

        Expected structure:
            root/
                Nitrogen/
                    img_001.jpg
                Phosphorus/
                    ...
                Healthy/
                    ...
        """
        valid_extensions = {".jpg", ".jpeg", ".png", ".bmp"}

        for nutrient_idx, nutrient_name in enumerate(self.nutrient_names):
            nutrient_dir = self.root / nutrient_name
            if not nutrient_dir.is_dir():
                continue

            for img_path in sorted(nutrient_dir.iterdir()):
                if img_path.suffix.lower() not in valid_extensions:
                    continue

                deficiencies = np.zeros(self.num_nutrients, dtype=np.float32)
                severity = np.zeros(self.num_nutrients, dtype=np.int64)
                deficiencies[nutrient_idx] = 1.0
                severity[nutrient_idx] = 2  # Default to "Moderate"

                self.samples.append({
                    "image_path": img_path,
                    "deficiencies": deficiencies,
                    "severity": severity,
                })

        # Load healthy samples
        healthy_dir = self.root / "Healthy"
        if healthy_dir.is_dir():
            for img_path in sorted(healthy_dir.iterdir()):
                if img_path.suffix.lower() in valid_extensions:
                    self.samples.append({
                        "image_path": img_path,
                        "deficiencies": np.zeros(self.num_nutrients, dtype=np.float32),
                        "severity": np.zeros(self.num_nutrients, dtype=np.int64),
                    })

    def __len__(self) -> int:
        return len(self.samples)

    def __getitem__(self, index: int) -> dict:
        """Get a single sample.

        Returns:
            Dict with:
                'image': Tensor (3, H, W)
                'deficiencies': ndarray (num_nutrients,) float32, multi-hot
                'severity': ndarray (num_nutrients,) int64, severity levels
        """
        sample = self.samples[index]

        image = cv2.imread(str(sample["image_path"]))
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

        if self.transform is not None:
            transformed = self.transform(image=image)
            image = transformed["image"]

        return {
            "image": image,
            "deficiencies": sample["deficiencies"].copy(),
            "severity": sample["severity"].copy(),
        }

    def get_primary_labels(self) -> list[int]:
        """Get primary label for stratified splitting.

        Uses argmax of deficiency vector, or a special 'healthy' label.
        """
        labels = []
        for s in self.samples:
            if s["deficiencies"].sum() == 0:
                labels.append(self.num_nutrients)  # Healthy class
            else:
                labels.append(int(s["deficiencies"].argmax()))
        return labels

    def get_class_frequencies(self) -> np.ndarray:
        """Get per-nutrient positive sample frequency."""
        all_labels = np.stack([s["deficiencies"] for s in self.samples])
        return all_labels.mean(axis=0)

    def get_pos_weights(self) -> np.ndarray:
        """Compute positive class weights for BCEWithLogitsLoss."""
        freq = self.get_class_frequencies()
        pos_weight = np.where(freq > 0, (1 - freq) / freq, 1.0)
        return pos_weight.astype(np.float32)


def create_nutrient_train_val(
    root: str | Path,
    train_transform: Optional[Callable] = None,
    val_transform: Optional[Callable] = None,
    val_fraction: float = 0.15,
    random_seed: int = 42,
) -> tuple[Subset, Subset]:
    """Create training and validation datasets with stratified split."""
    full_train = NutrientDataset(root=root, transform=train_transform)
    full_val = NutrientDataset(root=root, transform=val_transform)

    primary_labels = full_train.get_primary_labels()

    splitter = StratifiedShuffleSplit(
        n_splits=1, test_size=val_fraction, random_state=random_seed
    )
    train_idx, val_idx = next(splitter.split(np.zeros(len(primary_labels)), primary_labels))

    return Subset(full_train, train_idx.tolist()), Subset(full_val, val_idx.tolist())
