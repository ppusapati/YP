"""Dataset loader for training data collected by the AI gateway.

Reads the manifest.jsonl files produced by the data collector, loads images
and their associated labels, and provides PyTorch Dataset/DataLoader objects
for training.
"""

import json
import os
from pathlib import Path
from typing import Optional

import albumentations as A
import numpy as np
import torch
from albumentations.pytorch import ToTensorV2
from PIL import Image
from sklearn.model_selection import train_test_split
from torch.utils.data import DataLoader, Dataset


class PlantDataset(Dataset):
    """PyTorch dataset backed by the gateway's collected training samples."""

    def __init__(
        self,
        samples: list[dict],
        label_to_idx: dict[str, int],
        transform=None,
        input_size: int = 256,
    ):
        self.samples = samples
        self.label_to_idx = label_to_idx
        self.input_size = input_size
        self.transform = transform or self._default_transform()

    def _default_transform(self):
        return A.Compose(
            [
                A.Resize(self.input_size, self.input_size),
                A.Normalize(
                    mean=[0.485, 0.456, 0.406],
                    std=[0.229, 0.224, 0.225],
                ),
                ToTensorV2(),
            ]
        )

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        sample = self.samples[idx]
        image_path = sample["image"]
        primary_label = sample["labels"][0] if sample["labels"] else "unknown"
        label_idx = self.label_to_idx.get(primary_label, 0)

        img = Image.open(image_path).convert("RGB")
        img_np = np.array(img)

        transformed = self.transform(image=img_np)
        tensor = transformed["image"]

        return tensor, label_idx


def get_train_augmentation(input_size: int, config: dict) -> A.Compose:
    aug_cfg = config.get("augmentation", {})
    return A.Compose(
        [
            A.RandomResizedCrop(
                height=input_size,
                width=input_size,
                scale=tuple(aug_cfg.get("random_crop_scale", [0.8, 1.0])),
            ),
            A.HorizontalFlip(p=0.5 if aug_cfg.get("horizontal_flip", True) else 0),
            A.VerticalFlip(p=0.5 if aug_cfg.get("vertical_flip", False) else 0),
            A.Rotate(limit=aug_cfg.get("rotation_limit", 30), p=0.5),
            A.RandomBrightnessContrast(
                brightness_limit=aug_cfg.get("brightness_limit", 0.2),
                contrast_limit=aug_cfg.get("contrast_limit", 0.2),
                p=0.5,
            ),
            A.HueSaturationValue(
                hue_shift_limit=aug_cfg.get("hue_shift_limit", 10),
                p=0.3,
            ),
            A.Normalize(
                mean=[0.485, 0.456, 0.406],
                std=[0.229, 0.224, 0.225],
            ),
            ToTensorV2(),
        ]
    )


def get_val_transform(input_size: int) -> A.Compose:
    return A.Compose(
        [
            A.Resize(input_size, input_size),
            A.Normalize(
                mean=[0.485, 0.456, 0.406],
                std=[0.229, 0.224, 0.225],
            ),
            ToTensorV2(),
        ]
    )


def load_manifest(task_dir: Path, min_confidence: float = 0.7) -> list[dict]:
    """Load and filter samples from the manifest file."""
    manifest_path = task_dir / "manifest.jsonl"
    if not manifest_path.exists():
        raise FileNotFoundError(f"No manifest found at {manifest_path}")

    samples = []
    with open(manifest_path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            entry = json.loads(line)
            if not os.path.exists(entry["image"]):
                continue

            label_path = task_dir / "labels" / f"{entry['id']}.json"
            if label_path.exists():
                with open(label_path) as lf:
                    label_data = json.load(lf)
                    if label_data.get("labels"):
                        top = label_data["labels"][0]
                        if top.get("confidence", 0) >= min_confidence:
                            samples.append(
                                {
                                    "id": entry["id"],
                                    "image": entry["image"],
                                    "labels": [
                                        l["name"] for l in label_data["labels"]
                                    ],
                                    "confidence": top["confidence"],
                                }
                            )

    return samples


def build_label_map(samples: list[dict], min_per_class: int = 20) -> dict[str, int]:
    """Build label-to-index mapping, filtering out rare classes."""
    from collections import Counter

    counts = Counter(s["labels"][0] for s in samples if s["labels"])
    valid = {label for label, cnt in counts.items() if cnt >= min_per_class}
    return {label: idx for idx, label in enumerate(sorted(valid))}


def create_dataloaders(
    task: str,
    config: dict,
    base_dir: Optional[str] = None,
) -> tuple[DataLoader, DataLoader, DataLoader, dict[str, int]]:
    """Create train/val/test dataloaders for a given task."""
    data_cfg = config["data"]
    task_cfg = config["tasks"][task]
    base = Path(base_dir or data_cfg["base_dir"])
    task_dir = base / task

    min_conf = data_cfg.get("min_confidence_threshold", 0.7)
    samples = load_manifest(task_dir, min_confidence=min_conf)

    min_per_class = data_cfg.get("min_samples_per_class", 20)
    label_map = build_label_map(samples, min_per_class=min_per_class)
    samples = [s for s in samples if s["labels"][0] in label_map]

    if not samples:
        raise ValueError(f"No valid samples for task '{task}' after filtering")

    train_val, test = train_test_split(
        samples,
        test_size=data_cfg.get("test_split", 0.1),
        random_state=42,
        stratify=[s["labels"][0] for s in samples],
    )
    val_frac = data_cfg.get("val_split", 0.1) / (1 - data_cfg.get("test_split", 0.1))
    train, val = train_test_split(
        train_val,
        test_size=val_frac,
        random_state=42,
        stratify=[s["labels"][0] for s in train_val],
    )

    input_size = task_cfg.get("input_size", 256)
    train_aug = get_train_augmentation(input_size, config)
    val_tfm = get_val_transform(input_size)

    train_ds = PlantDataset(train, label_map, transform=train_aug, input_size=input_size)
    val_ds = PlantDataset(val, label_map, transform=val_tfm, input_size=input_size)
    test_ds = PlantDataset(test, label_map, transform=val_tfm, input_size=input_size)

    batch_size = task_cfg.get("batch_size", 32)
    train_loader = DataLoader(
        train_ds, batch_size=batch_size, shuffle=True, num_workers=4, pin_memory=True
    )
    val_loader = DataLoader(
        val_ds, batch_size=batch_size, shuffle=False, num_workers=4, pin_memory=True
    )
    test_loader = DataLoader(
        test_ds, batch_size=batch_size, shuffle=False, num_workers=4, pin_memory=True
    )

    return train_loader, val_loader, test_loader, label_map
