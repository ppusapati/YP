"""Export a trained PyTorch model to ONNX format for deployment in the Rust
inference engines.

The exported model matches the input/output contract expected by the Rust
ModelBackend::Onnx variant: a single [batch, 3, H, W] float32 input tensor
and classification logits as the first output.
"""

import click
import numpy as np
import onnx
import onnxruntime as ort
import torch
import torch.nn as nn


def export_to_onnx(
    model: nn.Module,
    input_size: int,
    num_classes: int,
    output_path: str,
    opset: int = 17,
    dynamic_batch: bool = True,
    optimize: bool = True,
):
    """Export a PyTorch model to ONNX format.

    The Rust engines expect:
      - Input: "input" tensor of shape [batch, 3, input_size, input_size]
      - Output: "logits" tensor of shape [batch, num_classes]
    """
    model.eval()
    device = next(model.parameters()).device
    dummy = torch.randn(1, 3, input_size, input_size, device=device)

    dynamic_axes = {}
    if dynamic_batch:
        dynamic_axes = {
            "input": {0: "batch_size"},
            "logits": {0: "batch_size"},
        }

    torch.onnx.export(
        model,
        dummy,
        output_path,
        export_params=True,
        opset_version=opset,
        do_constant_folding=True,
        input_names=["input"],
        output_names=["logits"],
        dynamic_axes=dynamic_axes if dynamic_axes else None,
    )

    onnx_model = onnx.load(output_path)
    onnx.checker.check_model(onnx_model)

    if optimize:
        from onnxruntime.transformers import optimizer as ort_optimizer

        try:
            optimized = ort_optimizer.optimize_model(output_path)
            optimized.save_model_to_file(output_path)
        except Exception:
            pass

    _validate_onnx(output_path, input_size, num_classes)


def _validate_onnx(path: str, input_size: int, num_classes: int):
    """Validate that the exported ONNX model produces correct output shapes."""
    session = ort.InferenceSession(path)
    dummy_input = np.random.randn(1, 3, input_size, input_size).astype(np.float32)
    outputs = session.run(None, {"input": dummy_input})

    assert len(outputs) >= 1, "ONNX model must have at least one output"
    assert outputs[0].shape == (
        1,
        num_classes,
    ), f"Expected (1, {num_classes}), got {outputs[0].shape}"


@click.command()
@click.option("--checkpoint", required=True, type=click.Path(exists=True))
@click.option("--output", required=True, type=click.Path())
@click.option("--input-size", default=256, type=int)
@click.option("--opset", default=17, type=int)
def main(checkpoint: str, output: str, input_size: int, opset: int):
    """Export a checkpoint to ONNX."""
    from train import build_model

    ckpt = torch.load(checkpoint, weights_only=False)
    label_map = ckpt["label_map"]
    num_classes = len(label_map)
    architecture = ckpt.get("config", {}).get("architecture", "efficientnet_b0")

    model = build_model(architecture, num_classes)
    model.load_state_dict(ckpt["model_state_dict"])

    export_to_onnx(
        model=model,
        input_size=input_size,
        num_classes=num_classes,
        output_path=output,
        opset=opset,
    )
    click.echo(f"Exported {architecture} ({num_classes} classes) to {output}")


if __name__ == "__main__":
    main()
