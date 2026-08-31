//! Non-Maximum Suppression for bounding box filtering.

use crate::types::BoundingBox;

/// Detection with class and score for NMS processing.
#[derive(Debug, Clone)]
pub struct Detection {
    pub bbox: BoundingBox,
    pub confidence: f32,
    pub class_index: usize,
}

/// Apply Non-Maximum Suppression to a set of detections.
///
/// Sorts by confidence descending, then suppresses overlapping boxes
/// with IoU above the threshold.
pub fn non_maximum_suppression(detections: &mut Vec<Detection>, iou_threshold: f32) {
    detections.sort_by(|a, b| {
        b.confidence
            .partial_cmp(&a.confidence)
            .unwrap_or(std::cmp::Ordering::Equal)
    });

    let mut keep = vec![true; detections.len()];

    for i in 0..detections.len() {
        if !keep[i] {
            continue;
        }
        for j in (i + 1)..detections.len() {
            if !keep[j] {
                continue;
            }
            if detections[i].bbox.iou(&detections[j].bbox) > iou_threshold {
                keep[j] = false;
            }
        }
    }

    let mut idx = 0;
    detections.retain(|_| {
        let k = keep[idx];
        idx += 1;
        k
    });
}

/// Apply class-aware NMS: only suppress boxes of the same class.
pub fn class_aware_nms(detections: &mut Vec<Detection>, iou_threshold: f32) {
    detections.sort_by(|a, b| {
        b.confidence
            .partial_cmp(&a.confidence)
            .unwrap_or(std::cmp::Ordering::Equal)
    });

    let mut keep = vec![true; detections.len()];

    for i in 0..detections.len() {
        if !keep[i] {
            continue;
        }
        for j in (i + 1)..detections.len() {
            if !keep[j] || detections[i].class_index != detections[j].class_index {
                continue;
            }
            if detections[i].bbox.iou(&detections[j].bbox) > iou_threshold {
                keep[j] = false;
            }
        }
    }

    let mut idx = 0;
    detections.retain(|_| {
        let k = keep[idx];
        idx += 1;
        k
    });
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_nms_suppresses_overlapping() {
        let mut detections = vec![
            Detection {
                bbox: BoundingBox { x1: 0.0, y1: 0.0, x2: 1.0, y2: 1.0 },
                confidence: 0.9,
                class_index: 0,
            },
            Detection {
                bbox: BoundingBox { x1: 0.1, y1: 0.1, x2: 1.0, y2: 1.0 },
                confidence: 0.8,
                class_index: 0,
            },
            Detection {
                bbox: BoundingBox { x1: 5.0, y1: 5.0, x2: 6.0, y2: 6.0 },
                confidence: 0.7,
                class_index: 0,
            },
        ];
        non_maximum_suppression(&mut detections, 0.5);
        assert_eq!(detections.len(), 2);
    }

    #[test]
    fn test_class_aware_nms() {
        let mut detections = vec![
            Detection {
                bbox: BoundingBox { x1: 0.0, y1: 0.0, x2: 1.0, y2: 1.0 },
                confidence: 0.9,
                class_index: 0,
            },
            Detection {
                bbox: BoundingBox { x1: 0.1, y1: 0.1, x2: 1.0, y2: 1.0 },
                confidence: 0.8,
                class_index: 1, // different class
            },
        ];
        class_aware_nms(&mut detections, 0.5);
        // Different classes should not suppress each other
        assert_eq!(detections.len(), 2);
    }
}
