import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ScrollReveal extends StatefulWidget {
  final Widget child;
  final int delayMs;
  final double offsetY;

  const ScrollReveal({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.offsetY = 18,
  });

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  bool _triggered = false;
  late final Key _visibilityKey;

  @override
  void initState() {
    super.initState();
    _visibilityKey = ValueKey('scroll-reveal-${identityHashCode(this)}');
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.offsetY / 100),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startReveal() {
    if (_triggered) return;
    _triggered = true;
    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.12) {
          _startReveal();
        }
      },
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(position: _slide, child: widget.child),
      ),
    );
  }
}
