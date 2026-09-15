//! ONNX protobuf message definitions (subset of `onnx.proto3`, opset-agnostic).
//!
//! These are complete enough to **decode an existing ONNX file, modify it, and
//! re-encode it without losing data** — which is what backbone composition and
//! weight quantization need. The original export path only ever wrote graphs,
//! so it modelled a handful of fields; anything omitted there would have been
//! silently dropped when re-encoding a third-party model.
//!
//! Field numbers follow the ONNX specification. Messages that the spec defines
//! as a `oneof` (`TypeProto.value`, `AttributeProto`'s value slots) are modelled
//! as plain optional fields: the wire encoding is identical, and it keeps the
//! construction ergonomics of the writer path.

/// A key/value metadata entry.
#[derive(Clone, PartialEq, prost::Message)]
pub struct StringStringEntryProto {
    #[prost(string, tag = "1")]
    pub key: String,
    #[prost(string, tag = "2")]
    pub value: String,
}

#[derive(Clone, PartialEq, prost::Message)]
pub struct OperatorSetIdProto {
    #[prost(string, tag = "1")]
    pub domain: String,
    #[prost(int64, tag = "2")]
    pub version: i64,
}

#[derive(Clone, PartialEq, prost::Message)]
pub struct TensorAnnotation {
    #[prost(string, tag = "1")]
    pub tensor_name: String,
    #[prost(message, repeated, tag = "2")]
    pub quant_parameter_tensor_names: Vec<StringStringEntryProto>,
}

#[derive(Clone, PartialEq, prost::Message)]
pub struct Segment {
    #[prost(int64, tag = "1")]
    pub begin: i64,
    #[prost(int64, tag = "2")]
    pub end: i64,
}

#[derive(Clone, PartialEq, prost::Message)]
pub struct TensorProto {
    #[prost(int64, repeated, tag = "1")]
    pub dims: Vec<i64>,
    #[prost(int32, tag = "2")]
    pub data_type: i32,
    #[prost(message, optional, tag = "3")]
    pub segment: Option<Segment>,
    #[prost(float, repeated, tag = "4")]
    pub float_data: Vec<f32>,
    #[prost(int32, repeated, tag = "5")]
    pub int32_data: Vec<i32>,
    #[prost(bytes = "vec", repeated, tag = "6")]
    pub string_data: Vec<Vec<u8>>,
    #[prost(int64, repeated, tag = "7")]
    pub int64_data: Vec<i64>,
    #[prost(string, tag = "8")]
    pub name: String,
    #[prost(bytes = "vec", tag = "9")]
    pub raw_data: Vec<u8>,
    #[prost(double, repeated, tag = "10")]
    pub double_data: Vec<f64>,
    #[prost(uint64, repeated, tag = "11")]
    pub uint64_data: Vec<u64>,
    #[prost(string, tag = "12")]
    pub doc_string: String,
    #[prost(message, repeated, tag = "13")]
    pub external_data: Vec<StringStringEntryProto>,
    #[prost(int32, tag = "14")]
    pub data_location: i32,
    #[prost(message, repeated, tag = "16")]
    pub metadata_props: Vec<StringStringEntryProto>,
}

#[derive(Clone, PartialEq, prost::Message)]
pub struct SparseTensorProto {
    #[prost(message, optional, tag = "1")]
    pub values: Option<TensorProto>,
    #[prost(message, optional, tag = "2")]
    pub indices: Option<TensorProto>,
    #[prost(int64, repeated, tag = "3")]
    pub dims: Vec<i64>,
}

#[derive(Clone, PartialEq, prost::Message)]
pub struct Dimension {
    #[prost(oneof = "DimValue", tags = "1, 2")]
    pub value: Option<DimValue>,
    #[prost(string, tag = "3")]
    pub denotation: String,
}

#[derive(Clone, PartialEq, prost::Oneof)]
pub enum DimValue {
    #[prost(int64, tag = "1")]
    DimValue(i64),
    #[prost(string, tag = "2")]
    DimParam(String),
}

#[derive(Clone, PartialEq, prost::Message)]
pub struct TensorShapeProto {
    #[prost(message, repeated, tag = "1")]
    pub dim: Vec<Dimension>,
}

/// `TypeProto.Tensor`.
#[derive(Clone, PartialEq, prost::Message)]
pub struct TensorTypeProto {
    #[prost(int32, tag = "1")]
    pub elem_type: i32,
    #[prost(message, optional, tag = "2")]
    pub shape: Option<TensorShapeProto>,
}

/// `TypeProto.Sequence`.
#[derive(Clone, PartialEq, prost::Message)]
pub struct SequenceTypeProto {
    #[prost(message, optional, boxed, tag = "1")]
    pub elem_type: Option<Box<TypeProto>>,
}

/// `TypeProto.Map`.
#[derive(Clone, PartialEq, prost::Message)]
pub struct MapTypeProto {
    #[prost(int32, tag = "1")]
    pub key_type: i32,
    #[prost(message, optional, boxed, tag = "2")]
    pub value_type: Option<Box<TypeProto>>,
}

/// `TypeProto.Optional`.
#[derive(Clone, PartialEq, prost::Message)]
pub struct OptionalTypeProto {
    #[prost(message, optional, boxed, tag = "1")]
    pub elem_type: Option<Box<TypeProto>>,
}

#[derive(Clone, PartialEq, prost::Message)]
pub struct TypeProto {
    #[prost(message, optional, tag = "1")]
    pub tensor_type: Option<TensorTypeProto>,
    #[prost(message, optional, boxed, tag = "4")]
    pub sequence_type: Option<Box<SequenceTypeProto>>,
    #[prost(message, optional, boxed, tag = "5")]
    pub map_type: Option<Box<MapTypeProto>>,
    #[prost(string, tag = "6")]
    pub denotation: String,
    #[prost(message, optional, tag = "8")]
    pub sparse_tensor_type: Option<TensorTypeProto>,
    #[prost(message, optional, boxed, tag = "9")]
    pub optional_type: Option<Box<OptionalTypeProto>>,
}

#[derive(Clone, PartialEq, prost::Message)]
pub struct ValueInfoProto {
    #[prost(string, tag = "1")]
    pub name: String,
    #[prost(message, optional, tag = "2")]
    pub r#type: Option<TypeProto>,
    #[prost(string, tag = "3")]
    pub doc_string: String,
    #[prost(message, repeated, tag = "4")]
    pub metadata_props: Vec<StringStringEntryProto>,
}

#[derive(Clone, PartialEq, prost::Message)]
pub struct AttributeProto {
    #[prost(string, tag = "1")]
    pub name: String,
    #[prost(float, tag = "2")]
    pub f: f32,
    #[prost(int64, tag = "3")]
    pub i: i64,
    #[prost(bytes = "vec", tag = "4")]
    pub s: Vec<u8>,
    #[prost(message, optional, tag = "5")]
    pub t: Option<TensorProto>,
    #[prost(message, optional, boxed, tag = "6")]
    pub g: Option<Box<GraphProto>>,
    #[prost(float, repeated, tag = "7")]
    pub floats: Vec<f32>,
    #[prost(int64, repeated, tag = "8")]
    pub ints: Vec<i64>,
    #[prost(bytes = "vec", repeated, tag = "9")]
    pub strings: Vec<Vec<u8>>,
    #[prost(message, repeated, tag = "10")]
    pub tensors: Vec<TensorProto>,
    #[prost(message, repeated, tag = "11")]
    pub graphs: Vec<GraphProto>,
    #[prost(string, tag = "13")]
    pub doc_string: String,
    #[prost(message, optional, tag = "14")]
    pub tp: Option<TypeProto>,
    #[prost(message, repeated, tag = "15")]
    pub type_protos: Vec<TypeProto>,
    #[prost(int32, tag = "20")]
    pub r#type: i32,
    #[prost(string, tag = "21")]
    pub ref_attr_name: String,
    #[prost(message, optional, tag = "22")]
    pub sparse_tensor: Option<SparseTensorProto>,
    #[prost(message, repeated, tag = "23")]
    pub sparse_tensors: Vec<SparseTensorProto>,
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
    #[prost(string, tag = "6")]
    pub doc_string: String,
    #[prost(string, tag = "7")]
    pub domain: String,
    #[prost(string, tag = "8")]
    pub overload: String,
    #[prost(message, repeated, tag = "9")]
    pub metadata_props: Vec<StringStringEntryProto>,
}

#[derive(Clone, PartialEq, prost::Message)]
pub struct GraphProto {
    #[prost(message, repeated, tag = "1")]
    pub node: Vec<NodeProto>,
    #[prost(string, tag = "2")]
    pub name: String,
    #[prost(message, repeated, tag = "5")]
    pub initializer: Vec<TensorProto>,
    #[prost(string, tag = "10")]
    pub doc_string: String,
    #[prost(message, repeated, tag = "11")]
    pub input: Vec<ValueInfoProto>,
    #[prost(message, repeated, tag = "12")]
    pub output: Vec<ValueInfoProto>,
    #[prost(message, repeated, tag = "13")]
    pub value_info: Vec<ValueInfoProto>,
    #[prost(message, repeated, tag = "14")]
    pub quantization_annotation: Vec<TensorAnnotation>,
    #[prost(message, repeated, tag = "15")]
    pub sparse_initializer: Vec<SparseTensorProto>,
    #[prost(message, repeated, tag = "16")]
    pub metadata_props: Vec<StringStringEntryProto>,
}

#[derive(Clone, PartialEq, prost::Message)]
pub struct TrainingInfoProto {
    #[prost(message, optional, tag = "1")]
    pub initialization: Option<GraphProto>,
    #[prost(message, optional, tag = "2")]
    pub algorithm: Option<GraphProto>,
    #[prost(message, repeated, tag = "3")]
    pub initialization_binding: Vec<StringStringEntryProto>,
    #[prost(message, repeated, tag = "4")]
    pub update_binding: Vec<StringStringEntryProto>,
}

#[derive(Clone, PartialEq, prost::Message)]
pub struct FunctionProto {
    #[prost(string, tag = "1")]
    pub name: String,
    #[prost(string, repeated, tag = "4")]
    pub input: Vec<String>,
    #[prost(string, repeated, tag = "5")]
    pub output: Vec<String>,
    #[prost(string, repeated, tag = "6")]
    pub attribute: Vec<String>,
    #[prost(message, repeated, tag = "7")]
    pub node: Vec<NodeProto>,
    #[prost(string, tag = "8")]
    pub doc_string: String,
    #[prost(message, repeated, tag = "9")]
    pub opset_import: Vec<OperatorSetIdProto>,
    #[prost(string, tag = "10")]
    pub domain: String,
    #[prost(message, repeated, tag = "11")]
    pub attribute_proto: Vec<AttributeProto>,
    #[prost(message, repeated, tag = "12")]
    pub value_info: Vec<ValueInfoProto>,
    #[prost(string, tag = "13")]
    pub overload: String,
    #[prost(message, repeated, tag = "14")]
    pub metadata_props: Vec<StringStringEntryProto>,
}

#[derive(Clone, PartialEq, prost::Message)]
pub struct ModelProto {
    #[prost(int64, tag = "1")]
    pub ir_version: i64,
    #[prost(string, tag = "2")]
    pub producer_name: String,
    #[prost(string, tag = "3")]
    pub producer_version: String,
    #[prost(string, tag = "4")]
    pub domain: String,
    #[prost(int64, tag = "5")]
    pub model_version: i64,
    #[prost(string, tag = "6")]
    pub doc_string: String,
    #[prost(message, optional, tag = "7")]
    pub graph: Option<GraphProto>,
    #[prost(message, repeated, tag = "8")]
    pub opset_import: Vec<OperatorSetIdProto>,
    #[prost(message, repeated, tag = "14")]
    pub metadata_props: Vec<StringStringEntryProto>,
    #[prost(message, repeated, tag = "20")]
    pub training_info: Vec<TrainingInfoProto>,
    #[prost(message, repeated, tag = "25")]
    pub functions: Vec<FunctionProto>,
}

// ── TensorProto.DataType ─────────────────────────────────────────────────────
pub const FLOAT: i32 = 1;
pub const INT8: i32 = 3;
pub const INT32: i32 = 6;
pub const INT64: i32 = 7;

// ── AttributeProto.AttributeType ─────────────────────────────────────────────
pub const ATTR_FLOAT: i32 = 1;
pub const ATTR_INT: i32 = 2;
pub const ATTR_STRING: i32 = 3;
pub const ATTR_TENSOR: i32 = 4;
pub const ATTR_FLOATS: i32 = 6;
pub const ATTR_INTS: i32 = 7;

impl TypeProto {
    /// A dense tensor type; negative dims become the symbolic `batch` parameter.
    pub fn tensor(elem_type: i32, dims: &[i64]) -> Self {
        Self {
            tensor_type: Some(TensorTypeProto {
                elem_type,
                shape: Some(TensorShapeProto {
                    dim: dims
                        .iter()
                        .map(|&d| Dimension {
                            value: Some(if d < 0 {
                                DimValue::DimParam("batch".to_string())
                            } else {
                                DimValue::DimValue(d)
                            }),
                            ..Default::default()
                        })
                        .collect(),
                }),
            }),
            ..Default::default()
        }
    }
}

impl ValueInfoProto {
    pub fn float_tensor(name: &str, dims: &[i64]) -> Self {
        Self {
            name: name.to_string(),
            r#type: Some(TypeProto::tensor(FLOAT, dims)),
            ..Default::default()
        }
    }

    /// Static dimensions of this value, `None` for symbolic ones.
    pub fn dims(&self) -> Vec<Option<i64>> {
        self.r#type
            .as_ref()
            .and_then(|t| t.tensor_type.as_ref())
            .and_then(|t| t.shape.as_ref())
            .map(|s| {
                s.dim
                    .iter()
                    .map(|d| match &d.value {
                        Some(DimValue::DimValue(v)) => Some(*v),
                        _ => None,
                    })
                    .collect()
            })
            .unwrap_or_default()
    }
}

impl TensorProto {
    /// A float tensor stored as little-endian `raw_data`.
    pub fn floats(name: &str, dims: &[usize], data: &[f32]) -> Self {
        Self {
            name: name.to_string(),
            dims: dims.iter().map(|&d| d as i64).collect(),
            data_type: FLOAT,
            raw_data: data.iter().flat_map(|f| f.to_le_bytes()).collect(),
            ..Default::default()
        }
    }

    /// Number of elements implied by `dims`.
    /// An int64 constant, as `Reshape` and friends take for their shapes.
    pub fn int64s(name: &str, dims: &[usize], data: &[i64]) -> Self {
        Self {
            name: name.to_string(),
            dims: dims.iter().map(|&d| d as i64).collect(),
            data_type: INT64,
            raw_data: data.iter().flat_map(|v| v.to_le_bytes()).collect(),
            ..Default::default()
        }
    }

    pub fn element_count(&self) -> usize {
        self.dims.iter().map(|&d| d.max(0) as usize).product()
    }

    /// Read float contents from `raw_data` or `float_data`.
    /// Returns `None` when the tensor is not float32 or is externally stored.
    pub fn as_f32(&self) -> Option<Vec<f32>> {
        if self.data_type != FLOAT || self.data_location != 0 {
            return None;
        }
        if !self.float_data.is_empty() {
            return Some(self.float_data.clone());
        }
        if self.raw_data.is_empty() {
            return None;
        }
        if self.raw_data.len() % 4 != 0 {
            return None;
        }
        Some(
            self.raw_data
                .chunks_exact(4)
                .map(|c| f32::from_le_bytes([c[0], c[1], c[2], c[3]]))
                .collect(),
        )
    }
}

impl GraphProto {
    /// Every tensor name the graph already uses, so new nodes can avoid clashes.
    pub fn known_names(&self) -> std::collections::HashSet<String> {
        let mut names: std::collections::HashSet<String> = std::collections::HashSet::new();
        for v in self
            .input
            .iter()
            .chain(&self.output)
            .chain(&self.value_info)
        {
            names.insert(v.name.clone());
        }
        for t in &self.initializer {
            names.insert(t.name.clone());
        }
        for n in &self.node {
            names.insert(n.name.clone());
            names.extend(n.input.iter().cloned());
            names.extend(n.output.iter().cloned());
        }
        names
    }

    /// True when some node produces `name`, or it is a graph input/initializer.
    pub fn produces(&self, name: &str) -> bool {
        self.node.iter().any(|n| n.output.iter().any(|o| o == name))
            || self.input.iter().any(|v| v.name == name)
            || self.initializer.iter().any(|t| t.name == name)
    }
}

// ── Node constructors shared by the export paths ─────────────────────────────

pub fn float_attr(name: &str, val: f32) -> AttributeProto {
    AttributeProto {
        name: name.to_string(),
        r#type: ATTR_FLOAT,
        f: val,
        ..Default::default()
    }
}

pub fn int_attr(name: &str, val: i64) -> AttributeProto {
    AttributeProto {
        name: name.to_string(),
        r#type: ATTR_INT,
        i: val,
        ..Default::default()
    }
}

pub fn ints_attr(name: &str, vals: &[i64]) -> AttributeProto {
    AttributeProto {
        name: name.to_string(),
        r#type: ATTR_INTS,
        ints: vals.to_vec(),
        ..Default::default()
    }
}

pub fn node(name: &str, op_type: &str, input: &[&str], output: &[&str]) -> NodeProto {
    NodeProto {
        name: name.to_string(),
        op_type: op_type.to_string(),
        input: input.iter().map(|s| s.to_string()).collect(),
        output: output.iter().map(|s| s.to_string()).collect(),
        ..Default::default()
    }
}

/// `Y = A · B + C` with burn's `[in, out]` weight layout (`transB = 0`).
pub fn gemm_node(name: &str, input: &str, weight: &str, bias: &str, output: &str) -> NodeProto {
    NodeProto {
        attribute: vec![
            float_attr("alpha", 1.0),
            float_attr("beta", 1.0),
            int_attr("transB", 0),
        ],
        ..node(name, "Gemm", &[input, weight, bias], &[output])
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use prost::Message;

    #[test]
    fn unmodelled_shapes_survive_a_decode_encode_cycle() {
        // A graph using fields the old writer-only structs never modelled:
        // node domain/doc_string, graph value_info, float_data, metadata.
        let model = ModelProto {
            ir_version: 8,
            producer_name: "third-party".into(),
            producer_version: "1.2.3".into(),
            model_version: 7,
            doc_string: "backbone".into(),
            domain: "ai.example".into(),
            opset_import: vec![OperatorSetIdProto {
                domain: String::new(),
                version: 17,
            }],
            metadata_props: vec![StringStringEntryProto {
                key: "author".into(),
                value: "someone".into(),
            }],
            graph: Some(GraphProto {
                name: "g".into(),
                node: vec![NodeProto {
                    domain: "ai.example".into(),
                    doc_string: "a node".into(),
                    ..node("n0", "Relu", &["x"], &["y"])
                }],
                initializer: vec![TensorProto {
                    name: "w".into(),
                    dims: vec![2],
                    data_type: FLOAT,
                    float_data: vec![1.5, -2.5],
                    doc_string: "weights".into(),
                    ..Default::default()
                }],
                value_info: vec![ValueInfoProto::float_tensor("mid", &[-1, 4])],
                input: vec![ValueInfoProto::float_tensor("x", &[-1, 4])],
                output: vec![ValueInfoProto::float_tensor("y", &[-1, 4])],
                ..Default::default()
            }),
            ..Default::default()
        };

        let mut buf = Vec::new();
        model.encode(&mut buf).unwrap();
        let decoded = ModelProto::decode(buf.as_slice()).unwrap();
        assert_eq!(decoded, model, "round-trip must be lossless");

        // Re-encoding the decoded model must reproduce the same bytes, which is
        // what makes decode → modify → encode safe for third-party models.
        let mut buf2 = Vec::new();
        decoded.encode(&mut buf2).unwrap();
        assert_eq!(buf, buf2);
    }

    #[test]
    fn tensor_float_accessors() {
        let t = TensorProto::floats("w", &[2, 3], &[1.0, 2.0, 3.0, 4.0, 5.0, 6.0]);
        assert_eq!(t.element_count(), 6);
        assert_eq!(t.as_f32().unwrap(), vec![1.0, 2.0, 3.0, 4.0, 5.0, 6.0]);
        assert_eq!(t.raw_data.len(), 24);

        let packed = TensorProto {
            float_data: vec![0.5, 1.5],
            data_type: FLOAT,
            dims: vec![2],
            ..Default::default()
        };
        assert_eq!(packed.as_f32().unwrap(), vec![0.5, 1.5]);

        let ints = TensorProto {
            data_type: INT64,
            dims: vec![1],
            int64_data: vec![3],
            ..Default::default()
        };
        assert!(ints.as_f32().is_none(), "non-float must not decode as f32");

        let external = TensorProto {
            data_location: 1,
            data_type: FLOAT,
            ..Default::default()
        };
        assert!(external.as_f32().is_none(), "external data is not inline");
    }

    #[test]
    fn graph_name_helpers() {
        let g = GraphProto {
            node: vec![node("n0", "Relu", &["x"], &["h"])],
            input: vec![ValueInfoProto::float_tensor("x", &[-1, 4])],
            initializer: vec![TensorProto::floats("w", &[1], &[0.0])],
            ..Default::default()
        };
        let names = g.known_names();
        for expected in ["x", "h", "w", "n0"] {
            assert!(names.contains(expected), "missing {expected}");
        }
        assert!(g.produces("h"));
        assert!(g.produces("x"));
        assert!(g.produces("w"));
        assert!(!g.produces("nope"));
    }

    #[test]
    fn value_info_dims_reports_symbolic_batch() {
        let vi = ValueInfoProto::float_tensor("input", &[-1, 3, 64, 64]);
        assert_eq!(vi.dims(), vec![None, Some(3), Some(64), Some(64)]);
        assert!(ValueInfoProto::default().dims().is_empty());
    }
}
