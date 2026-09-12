use burn::nn::conv::{Conv2d, Conv2dConfig};
use burn::nn::pool::{AdaptiveAvgPool2d, AdaptiveAvgPool2dConfig, MaxPool2d, MaxPool2dConfig};
use burn::nn::{BatchNorm, BatchNormConfig, Dropout, DropoutConfig, Linear, LinearConfig};
use burn::prelude::*;

/// A CNN classifier for plant image analysis.
///
/// Architecture:
///   conv_block(3→32) → conv_block(32→64) → conv_block(64→128) →
///   conv_block(128→256) → adaptive_avg_pool(1×1) → fc(256→512) →
///   relu → dropout → fc(512→num_classes)
///
/// Each conv_block: Conv2d(3×3) → BatchNorm → ReLU → MaxPool(2×2)
#[derive(Module, Debug)]
pub struct PlantCnn<B: Backend> {
    conv1: Conv2d<B>,
    bn1: BatchNorm<B, 2>,
    conv2: Conv2d<B>,
    bn2: BatchNorm<B, 2>,
    conv3: Conv2d<B>,
    bn3: BatchNorm<B, 2>,
    conv4: Conv2d<B>,
    bn4: BatchNorm<B, 2>,
    pool: MaxPool2d,
    gap: AdaptiveAvgPool2d,
    fc1: Linear<B>,
    fc2: Linear<B>,
    dropout: Dropout,
}

impl<B: Backend> PlantCnn<B> {
    pub fn new(num_classes: usize, device: &B::Device) -> Self {
        Self {
            conv1: Conv2dConfig::new([3, 32], [3, 3]).with_padding(burn::nn::PaddingConfig2d::Same).init(device),
            bn1: BatchNormConfig::new(32).init(device),
            conv2: Conv2dConfig::new([32, 64], [3, 3]).with_padding(burn::nn::PaddingConfig2d::Same).init(device),
            bn2: BatchNormConfig::new(64).init(device),
            conv3: Conv2dConfig::new([64, 128], [3, 3]).with_padding(burn::nn::PaddingConfig2d::Same).init(device),
            bn3: BatchNormConfig::new(128).init(device),
            conv4: Conv2dConfig::new([128, 256], [3, 3]).with_padding(burn::nn::PaddingConfig2d::Same).init(device),
            bn4: BatchNormConfig::new(256).init(device),
            pool: MaxPool2dConfig::new([2, 2]).with_strides([2, 2]).init(),
            gap: AdaptiveAvgPool2dConfig::new([1, 1]).init(),
            fc1: LinearConfig::new(256, 512).init(device),
            fc2: LinearConfig::new(512, num_classes).init(device),
            dropout: DropoutConfig::new(0.5).init(),
        }
    }

    pub fn forward(&self, x: Tensor<B, 4>) -> Tensor<B, 2> {
        let x = self.conv_block(x, &self.conv1, &self.bn1);
        let x = self.conv_block(x, &self.conv2, &self.bn2);
        let x = self.conv_block(x, &self.conv3, &self.bn3);
        let x = self.conv_block(x, &self.conv4, &self.bn4);

        let x = self.gap.forward(x);
        let [batch, channels, _, _] = x.dims();
        let x = x.reshape([batch, channels]);

        let x = self.fc1.forward(x);
        let x = burn::tensor::activation::relu(x);
        let x = self.dropout.forward(x);
        self.fc2.forward(x)
    }

    fn conv_block(
        &self,
        x: Tensor<B, 4>,
        conv: &Conv2d<B>,
        bn: &BatchNorm<B, 2>,
    ) -> Tensor<B, 4> {
        let x = conv.forward(x);
        let x = bn.forward(x);
        let x = burn::tensor::activation::relu(x);
        self.pool.forward(x)
    }

    pub fn _num_params(&self) -> usize {
        let conv_params = |c: &Conv2d<B>| {
            let w = c.weight.dims();
            w[0] * w[1] * w[2] * w[3]
        };
        conv_params(&self.conv1) + 32
            + conv_params(&self.conv2) + 64
            + conv_params(&self.conv3) + 128
            + conv_params(&self.conv4) + 256
            + 256 * 512 + 512
            + 512 * self.fc2.weight.dims()[0] + self.fc2.weight.dims()[0]
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use burn::tensor::Tensor;
    use burn_ndarray::NdArray;

    #[test]
    fn instantiate_model() {
        let device = Default::default();
        let _model: PlantCnn<NdArray> = PlantCnn::new(5, &device);
    }

    #[test]
    fn forward_output_shape() {
        let device = Default::default();
        let model: PlantCnn<NdArray> = PlantCnn::new(5, &device);
        let input = Tensor::<NdArray, 4>::zeros([2, 3, 64, 64], &device);
        let output = model.forward(input);
        assert_eq!(output.dims(), [2, 5]);
    }

    #[test]
    fn forward_single_sample() {
        let device = Default::default();
        let model: PlantCnn<NdArray> = PlantCnn::new(3, &device);
        let input = Tensor::<NdArray, 4>::zeros([1, 3, 64, 64], &device);
        let output = model.forward(input);
        assert_eq!(output.dims(), [1, 3]);
    }

    #[test]
    fn forward_different_num_classes() {
        let device = Default::default();
        let model: PlantCnn<NdArray> = PlantCnn::new(10, &device);
        let input = Tensor::<NdArray, 4>::zeros([1, 3, 64, 64], &device);
        let output = model.forward(input);
        assert_eq!(output.dims(), [1, 10]);
    }

    #[test]
    fn forward_larger_spatial_input() {
        let device = Default::default();
        let model: PlantCnn<NdArray> = PlantCnn::new(4, &device);
        // Adaptive avg pool handles varying spatial sizes
        let input = Tensor::<NdArray, 4>::zeros([2, 3, 128, 128], &device);
        let output = model.forward(input);
        assert_eq!(output.dims(), [2, 4]);
    }

    #[test]
    fn extract_weights_has_expected_keys() {
        let device = Default::default();
        let model: PlantCnn<NdArray> = PlantCnn::new(5, &device);
        let weights = extract_weights(&model);

        let names: Vec<&str> = weights.iter().map(|(n, _, _)| n.as_str()).collect();

        // Conv weights
        assert!(names.contains(&"conv1.weight"), "missing conv1.weight");
        assert!(names.contains(&"conv2.weight"), "missing conv2.weight");
        assert!(names.contains(&"conv3.weight"), "missing conv3.weight");
        assert!(names.contains(&"conv4.weight"), "missing conv4.weight");

        // Batch norm parameters (weight, bias, running_mean, running_var)
        for bn in &["bn1", "bn2", "bn3", "bn4"] {
            assert!(names.contains(&format!("{bn}.weight").as_str()), "missing {bn}.weight");
            assert!(names.contains(&format!("{bn}.bias").as_str()), "missing {bn}.bias");
            assert!(names.contains(&format!("{bn}.running_mean").as_str()), "missing {bn}.running_mean");
            assert!(names.contains(&format!("{bn}.running_var").as_str()), "missing {bn}.running_var");
        }

        // Fully connected layers
        assert!(names.contains(&"fc1.weight"), "missing fc1.weight");
        assert!(names.contains(&"fc2.weight"), "missing fc2.weight");
    }

    #[test]
    fn extract_weights_conv1_shape() {
        let device = Default::default();
        let model: PlantCnn<NdArray> = PlantCnn::new(5, &device);
        let weights = extract_weights(&model);

        let (_, dims, data) = weights.iter().find(|(n, _, _)| n == "conv1.weight").unwrap();
        // Conv1: 3 input channels -> 32 output channels, 3x3 kernel
        assert_eq!(dims, &[32, 3, 3, 3]);
        assert_eq!(data.len(), 32 * 3 * 3 * 3);
    }

    #[test]
    fn extract_weights_fc2_shape_matches_num_classes() {
        let device = Default::default();
        let model: PlantCnn<NdArray> = PlantCnn::new(7, &device);
        let weights = extract_weights(&model);

        let (_, dims, data) = weights.iter().find(|(n, _, _)| n == "fc2.weight").unwrap();
        // fc2: 512 -> num_classes
        assert_eq!(dims, &[7, 512]);
        assert_eq!(data.len(), 7 * 512);
    }
}

/// Extract named weight tensors from the model for ONNX export.
pub fn extract_weights<B: Backend>(model: &PlantCnn<B>) -> Vec<(String, Vec<usize>, Vec<f32>)> {
    let mut weights = Vec::new();

    let extract_conv = |name: &str, conv: &Conv2d<B>, w: &mut Vec<(String, Vec<usize>, Vec<f32>)>| {
        let weight = conv.weight.val();
        let dims: Vec<usize> = weight.dims().to_vec();
        let data: Vec<f32> = weight.into_data().to_vec().unwrap();
        w.push((format!("{name}.weight"), dims, data));
        if let Some(ref bias) = conv.bias {
            let b = bias.val();
            let bdims: Vec<usize> = b.dims().to_vec();
            let bdata: Vec<f32> = b.into_data().to_vec().unwrap();
            w.push((format!("{name}.bias"), bdims, bdata));
        }
    };

    let extract_bn = |name: &str, bn: &BatchNorm<B, 2>, w: &mut Vec<(String, Vec<usize>, Vec<f32>)>| {
        let gamma = bn.gamma.val();
        let beta = bn.beta.val();
        let running_mean = bn.running_mean.value();
        let running_var = bn.running_var.value();

        let g_dims: Vec<usize> = gamma.dims().to_vec();
        w.push((format!("{name}.weight"), g_dims.clone(), gamma.into_data().to_vec().unwrap()));
        w.push((format!("{name}.bias"), g_dims.clone(), beta.into_data().to_vec().unwrap()));
        w.push((format!("{name}.running_mean"), g_dims.clone(), running_mean.into_data().to_vec().unwrap()));
        w.push((format!("{name}.running_var"), g_dims, running_var.into_data().to_vec().unwrap()));
    };

    let extract_linear = |name: &str, linear: &Linear<B>, w: &mut Vec<(String, Vec<usize>, Vec<f32>)>| {
        let weight = linear.weight.val();
        let dims: Vec<usize> = weight.dims().to_vec();
        w.push((format!("{name}.weight"), dims, weight.into_data().to_vec().unwrap()));
        if let Some(ref bias) = linear.bias {
            let b = bias.val();
            let bdims: Vec<usize> = b.dims().to_vec();
            w.push((format!("{name}.bias"), bdims, b.into_data().to_vec().unwrap()));
        }
    };

    extract_conv("conv1", &model.conv1, &mut weights);
    extract_bn("bn1", &model.bn1, &mut weights);
    extract_conv("conv2", &model.conv2, &mut weights);
    extract_bn("bn2", &model.bn2, &mut weights);
    extract_conv("conv3", &model.conv3, &mut weights);
    extract_bn("bn3", &model.bn3, &mut weights);
    extract_conv("conv4", &model.conv4, &mut weights);
    extract_bn("bn4", &model.bn4, &mut weights);
    extract_linear("fc1", &model.fc1, &mut weights);
    extract_linear("fc2", &model.fc2, &mut weights);

    weights
}
