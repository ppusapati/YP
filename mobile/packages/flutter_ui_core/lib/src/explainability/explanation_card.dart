import 'package:flutter/material.dart';

import 'analysed_image.dart';
import 'model_explanation.dart';

/// "Why this answer" — the photo with the model's attention painted over it.
///
/// The heatmap is a greyscale PNG from Grad-CAM, brightest where the evidence
/// is. It is tinted and screened over the photo so the bright areas glow and
/// the dark ones leave the photo untouched, and the region the model keyed on
/// is outlined so it is legible at phone size where a soft gradient is not.
///
/// The overlay can be switched off, because the point of the card is to let
/// someone check the model against the leaf in front of them and that means
/// being able to see the leaf.
///
/// Three states, deliberately distinct:
///   * a localised explanation — heatmap, focus box, coverage
///   * an explanation with a flat map — heatmap, no box, and it says the model
///     did not settle on anywhere in particular
///   * no explanation at all — the caller does not build this card; see
///     [ExplanationSection]
class ExplanationCard extends StatefulWidget {
  const ExplanationCard({
    super.key,
    required this.explanation,
    required this.imagePath,
  });

  final ModelExplanation explanation;
  final String imagePath;

  @override
  State<ExplanationCard> createState() => _ExplanationCardState();
}

class _ExplanationCardState extends State<ExplanationCard> {
  bool _showOverlay = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final e = widget.explanation;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnalysedImage(imagePath: widget.imagePath),
                if (_showOverlay && e.hasHeatmap)
                  // `fit: BoxFit.fill` rather than `cover`: the heatmap is the
                  // same frame as the photo at a lower resolution, so it has
                  // to stretch to the same box or it points at the wrong part
                  // of the leaf.
                  Opacity(
                    opacity: 0.55,
                    child: Image.memory(
                      e.heatmapPng,
                      fit: BoxFit.fill,
                      gaplessPlayback: true,
                      color: colorScheme.error,
                      colorBlendMode: BlendMode.modulate,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                if (_showOverlay && e.localised)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _FocusBoxPainter(
                        left: e.focusX,
                        top: e.focusY,
                        width: e.focusWidth,
                        height: e.focusHeight,
                        color: colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.className.isNotEmpty ? e.className : 'Model attention',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (e.hasHeatmap)
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => _showOverlay = !_showOverlay),
                        icon: Icon(
                          _showOverlay
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                        ),
                        label: Text(_showOverlay ? 'Hide' : 'Show'),
                      ),
                  ],
                ),
                if (e.summary.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    e.summary,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                ],
                if (!e.localised) ...[
                  const SizedBox(height: 8),
                  Text(
                    'The model spread its attention across the whole photo '
                    'rather than settling on one area. Treat the answer with '
                    'more caution than the confidence score alone suggests.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    if (e.localised)
                      _Fact(label: 'Focus area', value: e.coveragePercent),
                    if (e.method.isNotEmpty)
                      _Fact(label: 'Method', value: e.method),
                    if (e.task.isNotEmpty) _Fact(label: 'Task', value: e.task),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(value, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

/// Outlines the region the model keyed on.
///
/// Coordinates are normalised to [0,1] from the top left, which is what makes
/// the box land in the right place however the photo is scaled to the screen.
class _FocusBoxPainter extends CustomPainter {
  const _FocusBoxPainter({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.color,
  });

  final double left;
  final double top;
  final double width;
  final double height;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (width <= 0 || height <= 0) return;

    final rect = Rect.fromLTWH(
      left * size.width,
      top * size.height,
      width * size.width,
      height * size.height,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_FocusBoxPainter old) =>
      old.left != left ||
      old.top != top ||
      old.width != width ||
      old.height != height ||
      old.color != color;
}

/// The "why this answer" section of a result screen.
///
/// Says the model could not explain itself rather than rendering nothing: a
/// missing section reads as a UI that forgot, and the distinction between "no
/// explanation was produced" and "the explanation is empty" is exactly what a
/// farmer needs to judge how much to trust the diagnosis.
class ExplanationSection extends StatelessWidget {
  const ExplanationSection({
    super.key,
    required this.explanations,
    required this.imagePath,
  });

  final List<ModelExplanation> explanations;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why this answer',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (explanations.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'This diagnosis came from a model that cannot show its working. '
              'No heatmap is shown rather than a made-up one.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          )
        else
          ...explanations.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ExplanationCard(explanation: e, imagePath: imagePath),
            ),
          ),
      ],
    );
  }
}
