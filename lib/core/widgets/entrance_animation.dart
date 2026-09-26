import 'package:flutter/material.dart';

/// Hero tag shared by a project's catalogue card cover and its detail-page
/// cover, so the image flies between the two on navigation.
String projectCoverHeroTag(String projectId) => 'project-cover-$projectId';

/// Fades and lifts [child] in on first build, staggered by [index] so a grid
/// "arrives" row by row instead of popping in all at once.
///
/// The delay is folded into the controller as an [Interval] rather than a
/// Timer, so no timer is ever left pending (which would fail widget tests),
/// and it's capped so items far down a long list don't wait visibly.
/// Skipped entirely when the platform asks for reduced motion.
class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  static const _step = Duration(milliseconds: 45);
  static const _maxStaggered = 8;
  static const _duration = Duration(milliseconds: 260);

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _progress;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return;

    final slot = widget.index.clamp(0, StaggeredEntrance._maxStaggered);
    final delay = StaggeredEntrance._step * slot;
    final total = delay + StaggeredEntrance._duration;
    _controller = AnimationController(vsync: this, duration: total);
    _progress = CurvedAnimation(
      parent: _controller!,
      curve: Interval(
        delay.inMicroseconds / total.inMicroseconds,
        1,
        curve: Curves.easeOutCubic,
      ),
    );
    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progress;
    if (progress == null) return widget.child;
    return AnimatedBuilder(
      animation: progress,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: progress.value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - progress.value)),
          child: child,
        ),
      ),
    );
  }
}
