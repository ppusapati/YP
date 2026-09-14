# yp-ml-training

Trains the vision and yield models the AI gateway serves, from data the
gateway itself collects in the field.

The pipeline is deliberately boring: images and labels land on disk as plain
files, training reads them, and a model directory is the unit of deployment.
Nothing here talks to a database or a queue, so a run can be reproduced from a
directory and a config file.

```
gateway collects → data/<task>/ → train → evaluate → benchmark gate → export → gateway serves
```

## Commands

| Command | What it does |
| --- | --- |
| `status` | How much labelled data each task has, and whether it is enough to train |
| `train --task <t>` | Train one task's model from scratch |
| `train-heads` | Transfer learning: fit a head per task on a frozen pretrained backbone, then compose them into one multi-task model |
| `validate --task <t> --model-dir <d>` | Full evaluation of a trained model on the current test split |
| `benchmark create --task <t>` | Freeze the current test split into a fixed benchmark suite |
| `benchmark run --task <t> --model-dir <d>` | Score a candidate against the frozen suite and gate promotion |
| `export --task <t> --model-dir <d>` | Write `model.onnx`, `labels.json` and `version.txt` for serving |
| `train-tabular --task yield` | Train the gradient-boosted yield model |
| `pipeline` | train → validate → export for every task |

Every command takes `--config` (default `configs/training_config.toml`).

## Data layout

The gateway writes what training reads, so no conversion step exists:

```
data/<task>/
  manifest.jsonl        one line per sample: id, image path, labels, timestamp
  labels/<id>.json      labels with confidence, provenance, review decision, context
  images/<id>.<ext>     the image itself
```

Task directory names must match what the gateway collects into: `disease`,
`pest`, `nutrient_deficiency`, `plant_classification`.

Labels carry their **provenance** — human review, an external API, or a local
model — and training weights them accordingly, so a reviewed label counts for
more than a guess. A `rejected` review drops the sample; a `corrected` one
replaces the label.

## Training a model

```bash
yp-ml-training train --task disease --output-dir runs
```

A run directory is self-describing, which is what lets evaluation and
benchmarking happen later without guessing:

| File | Why it is there |
| --- | --- |
| `best_model.mpk` | The checkpoint with the best validation accuracy |
| `labels.json` | Class order this checkpoint was trained with. Indices mean nothing without it |
| `version.txt` | Names the run, so a result can say which model produced it |
| `dataset_snapshot.json` | Exactly which samples, with which labels, trained this run |
| `dataset_report.json` | Class balance, provenance mix, and warnings |
| `label_noise_report.json` | Samples the model disagrees with most confidently — the first place to look for bad labels |
| `evaluation.json` | Written by `validate`: the full evaluation below |

### Transfer learning

Training a small CNN from scratch on a few thousand field photos wastes most of
what the images could teach. `train-heads` runs a pretrained ONNX backbone over
each image once, caches the embeddings, and fits a small head per task on them:

```bash
yp-ml-training train-heads --backbone mobilenetv3.onnx --tasks disease,pest \
  --output-dir runs/multitask --quantize
```

The heads are spliced back onto the backbone as a single model with one
`logits_<task>` output per task, so serving every task costs one forward pass.
`--quantize` additionally writes an int8 copy for on-device inference.

The backbone stays **frozen**. burn imports ONNX only as build-time codegen, so
backpropagating into the backbone is not available here; this is frozen-feature
transfer, which is still a large step up from random initialisation on small
data.

No checkpoint to hand? Generate a stand-in to exercise the pipeline:

```bash
cargo run --example synthetic_backbone -- /tmp/backbone.onnx 32 32
```

## Evaluation

`validate` reports far more than accuracy, because accuracy hides the failures
that matter in the field:

- **Confusion matrix**, with the most frequent mistakes called out. Confusing
  two rusts is a different problem from calling blight healthy.
- **Calibration** — reliability bins, expected (ECE) and maximum (MCE)
  calibration error, Brier score, and negative log-likelihood. A model that says
  90% and is right 60% of the time drives bad spray decisions at any accuracy.
  The report also fits the **temperature** that would fix it: one scalar divided
  into the logits, which changes no prediction but brings confidence back in
  line with correctness.
- **Slices** — the same metrics by `crop`, `source` (label provenance),
  `region` (a one-degree grid cell), and `season` (derived from the capture
  timestamp, flipped below the equator). A model that is fine on average but
  poor on rice is a model that will be wrong exactly when someone growing rice
  relies on it. Slices with too few samples are reported but flagged, never
  gated on.

## The benchmark gate

A test split recomputed from the current dataset is not a benchmark: it moves
every time data arrives, so two models are never compared on the same images and
a "+2% accuracy" can be entirely an easier split.

```bash
yp-ml-training benchmark create --task disease        # freeze it, once
yp-ml-training benchmark run --task disease --model-dir runs/disease
```

`benchmark create` pins the exact sample ids **and the labels they had when
frozen**, so a later relabel shows up as reported drift rather than quietly
moving the target. The suite lands in `benchmarks/<task>.json`; edit the
thresholds there to match what the task needs.

`benchmark run` scores a candidate and **exits non-zero if it must not ship**.
It checks:

| Gate | Blocks promotion when |
| --- | --- |
| `min_samples` | The suite is too small for its verdict to mean anything |
| `min_coverage` | Too many pinned samples have left the dataset |
| `min_accuracy`, `min_macro_f1` | The model is not good enough in absolute terms |
| `max_ece` | Confidence does not match correctness |
| `min_worst_slice_accuracy` | Any large-enough slice fails, even if the average passes |
| `max_accuracy_drop` | It is materially worse than the baseline already live |
| `max_ece_increase` | It is materially less calibrated than the baseline |

Two absolutes and two regressions, because a release goes wrong in two ways:
shipping a model that was never good enough, and shipping one that is worse than
what is already running.

`--update-baseline` records a passing model's scores as the new baseline, so the
next candidate is compared against what actually shipped.

Class order is handled by name, not by index: a candidate trained on a different
class ordering is folded into the benchmark's label space before anything is
measured. Comparing two index spaces would produce metrics that look plausible
and mean nothing.

### In CI

`scripts/model-gate.sh` runs every suite that has a matching model and fails the
build if any gate fails:

```bash
scripts/model-gate.sh models benchmarks
```

Tasks with a suite but no candidate model are skipped, not failed — not every
pipeline rebuilds every model. The `model-gate` job in `.github/workflows/ci.yml`
runs this against models uploaded as a `candidate-models` artifact.

## Serving

`export` writes what the AI gateway loads directly:

```
model.onnx      the graph
labels.json     class order
version.txt     what the gateway reports on its health endpoint
```

Point the gateway's `models.*_model` config at that directory, or
`models.multitask_model` at a `train-heads` output. The gateway prefers a
task's own model, falls back to the shared multi-task model, then to an external
API, then to demo weights.

## Configuration

See `configs/training_config.toml`; every section is commented. The parts worth
knowing:

- `[data]` — split ratios, minimum confidence and samples per class, and the
  provenance trust weights.
- `[tasks.<name>]` — per-task hyper-parameters. **Task keys must match the
  gateway's collection directory names.**
- `[augmentation]` — field-photo augmentation (lighting, colour cast, occlusion,
  motion blur, background, noise). Training batches only; validation, test and
  inference all see plain preprocessing.
- `[backbone]` and `[heads]` — transfer learning.
- `[tabular.<name>]` — gradient-boosted regression tasks such as yield.

## Compute backend

The backend is chosen at compile time:

```bash
cargo build --release                     # ndarray, CPU
cargo build --release --features wgpu     # any Vulkan/Metal/DX12 GPU
cargo build --release --features cuda     # NVIDIA, via burn's cuda-jit
```

`Dockerfile` takes a `FEATURES` build argument; `Dockerfile.cuda` builds the
CUDA variant on the NVIDIA toolkit image.
