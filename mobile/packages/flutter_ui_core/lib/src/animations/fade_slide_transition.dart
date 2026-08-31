import 'package:flutter/material.dart';

/// A widget that fades in and slides from a configurable offset simultaneously.
///
/// Useful for staggered list item entries and page transitions.
class FadeSlideTransition extends StatefulWidget {
  const FadeSlideTransition({
    super.key,
    required this.child,
    this.offset = const Offset(0, 24),
    this.duration = const Duration(milliseconds: 350),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.animate = true,
  });

  /// The child widget to animate in.
  final Widget child;

  /// Pixel offset from which the child slides in (default: 24px from bottom).
  final Offset offset;

  /// Duration of the combined fade + slide animation.
  final Duration duration;

  /// Delay before the animation starts.
  final Duration delay;

  /// Animation curve.
  final Curve curve;

  /// Set to false to disable animation and show the child immediately.
  final bool animate;

  @override
  State<FadeSlideTransition> createState() => _FadeSlideTransitionState();
}

class _FadeSlideTransitionState extends State<FadeSlideTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);

    _opacity = Tween<double>(begin: 0, end: 1).animate(curved);
    _position = Tween<Offset>(begin: widget.offset, end: Offset.zero)
        .animate(curved);

    if (widget.animate) {
      if (widget.delay > Duration.zero) {
        Future.delayed(widget.delay, () {
          if (mounted) _controller.forward();
        });
      } else {
        _controller.forward();
      }
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: _position.value,
        child: Opacity(
          opacity: _opacity.value,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
