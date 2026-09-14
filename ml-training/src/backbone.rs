//! Transfer learning from a pretrained ONNX backbone.
//!
//! Training four small CNNs from scratch on a few thousand field photos wastes
//! most of what the images could teach. Instead we take a backbone pretrained
//! on a large corpus (ImageNet, or an agriculture-specific checkpoint), run it
//! once per image to get an embedding, and fit a small head per task on those
//! embeddings.
//!
//! The backbone stays frozen. burn 0.16 cannot import ONNX weights at runtime
//! (its importer is build-time codegen), so backpropagating into the backbone
//! is not available here; frozen-feature transfer is what this pipeline does,
//! and it is still a large step up from random initialisation on small data.
//! Because it is frozen, embeddings are computed once and cached on disk, so
//! head training iterates in seconds.

use std::collections::HashMap;
use std::io::{Read, Write};
use std::path::{Path, PathBuf};

use image::RgbImage;
use sha2::{Digest, Sha256};
use tract_onnx::prelude::*;
use tract_onnx::tract_hir::infer::Factoid;

use crate::config::BackboneConfig;
use crate::dataset::preprocess_rgb_with;

type Plan = SimplePlan<TypedFact, Box<dyn TypedOp>, Graph<TypedFact, Box<dyn TypedOp>>>;

/// Pixel normalization the backbone was trained with.
#[derive(Debug, Clone, Copy, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct Normalization {
    pub mean: [f32; 3],
    pub std: [f32; 3],
}

impl Normalization {
    pub fn imagenet() -> Self {
        Self {
            mean: [0.485, 0.456, 0.406],
            std: [0.229, 0.224, 0.225],
        }
    }

    /// Plain `[0, 1]` scaling.
    pub fn unit() -> Self {
        Self {
            mean: [0.0; 3],
            std: [1.0; 3],
        }
    }

    /// `[-1, 1]`, used by most MobileNet/Inception exports.
    pub fn symmetric() -> Self {
        Self {
            mean: [0.5; 3],
            std: [0.5; 3],
        }
    }

    pub fn parse(name: &str) -> anyhow::Result<Self> {
        match name.trim().to_ascii_lowercase().as_str() {
            "" | "imagenet" => Ok(Self::imagenet()),
            "unit" | "zero_one" => Ok(Self::unit()),
            "symmetric" | "minus_one_one" => Ok(Self::symmetric()),
            other => anyhow::bail!(
                "unknown normalization {other:?} (expected imagenet, unit, or symmetric)"
            ),
        }
    }
}

/// A frozen pretrained backbone used as a feature extractor.
pub struct Backbone {
    plan: Plan,
    path: PathBuf,
    /// SHA-256 of the ONNX file; part of the embedding cache key.
    fingerprint: String,
    input_size: u32,
    embedding_dim: usize,
    /// ONNX tensor name the embedding is read from.
    embedding_tensor: String,
    normalization: Normalization,
    onnx_bytes: Vec<u8>,
}

impl std::fmt::Debug for Backbone {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("Backbone")
            .field("path", &self.path)
            .field("input_size", &self.input_size)
            .field("embedding_dim", &self.embedding_dim)
            .field("embedding_tensor", &self.embedding_tensor)
            .finish()
    }
}

impl Backbone {
    /// Load a backbone, optionally cutting the graph at an intermediate tensor
    /// (typically the pooled feature map, before the pretrained classifier).
    pub fn load(cfg: &BackboneConfig) -> anyhow::Result<Self> {
        let path = PathBuf::from(&cfg.path);
        if !path.exists() {
            anyhow::bail!("backbone ONNX not found at {}", path.display());
        }
        let onnx_bytes = std::fs::read(&path)?;
        let fingerprint = hex(&Sha256::digest(&onnx_bytes));
        let normalization = Normalization::parse(&cfg.normalization)?;

        let mut model =
            tract_onnx::onnx().model_for_read(&mut std::io::Cursor::new(&onnx_bytes))?;

        // Resolve the input size, preferring the config when the graph is
        // fully symbolic (common for exports with dynamic H/W).
        let input_fact = model.input_fact(0)?;
        let dims: Vec<Option<i64>> = input_fact
            .shape
            .dims()
            .map(|d| d.concretize().and_then(|t| t.to_i64().ok()))
            .collect();
        if dims.len() != 4 {
            anyhow::bail!(
                "backbone input must be a rank-4 NCHW tensor, got rank {}",
                dims.len()
            );
        }
        if dims[1] != Some(3) {
            anyhow::bail!("backbone input must have 3 channels, got {:?}", dims[1]);
        }
        let input_size = match (dims[2], dims[3], cfg.input_size) {
            (Some(h), Some(w), _) if h == w && h > 0 => h as u32,
            (_, _, s) if s > 0 => s as u32,
            _ => anyhow::bail!(
                "backbone has a symbolic input size; set backbone.input_size in the config"
            ),
        };

        let embedding_tensor = cfg.embedding_output.trim().to_string();
        if !embedding_tensor.is_empty() {
            model
                .set_output_names([embedding_tensor.as_str()])
                .map_err(|e| {
                    anyhow::anyhow!(
                        "embedding_output {embedding_tensor:?} not found in {}: {e}",
                        path.display()
                    )
                })?;
        }

        let model = model
            .with_input_fact(
                0,
                f32::fact([1, 3, input_size as usize, input_size as usize]).into(),
            )?
            .into_optimized()?;
        let plan = model.into_runnable()?;

        let mut backbone = Self {
            plan,
            path,
            fingerprint,
            input_size,
            embedding_dim: 0,
            embedding_tensor,
            normalization,
            onnx_bytes,
        };

        // A dry run settles the embedding width and proves the graph runs.
        let probe = vec![0.0f32; 3 * (input_size as usize) * (input_size as usize)];
        let embedding = backbone.run(&probe)?;
        if embedding.is_empty() {
            anyhow::bail!("backbone produced an empty embedding");
        }
        backbone.embedding_dim = embedding.len();

        if backbone.embedding_tensor.is_empty() {
            backbone.embedding_tensor = backbone.graph_output_name()?;
        }
        Ok(backbone)
    }

    /// Name of the backbone graph's single output, used when the config does
    /// not pick an intermediate tensor.
    fn graph_output_name(&self) -> anyhow::Result<String> {
        let model = crate::compose::decode_model(&self.onnx_bytes)?;
        let graph = model
            .graph
            .ok_or_else(|| anyhow::anyhow!("backbone has no graph"))?;
        match graph.output.len() {
            1 => Ok(graph.output[0].name.clone()),
            n => {
                anyhow::bail!("backbone has {n} outputs; set backbone.embedding_output to pick one")
            }
        }
    }

    pub fn input_size(&self) -> u32 {
        self.input_size
    }

    pub fn embedding_dim(&self) -> usize {
        self.embedding_dim
    }

    pub fn embedding_tensor(&self) -> &str {
        &self.embedding_tensor
    }

    pub fn normalization(&self) -> Normalization {
        self.normalization
    }

    pub fn fingerprint(&self) -> &str {
        &self.fingerprint
    }

    pub fn onnx_bytes(&self) -> &[u8] {
        &self.onnx_bytes
    }

    pub fn path(&self) -> &Path {
        &self.path
    }

    /// Run the backbone on a normalised CHW tensor and flatten the result.
    pub fn run(&self, chw: &[f32]) -> anyhow::Result<Vec<f32>> {
        let size = self.input_size as usize;
        let expected = 3 * size * size;
        if chw.len() != expected {
            anyhow::bail!("expected {expected} input values, got {}", chw.len());
        }
        let input = tract_ndarray::Array4::from_shape_vec((1, 3, size, size), chw.to_vec())?;
        let outputs = self.plan.run(tvec!(Tensor::from(input).into()))?;
        let view = outputs[0].to_array_view::<f32>()?;
        Ok(view.iter().copied().collect())
    }

    /// Preprocess and embed a decoded image.
    pub fn embed_rgb(&self, rgb: &RgbImage) -> anyhow::Result<Vec<f32>> {
        let chw = preprocess_rgb_with(
            rgb,
            self.input_size as usize,
            self.normalization.mean,
            self.normalization.std,
        );
        self.run(&chw)
    }

    /// Decode an image file and embed it.
    pub fn embed_file(&self, path: &Path) -> anyhow::Result<Vec<f32>> {
        let img = image::open(path)?;
        self.embed_rgb(&img.to_rgb8())
    }

    /// Cache key component that invalidates on any change to what embeddings mean.
    pub fn cache_key(&self) -> String {
        let mut h = Sha256::new();
        h.update(self.fingerprint.as_bytes());
        h.update(self.embedding_tensor.as_bytes());
        h.update(self.input_size.to_le_bytes());
        for v in self
            .normalization
            .mean
            .iter()
            .chain(&self.normalization.std)
        {
            h.update(v.to_le_bytes());
        }
        hex(&h.finalize())[..16].to_string()
    }
}

fn hex(bytes: &[u8]) -> String {
    bytes.iter().map(|b| format!("{b:02x}")).collect()
}

/// Disk-backed map of sample id → embedding.
///
/// Embeddings are deterministic for a frozen backbone, so a run that only
/// changes head hyper-parameters reuses them instead of re-running the network
/// over every image.
#[derive(Debug, Default)]
pub struct EmbeddingCache {
    entries: HashMap<String, Vec<f32>>,
    dim: usize,
    dirty: bool,
}

const CACHE_MAGIC: &[u8; 8] = b"YPEMBED1";

impl EmbeddingCache {
    pub fn new(dim: usize) -> Self {
        Self {
            entries: HashMap::new(),
            dim,
            dirty: false,
        }
    }

    pub fn len(&self) -> usize {
        self.entries.len()
    }

    pub fn is_empty(&self) -> bool {
        self.entries.is_empty()
    }

    pub fn get(&self, id: &str) -> Option<&Vec<f32>> {
        self.entries.get(id)
    }

    pub fn insert(&mut self, id: String, embedding: Vec<f32>) {
        self.dirty = true;
        self.entries.insert(id, embedding);
    }

    /// Load a cache file, ignoring one written for a different embedding width.
    pub fn load(path: &Path, dim: usize) -> Self {
        match Self::read(path, dim) {
            Ok(cache) => cache,
            Err(e) => {
                if path.exists() {
                    tracing::warn!(path = %path.display(), error = %e, "ignoring unusable embedding cache");
                }
                Self::new(dim)
            }
        }
    }

    fn read(path: &Path, dim: usize) -> anyhow::Result<Self> {
        let mut file = std::io::BufReader::new(std::fs::File::open(path)?);
        let mut magic = [0u8; 8];
        file.read_exact(&mut magic)?;
        if &magic != CACHE_MAGIC {
            anyhow::bail!("bad cache magic");
        }
        let stored_dim = read_u32(&mut file)? as usize;
        if stored_dim != dim {
            anyhow::bail!("cache holds {stored_dim}-d embeddings, need {dim}-d");
        }
        let count = read_u32(&mut file)? as usize;
        let mut entries = HashMap::with_capacity(count);
        for _ in 0..count {
            let id_len = read_u32(&mut file)? as usize;
            let mut id = vec![0u8; id_len];
            file.read_exact(&mut id)?;
            let mut raw = vec![0u8; dim * 4];
            file.read_exact(&mut raw)?;
            let values = raw
                .chunks_exact(4)
                .map(|c| f32::from_le_bytes([c[0], c[1], c[2], c[3]]))
                .collect();
            entries.insert(String::from_utf8(id)?, values);
        }
        Ok(Self {
            entries,
            dim,
            dirty: false,
        })
    }

    /// Write the cache when it has new entries.
    pub fn save(&self, path: &Path) -> anyhow::Result<()> {
        if !self.dirty {
            return Ok(());
        }
        if let Some(parent) = path.parent() {
            std::fs::create_dir_all(parent)?;
        }
        let tmp = path.with_extension("tmp");
        {
            let mut file = std::io::BufWriter::new(std::fs::File::create(&tmp)?);
            file.write_all(CACHE_MAGIC)?;
            file.write_all(&(self.dim as u32).to_le_bytes())?;
            file.write_all(&(self.entries.len() as u32).to_le_bytes())?;
            // Sorted so the file is reproducible for a given set of samples.
            let mut ids: Vec<&String> = self.entries.keys().collect();
            ids.sort();
            for id in ids {
                let values = &self.entries[id];
                file.write_all(&(id.len() as u32).to_le_bytes())?;
                file.write_all(id.as_bytes())?;
                for v in values {
                    file.write_all(&v.to_le_bytes())?;
                }
            }
            file.flush()?;
        }
        std::fs::rename(&tmp, path)?;
        Ok(())
    }
}

fn read_u32(r: &mut impl Read) -> anyhow::Result<u32> {
    let mut buf = [0u8; 4];
    r.read_exact(&mut buf)?;
    Ok(u32::from_le_bytes(buf))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn normalization_presets_and_parsing() {
        assert_eq!(Normalization::parse("").unwrap(), Normalization::imagenet());
        assert_eq!(
            Normalization::parse("ImageNet").unwrap(),
            Normalization::imagenet()
        );
        assert_eq!(Normalization::parse("unit").unwrap().std, [1.0; 3]);
        assert_eq!(Normalization::parse("symmetric").unwrap().mean, [0.5; 3]);
        assert!(Normalization::parse("nope").is_err());
    }

    #[test]
    fn cache_round_trips_and_rejects_wrong_width() {
        let dir = tempfile::tempdir().unwrap();
        let path = dir.path().join("emb.bin");

        let mut cache = EmbeddingCache::new(3);
        cache.insert("a".into(), vec![1.0, 2.0, 3.0]);
        cache.insert("b".into(), vec![-1.0, 0.5, 0.25]);
        cache.save(&path).unwrap();

        let loaded = EmbeddingCache::load(&path, 3);
        assert_eq!(loaded.len(), 2);
        assert_eq!(loaded.get("a").unwrap(), &vec![1.0, 2.0, 3.0]);
        assert_eq!(loaded.get("b").unwrap(), &vec![-1.0, 0.5, 0.25]);
        assert!(loaded.get("missing").is_none());

        // A different embedding width means a different backbone: start over.
        let mismatched = EmbeddingCache::load(&path, 4);
        assert!(mismatched.is_empty());

        // Missing file is simply an empty cache.
        assert!(EmbeddingCache::load(&dir.path().join("nope.bin"), 3).is_empty());
    }

    #[test]
    fn clean_cache_does_not_write() {
        let dir = tempfile::tempdir().unwrap();
        let path = dir.path().join("emb.bin");
        EmbeddingCache::new(2).save(&path).unwrap();
        assert!(!path.exists(), "nothing new to persist");
    }

    #[test]
    fn missing_backbone_file_is_reported() {
        let cfg = BackboneConfig {
            path: "/nonexistent/backbone.onnx".into(),
            ..Default::default()
        };
        let err = Backbone::load(&cfg).unwrap_err().to_string();
        assert!(err.contains("not found"), "{err}");
    }
}
