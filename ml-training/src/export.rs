//! ONNX export by constructing the protobuf graph directly.
//!
//! Builds an ONNX ModelProto for the PlantCnn architecture using the trained
//! weights extracted from the burn model. The output matches the contract
//! expected by the Rust inference engines:
//!   Input:  "input"  — float32 [batch, 3, H, W]
//!   Output: "logits" — float32 [batch, num_classes]

use std::path::Path;

use prost::Message;

mod onnx_pb {
    #[derive(Clone, PartialEq, prost::Message)]
    pub struct ModelProto {
        #[prost(int64, tag = "1")]
        pub ir_version: i64,
        #[prost(message, repeated, tag = "8")]
        pub opset_import: Vec<OperatorSetIdProto>,
        #[prost(message, optional, tag = "7")]
        pub graph: Option<GraphProto>,
        #[prost(string, tag = "5")]
        pub producer_name: String,
    }

    #[derive(Clone, PartialEq, prost::Message)]
    pub struct OperatorSetIdProto {
        #[prost(string, tag = "1")]
        pub domain: String,
        #[prost(int64, tag = "2")]
        pub version: i64,
    }

    #[derive(Clone, PartialEq, prost::Message)]
    pub struct GraphProto {
        #[prost(message, repeated, tag = "1")]
        pub node: Vec<NodeProto>,
        #[prost(string, tag = "2")]
        pub name: String,
        #[prost(message, repeated, tag = "5")]
        pub initializer: Vec<TensorProto>,
        #[prost(message, repeated, tag = "11")]
        pub input: Vec<ValueInfoProto>,
        #[prost(message, repeated, tag = "12")]
        pub output: Vec<ValueInfoProto>,
    }

    #[derive(Clone, PartialEq, prost::Message)]
    pub struct NodeProto {
        #[prost(string, repeated, tag = "1")]
        pub input: Vec<String>,
        #[prost(string, repeated, tag = "2")]
        pub output: Vec<String>,
        #[prost(string, tag = "3")]
        pub name: String,
        #[prost(string, tag = "4")]
        pub op_type: String,
        #[prost(message, repeated, tag = "5")]
        pub attribute: Vec<AttributeProto>,
    }

    #[derive(Clone, PartialEq, prost::Message)]
    pub struct AttributeProto {
        #[prost(string, tag = "1")]
        pub name: String,
        #[prost(int32, tag = "20")]
        pub r#type: i32,
        #[prost(float, tag = "4")]
        pub f: f32,
        #[prost(int64, tag = "3")]
        pub i: i64,
        #[prost(float, repeated, tag = "7")]
        pub floats: Vec<f32>,
        #[prost(int64, repeated, tag = "8")]
        pub ints: Vec<i64>,
    }

    #[derive(Clone, PartialEq, prost::Message)]
    pub struct TensorProto {
        #[prost(int64, repeated, tag = "1")]
        pub dims: Vec<i64>,
        #[prost(int32, tag = "2")]
        pub data_type: i32,
        #[prost(string, tag = "8")]
        pub name: String,
        #[prost(bytes, tag = "13")]
        pub raw_data: Vec<u8>,
    }

    #[derive(Clone, PartialEq, prost::Message)]
    pub struct ValueInfoProto {
        #[prost(string, tag = "1")]
        pub name: String,
        #[prost(message, optional, tag = "2")]
        pub r#type: Option<TypeProto>,
    }

    #[derive(Clone, PartialEq, prost::Message)]
    pub struct TypeProto {
        #[prost(message, optional, tag = "1")]
        pub tensor_type: Option<TensorTypeProto>,
    }

    #[derive(Clone, PartialEq, prost::Message)]
    pub struct TensorTypeProto {
        #[prost(int32, tag = "1")]
        pub elem_type: i32,
        #[prost(message, optional, tag = "2")]
        pub shape: Option<TensorShapeProto>,
    }

    #[derive(Clone, PartialEq, prost::Message)]
    pub struct TensorShapeProto {
        #[prost(message, repeated, tag = "1")]
        pub dim: Vec<Dimension>,
    }

    #[derive(Clone, PartialEq, prost::Message)]
    pub struct Dimension {
        #[prost(oneof = "DimValue", tags = "1, 2")]
        pub value: Option<DimValue>,
    }

    #[derive(Clone, PartialEq, prost::Oneof)]
    pub enum DimValue {
        #[prost(int64, tag = "1")]
        DimValue(i64),
        #[prost(string, tag = "2")]
        DimParam(String),
    }

    pub const FLOAT: i32 = 1;
    pub const ATTR_FLOAT: i32 = 1;
    pub const ATTR_INT: i32 = 2;
    pub const ATTR_INTS: i32 = 7;
}

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
        initializers.push(make_tensor(name, dims, data));
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
        nodes.push(make_relu_node(&format!("{conv_name}_relu"), &current, &relu_out));
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
    nodes.push(make_gemm_node("fc1_gemm", &current, "fc1.weight", "fc1.bias", &fc1_out));
    current = fc1_out;

    let fc1_relu_out = "fc1_relu_out".to_string();
    nodes.push(make_relu_node("fc1_relu", &current, &fc1_relu_out));
    current = fc1_relu_out;

    let logits = "logits".to_string();
    nodes.push(make_gemm_node("fc2_gemm", &current, "fc2.weight", "fc2.bias", &logits));

    let graph = GraphProto {
        name: "plant_cnn".to_string(),
        node: nodes,
        initializer: initializers,
        input: vec![make_value_info(
            "input",
            &[-1, 3, input_size as i64, input_size as i64],
        )],
        output: vec![make_value_info("logits", &[-1, num_classes as i64])],
    };

    let model = ModelProto {
        ir_version: 8,
        opset_import: vec![OperatorSetIdProto {
            domain: String::new(),
            version: opset,
        }],
        graph: Some(graph),
        producer_name: "yp-ml-training".to_string(),
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

fn make_tensor(name: &str, dims: &[usize], data: &[f32]) -> TensorProto {
    let raw_data: Vec<u8> = data.iter().flat_map(|f| f.to_le_bytes()).collect();
    TensorProto {
        name: name.to_string(),
        dims: dims.iter().map(|&d| d as i64).collect(),
        data_type: FLOAT,
        raw_data,
    }
}

fn make_value_info(name: &str, dims: &[i64]) -> ValueInfoProto {
    ValueInfoProto {
        name: name.to_string(),
        r#type: Some(TypeProto {
            tensor_type: Some(TensorTypeProto {
                elem_type: FLOAT,
                shape: Some(TensorShapeProto {
                    dim: dims
                        .iter()
                        .map(|&d| {
                            if d < 0 {
                                Dimension {
                                    value: Some(DimValue::DimParam("batch".to_string())),
                                }
                            } else {
                                Dimension {
                                    value: Some(DimValue::DimValue(d)),
                                }
                            }
                        })
                        .collect(),
                }),
            }),
        }),
    }
}

fn make_conv_node(name: &str, input: &str, output: &str) -> NodeProto {
    NodeProto {
        name: name.to_string(),
        op_type: "Conv".to_string(),
        input: vec![
            input.to_string(),
            format!("{name}.weight"),
            format!("{name}.bias"),
        ],
        output: vec![output.to_string()],
        attribute: vec![
            int_attr("group", 1),
            ints_attr("kernel_shape", &[3, 3]),
            ints_attr("pads", &[1, 1, 1, 1]),
            ints_attr("strides", &[1, 1]),
        ],
    }
}

fn make_bn_node(name: &str, input: &str, output: &str) -> NodeProto {
    NodeProto {
        name: name.to_string(),
        op_type: "BatchNormalization".to_string(),
        input: vec![
            input.to_string(),
            format!("{name}.weight"),
            format!("{name}.bias"),
            format!("{name}.running_mean"),
            format!("{name}.running_var"),
        ],
        output: vec![output.to_string()],
        attribute: vec![float_attr("epsilon", 1e-5), float_attr("momentum", 0.1)],
    }
}

fn make_relu_node(name: &str, input: &str, output: &str) -> NodeProto {
    NodeProto {
        name: name.to_string(),
        op_type: "Relu".to_string(),
        input: vec![input.to_string()],
        output: vec![output.to_string()],
        attribute: vec![],
    }
}

fn make_maxpool_node(name: &str, input: &str, output: &str) -> NodeProto {
    NodeProto {
        name: name.to_string(),
        op_type: "MaxPool".to_string(),
        input: vec![input.to_string()],
        output: vec![output.to_string()],
        attribute: vec![
            ints_attr("kernel_shape", &[2, 2]),
            ints_attr("strides", &[2, 2]),
        ],
    }
}

fn make_global_avg_pool_node(name: &str, input: &str, output: &str) -> NodeProto {
    NodeProto {
        name: name.to_string(),
        op_type: "GlobalAveragePool".to_string(),
        input: vec![input.to_string()],
        output: vec![output.to_string()],
        attribute: vec![],
    }
}

fn make_flatten_node(name: &str, input: &str, output: &str) -> NodeProto {
    NodeProto {
        name: name.to_string(),
        op_type: "Flatten".to_string(),
        input: vec![input.to_string()],
        output: vec![output.to_string()],
        attribute: vec![int_attr("axis", 1)],
    }
}

fn make_gemm_node(name: &str, input: &str, weight: &str, bias: &str, output: &str) -> NodeProto {
    NodeProto {
        name: name.to_string(),
        op_type: "Gemm".to_string(),
        input: vec![
            input.to_string(),
            weight.to_string(),
            bias.to_string(),
        ],
        output: vec![output.to_string()],
        attribute: vec![
            float_attr("alpha", 1.0),
            float_attr("beta", 1.0),
            int_attr("transB", 1),
        ],
    }
}

fn float_attr(name: &str, val: f32) -> AttributeProto {
    AttributeProto {
        name: name.to_string(),
        r#type: ATTR_FLOAT,
        f: val,
        ..Default::default()
    }
}

fn int_attr(name: &str, val: i64) -> AttributeProto {
    AttributeProto {
        name: name.to_string(),
        r#type: ATTR_INT,
        i: val,
        ..Default::default()
    }
}

fn ints_attr(name: &str, vals: &[i64]) -> AttributeProto {
    AttributeProto {
        name: name.to_string(),
        r#type: ATTR_INTS,
        ints: vals.to_vec(),
        ..Default::default()
    }
}
