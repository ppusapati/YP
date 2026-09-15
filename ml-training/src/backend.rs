//! Compute backend selection.
//!
//! CPU (`ndarray`) is the default so the trainer builds and runs anywhere.
//! Building with `--features cuda` or `--features wgpu` swaps in a GPU backend
//! without touching the training code; `cuda` wins when both are enabled.

/// Backend used for inference and weight extraction.
#[cfg(feature = "cuda")]
pub type Compute = burn::backend::CudaJit;
#[cfg(all(feature = "wgpu", not(feature = "cuda")))]
pub type Compute = burn::backend::Wgpu;
#[cfg(not(any(feature = "cuda", feature = "wgpu")))]
pub type Compute = burn_ndarray::NdArray;

/// Backend used for training (the inference backend plus autodiff).
pub type TrainBackend = burn_autodiff::Autodiff<Compute>;

/// Backend used for evaluation and export.
pub type InferBackend = Compute;

/// Name of the active backend, for logs and run metadata.
pub const NAME: &str = if cfg!(feature = "cuda") {
    "cuda"
} else if cfg!(feature = "wgpu") {
    "wgpu"
} else {
    "ndarray-cpu"
};

#[cfg(test)]
mod tests {
    use super::*;
    use burn::prelude::*;

    #[test]
    fn selected_backend_runs_a_tensor_op() {
        let device = <InferBackend as Backend>::Device::default();
        let t = Tensor::<InferBackend, 1>::from_floats([1.0, 2.0, 3.0], &device);
        let sum: f32 = t.sum().into_scalar().elem();
        assert_eq!(sum, 6.0);
        assert!(!NAME.is_empty());
    }
}
