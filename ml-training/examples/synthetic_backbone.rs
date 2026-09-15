//! Write a tiny stand-in backbone ONNX file.
//!
//! Useful for exercising `yp-ml-training train-heads` end to end before a real
//! pretrained checkpoint is available:
//!
//! ```text
//! cargo run --example synthetic_backbone -- /tmp/backbone.onnx 32 32
//! yp-ml-training train-heads --backbone /tmp/backbone.onnx --tasks disease
//! ```
//!
//! The graph is Conv → Relu → GlobalAveragePool → Flatten (named `embedding`)
//! followed by a throwaway classifier, mirroring the shape of a real backbone.

use std::path::PathBuf;

use yp_ml_training::compose::synthetic::synthetic_backbone;

fn main() -> anyhow::Result<()> {
    let mut args = std::env::args().skip(1);
    let path: PathBuf = args
        .next()
        .unwrap_or_else(|| "backbone.onnx".to_string())
        .into();
    let input_size: i64 = args.next().unwrap_or_else(|| "32".into()).parse()?;
    let channels: usize = args.next().unwrap_or_else(|| "32".into()).parse()?;
    let tail_classes: usize = args.next().unwrap_or_else(|| "1000".into()).parse()?;

    let bytes = synthetic_backbone(input_size, channels, tail_classes);
    if let Some(parent) = path.parent() {
        if !parent.as_os_str().is_empty() {
            std::fs::create_dir_all(parent)?;
        }
    }
    std::fs::write(&path, &bytes)?;

    println!(
        "wrote {} ({} KB): {}x{} input, {}-d embedding tensor \"embedding\"",
        path.display(),
        bytes.len() / 1024,
        input_size,
        input_size,
        channels
    );
    Ok(())
}
