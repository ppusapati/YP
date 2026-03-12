"""
Disease Detection AI Module.

Detects plant diseases from leaf images using an EfficientNet-B4-based
multi-task model with classification and segmentation heads.
"""

from .model import (
    DiseaseDetectionModel,
    DISEASE_CLASSES,
    NUM_DISEASE_CLASSES,
    CombinedLoss,
    DiceLoss,
    SqueezeExcitation,
    SegmentationDecoder,
    DecoderBlock,
)
from .inference import (
    DiseaseDetector,
    DiseaseDetectionResult,
    DiseaseResult,
)
from .dataset import DiseaseDataset, create_disease_train_val
from .trainer import DiseaseDetectionTrainer, DiseaseTrainConfig
from .transforms import get_train_transforms, get_val_transforms

__all__ = [
    "DiseaseDetectionModel",
    "DISEASE_CLASSES",
    "NUM_DISEASE_CLASSES",
    "CombinedLoss",
    "DiceLoss",
    "SqueezeExcitation",
    "SegmentationDecoder",
    "DecoderBlock",
    "DiseaseDetector",
    "DiseaseDetectionResult",
    "DiseaseResult",
    "DiseaseDataset",
    "create_disease_train_val",
    "DiseaseDetectionTrainer",
    "DiseaseTrainConfig",
    "get_train_transforms",
    "get_val_transforms",
]
