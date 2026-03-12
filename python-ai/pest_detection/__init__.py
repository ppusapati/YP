"""
Pest Detection AI Module.

Detects agricultural pests from field/trap images using a MobileNetV3-based
multi-label classifier with bounding box regression for pest localization.
"""

from .model import PestDetectionModel, PEST_CLASSES, NUM_PEST_CLASSES
from .inference import PestDetector, PestDetectionResult, DetectedPest
from .dataset import PestDataset, create_pest_train_val
from .trainer import PestDetectionTrainer, PestTrainConfig
from .transforms import get_train_transforms, get_val_transforms

__all__ = [
    "PestDetectionModel",
    "PEST_CLASSES",
    "NUM_PEST_CLASSES",
    "PestDetector",
    "PestDetectionResult",
    "DetectedPest",
    "PestDataset",
    "create_pest_train_val",
    "PestDetectionTrainer",
    "PestTrainConfig",
    "get_train_transforms",
    "get_val_transforms",
]
