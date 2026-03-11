"""
Metrics utilities for agriculture AI models.

Provides accuracy, precision, recall, F1, mAP, and IoU calculations
used across all modules (classification, detection, segmentation).
"""

from __future__ import annotations

import numpy as np
import torch
from typing import Optional


def accuracy(predictions: torch.Tensor, targets: torch.Tensor) -> float:
    """Compute top-1 accuracy for classification tasks.

    Args:
        predictions: Model logits or probabilities of shape (N, C).
        targets: Ground truth labels of shape (N,).

    Returns:
        Accuracy as a float in [0, 1].
    """
    if predictions.dim() == 2:
        pred_classes = predictions.argmax(dim=1)
    else:
        pred_classes = predictions
    correct = (pred_classes == targets).sum().item()
    return correct / targets.size(0) if targets.size(0) > 0 else 0.0


def top_k_accuracy(predictions: torch.Tensor, targets: torch.Tensor, k: int = 5) -> float:
    """Compute top-k accuracy for classification tasks.

    Args:
        predictions: Model logits or probabilities of shape (N, C).
        targets: Ground truth labels of shape (N,).
        k: Number of top predictions to consider.

    Returns:
        Top-k accuracy as a float in [0, 1].
    """
    if predictions.dim() == 1:
        predictions = predictions.unsqueeze(0)
    _, top_k_preds = predictions.topk(k, dim=1)
    targets_expanded = targets.unsqueeze(1).expand_as(top_k_preds)
    correct = (top_k_preds == targets_expanded).any(dim=1).sum().item()
    return correct / targets.size(0) if targets.size(0) > 0 else 0.0


def precision_recall_f1(
    predictions: torch.Tensor,
    targets: torch.Tensor,
    num_classes: int,
    average: str = "macro",
) -> tuple[float, float, float]:
    """Compute precision, recall, and F1 score.

    Args:
        predictions: Predicted class indices of shape (N,) or logits of shape (N, C).
        targets: Ground truth labels of shape (N,).
        num_classes: Total number of classes.
        average: Averaging method - 'macro', 'micro', or 'weighted'.

    Returns:
        Tuple of (precision, recall, f1) as floats in [0, 1].
    """
    if predictions.dim() == 2:
        predictions = predictions.argmax(dim=1)

    predictions = predictions.cpu().numpy()
    targets = targets.cpu().numpy()

    # Per-class true positives, false positives, false negatives
    tp = np.zeros(num_classes, dtype=np.float64)
    fp = np.zeros(num_classes, dtype=np.float64)
    fn = np.zeros(num_classes, dtype=np.float64)

    for c in range(num_classes):
        tp[c] = np.sum((predictions == c) & (targets == c))
        fp[c] = np.sum((predictions == c) & (targets != c))
        fn[c] = np.sum((predictions != c) & (targets == c))

    if average == "micro":
        total_tp = tp.sum()
        total_fp = fp.sum()
        total_fn = fn.sum()
        prec = total_tp / (total_tp + total_fp) if (total_tp + total_fp) > 0 else 0.0
        rec = total_tp / (total_tp + total_fn) if (total_tp + total_fn) > 0 else 0.0
        f1 = 2 * prec * rec / (prec + rec) if (prec + rec) > 0 else 0.0
        return prec, rec, f1

    # Per-class metrics
    per_class_prec = np.zeros(num_classes)
    per_class_rec = np.zeros(num_classes)
    per_class_f1 = np.zeros(num_classes)
    support = np.zeros(num_classes)

    for c in range(num_classes):
        support[c] = tp[c] + fn[c]
        per_class_prec[c] = tp[c] / (tp[c] + fp[c]) if (tp[c] + fp[c]) > 0 else 0.0
        per_class_rec[c] = tp[c] / (tp[c] + fn[c]) if (tp[c] + fn[c]) > 0 else 0.0
        if (per_class_prec[c] + per_class_rec[c]) > 0:
            per_class_f1[c] = (
                2 * per_class_prec[c] * per_class_rec[c] / (per_class_prec[c] + per_class_rec[c])
            )

    if average == "weighted":
        total_support = support.sum()
        if total_support > 0:
            weights = support / total_support
        else:
            weights = np.ones(num_classes) / num_classes
        prec = float(np.sum(per_class_prec * weights))
        rec = float(np.sum(per_class_rec * weights))
        f1 = float(np.sum(per_class_f1 * weights))
    else:  # macro
        # Only consider classes that appear in the targets
        active = support > 0
        if active.any():
            prec = float(per_class_prec[active].mean())
            rec = float(per_class_rec[active].mean())
            f1 = float(per_class_f1[active].mean())
        else:
            prec = rec = f1 = 0.0

    return prec, rec, f1


def confusion_matrix(
    predictions: torch.Tensor,
    targets: torch.Tensor,
    num_classes: int,
) -> np.ndarray:
    """Compute confusion matrix.

    Args:
        predictions: Predicted class indices of shape (N,) or logits of shape (N, C).
        targets: Ground truth labels of shape (N,).
        num_classes: Total number of classes.

    Returns:
        Confusion matrix of shape (num_classes, num_classes) where
        element [i, j] is the count of samples with true label i predicted as j.
    """
    if predictions.dim() == 2:
        predictions = predictions.argmax(dim=1)

    predictions = predictions.cpu().numpy().astype(int)
    targets = targets.cpu().numpy().astype(int)

    cm = np.zeros((num_classes, num_classes), dtype=np.int64)
    for t, p in zip(targets, predictions):
        if 0 <= t < num_classes and 0 <= p < num_classes:
            cm[t, p] += 1
    return cm


def intersection_over_union(
    boxes_a: torch.Tensor,
    boxes_b: torch.Tensor,
) -> torch.Tensor:
    """Compute IoU between two sets of bounding boxes.

    Args:
        boxes_a: Boxes of shape (N, 4) in (x1, y1, x2, y2) format.
        boxes_b: Boxes of shape (M, 4) in (x1, y1, x2, y2) format.

    Returns:
        IoU matrix of shape (N, M).
    """
    area_a = (boxes_a[:, 2] - boxes_a[:, 0]) * (boxes_a[:, 3] - boxes_a[:, 1])
    area_b = (boxes_b[:, 2] - boxes_b[:, 0]) * (boxes_b[:, 3] - boxes_b[:, 1])

    # Intersection
    inter_x1 = torch.max(boxes_a[:, 0].unsqueeze(1), boxes_b[:, 0].unsqueeze(0))
    inter_y1 = torch.max(boxes_a[:, 1].unsqueeze(1), boxes_b[:, 1].unsqueeze(0))
    inter_x2 = torch.min(boxes_a[:, 2].unsqueeze(1), boxes_b[:, 2].unsqueeze(0))
    inter_y2 = torch.min(boxes_a[:, 3].unsqueeze(1), boxes_b[:, 3].unsqueeze(0))

    inter_area = (inter_x2 - inter_x1).clamp(min=0) * (inter_y2 - inter_y1).clamp(min=0)

    union_area = area_a.unsqueeze(1) + area_b.unsqueeze(0) - inter_area

    return inter_area / (union_area + 1e-7)


def generalized_iou(
    boxes_a: torch.Tensor,
    boxes_b: torch.Tensor,
) -> torch.Tensor:
    """Compute Generalized IoU (GIoU) between two sets of bounding boxes.

    Args:
        boxes_a: Boxes of shape (N, 4) in (x1, y1, x2, y2) format.
        boxes_b: Boxes of shape (N, 4) in (x1, y1, x2, y2) format (paired).

    Returns:
        GIoU values of shape (N,).
    """
    area_a = (boxes_a[:, 2] - boxes_a[:, 0]) * (boxes_a[:, 3] - boxes_a[:, 1])
    area_b = (boxes_b[:, 2] - boxes_b[:, 0]) * (boxes_b[:, 3] - boxes_b[:, 1])

    inter_x1 = torch.max(boxes_a[:, 0], boxes_b[:, 0])
    inter_y1 = torch.max(boxes_a[:, 1], boxes_b[:, 1])
    inter_x2 = torch.min(boxes_a[:, 2], boxes_b[:, 2])
    inter_y2 = torch.min(boxes_a[:, 3], boxes_b[:, 3])

    inter_area = (inter_x2 - inter_x1).clamp(min=0) * (inter_y2 - inter_y1).clamp(min=0)
    union_area = area_a + area_b - inter_area
    iou = inter_area / (union_area + 1e-7)

    # Enclosing box
    enclose_x1 = torch.min(boxes_a[:, 0], boxes_b[:, 0])
    enclose_y1 = torch.min(boxes_a[:, 1], boxes_b[:, 1])
    enclose_x2 = torch.max(boxes_a[:, 2], boxes_b[:, 2])
    enclose_y2 = torch.max(boxes_a[:, 3], boxes_b[:, 3])

    enclose_area = (enclose_x2 - enclose_x1) * (enclose_y2 - enclose_y1)

    giou = iou - (enclose_area - union_area) / (enclose_area + 1e-7)
    return giou


def mean_average_precision(
    all_predictions: list[dict],
    all_targets: list[dict],
    iou_threshold: float = 0.5,
    num_classes: int = 102,
) -> tuple[float, dict[int, float]]:
    """Compute mean Average Precision (mAP) for object detection.

    Args:
        all_predictions: List of dicts per image, each with keys:
            'boxes' (N, 4), 'scores' (N,), 'labels' (N,).
        all_targets: List of dicts per image, each with keys:
            'boxes' (M, 4), 'labels' (M,).
        iou_threshold: IoU threshold for matching predictions to ground truth.
        num_classes: Total number of classes.

    Returns:
        Tuple of (mAP, per_class_ap_dict).
    """
    # Gather all predictions and ground truths per class
    class_predictions: dict[int, list[tuple[float, int, int]]] = {
        c: [] for c in range(num_classes)
    }
    class_num_gt: dict[int, int] = {c: 0 for c in range(num_classes)}
    gt_matched: dict[int, dict[int, list[bool]]] = {}

    for img_idx, (preds, targets) in enumerate(zip(all_predictions, all_targets)):
        gt_boxes = targets["boxes"]
        gt_labels = targets["labels"]

        gt_matched[img_idx] = {}
        for c in range(num_classes):
            mask = gt_labels == c
            count = mask.sum().item()
            class_num_gt[c] += count
            gt_matched[img_idx][c] = [False] * count

        if preds["boxes"].numel() == 0:
            continue

        pred_boxes = preds["boxes"]
        pred_scores = preds["scores"]
        pred_labels = preds["labels"]

        for p_idx in range(pred_boxes.size(0)):
            c = pred_labels[p_idx].item()
            score = pred_scores[p_idx].item()
            p_box = pred_boxes[p_idx].unsqueeze(0)

            gt_mask = gt_labels == c
            if gt_mask.sum() == 0:
                class_predictions[c].append((score, 0, img_idx))
                continue

            gt_class_boxes = gt_boxes[gt_mask]
            ious = intersection_over_union(p_box, gt_class_boxes).squeeze(0)
            best_iou, best_gt_idx = ious.max(dim=0)

            if best_iou.item() >= iou_threshold and not gt_matched[img_idx][c][best_gt_idx.item()]:
                class_predictions[c].append((score, 1, img_idx))
                gt_matched[img_idx][c][best_gt_idx.item()] = True
            else:
                class_predictions[c].append((score, 0, img_idx))

    # Compute AP per class
    per_class_ap: dict[int, float] = {}
    for c in range(num_classes):
        if class_num_gt[c] == 0:
            continue

        preds_sorted = sorted(class_predictions[c], key=lambda x: x[0], reverse=True)
        tp_cumsum = np.zeros(len(preds_sorted))
        fp_cumsum = np.zeros(len(preds_sorted))

        tp_count = 0
        fp_count = 0
        for i, (_, is_tp, _) in enumerate(preds_sorted):
            if is_tp:
                tp_count += 1
            else:
                fp_count += 1
            tp_cumsum[i] = tp_count
            fp_cumsum[i] = fp_count

        recall = tp_cumsum / class_num_gt[c]
        precision = tp_cumsum / (tp_cumsum + fp_cumsum + 1e-7)

        # 11-point interpolation
        ap = 0.0
        for t in np.arange(0.0, 1.1, 0.1):
            mask = recall >= t
            if mask.any():
                ap += precision[mask].max()
        ap /= 11.0
        per_class_ap[c] = ap

    map_score = float(np.mean(list(per_class_ap.values()))) if per_class_ap else 0.0
    return map_score, per_class_ap


def dice_coefficient(
    predictions: torch.Tensor,
    targets: torch.Tensor,
    smooth: float = 1e-6,
) -> torch.Tensor:
    """Compute Dice coefficient for segmentation.

    Args:
        predictions: Predicted mask probabilities of shape (N, H, W) or (N, C, H, W).
        targets: Ground truth masks of shape (N, H, W) or (N, C, H, W).
        smooth: Smoothing factor to avoid division by zero.

    Returns:
        Dice coefficient as a scalar tensor.
    """
    predictions = predictions.float().flatten(1)
    targets = targets.float().flatten(1)

    intersection = (predictions * targets).sum(dim=1)
    union = predictions.sum(dim=1) + targets.sum(dim=1)

    dice = (2.0 * intersection + smooth) / (union + smooth)
    return dice.mean()


def multilabel_accuracy(
    predictions: torch.Tensor,
    targets: torch.Tensor,
    threshold: float = 0.5,
) -> tuple[float, float, float, float]:
    """Compute metrics for multi-label classification.

    Args:
        predictions: Sigmoid probabilities of shape (N, C).
        targets: Binary labels of shape (N, C).
        threshold: Classification threshold.

    Returns:
        Tuple of (exact_match_ratio, sample_accuracy, sample_precision, sample_recall).
    """
    pred_binary = (predictions >= threshold).float()

    # Exact match ratio
    exact_match = (pred_binary == targets).all(dim=1).float().mean().item()

    # Per-sample accuracy, precision, recall
    intersection = (pred_binary * targets).sum(dim=1)
    union = ((pred_binary + targets) > 0).float().sum(dim=1)
    pred_sum = pred_binary.sum(dim=1)
    target_sum = targets.sum(dim=1)

    sample_acc = torch.where(
        union > 0, intersection / union, torch.ones_like(union)
    ).mean().item()

    sample_prec = torch.where(
        pred_sum > 0, intersection / pred_sum, torch.ones_like(pred_sum)
    ).mean().item()

    sample_rec = torch.where(
        target_sum > 0, intersection / target_sum, torch.ones_like(target_sum)
    ).mean().item()

    return exact_match, sample_acc, sample_prec, sample_rec
