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

/// GradCAM heatmap result for model interpretability.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GradCAMResult {
    /// Heatmap values (normalized 0-1), shape is (height, width).
    pub heatmap: Vec<Vec<f32>>,
    /// Width of the heatmap.
    pub width: usize,
    /// Height of the heatmap.
    pub height: usize,
    /// Target class index the heatmap was generated for.
    pub target_class: usize,
    /// Target class name.
    pub target_class_name: String,
}

impl GradCAMResult {
    /// Get the heatmap value at a pixel coordinate.
    pub fn at(&self, row: usize, col: usize) -> f32 {
        if row < self.height && col < self.width {
            self.heatmap[row][col]
        } else {
            0.0
        }
    }

    /// Find the coordinates of the maximum activation.
    pub fn max_activation_point(&self) -> (usize, usize, f32) {
        let mut max_val = f32::NEG_INFINITY;
        let mut max_row = 0;
        let mut max_col = 0;
        for (r, row) in self.heatmap.iter().enumerate() {
            for (c, &val) in row.iter().enumerate() {
                if val > max_val {
                    max_val = val;
                    max_row = r;
                    max_col = c;
                }
            }
        }
        (max_row, max_col, max_val)
    }

    /// Get a bounding box around the region of high activation.
    ///
    /// Returns (x1, y1, x2, y2) normalized to 0-1 range.
    pub fn activation_bbox(&self, threshold: f32) -> Option<(f32, f32, f32, f32)> {
        let mut min_r = self.height;
        let mut max_r = 0usize;
        let mut min_c = self.width;
        let mut max_c = 0usize;
        let mut found = false;

        for (r, row) in self.heatmap.iter().enumerate() {
            for (c, &val) in row.iter().enumerate() {
                if val >= threshold {
                    min_r = min_r.min(r);
                    max_r = max_r.max(r);
                    min_c = min_c.min(c);
                    max_c = max_c.max(c);
                    found = true;
                }
            }
        }

        if !found || self.width == 0 || self.height == 0 {
            return None;
        }

        Some((
            min_c as f32 / self.width as f32,
            min_r as f32 / self.height as f32,
            (max_c + 1) as f32 / self.width as f32,
            (max_r + 1) as f32 / self.height as f32,
        ))
    }
}

/// Generate a simulated GradCAM heatmap from model logits and input features.
///
/// This is a simplified GradCAM approximation that uses the gradient of the
/// target class logit with respect to spatial features. In production, this
/// would use actual model gradients from the last convolutional layer.
///
/// # Arguments
/// * `logits` - Model output logits
/// * `feature_map` - Flattened spatial feature activations from last conv layer
/// * `feature_map_size` - (height, width) of the feature map
/// * `target_class` - Class index to generate heatmap for
/// * `class_names` - Class name lookup
pub fn generate_gradcam(
    logits: &[f32],
    feature_map: &[f32],
    feature_map_size: (usize, usize),
    target_class: usize,
    class_names: &[String],
) -> GradCAMResult {
    let (fh, fw) = feature_map_size;
    let num_spatial = fh * fw;

    // Compute importance weights using gradient approximation.
    // In a real implementation, we'd compute d(logit_c) / d(feature_map)
    // and then GAP (global average pooling) the gradients.
    // Here we use feature activation magnitude as an approximation.
    let target_logit = logits.get(target_class).copied().unwrap_or(0.0);

    // Build the heatmap by computing weighted combination of feature activations
    let num_channels = if num_spatial > 0 { feature_map.len() / num_spatial } else { 0 };
    let num_channels = num_channels.max(1);

    let mut heatmap = vec![vec![0.0f32; fw]; fh];

    if num_spatial > 0 && !feature_map.is_empty() {
        // For each spatial location, sum weighted activations across channels
        for ch in 0..num_channels.min(feature_map.len() / num_spatial.max(1)) {
            // Weight approximation: use the target logit magnitude as a proxy
            let weight = target_logit / num_channels as f32;
            for r in 0..fh {
                for c in 0..fw {
                    let idx = ch * num_spatial + r * fw + c;
                    if idx < feature_map.len() {
                        heatmap[r][c] += weight * feature_map[idx];
                    }
                }
            }
        }

        // Apply ReLU (only positive contributions)
        for row in heatmap.iter_mut() {
            for val in row.iter_mut() {
                *val = val.max(0.0);
            }
        }

        // Normalize to 0-1
        let max_val = heatmap.iter().flat_map(|r| r.iter()).cloned().fold(0.0f32, f32::max);
        if max_val > 1e-8 {
            for row in heatmap.iter_mut() {
                for val in row.iter_mut() {
                    *val /= max_val;
                }
            }
        }
    }

    let class_name = class_names
        .get(target_class)
        .cloned()
        .unwrap_or_else(|| format!("class_{target_class}"));

    GradCAMResult {
        heatmap,
        width: fw,
        height: fh,
        target_class,
        target_class_name: class_name,
    }
}

/// Filter classification results by confidence threshold.
pub fn filter_by_confidence(
    results: &[ClassificationOutput],
    threshold: f32,
) -> Vec<&ClassificationOutput> {
    results
        .iter()
        .filter(|r| r.confidence >= threshold)
        .collect()
}

/// Extract top-K classes from logits above a confidence threshold.
pub fn top_k_above_threshold(
    logits: &[f32],
    class_names: &[String],
    k: usize,
    threshold: f32,
) -> Vec<TopKResult> {
    let probs = softmax(logits);
    let mut indexed: Vec<(usize, f32)> = probs.iter().copied().enumerate().collect();
    indexed.sort_by(|a, b| b.1.partial_cmp(&a.1).unwrap_or(std::cmp::Ordering::Equal));

    indexed
        .into_iter()
        .take(k)
        .filter(|(_, prob)| *prob >= threshold)
        .map(|(idx, prob)| {
            let name = class_names
                .get(idx)
                .cloned()
                .unwrap_or_else(|| format!("class_{idx}"));
            TopKResult {
                class_name: name,
                class_index: idx,
                probability: prob,
            }
        })
        .collect()
}

/// Map raw class indices to human-readable labels.
pub fn map_class_labels(
    predictions: &[ClassificationOutput],
    label_map: &std::collections::HashMap<usize, String>,
) -> Vec<ClassificationOutput> {
    predictions
        .iter()
        .map(|pred| {
            let class_name = label_map
                .get(&pred.class_index)
                .cloned()
                .unwrap_or_else(|| pred.class_name.clone());

            let top_k = pred
                .top_k
                .iter()
                .map(|tk| TopKResult {
                    class_name: label_map
                        .get(&tk.class_index)
                        .cloned()
                        .unwrap_or_else(|| tk.class_name.clone()),
                    class_index: tk.class_index,
                    probability: tk.probability,
                })
                .collect();

            ClassificationOutput {
                class_name,
                confidence: pred.confidence,
                class_index: pred.class_index,
                top_k,
            }
        })
        .collect()
}

/// Extract detection boxes from a raw output tensor.
///
/// Assumes YOLO-style output format: each detection has
/// [x_center, y_center, width, height, objectness, class_scores...].
pub fn extract_detections(
    raw_output: &[f32],
    num_classes: usize,
    confidence_threshold: f32,
    class_names: &[String],
) -> Vec<DetectionBox> {
    let detection_size = 5 + num_classes; // x, y, w, h, obj, classes...
    if raw_output.len() < detection_size {
        return Vec::new();
    }

    let num_detections = raw_output.len() / detection_size;
    let mut boxes = Vec::new();

    for i in 0..num_detections {
        let offset = i * detection_size;
        if offset + detection_size > raw_output.len() {
            break;
        }

        let cx = raw_output[offset];
        let cy = raw_output[offset + 1];
        let w = raw_output[offset + 2];
        let h = raw_output[offset + 3];
        let objectness = raw_output[offset + 4];

        if objectness < confidence_threshold {
            continue;
        }

        // Find best class
        let class_scores = &raw_output[offset + 5..offset + detection_size];
        let (best_class, &best_score) = class_scores
            .iter()
            .enumerate()
            .max_by(|a, b| a.1.partial_cmp(b.1).unwrap_or(std::cmp::Ordering::Equal))
            .unwrap_or((0, &0.0));

        let confidence = objectness * best_score;
        if confidence < confidence_threshold {
            continue;
        }

        let class_name = class_names
            .get(best_class)
            .cloned()
            .unwrap_or_else(|| format!("class_{best_class}"));

        boxes.push(DetectionBox {
            x1: (cx - w / 2.0).clamp(0.0, 1.0),
            y1: (cy - h / 2.0).clamp(0.0, 1.0),
            x2: (cx + w / 2.0).clamp(0.0, 1.0),
            y2: (cy + h / 2.0).clamp(0.0, 1.0),
            confidence,
            class_index: best_class,
            class_name,
        });
    }

    boxes
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
    fn test_gradcam() {
        let logits = vec![0.1, 2.0, 0.5];
        let feature_map = vec![
            0.1, 0.2, 0.3, 0.4, // channel 0, 2x2
            0.5, 0.6, 0.7, 0.8, // channel 1, 2x2
        ];
        let names = vec!["A".into(), "B".into(), "C".into()];
        let result = generate_gradcam(&logits, &feature_map, (2, 2), 1, &names);
        assert_eq!(result.width, 2);
        assert_eq!(result.height, 2);
        assert_eq!(result.target_class, 1);
        assert_eq!(result.target_class_name, "B");
        // Check heatmap is normalized to 0-1
        let max_val = result.heatmap.iter().flat_map(|r| r.iter()).cloned().fold(0.0f32, f32::max);
        assert!(max_val <= 1.0 + 1e-6);
    }

    #[test]
    fn test_gradcam_max_activation() {
        let logits = vec![1.0, 3.0];
        let feature_map = vec![0.1, 0.9, 0.2, 0.3]; // 2x2, 1 channel
        let names = vec!["A".into(), "B".into()];
        let result = generate_gradcam(&logits, &feature_map, (2, 2), 1, &names);
        let (_, max_col, _) = result.max_activation_point();
        assert_eq!(max_col, 1); // Column 1 has the highest activation (0.9)
    }

    #[test]
    fn test_gradcam_activation_bbox() {
        let logits = vec![1.0];
        // Create a 4x4 feature map with high values in the center
        let mut fm = vec![0.0f32; 16];
        fm[5] = 1.0; fm[6] = 1.0;
        fm[9] = 1.0; fm[10] = 1.0;
        let result = generate_gradcam(&logits, &fm, (4, 4), 0, &["A".into()]);
        let bbox = result.activation_bbox(0.5);
        assert!(bbox.is_some());
    }

    #[test]
    fn test_top_k_above_threshold() {
        let logits = vec![0.5, 5.0, 1.0, 0.1];
        let names: Vec<String> = vec!["A".into(), "B".into(), "C".into(), "D".into()];
        let results = top_k_above_threshold(&logits, &names, 3, 0.1);
        assert!(!results.is_empty());
        assert_eq!(results[0].class_name, "B");
    }

    #[test]
    fn test_extract_detections() {
        // Format: cx, cy, w, h, objectness, class0, class1
        let raw = vec![
            0.5, 0.5, 0.2, 0.2, 0.9, 0.1, 0.9, // high conf detection
            0.3, 0.3, 0.1, 0.1, 0.1, 0.5, 0.5, // low objectness
        ];
        let names = vec!["cat".into(), "dog".into()];
        let detections = extract_detections(&raw, 2, 0.5, &names);
        assert_eq!(detections.len(), 1);
        assert_eq!(detections[0].class_name, "dog");
        assert!(detections[0].confidence > 0.5);
    }

    #[test]
    fn test_filter_by_confidence() {
        let results = vec![
            postprocess_classification(&[5.0, 0.1], &["A".into(), "B".into()], 2),
            postprocess_classification(&[0.1, 0.1], &["A".into(), "B".into()], 2),
        ];
        let filtered = filter_by_confidence(&results, 0.9);
        assert_eq!(filtered.len(), 1);
    }

    #[test]
    fn test_map_class_labels() {
        let results = vec![
            postprocess_classification(&[5.0, 0.1], &["0".into(), "1".into()], 2),
        ];
        let mut label_map = std::collections::HashMap::new();
        label_map.insert(0, "Healthy".to_string());
        label_map.insert(1, "Diseased".to_string());
        let mapped = map_class_labels(&results, &label_map);
        assert_eq!(mapped[0].class_name, "Healthy");
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
