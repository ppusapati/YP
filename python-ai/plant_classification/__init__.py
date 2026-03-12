"""
Plant Classification AI Module.

Classifies plant species and health states from leaf images using a
ResNet50-based model trained on the PlantVillage 38-class dataset.
"""

from .model import (
    PlantClassificationModel,
    PlantClassificationHead,
    PLANTVILLAGE_CLASSES,
    NUM_CLASSES,
)
from .inference import (
    PlantClassifier,
    ClassificationResult,
)
from .dataset import PlantVillageDataset, create_train_val_datasets
from .trainer import PlantClassificationTrainer, TrainConfig
from .transforms import get_train_transforms, get_val_transforms, get_tta_transforms

__all__ = [
    "PlantClassificationModel",
    "PlantClassificationHead",
    "PLANTVILLAGE_CLASSES",
    "NUM_CLASSES",
    "PlantClassifier",
    "ClassificationResult",
    "PlantVillageDataset",
    "create_train_val_datasets",
    "PlantClassificationTrainer",
    "TrainConfig",
    "get_train_transforms",
    "get_val_transforms",
    "get_tta_transforms",
]
