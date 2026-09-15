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

// ── Multi-task composition ───────────────────────────────────────────────────

/// A backbone plus trained heads must, once composed, compute exactly the
/// logits the heads were trained to produce — and the manifest written by the
/// trainer must be readable by the serving crate.
#[test]
fn composed_multitask_model_matches_the_heads_it_was_built_from() {
    use plant_ai_inference_engine::MultiTaskClassifier;
    use yp_ml_training::backbone::Backbone;
    use yp_ml_training::compose::{compose_multitask, synthetic::synthetic_backbone, HeadSpec};
    use yp_ml_training::config::BackboneConfig;

    let dir = tempfile::tempdir().unwrap();
    let backbone_path = dir.path().join("backbone.onnx");
    std::fs::write(&backbone_path, synthetic_backbone(32, 8, 1000)).unwrap();

    let backbone = Backbone::load(&BackboneConfig {
        path: backbone_path.display().to_string(),
        embedding_output: "embedding".into(),
        ..Default::default()
    })
    .unwrap();
    let dim = backbone.embedding_dim();
    assert_eq!(dim, 8);

    // Deterministic head weights so the expected logits can be computed by hand.
    let head = |task: &str, classes: usize, scale: f32| HeadSpec {
        task: task.to_string(),
        layers: vec![(
            (0..dim * classes)
                .map(|i| (i as f32 % 5.0 - 2.0) * scale)
                .collect(),
            (0..classes).map(|i| i as f32 * 0.1).collect(),
            dim,
            classes,
        )],
        labels: (0..classes).map(|i| format!("{task}_{i}")).collect(),
    };
    let heads = vec![head("disease", 3, 0.05), head("pest", 2, 0.08)];

    let model_dir = dir.path().join("multitask");
    let manifest = compose_multitask(&backbone, &heads, &model_dir).unwrap();
    assert_eq!(manifest.tasks.len(), 2);
    assert_eq!(manifest.input_size, 32);

    // The serving crate reads the trainer's manifest as written.
    let classifier = MultiTaskClassifier::load_dir(&model_dir).unwrap();
    assert_eq!(classifier.tasks(), vec!["disease", "pest"]);
    assert_eq!(classifier.num_classes("disease"), 3);
    assert!(classifier.has_task("pest"));
    assert!(!classifier.has_task("yield"));

    // A real image through both paths must agree.
    let image = image::RgbImage::from_fn(50, 44, |x, y| {
        image::Rgb([(x * 3) as u8, (y * 5 + 20) as u8, ((x ^ y) * 2) as u8])
    });
    let png = {
        let mut buf = std::io::Cursor::new(Vec::new());
        image::DynamicImage::ImageRgb8(image.clone())
            .write_to(&mut buf, image::ImageFormat::Png)
            .unwrap();
        buf.into_inner()
    };

    let embedding = backbone.embed_rgb(&image).unwrap();
    let logits = classifier
        .run(&classifier.preprocess(&png).unwrap())
        .unwrap();
    assert_eq!(logits.len(), 2);

    for (head, actual) in heads.iter().zip(&logits) {
        let (weight, bias, fan_in, fan_out) = &head.layers[0];
        assert_eq!(actual.len(), *fan_out);
        for out in 0..*fan_out {
            let expected: f32 = (0..*fan_in)
                .map(|i| embedding[i] * weight[i * fan_out + out])
                .sum::<f32>()
                + bias[out];
            assert!(
                (expected - actual[out]).abs() < 1e-3,
                "{} class {out}: expected {expected}, got {}",
                head.task,
                actual[out]
            );
        }
    }

    // Per-task classification reads the right slot and ranks the labels.
    let disease = classifier.classify_task("disease", &png, 3).unwrap();
    assert!(disease.class_name.starts_with("disease_"));
    assert_eq!(disease.top_k.len(), 3);
    let all = classifier.classify_image(&png, 1).unwrap();
    assert_eq!(all.len(), 2);
    assert_eq!(all["disease"].class_name, disease.class_name);
}

/// The int8 model shipped to phones must still agree with the float model it
/// was derived from, and must be substantially smaller.
#[test]
fn quantized_model_tracks_the_float_model() {
    use plant_ai_inference_engine::MultiTaskClassifier;
    use yp_ml_training::compose::{compose_bytes, synthetic::synthetic_backbone, HeadSpec};
    use yp_ml_training::quantize::{quantize_bytes, DEFAULT_MIN_ELEMENTS};

    let dim = 64;
    let classes = 4;
    let head = HeadSpec {
        task: "disease".into(),
        layers: vec![(
            (0..dim * classes)
                .map(|i| ((i % 13) as f32 - 6.0) * 0.03)
                .collect(),
            vec![0.0; classes],
            dim,
            classes,
        )],
        labels: (0..classes).map(|i| format!("class_{i}")).collect(),
    };
    let float_model = compose_bytes(
        &synthetic_backbone(32, dim, 500),
        "embedding",
        &[head.clone()],
        None,
    )
    .unwrap();
    let (int8_model, report) = quantize_bytes(&float_model, DEFAULT_MIN_ELEMENTS).unwrap();
    // The convolution weights dominate the file and are quantized; the small
    // head and every bias stay float, which is the intended trade.
    assert_eq!(report.tensors_quantized, 1, "{report:?}");
    assert!(report.tensors_kept_float >= 3, "{report:?}");
    assert!(
        report.size_reduction_pct() > 40.0,
        "expected a real size win, got {:.1}%",
        report.size_reduction_pct()
    );

    let manifest = serde_json::json!({
        "input_size": 32,
        "tasks": [{ "name": "disease", "output": "logits_disease", "labels": head.labels }],
    });
    let manifest: plant_ai_inference_engine::MultiTaskManifest =
        serde_json::from_value(manifest).unwrap();

    let float_clf =
        MultiTaskClassifier::from_bytes(&float_model, manifest.clone(), "float").unwrap();
    let int8_clf = MultiTaskClassifier::from_bytes(&int8_model, manifest, "int8").unwrap();

    let image = image::RgbImage::from_fn(40, 40, |x, y| {
        image::Rgb([(x * 6) as u8, (y * 6) as u8, 128])
    });
    let png = {
        let mut buf = std::io::Cursor::new(Vec::new());
        image::DynamicImage::ImageRgb8(image)
            .write_to(&mut buf, image::ImageFormat::Png)
            .unwrap();
        buf.into_inner()
    };
    let chw = float_clf.preprocess(&png).unwrap();
    let float_logits = &float_clf.run(&chw).unwrap()[0];
    let int8_logits = &int8_clf.run(&chw).unwrap()[0];

    let spread = float_logits.iter().cloned().fold(f32::MIN, f32::max)
        - float_logits.iter().cloned().fold(f32::MAX, f32::min);
    assert!(spread > 1e-3, "logits are degenerate: {float_logits:?}");

    for (i, (f, q)) in float_logits.iter().zip(int8_logits).enumerate() {
        assert!(
            (f - q).abs() < spread * 0.05,
            "logit {i} drifted too far under quantization: float {f}, int8 {q}"
        );
    }
    // The ranking a user sees must be unchanged.
    let argmax = |v: &[f32]| {
        v.iter()
            .enumerate()
            .fold(
                (0usize, f32::MIN),
                |a, (i, &x)| if x > a.1 { (i, x) } else { a },
            )
            .0
    };
    assert_eq!(argmax(float_logits), argmax(int8_logits));
}

// ── Explainability ───────────────────────────────────────────────────────────

/// Grad-CAM must explain the model that is actually serving. With a
/// non-negative single-layer head the rectifier is a no-op, which makes an
/// exact identity available: the mean of the raw map is the logit minus its
/// bias. If the heatmap were computed from anything other than the real
/// gradient, that identity would not hold.
#[test]
fn grad_cam_explains_the_prediction_it_accompanies() {
    use plant_ai_inference_engine::MultiTaskClassifier;
    use yp_ml_training::backbone::Backbone;
    use yp_ml_training::compose::{compose_multitask, synthetic::synthetic_backbone, HeadSpec};
    use yp_ml_training::config::BackboneConfig;

    let dir = tempfile::tempdir().unwrap();
    let backbone_path = dir.path().join("backbone.onnx");
    let (channels, classes, input_size) = (8usize, 3usize, 32i64);
    std::fs::write(
        &backbone_path,
        synthetic_backbone(input_size, channels, 100),
    )
    .unwrap();

    let backbone = Backbone::load(&BackboneConfig {
        path: backbone_path.display().to_string(),
        embedding_output: "embedding".into(),
        ..Default::default()
    })
    .unwrap();

    // The backbone convolves with padding and stride 1, so the feature map
    // keeps the input resolution.
    let fm = backbone.feature_map().unwrap();
    assert_eq!(fm.tensor, "relu_out");
    assert_eq!(fm.channels, channels);
    assert_eq!((fm.height, fm.width), (32, 32));

    // Non-negative weights, different per class so the maps must differ.
    let weights: Vec<f32> = (0..channels * classes)
        .map(|i| ((i % 5) as f32 + 1.0) * 0.1)
        .collect();
    let bias: Vec<f32> = (0..classes).map(|k| k as f32 * 0.25).collect();
    let head = HeadSpec {
        task: "disease".into(),
        layers: vec![(weights.clone(), bias.clone(), channels, classes)],
        labels: vec!["healthy".into(), "leaf_rust".into(), "blight".into()],
    };

    let model_dir = dir.path().join("multitask");
    let manifest = compose_multitask(&backbone, &[head], &model_dir).unwrap();
    let cam = manifest
        .cam
        .expect("an average-pooled backbone supports Grad-CAM");
    assert_eq!((cam.height, cam.width), (32, 32));
    assert_eq!(manifest.tasks[0].cam_output, "cam_disease");

    let classifier = MultiTaskClassifier::load_dir(&model_dir).unwrap();
    assert!(classifier.explains());
    assert!(classifier.explains_task("disease"));
    assert_eq!(classifier.cam_size(), Some((32, 32)));

    let png = {
        let image = image::RgbImage::from_fn(48, 40, |x, y| {
            image::Rgb([(x * 4) as u8, (y * 6 + 30) as u8, ((x + y) * 3) as u8])
        });
        let mut buf = std::io::Cursor::new(Vec::new());
        image::DynamicImage::ImageRgb8(image)
            .write_to(&mut buf, image::ImageFormat::Png)
            .unwrap();
        buf.into_inner()
    };

    let (output, heatmap) = classifier
        .classify_task_explained("disease", &png, 3)
        .unwrap();
    let heatmap = heatmap.expect("a CAM-composed model explains its answer");

    // The explanation is for the class the model chose.
    assert_eq!(heatmap.class_name, output.class_name);
    assert_eq!(heatmap.width * heatmap.height, 32 * 32);
    assert!(heatmap.localised);
    assert!((heatmap.values.iter().cloned().fold(0.0f32, f32::max) - 1.0).abs() < 1e-6);

    // The identity: mean of the raw map is the logit minus its bias.
    let logits = classifier
        .run(&classifier.preprocess(&png).unwrap())
        .unwrap();
    let k = heatmap.class_index;
    let mean_raw: f32 =
        heatmap.values.iter().map(|v| v * heatmap.peak).sum::<f32>() / heatmap.values.len() as f32;
    let expected = logits[0][k] - bias[k];
    assert!(
        (mean_raw - expected).abs() < 1e-3 * expected.abs().max(1.0),
        "mean raw CAM {mean_raw} should equal logit - bias {expected}"
    );

    // Grad-CAM is class-specific: asking about a different class must give a
    // different map, or it is a generic saliency blob rather than an
    // explanation of this answer.
    let other = (k + 1) % classes;
    let other_map = classifier.explain("disease", &png, Some(other)).unwrap();
    assert_eq!(other_map.class_index, other);
    let differences = heatmap
        .values
        .iter()
        .zip(&other_map.values)
        .filter(|(a, b)| (*a - *b).abs() > 1e-4)
        .count();
    assert!(
        differences > 0,
        "the map for class {other} is identical to the one for class {k}"
    );

    // And it renders for transport.
    let png_out = heatmap.resized(64, 64).to_png().unwrap();
    assert_eq!(&png_out[1..4], b"PNG");
    assert!(!heatmap.summary(0.5).is_empty());
}

/// A model composed without Grad-CAM must say so rather than inventing maps.
#[test]
fn a_model_without_cam_outputs_refuses_to_explain() {
    use plant_ai_inference_engine::{MultiTaskClassifier, MultiTaskManifest};
    use yp_ml_training::compose::{compose_bytes, synthetic::synthetic_backbone, HeadSpec};

    let (channels, classes) = (4usize, 2usize);
    let head = HeadSpec {
        task: "pest".into(),
        layers: vec![(
            (0..channels * classes).map(|i| i as f32 * 0.1).collect(),
            vec![0.0; classes],
            channels,
            classes,
        )],
        labels: vec!["none".into(), "aphid".into()],
    };
    let bytes = compose_bytes(
        &synthetic_backbone(32, channels, 50),
        "embedding",
        &[head],
        None,
    )
    .unwrap();

    let manifest: MultiTaskManifest = serde_json::from_value(serde_json::json!({
        "input_size": 32,
        "tasks": [{ "name": "pest", "output": "logits_pest", "labels": ["none", "aphid"] }],
    }))
    .unwrap();
    let classifier = MultiTaskClassifier::from_bytes(&bytes, manifest, "v1").unwrap();

    assert!(!classifier.explains());
    assert!(!classifier.explains_task("pest"));
    assert_eq!(classifier.cam_size(), None);

    let png = {
        let mut buf = std::io::Cursor::new(Vec::new());
        image::DynamicImage::ImageRgb8(image::RgbImage::new(8, 8))
            .write_to(&mut buf, image::ImageFormat::Png)
            .unwrap();
        buf.into_inner()
    };
    // Classification still works; only the explanation is absent.
    let (output, heatmap) = classifier.classify_task_explained("pest", &png, 2).unwrap();
    assert!(!output.class_name.is_empty());
    assert!(heatmap.is_none());

    let err = classifier
        .explain("pest", &png, None)
        .unwrap_err()
        .to_string();
    assert!(err.contains("no Grad-CAM output"), "{err}");
}
