"""
Model export utilities for converting PyTorch models to ONNX format
for inference in the Rust inference engine.
"""

from __future__ import annotations

import logging
from pathlib import Path
from typing import Optional

import torch
import torch.nn as nn

logger = logging.getLogger(__name__)


def export_to_onnx(
    model: nn.Module,
    output_path: str | Path,
    input_shape: tuple[int, ...] = (1, 3, 224, 224),
    input_names: Optional[list[str]] = None,
    output_names: Optional[list[str]] = None,
    dynamic_axes: Optional[dict[str, dict[int, str]]] = None,
    opset_version: int = 17,
    simplify: bool = True,
) -> Path:
    """Export a PyTorch model to ONNX format.

    Args:
        model: PyTorch model to export.
        output_path: Path to save the ONNX model.
        input_shape: Shape of the dummy input tensor.
        input_names: Names for input tensors.
        output_names: Names for output tensors.
        dynamic_axes: Dynamic axes specification for variable-length dimensions.
        opset_version: ONNX opset version.
        simplify: Whether to simplify the ONNX model using onnx-simplifier.

    Returns:
        Path to the exported ONNX model.
    """
    output_path = Path(output_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    if input_names is None:
        input_names = ["input"]
    if output_names is None:
        output_names = ["output"]
    if dynamic_axes is None:
        dynamic_axes = {
            "input": {0: "batch_size"},
            "output": {0: "batch_size"},
        }

    model.eval()
    device = next(model.parameters()).device
    dummy_input = torch.randn(*input_shape, device=device)

    logger.info(f"Exporting model to ONNX: {output_path}")
    logger.info(f"  Input shape: {input_shape}")
    logger.info(f"  Opset version: {opset_version}")

    torch.onnx.export(
        model,
        dummy_input,
        str(output_path),
        input_names=input_names,
        output_names=output_names,
        dynamic_axes=dynamic_axes,
        opset_version=opset_version,
        do_constant_folding=True,
    )

    logger.info(f"ONNX model saved to {output_path}")

    # Validate the exported model
    _validate_onnx(output_path)

    # Optionally simplify
    if simplify:
        _simplify_onnx(output_path)

    return output_path


def _validate_onnx(model_path: Path) -> None:
    """Validate an ONNX model file."""
    try:
        import onnx

        model = onnx.load(str(model_path))
        onnx.checker.check_model(model)
        logger.info("ONNX model validation passed")
    except ImportError:
        logger.warning("onnx package not installed, skipping validation")
    except Exception as e:
        logger.error(f"ONNX validation failed: {e}")
        raise


def _simplify_onnx(model_path: Path) -> None:
    """Simplify an ONNX model to reduce graph complexity."""
    try:
        import onnx
        import onnxsim

        model = onnx.load(str(model_path))
        simplified_model, check = onnxsim.simplify(model)
        if check:
            onnx.save(simplified_model, str(model_path))
            logger.info("ONNX model simplified successfully")
        else:
            logger.warning("ONNX simplification check failed, keeping original")
    except ImportError:
        logger.warning("onnxsim not installed, skipping simplification")
    except Exception as e:
        logger.warning(f"ONNX simplification failed: {e}")


def export_classification_model(
    model: nn.Module,
    output_path: str | Path,
    image_size: int = 224,
    num_classes: int = 38,
    opset_version: int = 17,
) -> Path:
    """Export a classification model to ONNX.

    Args:
        model: Classification model.
        output_path: Path to save the ONNX model.
        image_size: Input image size (square).
        num_classes: Number of output classes.
        opset_version: ONNX opset version.

    Returns:
        Path to the exported ONNX model.
    """
    return export_to_onnx(
        model=model,
        output_path=output_path,
        input_shape=(1, 3, image_size, image_size),
        input_names=["image"],
        output_names=["logits"],
        dynamic_axes={
            "image": {0: "batch_size"},
            "logits": {0: "batch_size"},
        },
        opset_version=opset_version,
    )


def export_detection_model(
    model: nn.Module,
    output_path: str | Path,
    image_size: int = 640,
    opset_version: int = 17,
) -> Path:
    """Export an object detection model to ONNX.

    Args:
        model: Detection model.
        output_path: Path to save the ONNX model.
        image_size: Input image size (square).
        opset_version: ONNX opset version.

    Returns:
        Path to the exported ONNX model.
    """
    return export_to_onnx(
        model=model,
        output_path=output_path,
        input_shape=(1, 3, image_size, image_size),
        input_names=["image"],
        output_names=["boxes", "scores", "labels"],
        dynamic_axes={
            "image": {0: "batch_size"},
            "boxes": {0: "batch_size", 1: "num_detections"},
            "scores": {0: "batch_size", 1: "num_detections"},
            "labels": {0: "batch_size", 1: "num_detections"},
        },
        opset_version=opset_version,
    )


def export_segmentation_model(
    model: nn.Module,
    output_path: str | Path,
    image_size: int = 256,
    opset_version: int = 17,
) -> Path:
    """Export a segmentation model to ONNX.

    Args:
        model: Segmentation model.
        output_path: Path to save the ONNX model.
        image_size: Input image size (square).
        opset_version: ONNX opset version.

    Returns:
        Path to the exported ONNX model.
    """
    return export_to_onnx(
        model=model,
        output_path=output_path,
        input_shape=(1, 3, image_size, image_size),
        input_names=["image"],
        output_names=["classification", "segmentation_mask"],
        dynamic_axes={
            "image": {0: "batch_size"},
            "classification": {0: "batch_size"},
            "segmentation_mask": {0: "batch_size"},
        },
        opset_version=opset_version,
    )


def quantize_onnx_model(
    model_path: str | Path,
    output_path: Optional[str | Path] = None,
    quantization_type: str = "dynamic",
) -> Path:
    """Quantize an ONNX model for faster inference.

    Args:
        model_path: Path to input ONNX model.
        output_path: Path for quantized model. Defaults to appending '_quantized'.
        quantization_type: 'dynamic' or 'static'.

    Returns:
        Path to the quantized ONNX model.
    """
    model_path = Path(model_path)
    if output_path is None:
        output_path = model_path.with_stem(model_path.stem + "_quantized")
    else:
        output_path = Path(output_path)

    try:
        from onnxruntime.quantization import quantize_dynamic, quantize_static, QuantType

        if quantization_type == "dynamic":
            quantize_dynamic(
                model_input=str(model_path),
                model_output=str(output_path),
                weight_type=QuantType.QInt8,
            )
        else:
            logger.warning(
                "Static quantization requires a calibration dataset. "
                "Falling back to dynamic quantization."
            )
            quantize_dynamic(
                model_input=str(model_path),
                model_output=str(output_path),
                weight_type=QuantType.QInt8,
            )

        logger.info(f"Quantized model saved to {output_path}")
        return output_path

    except ImportError:
        logger.error("onnxruntime not installed, cannot quantize")
        raise
