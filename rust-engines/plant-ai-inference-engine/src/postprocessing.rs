//! Postprocessing of model inference outputs.

use serde::{Deserialize, Serialize};

/// A single classification output with class name and probability.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ClassificationOutput {
    /// Predicted class name.
    pub class_name: String,
    /// Prediction confidence (0.0 - 1.0).
    pub confidence: f32,
    /// Class index.
    pub class_index: usize,
    /// Top-K predictions.
    pub top_k: Vec<TopKResult>,
}

/// A single top-K prediction.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TopKResult {
    pub class_name: String,
    pub class_index: usize,
    pub probability: f32,
}

/// A detected bounding box (for object detection models).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DetectionBox {
    /// Top-left x coordinate (normalized 0-1).
    pub x1: f32,
    /// Top-left y coordinate (normalized 0-1).
    pub y1: f32,
    /// Bottom-right x coordinate (normalized 0-1).
    pub x2: f32,
    /// Bottom-right y coordinate (normalized 0-1).
    pub y2: f32,
    /// Detection confidence.
    pub confidence: f32,
    /// Class index.
    pub class_index: usize,
    /// Class name.
    pub class_name: String,
}

impl DetectionBox {
    /// Compute the area of the bounding box.
    pub fn area(&self) -> f32 {
        (self.x2 - self.x1).max(0.0) * (self.y2 - self.y1).max(0.0)
    }

    /// Compute IoU (Intersection over Union) with another box.
    pub fn iou(&self, other: &DetectionBox) -> f32 {
        let inter_x1 = self.x1.max(other.x1);
        let inter_y1 = self.y1.max(other.y1);
        let inter_x2 = self.x2.min(other.x2);
        let inter_y2 = self.y2.min(other.y2);

        let inter_area = (inter_x2 - inter_x1).max(0.0) * (inter_y2 - inter_y1).max(0.0);
        let union_area = self.area() + other.area() - inter_area;

        if union_area <= 0.0 {
            0.0
        } else {
            inter_area / union_area
        }
    }
}

/// Apply softmax to logits.
pub fn softmax(logits: &[f32]) -> Vec<f32> {
    if logits.is_empty() {
        return Vec::new();
    }

    let max_val = logits.iter().cloned().fold(f32::NEG_INFINITY, f32::max);
    let exp_values: Vec<f32> = logits.iter().map(|&x| (x - max_val).exp()).collect();
    let sum: f32 = exp_values.iter().sum();

    if sum <= 0.0 {
        return vec![1.0 / logits.len() as f32; logits.len()];
    }

    exp_values.iter().map(|&e| e / sum).collect()
}

/// Postprocess classification logits into a ClassificationOutput.
///
/// Applies softmax, extracts top-k predictions, and maps to class names.
pub fn postprocess_classification(
    logits: &[f32],
    class_names: &[String],
    top_k: usize,
) -> ClassificationOutput {
    let probs = softmax(logits);
    let k = top_k.min(probs.len());

    // Get top-k indices by sorting
    let mut indexed: Vec<(usize, f32)> = probs.iter().copied().enumerate().collect();
    indexed.sort_by(|a, b| b.1.partial_cmp(&a.1).unwrap_or(std::cmp::Ordering::Equal));

    let top_k_results: Vec<TopKResult> = indexed[..k]
        .iter()
        .map(|&(idx, prob)| {
            let name = class_names.get(idx).cloned().unwrap_or_else(|| format!("class_{idx}"));
            TopKResult {
                class_name: name,
                class_index: idx,
                probability: prob,
            }
        })
        .collect();

    let best_idx = indexed[0].0;
    let best_prob = indexed[0].1;
    let best_name = class_names
        .get(best_idx)
        .cloned()
        .unwrap_or_else(|| format!("class_{best_idx}"));

    ClassificationOutput {
        class_name: best_name,
        confidence: best_prob,
        class_index: best_idx,
        top_k: top_k_results,
    }
}

/// Apply Non-Maximum Suppression (NMS) to detection boxes.
pub fn nms(boxes: &mut Vec<DetectionBox>, iou_threshold: f32) {
    // Sort by confidence descending
    boxes.sort_by(|a, b| b.confidence.partial_cmp(&a.confidence).unwrap_or(std::cmp::Ordering::Equal));

    let mut keep = vec![true; boxes.len()];

    for i in 0..boxes.len() {
        if !keep[i] {
            continue;
        }
        for j in (i + 1)..boxes.len() {
            if !keep[j] {
                continue;
            }
            if boxes[i].iou(&boxes[j]) > iou_threshold {
                keep[j] = false;
            }
        }
    }

    let mut idx = 0;
    boxes.retain(|_| {
        let k = keep[idx];
        idx += 1;
        k
    });
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_softmax() {
        let logits = vec![1.0, 2.0, 3.0];
        let probs = softmax(&logits);
        assert_eq!(probs.len(), 3);
        let sum: f32 = probs.iter().sum();
        assert!((sum - 1.0).abs() < 1e-5);
        // Probabilities should be increasing
        assert!(probs[0] < probs[1]);
        assert!(probs[1] < probs[2]);
    }

    #[test]
    fn test_softmax_empty() {
        assert!(softmax(&[]).is_empty());
    }

    #[test]
    fn test_postprocess_classification() {
        let logits = vec![0.5, 2.0, 1.0, 0.1];
        let names: Vec<String> = vec!["A".into(), "B".into(), "C".into(), "D".into()];
        let result = postprocess_classification(&logits, &names, 3);
        assert_eq!(result.class_name, "B");
        assert_eq!(result.class_index, 1);
        assert_eq!(result.top_k.len(), 3);
        assert_eq!(result.top_k[0].class_name, "B");
    }

    #[test]
    fn test_detection_box_iou() {
        let a = DetectionBox {
            x1: 0.0, y1: 0.0, x2: 1.0, y2: 1.0,
            confidence: 0.9, class_index: 0, class_name: "A".into(),
        };
        let b = DetectionBox {
            x1: 0.5, y1: 0.5, x2: 1.5, y2: 1.5,
            confidence: 0.8, class_index: 0, class_name: "A".into(),
        };
        let iou = a.iou(&b);
        // Intersection = 0.5*0.5 = 0.25, Union = 1.0 + 1.0 - 0.25 = 1.75
        assert!((iou - 0.25 / 1.75).abs() < 1e-5);
    }

    #[test]
    fn test_detection_box_no_overlap() {
        let a = DetectionBox {
            x1: 0.0, y1: 0.0, x2: 0.5, y2: 0.5,
            confidence: 0.9, class_index: 0, class_name: "A".into(),
        };
        let b = DetectionBox {
            x1: 0.6, y1: 0.6, x2: 1.0, y2: 1.0,
            confidence: 0.8, class_index: 0, class_name: "A".into(),
        };
        assert!((a.iou(&b) - 0.0).abs() < 1e-5);
    }

    #[test]
    fn test_nms() {
        let mut boxes = vec![
            DetectionBox {
                x1: 0.0, y1: 0.0, x2: 1.0, y2: 1.0,
                confidence: 0.9, class_index: 0, class_name: "A".into(),
            },
            DetectionBox {
                x1: 0.1, y1: 0.1, x2: 1.0, y2: 1.0,
                confidence: 0.8, class_index: 0, class_name: "A".into(),
            },
            DetectionBox {
                x1: 5.0, y1: 5.0, x2: 6.0, y2: 6.0,
                confidence: 0.7, class_index: 0, class_name: "A".into(),
            },
        ];
        nms(&mut boxes, 0.5);
        // First two overlap heavily, so second should be suppressed
        assert_eq!(boxes.len(), 2);
        assert!((boxes[0].confidence - 0.9).abs() < 1e-5);
        assert!((boxes[1].confidence - 0.7).abs() < 1e-5);
    }
}
