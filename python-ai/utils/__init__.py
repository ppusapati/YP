"""
Shared utilities for agriculture AI models.

Provides metrics, visualization, and model export functionality
used across all detection/classification modules.
"""

from .metrics import (
    accuracy,
    top_k_accuracy,
    precision_recall_f1,
    confusion_matrix,
    intersection_over_union,
    generalized_iou,
    mean_average_precision,
    dice_coefficient,
    multilabel_accuracy,
)
from .visualization import (
    draw_bounding_boxes,
    draw_heatmap_overlay,
    draw_prediction_label,
    draw_segmentation_overlay,
    draw_disease_severity_bar,
    create_confusion_matrix_image,
)
from .export import (
    export_to_onnx,
    export_classification_model,
    export_detection_model,
    export_segmentation_model,
    quantize_onnx_model,
)

__all__ = [
    # Metrics
    "accuracy",
    "top_k_accuracy",
    "precision_recall_f1",
    "confusion_matrix",
    "intersection_over_union",
    "generalized_iou",
    "mean_average_precision",
    "dice_coefficient",
    "multilabel_accuracy",
    # Visualization
    "draw_bounding_boxes",
    "draw_heatmap_overlay",
    "draw_prediction_label",
    "draw_segmentation_overlay",
    "draw_disease_severity_bar",
    "create_confusion_matrix_image",
    # Export
    "export_to_onnx",
    "export_classification_model",
    "export_detection_model",
    "export_segmentation_model",
    "quantize_onnx_model",
]
