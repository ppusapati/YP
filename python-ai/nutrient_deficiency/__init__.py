"""
Nutrient Deficiency Detection AI Module.

Detects nutrient deficiencies (N, P, K, Ca, Mg, Fe, Zn, B) from plant leaf
images using a DenseNet-121-based multi-label classifier with per-nutrient
severity scoring.
"""

from .model import (
    NutrientDeficiencyModel,
    NutrientDeficiencyLoss,
    SeverityHead,
    NUTRIENT_DEFICIENCIES,
    NUM_NUTRIENTS,
    SEVERITY_LEVELS,
    NUM_SEVERITY,
    SUPPLEMENTATION_MAP,
)
from .inference import (
    NutrientAnalyzer,
    NutrientAnalysisResult,
    NutrientDeficiencyResult,
)
from .dataset import NutrientDataset, create_nutrient_train_val
from .trainer import NutrientDeficiencyTrainer, NutrientTrainConfig
from .transforms import get_train_transforms, get_val_transforms

__all__ = [
    "NutrientDeficiencyModel",
    "NutrientDeficiencyLoss",
    "SeverityHead",
    "NUTRIENT_DEFICIENCIES",
    "NUM_NUTRIENTS",
    "SEVERITY_LEVELS",
    "NUM_SEVERITY",
    "SUPPLEMENTATION_MAP",
    "NutrientAnalyzer",
    "NutrientAnalysisResult",
    "NutrientDeficiencyResult",
    "NutrientDataset",
    "create_nutrient_train_val",
    "NutrientDeficiencyTrainer",
    "NutrientTrainConfig",
    "get_train_transforms",
    "get_val_transforms",
]
