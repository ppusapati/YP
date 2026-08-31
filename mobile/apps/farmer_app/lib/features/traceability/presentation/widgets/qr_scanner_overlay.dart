import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A visually styled QR scanning overlay with corner brackets and a scan line.
class QrScannerOverlay extends StatefulWidget {
  const QrScannerOverlay({
    super.key,
    this.scanAreaSize = 250,
    this.borderColor,
    this.overlayColor,
  });

  final double scanAreaSize;
  final Color? borderColor;
  final Color? overlayColor;

  @override
  State<QrScannerOverlay> createState() => _QrScannerOverlayState();
}

class _QrScannerOverlayState extends State<QrScannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor =
        widget.borderColor ?? Theme.of(context).colorScheme.primary;
    final overlayColor =
        widget.overlayColor ?? Colors.black.withValues(alpha: 0.55);

    return Stack(
      children: [
        // Dark overlay with transparent center
        CustomPaint(
          size: Size.infinite,
          painter: _OverlayPainter(
            scanAreaSize: widget.scanAreaSize,
            overlayColor: overlayColor,
          ),
        ),
        // Corner brackets
        Center(
          child: SizedBox(
            width: widget.scanAreaSize,
            height: widget.scanAreaSize,
            child: CustomPaint(
              painter: _CornerPainter(color: borderColor),
            ),
          ),
        ),
        // Animated scan line
        Center(
          child: SizedBox(
            width: widget.scanAreaSize,
            height: widget.scanAreaSize,
            child: AnimatedBuilder(
              animation: _scanLineAnimation,
              builder: (context, child) {
                return Align(
                  alignment: Alignment(
                    0,
                    -1 + 2 * _scanLineAnimation.value,
                  ),
                  child: Container(
                    width: widget.scanAreaSize - 20,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          borderColor.withValues(alpha: 0.0),
                          borderColor,
                          borderColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Instructions
        Positioned(
          bottom: 120,
          left: 0,
          right: 0,
          child: Text(
            'Align QR code within the frame',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Draws the dark overlay with a transparent scan area in the center.
class _OverlayPainter extends CustomPainter {
  _OverlayPainter({
    required this.scanAreaSize,
    required this.overlayColor,
  });

  final double scanAreaSize;
  final Color overlayColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = overlayColor;

    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize,
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(
              RRect.fromRectAndRadius(scanRect, const Radius.circular(12))),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) =>
      oldDelegate.scanAreaSize != scanAreaSize ||
      oldDelegate.overlayColor != overlayColor;
}

/// Draws corner brackets around the scan area.
class _CornerPainter extends CustomPainter {
  _CornerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;
    const radius = 12.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerLength)
        ..lineTo(0, radius)
        ..arcTo(
          const Rect.fromLTWH(0, 0, radius * 2, radius * 2),
          math.pi,
          math.pi / 2,
          false,
        )
        ..lineTo(cornerLength, 0),
      paint,
    );

    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLength, 0)
        ..lineTo(size.width - radius, 0)
        ..arcTo(
          Rect.fromLTWH(size.width - radius * 2, 0, radius * 2, radius * 2),
          -math.pi / 2,
          math.pi / 2,
          false,
        )
        ..lineTo(size.width, cornerLength),
      paint,
    );

    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height - cornerLength)
        ..lineTo(size.width, size.height - radius)
        ..arcTo(
          Rect.fromLTWH(size.width - radius * 2, size.height - radius * 2,
              radius * 2, radius * 2),
          0,
          math.pi / 2,
          false,
        )
        ..lineTo(size.width - cornerLength, size.height),
      paint,
    );

    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(cornerLength, size.height)
        ..lineTo(radius, size.height)
        ..arcTo(
          Rect.fromLTWH(
              0, size.height - radius * 2, radius * 2, radius * 2),
          math.pi / 2,
          math.pi / 2,
          false,
        )
        ..lineTo(0, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Wrapper to match Flutter's AnimatedBuilder API (which uses [Listenable]).
class AnimatedBuilder extends AnimatedWidget {
  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  final Widget Function(BuildContext context, Widget? child) builder;

  @override
  Widget build(BuildContext context) => builder(context, null);
}
