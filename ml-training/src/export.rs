//! ONNX export by constructing the protobuf graph directly.
//!
//! Builds an ONNX ModelProto for the PlantCnn architecture using the trained
//! weights extracted from the burn model. The output matches the contract
//! expected by the Rust inference engines:
//!   Input:  "input"  — float32 [batch, 3, H, W]
//!   Output: "logits" — float32 [batch, num_classes]

use std::path::Path;

use prost::Message;

use crate::onnx_proto as onnx_pb;

use onnx_pb::*;

pub fn export_to_onnx(
    weights: &[(String, Vec<usize>, Vec<f32>)],
    input_size: usize,
    num_classes: usize,
    opset: i64,
    output_path: &Path,
) -> anyhow::Result<()> {
    let mut nodes = Vec::new();
    let mut initializers = Vec::new();

    for (name, dims, data) in weights {
        initializers.push(TensorProto::floats(name, dims, data));
    }

    let conv_blocks = [
        ("conv1", "bn1", 3, 32),
        ("conv2", "bn2", 32, 64),
        ("conv3", "bn3", 64, 128),
        ("conv4", "bn4", 128, 256),
    ];

    let mut current = "input".to_string();

    for (conv_name, bn_name, _in_ch, _out_ch) in &conv_blocks {
        let conv_out = format!("{conv_name}_out");
        nodes.push(make_conv_node(conv_name, &current, &conv_out));
        current = conv_out;

        let bn_out = format!("{bn_name}_out");
        nodes.push(make_bn_node(bn_name, &current, &bn_out));
        current = bn_out;

        let relu_out = format!("{conv_name}_relu_out");
        nodes.push(make_relu_node(
            &format!("{conv_name}_relu"),
            &current,
            &relu_out,
        ));
        current = relu_out;

        let pool_out = format!("{conv_name}_pool_out");
        nodes.push(make_maxpool_node(
            &format!("{conv_name}_pool"),
            &current,
            &pool_out,
        ));
        current = pool_out;
    }

    let gap_out = "gap_out".to_string();
    nodes.push(make_global_avg_pool_node("gap", &current, &gap_out));
    current = gap_out;

    let flatten_out = "flatten_out".to_string();
    nodes.push(make_flatten_node("flatten", &current, &flatten_out));
    current = flatten_out;

    let fc1_out = "fc1_out".to_string();
    nodes.push(make_gemm_node(
        "fc1_gemm",
        &current,
        "fc1.weight",
        "fc1.bias",
        &fc1_out,
    ));
    current = fc1_out;

    let fc1_relu_out = "fc1_relu_out".to_string();
    nodes.push(make_relu_node("fc1_relu", &current, &fc1_relu_out));
    current = fc1_relu_out;

    let logits = "logits".to_string();
    nodes.push(make_gemm_node(
        "fc2_gemm",
        &current,
        "fc2.weight",
        "fc2.bias",
        &logits,
    ));

    let graph = GraphProto {
        name: "plant_cnn".to_string(),
        node: nodes,
        initializer: initializers,
        input: vec![ValueInfoProto::float_tensor(
            "input",
            &[-1, 3, input_size as i64, input_size as i64],
        )],
        output: vec![ValueInfoProto::float_tensor(
            "logits",
            &[-1, num_classes as i64],
        )],
        ..Default::default()
    };

    let model = ModelProto {
        ir_version: 8,
        opset_import: vec![OperatorSetIdProto {
            domain: String::new(),
            version: opset,
        }],
        graph: Some(graph),
        producer_name: "yp-ml-training".to_string(),
        ..Default::default()
    };

    let mut buf = Vec::new();
    model.encode(&mut buf)?;

    if let Some(parent) = output_path.parent() {
        std::fs::create_dir_all(parent)?;
    }
    std::fs::write(output_path, &buf)?;

    tracing::info!(
        path = %output_path.display(),
        size_kb = buf.len() / 1024,
        "ONNX model exported"
    );

    Ok(())
}

fn make_conv_node(name: &str, input: &str, output: &str) -> NodeProto {
    NodeProto {
        attribute: vec![
            int_attr("group", 1),
            ints_attr("kernel_shape", &[3, 3]),
            ints_attr("pads", &[1, 1, 1, 1]),
            ints_attr("strides", &[1, 1]),
        ],
        ..onnx_pb::node(
            name,
            "Conv",
            &[input, &format!("{name}.weight"), &format!("{name}.bias")],
            &[output],
        )
    }
}

fn make_bn_node(name: &str, input: &str, output: &str) -> NodeProto {
    NodeProto {
        attribute: vec![float_attr("epsilon", 1e-5), float_attr("momentum", 0.1)],
        ..onnx_pb::node(
            name,
            "BatchNormalization",
            &[
                input,
                &format!("{name}.weight"),
                &format!("{name}.bias"),
                &format!("{name}.running_mean"),
                &format!("{name}.running_var"),
            ],
            &[output],
        )
    }
}

fn make_relu_node(name: &str, input: &str, output: &str) -> NodeProto {
    onnx_pb::node(name, "Relu", &[input], &[output])
}

fn make_maxpool_node(name: &str, input: &str, output: &str) -> NodeProto {
    NodeProto {
        attribute: vec![
            ints_attr("kernel_shape", &[2, 2]),
            ints_attr("strides", &[2, 2]),
        ],
        ..onnx_pb::node(name, "MaxPool", &[input], &[output])
    }
}

fn make_global_avg_pool_node(name: &str, input: &str, output: &str) -> NodeProto {
    onnx_pb::node(name, "GlobalAveragePool", &[input], &[output])
}

fn make_flatten_node(name: &str, input: &str, output: &str) -> NodeProto {
    NodeProto {
        attribute: vec![int_attr("axis", 1)],
        ..onnx_pb::node(name, "Flatten", &[input], &[output])
    }
}

fn make_gemm_node(name: &str, input: &str, weight: &str, bias: &str, output: &str) -> NodeProto {
    // burn's Linear stores weight as [in_features, out_features], which is
    // exactly Gemm's B operand when transB = 0 (Y = A[N,in] · B[in,out]).
    onnx_pb::gemm_node(name, input, weight, bias, output)
}

#[cfg(test)]
mod tests {
    use super::onnx_pb::*;
    use super::*;
    use prost::Message;

    #[test]
    fn model_proto_roundtrip() {
        let model = ModelProto {
            ir_version: 8,
            opset_import: vec![OperatorSetIdProto {
                domain: String::new(),
                version: 17,
            }],
            graph: Some(GraphProto {
                name: "test_graph".to_string(),
                ..Default::default()
            }),
            producer_name: "test-producer".to_string(),
            ..Default::default()
        };

        let mut buf = Vec::new();
        model.encode(&mut buf).unwrap();
        assert!(!buf.is_empty());

        let decoded = ModelProto::decode(buf.as_slice()).unwrap();
        assert_eq!(decoded.ir_version, 8);
        assert_eq!(decoded.producer_name, "test-producer");
        assert_eq!(decoded.opset_import.len(), 1);
        assert_eq!(decoded.opset_import[0].version, 17);
        assert_eq!(decoded.graph.unwrap().name, "test_graph");
    }

    #[test]
    fn make_tensor_encodes_floats() {
        let data = vec![1.0f32, 2.0, 3.0, 4.0, 5.0, 6.0];
        let tensor = TensorProto::floats("w", &[2, 3], &data);
        assert_eq!(tensor.name, "w");
        assert_eq!(tensor.dims, vec![2, 3]);
        assert_eq!(tensor.data_type, FLOAT);
        // 6 floats x 4 bytes each
        assert_eq!(tensor.raw_data.len(), 24);

        // Verify first float decodes back correctly
        let first = f32::from_le_bytes(tensor.raw_data[0..4].try_into().unwrap());
        assert_eq!(first, 1.0);
    }

    #[test]
    fn make_value_info_static_dims() {
        let vi = ValueInfoProto::float_tensor("input", &[1, 3, 64, 64]);
        assert_eq!(vi.name, "input");
        let shape = vi.r#type.unwrap().tensor_type.unwrap().shape.unwrap();
        assert_eq!(shape.dim.len(), 4);
        for (i, expected) in [1i64, 3, 64, 64].iter().enumerate() {
            match &shape.dim[i].value {
                Some(DimValue::DimValue(v)) => assert_eq!(v, expected),
                other => panic!("dim {i}: expected DimValue({expected}), got {other:?}"),
            }
        }
    }

    #[test]
    fn make_value_info_dynamic_batch() {
        let vi = ValueInfoProto::float_tensor("x", &[-1, 3, 64, 64]);
        let shape = vi.r#type.unwrap().tensor_type.unwrap().shape.unwrap();
        match &shape.dim[0].value {
            Some(DimValue::DimParam(s)) => assert_eq!(s, "batch"),
            other => panic!("expected DimParam(\"batch\"), got {other:?}"),
        }
        // Remaining dims are static
        match &shape.dim[1].value {
            Some(DimValue::DimValue(3)) => {}
            other => panic!("expected DimValue(3), got {other:?}"),
        }
    }

    #[test]
    fn export_to_onnx_writes_valid_file() {
        // Build minimal weight set matching PlantCnn architecture
        let weights: Vec<(String, Vec<usize>, Vec<f32>)> = vec![
            (
                "conv1.weight".into(),
                vec![32, 3, 3, 3],
                vec![0.0; 32 * 3 * 3 * 3],
            ),
            ("conv1.bias".into(), vec![32], vec![0.0; 32]),
            ("bn1.weight".into(), vec![32], vec![1.0; 32]),
            ("bn1.bias".into(), vec![32], vec![0.0; 32]),
            ("bn1.running_mean".into(), vec![32], vec![0.0; 32]),
            ("bn1.running_var".into(), vec![32], vec![1.0; 32]),
            (
                "conv2.weight".into(),
                vec![64, 32, 3, 3],
                vec![0.0; 64 * 32 * 3 * 3],
            ),
            ("conv2.bias".into(), vec![64], vec![0.0; 64]),
            ("bn2.weight".into(), vec![64], vec![1.0; 64]),
            ("bn2.bias".into(), vec![64], vec![0.0; 64]),
            ("bn2.running_mean".into(), vec![64], vec![0.0; 64]),
            ("bn2.running_var".into(), vec![64], vec![1.0; 64]),
            (
                "conv3.weight".into(),
                vec![128, 64, 3, 3],
                vec![0.0; 128 * 64 * 3 * 3],
            ),
            ("conv3.bias".into(), vec![128], vec![0.0; 128]),
            ("bn3.weight".into(), vec![128], vec![1.0; 128]),
            ("bn3.bias".into(), vec![128], vec![0.0; 128]),
            ("bn3.running_mean".into(), vec![128], vec![0.0; 128]),
            ("bn3.running_var".into(), vec![128], vec![1.0; 128]),
            (
                "conv4.weight".into(),
                vec![256, 128, 3, 3],
                vec![0.0; 256 * 128 * 3 * 3],
            ),
            ("conv4.bias".into(), vec![256], vec![0.0; 256]),
            ("bn4.weight".into(), vec![256], vec![1.0; 256]),
            ("bn4.bias".into(), vec![256], vec![0.0; 256]),
            ("bn4.running_mean".into(), vec![256], vec![0.0; 256]),
            ("bn4.running_var".into(), vec![256], vec![1.0; 256]),
            ("fc1.weight".into(), vec![256, 512], vec![0.0; 256 * 512]),
            ("fc1.bias".into(), vec![512], vec![0.0; 512]),
            ("fc2.weight".into(), vec![512, 5], vec![0.0; 512 * 5]),
            ("fc2.bias".into(), vec![5], vec![0.0; 5]),
        ];

        let dir = std::env::temp_dir().join("yp_test_export");
        let _ = std::fs::create_dir_all(&dir);
        let output_path = dir.join("test_model.onnx");

        export_to_onnx(&weights, 64, 5, 17, &output_path).unwrap();

        let data = std::fs::read(&output_path).unwrap();
        assert!(!data.is_empty());

        let model = ModelProto::decode(data.as_slice()).unwrap();
        assert_eq!(model.ir_version, 8);
        assert_eq!(model.producer_name, "yp-ml-training");
        assert_eq!(model.opset_import[0].version, 17);

        let graph = model.graph.unwrap();
        assert_eq!(graph.name, "plant_cnn");
        assert_eq!(graph.input.len(), 1);
        assert_eq!(graph.input[0].name, "input");
        assert_eq!(graph.output.len(), 1);
        assert_eq!(graph.output[0].name, "logits");

        // Should have nodes: 4*(conv+bn+relu+pool) + gap + flatten + fc1_gemm + fc1_relu + fc2_gemm
        assert_eq!(graph.node.len(), 4 * 4 + 5);

        // Initializers for all weight tensors
        assert_eq!(graph.initializer.len(), weights.len());

        let _ = std::fs::remove_dir_all(&dir);
    }

    #[test]
    fn export_graph_node_types() {
        let weights: Vec<(String, Vec<usize>, Vec<f32>)> = vec![
            (
                "conv1.weight".into(),
                vec![32, 3, 3, 3],
                vec![0.0; 32 * 3 * 3 * 3],
            ),
            ("conv1.bias".into(), vec![32], vec![0.0; 32]),
            ("bn1.weight".into(), vec![32], vec![1.0; 32]),
            ("bn1.bias".into(), vec![32], vec![0.0; 32]),
            ("bn1.running_mean".into(), vec![32], vec![0.0; 32]),
            ("bn1.running_var".into(), vec![32], vec![1.0; 32]),
            (
                "conv2.weight".into(),
                vec![64, 32, 3, 3],
                vec![0.0; 64 * 32 * 3 * 3],
            ),
            ("conv2.bias".into(), vec![64], vec![0.0; 64]),
            ("bn2.weight".into(), vec![64], vec![1.0; 64]),
            ("bn2.bias".into(), vec![64], vec![0.0; 64]),
            ("bn2.running_mean".into(), vec![64], vec![0.0; 64]),
            ("bn2.running_var".into(), vec![64], vec![1.0; 64]),
            (
                "conv3.weight".into(),
                vec![128, 64, 3, 3],
                vec![0.0; 128 * 64 * 3 * 3],
            ),
            ("conv3.bias".into(), vec![128], vec![0.0; 128]),
            ("bn3.weight".into(), vec![128], vec![1.0; 128]),
            ("bn3.bias".into(), vec![128], vec![0.0; 128]),
            ("bn3.running_mean".into(), vec![128], vec![0.0; 128]),
            ("bn3.running_var".into(), vec![128], vec![1.0; 128]),
            (
                "conv4.weight".into(),
                vec![256, 128, 3, 3],
                vec![0.0; 256 * 128 * 3 * 3],
            ),
            ("conv4.bias".into(), vec![256], vec![0.0; 256]),
            ("bn4.weight".into(), vec![256], vec![1.0; 256]),
            ("bn4.bias".into(), vec![256], vec![0.0; 256]),
            ("bn4.running_mean".into(), vec![256], vec![0.0; 256]),
            ("bn4.running_var".into(), vec![256], vec![1.0; 256]),
            ("fc1.weight".into(), vec![256, 512], vec![0.0; 256 * 512]),
            ("fc1.bias".into(), vec![512], vec![0.0; 512]),
            ("fc2.weight".into(), vec![512, 3], vec![0.0; 512 * 3]),
            ("fc2.bias".into(), vec![3], vec![0.0; 3]),
        ];

        let dir = std::env::temp_dir().join("yp_test_export_nodes");
        let _ = std::fs::create_dir_all(&dir);
        let output_path = dir.join("model.onnx");

        export_to_onnx(&weights, 32, 3, 13, &output_path).unwrap();

        let data = std::fs::read(&output_path).unwrap();
        let model = ModelProto::decode(data.as_slice()).unwrap();
        let graph = model.graph.unwrap();

        let op_types: Vec<&str> = graph.node.iter().map(|n| n.op_type.as_str()).collect();
        assert_eq!(op_types.iter().filter(|&&t| t == "Conv").count(), 4);
        assert_eq!(
            op_types
                .iter()
                .filter(|&&t| t == "BatchNormalization")
                .count(),
            4
        );
        assert_eq!(op_types.iter().filter(|&&t| t == "Relu").count(), 5); // 4 conv + 1 fc1
        assert_eq!(op_types.iter().filter(|&&t| t == "MaxPool").count(), 4);
        assert_eq!(
            op_types
                .iter()
                .filter(|&&t| t == "GlobalAveragePool")
                .count(),
            1
        );
        assert_eq!(op_types.iter().filter(|&&t| t == "Flatten").count(), 1);
        assert_eq!(op_types.iter().filter(|&&t| t == "Gemm").count(), 2);

        let _ = std::fs::remove_dir_all(&dir);
    }
}
