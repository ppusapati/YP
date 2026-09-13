//! The ONNX file written by `export_to_onnx` must reproduce burn's forward
//! pass when loaded by the gateway's tract-based classifier. This guards the
//! weight layouts (Conv OIHW, Linear [in,out] with Gemm transB=0) and the
//! BatchNorm parameter order end to end.

use burn::prelude::*;
use burn_ndarray::NdArray;

use plant_ai_inference_engine::OnnxClassifier;
use yp_ml_training::export::export_to_onnx;
use yp_ml_training::model::{extract_weights, PlantCnn};

fn deterministic_input(size: usize) -> Vec<f32> {
    // Smooth, non-symmetric pattern so every conv filter sees structure.
    let mut v = Vec::with_capacity(3 * size * size);
    for c in 0..3 {
        for y in 0..size {
            for x in 0..size {
                let f = ((x as f32) * 0.37 + (y as f32) * 0.11 + c as f32).sin() * 1.5
                    + ((x * y) % 7) as f32 * 0.1
                    - 0.5;
                v.push(f);
            }
        }
    }
    v
}

#[test]
fn exported_onnx_matches_burn_forward() {
    let device = Default::default();
    let num_classes = 6;
    let size = 64;
    let model: PlantCnn<NdArray> = PlantCnn::new(num_classes, &device);

    // burn's Conv/Linear/BatchNorm init is random; the weights are what we export.
    let weights = extract_weights(&model);
    let dir = tempfile::tempdir().unwrap();
    let onnx_path = dir.path().join("model.onnx");
    export_to_onnx(&weights, size, num_classes, 17, &onnx_path).unwrap();

    let input = deterministic_input(size);
    let burn_logits: Vec<f32> = model
        .forward(
            Tensor::<NdArray, 1>::from_floats(input.as_slice(), &device)
                .reshape([1, 3, size, size]),
        )
        .into_data()
        .to_vec()
        .unwrap();
    assert_eq!(burn_logits.len(), num_classes);

    let labels: Vec<String> = (0..num_classes).map(|i| format!("class_{i}")).collect();
    let classifier = OnnxClassifier::from_bytes(
        &std::fs::read(&onnx_path).unwrap(),
        labels.clone(),
        "roundtrip",
    )
    .unwrap();
    assert_eq!(classifier.input_size() as usize, size);
    assert_eq!(classifier.num_classes(), num_classes);

    let tract_logits = classifier.classify_tensor(&input).unwrap();
    assert_eq!(tract_logits.len(), num_classes);

    let spread = burn_logits.iter().cloned().fold(f32::MIN, f32::max)
        - burn_logits.iter().cloned().fold(f32::MAX, f32::min);
    assert!(
        spread > 1e-4,
        "logits are degenerate ({burn_logits:?}); the test would pass vacuously"
    );

    for (i, (b, t)) in burn_logits.iter().zip(&tract_logits).enumerate() {
        assert!(
            (b - t).abs() < 1e-3,
            "logit {i}: burn {b} vs tract {t} (all burn {burn_logits:?}, tract {tract_logits:?})"
        );
    }
}

#[test]
fn load_dir_reads_training_meta_labels() {
    let device = Default::default();
    let model: PlantCnn<NdArray> = PlantCnn::new(3, &device);
    let dir = tempfile::tempdir().unwrap();
    export_to_onnx(
        &extract_weights(&model),
        32,
        3,
        17,
        &dir.path().join("model.onnx"),
    )
    .unwrap();
    std::fs::write(
        dir.path().join("training_meta.json"),
        r#"{"task":"disease","num_classes":3,"label_map":{"healthy":0,"rust":1,"blight":2}}"#,
    )
    .unwrap();
    std::fs::write(dir.path().join("version.txt"), "disease-v7\n").unwrap();

    let classifier = OnnxClassifier::load_dir(dir.path()).unwrap();
    assert_eq!(classifier.labels(), ["healthy", "rust", "blight"]);
    assert_eq!(classifier.version(), "disease-v7");
    assert_eq!(classifier.input_size(), 32);

    // A wrong label count must be rejected at load time, not at request time.
    std::fs::write(dir.path().join("labels.json"), r#"["a","b"]"#).unwrap();
    assert!(OnnxClassifier::load_dir(dir.path()).is_err());
}
