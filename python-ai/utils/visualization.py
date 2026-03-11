"""
Visualization utilities for agriculture AI models.

Provides functions to draw bounding boxes, heatmap overlays,
prediction labels, and confusion matrices on images.
"""

from __future__ import annotations

import cv2
import numpy as np
from typing import Optional


# Default color palette for classes (BGR format for OpenCV)
DEFAULT_PALETTE = [
    (76, 153, 0), (204, 51, 0), (0, 102, 204), (204, 153, 0),
    (128, 0, 128), (0, 153, 153), (204, 0, 102), (76, 76, 76),
    (0, 204, 102), (102, 0, 204), (204, 102, 0), (0, 51, 204),
    (153, 204, 0), (204, 0, 204), (0, 204, 204), (102, 102, 0),
    (204, 204, 0), (0, 0, 204), (102, 204, 0), (204, 0, 0),
]


def _get_color(class_id: int) -> tuple[int, int, int]:
    """Get a deterministic color for a class index."""
    return DEFAULT_PALETTE[class_id % len(DEFAULT_PALETTE)]


def draw_bounding_boxes(
    image: np.ndarray,
    boxes: np.ndarray,
    labels: Optional[list[str]] = None,
    scores: Optional[np.ndarray] = None,
    class_ids: Optional[np.ndarray] = None,
    thickness: int = 2,
    font_scale: float = 0.6,
    alpha: float = 0.3,
) -> np.ndarray:
    """Draw bounding boxes with labels and scores on an image.

    Args:
        image: Input image in BGR format, shape (H, W, 3), dtype uint8.
        boxes: Bounding boxes of shape (N, 4) in (x1, y1, x2, y2) format.
        labels: Optional list of label strings for each box.
        scores: Optional confidence scores of shape (N,).
        class_ids: Optional class indices of shape (N,) for color assignment.
        thickness: Box border thickness.
        font_scale: Font scale for labels.
        alpha: Opacity for filled label background.

    Returns:
        Annotated image copy.
    """
    result = image.copy()
    overlay = image.copy()

    if boxes is None or len(boxes) == 0:
        return result

    for i, box in enumerate(boxes):
        x1, y1, x2, y2 = int(box[0]), int(box[1]), int(box[2]), int(box[3])

        cid = int(class_ids[i]) if class_ids is not None else i
        color = _get_color(cid)

        # Draw filled rectangle for label background on overlay
        cv2.rectangle(overlay, (x1, y1), (x2, y2), color, thickness)

        # Build label text
        text_parts = []
        if labels is not None and i < len(labels):
            text_parts.append(labels[i])
        if scores is not None and i < len(scores):
            text_parts.append(f"{scores[i]:.2f}")
        text = " ".join(text_parts)

        if text:
            (text_w, text_h), baseline = cv2.getTextSize(
                text, cv2.FONT_HERSHEY_SIMPLEX, font_scale, 1
            )
            label_y1 = max(y1 - text_h - baseline - 4, 0)
            label_y2 = y1

            # Semi-transparent background for text
            cv2.rectangle(
                overlay,
                (x1, label_y1),
                (x1 + text_w + 4, label_y2),
                color,
                cv2.FILLED,
            )

    # Blend overlay
    cv2.addWeighted(overlay, alpha, result, 1 - alpha, 0, result)

    # Draw boxes and text on top (not blended)
    for i, box in enumerate(boxes):
        x1, y1, x2, y2 = int(box[0]), int(box[1]), int(box[2]), int(box[3])
        cid = int(class_ids[i]) if class_ids is not None else i
        color = _get_color(cid)

        cv2.rectangle(result, (x1, y1), (x2, y2), color, thickness)

        text_parts = []
        if labels is not None and i < len(labels):
            text_parts.append(labels[i])
        if scores is not None and i < len(scores):
            text_parts.append(f"{scores[i]:.2f}")
        text = " ".join(text_parts)

        if text:
            (text_w, text_h), baseline = cv2.getTextSize(
                text, cv2.FONT_HERSHEY_SIMPLEX, font_scale, 1
            )
            label_y1 = max(y1 - text_h - baseline - 4, 0)
            cv2.putText(
                result,
                text,
                (x1 + 2, y1 - baseline - 2),
                cv2.FONT_HERSHEY_SIMPLEX,
                font_scale,
                (255, 255, 255),
                2,
                cv2.LINE_AA,
            )

    return result


def draw_heatmap_overlay(
    image: np.ndarray,
    heatmap: np.ndarray,
    colormap: int = cv2.COLORMAP_JET,
    alpha: float = 0.5,
) -> np.ndarray:
    """Overlay a heatmap on an image.

    Args:
        image: Input image in BGR format, shape (H, W, 3), dtype uint8.
        heatmap: Heatmap of shape (H, W) with values in [0, 1].
        colormap: OpenCV colormap to apply.
        alpha: Blending factor (0 = only image, 1 = only heatmap).

    Returns:
        Image with heatmap overlay.
    """
    h, w = image.shape[:2]

    # Resize heatmap to match image if needed
    if heatmap.shape[:2] != (h, w):
        heatmap = cv2.resize(heatmap, (w, h), interpolation=cv2.INTER_LINEAR)

    # Convert to uint8 and apply colormap
    heatmap_uint8 = (heatmap * 255).clip(0, 255).astype(np.uint8)
    colored_heatmap = cv2.applyColorMap(heatmap_uint8, colormap)

    # Blend
    result = cv2.addWeighted(image, 1 - alpha, colored_heatmap, alpha, 0)
    return result


def draw_prediction_label(
    image: np.ndarray,
    label: str,
    confidence: float,
    position: str = "top-left",
    font_scale: float = 0.8,
    bg_color: tuple[int, int, int] = (0, 0, 0),
    text_color: tuple[int, int, int] = (255, 255, 255),
    padding: int = 8,
) -> np.ndarray:
    """Draw a prediction label with confidence score on an image.

    Args:
        image: Input image in BGR format.
        label: Prediction label text.
        confidence: Confidence score in [0, 1].
        position: Label position ('top-left', 'top-right', 'bottom-left', 'bottom-right').
        font_scale: Font scale.
        bg_color: Background color (BGR).
        text_color: Text color (BGR).
        padding: Padding around text.

    Returns:
        Annotated image copy.
    """
    result = image.copy()
    h, w = result.shape[:2]

    text = f"{label}: {confidence:.1%}"
    (text_w, text_h), baseline = cv2.getTextSize(
        text, cv2.FONT_HERSHEY_SIMPLEX, font_scale, 2
    )

    if position == "top-left":
        x, y = padding, padding + text_h + baseline
    elif position == "top-right":
        x, y = w - text_w - padding, padding + text_h + baseline
    elif position == "bottom-left":
        x, y = padding, h - padding
    elif position == "bottom-right":
        x, y = w - text_w - padding, h - padding
    else:
        x, y = padding, padding + text_h + baseline

    # Background rectangle
    cv2.rectangle(
        result,
        (x - padding, y - text_h - baseline - padding),
        (x + text_w + padding, y + padding),
        bg_color,
        cv2.FILLED,
    )

    # Text
    cv2.putText(
        result,
        text,
        (x, y),
        cv2.FONT_HERSHEY_SIMPLEX,
        font_scale,
        text_color,
        2,
        cv2.LINE_AA,
    )

    return result


def draw_segmentation_overlay(
    image: np.ndarray,
    mask: np.ndarray,
    color: tuple[int, int, int] = (0, 0, 255),
    alpha: float = 0.4,
    contour_thickness: int = 2,
) -> np.ndarray:
    """Draw a segmentation mask overlay on an image.

    Args:
        image: Input image in BGR format, shape (H, W, 3).
        mask: Binary mask of shape (H, W) with values 0 or 1.
        color: Overlay color (BGR).
        alpha: Blending factor.
        contour_thickness: Thickness of contour outline.

    Returns:
        Image with segmentation overlay.
    """
    result = image.copy()
    h, w = result.shape[:2]

    if mask.shape[:2] != (h, w):
        mask = cv2.resize(mask.astype(np.float32), (w, h), interpolation=cv2.INTER_LINEAR)
        mask = (mask > 0.5).astype(np.uint8)
    else:
        mask = mask.astype(np.uint8)

    # Create colored overlay
    overlay = result.copy()
    overlay[mask == 1] = color

    # Blend
    result = cv2.addWeighted(overlay, alpha, result, 1 - alpha, 0)

    # Draw contours
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    cv2.drawContours(result, contours, -1, color, contour_thickness)

    return result


def draw_disease_severity_bar(
    image: np.ndarray,
    severity: str,
    affected_percentage: float,
    bar_height: int = 30,
    bar_width_fraction: float = 0.8,
) -> np.ndarray:
    """Draw a severity indicator bar at the bottom of an image.

    Args:
        image: Input image in BGR format.
        severity: Severity level ('MILD', 'MODERATE', 'SEVERE', 'CRITICAL').
        affected_percentage: Percentage of affected area (0-100).
        bar_height: Height of the severity bar in pixels.
        bar_width_fraction: Fraction of image width for the bar.

    Returns:
        Image with severity bar appended at bottom.
    """
    h, w = image.shape[:2]
    bar_width = int(w * bar_width_fraction)
    bar_x_start = (w - bar_width) // 2

    severity_colors = {
        "MILD": (0, 200, 0),       # Green
        "MODERATE": (0, 200, 200),  # Yellow
        "SEVERE": (0, 100, 255),    # Orange
        "CRITICAL": (0, 0, 255),    # Red
    }
    color = severity_colors.get(severity, (128, 128, 128))

    # Extend image
    bar_section = np.zeros((bar_height + 20, w, 3), dtype=np.uint8)
    result = np.vstack([image, bar_section])

    # Draw background bar
    cv2.rectangle(
        result,
        (bar_x_start, h + 5),
        (bar_x_start + bar_width, h + 5 + bar_height),
        (60, 60, 60),
        cv2.FILLED,
    )

    # Draw filled portion
    fill_width = int(bar_width * affected_percentage / 100.0)
    cv2.rectangle(
        result,
        (bar_x_start, h + 5),
        (bar_x_start + fill_width, h + 5 + bar_height),
        color,
        cv2.FILLED,
    )

    # Draw text
    text = f"{severity} - {affected_percentage:.1f}% affected"
    cv2.putText(
        result,
        text,
        (bar_x_start + 5, h + 5 + bar_height - 8),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.5,
        (255, 255, 255),
        1,
        cv2.LINE_AA,
    )

    return result


def create_confusion_matrix_image(
    cm: np.ndarray,
    class_names: Optional[list[str]] = None,
    cell_size: int = 40,
    font_scale: float = 0.3,
) -> np.ndarray:
    """Create a visual confusion matrix image.

    Args:
        cm: Confusion matrix of shape (C, C).
        class_names: Optional list of class names.
        cell_size: Size of each cell in pixels.
        font_scale: Font scale for cell values.

    Returns:
        Confusion matrix as a BGR image.
    """
    num_classes = cm.shape[0]
    margin = 100 if class_names else 20

    img_h = num_classes * cell_size + margin
    img_w = num_classes * cell_size + margin
    img = np.ones((img_h, img_w, 3), dtype=np.uint8) * 255

    # Normalize for coloring
    cm_norm = cm.astype(np.float64)
    row_sums = cm_norm.sum(axis=1, keepdims=True)
    row_sums[row_sums == 0] = 1
    cm_norm = cm_norm / row_sums

    offset = margin

    for i in range(num_classes):
        for j in range(num_classes):
            x = offset + j * cell_size
            y = offset + i * cell_size

            # Color based on normalized value
            val = cm_norm[i, j]
            blue = int(255 * (1 - val))
            green = int(255 * (1 - val))
            red = 255
            color = (blue, green, red)

            cv2.rectangle(img, (x, y), (x + cell_size, y + cell_size), color, cv2.FILLED)
            cv2.rectangle(img, (x, y), (x + cell_size, y + cell_size), (200, 200, 200), 1)

            # Cell value
            text = str(int(cm[i, j]))
            (tw, th), _ = cv2.getTextSize(text, cv2.FONT_HERSHEY_SIMPLEX, font_scale, 1)
            tx = x + (cell_size - tw) // 2
            ty = y + (cell_size + th) // 2
            cv2.putText(
                img, text, (tx, ty),
                cv2.FONT_HERSHEY_SIMPLEX, font_scale,
                (0, 0, 0), 1, cv2.LINE_AA,
            )

    # Class names along axes
    if class_names:
        for i, name in enumerate(class_names):
            # Truncate long names
            display_name = name[:10] if len(name) > 10 else name

            # Y-axis (true labels)
            y_pos = offset + i * cell_size + cell_size // 2 + 4
            cv2.putText(
                img, display_name, (2, y_pos),
                cv2.FONT_HERSHEY_SIMPLEX, font_scale * 0.8,
                (0, 0, 0), 1, cv2.LINE_AA,
            )

            # X-axis (predicted labels) - rotated would be ideal but use horizontal
            x_pos = offset + i * cell_size + 2
            cv2.putText(
                img, display_name, (x_pos, offset - 5),
                cv2.FONT_HERSHEY_SIMPLEX, font_scale * 0.8,
                (0, 0, 0), 1, cv2.LINE_AA,
            )

    return img
