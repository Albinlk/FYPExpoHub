import 'package:flutter/material.dart';

/// A button that cannot be pressed twice. While [busy] it is disabled, shows a
/// small spinner and keeps a text label ([busyLabel] if given) so the button
/// still has an accessible name.
///
/// Prefer this over `onPressed: _busy ? null : _save` with an unchanged label.
class BusyButton extends StatelessWidget {
  const BusyButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.busy,
    this.busyLabel,
    this.style,
    this.outlined = false,
  });

  final String label;
  final String? busyLabel;
  final VoidCallback? onPressed;
  final bool busy;
  final ButtonStyle? style;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final shownLabel = busy ? (busyLabel ?? '$label…') : label;
    final child = busy
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Flexible(child: Text(shownLabel, overflow: TextOverflow.ellipsis)),
            ],
          )
        : Text(label);
    final handler = busy ? null : onPressed;
    final button = outlined
        ? OutlinedButton(onPressed: handler, style: style, child: child)
        : FilledButton(onPressed: handler, style: style, child: child);
    return Semantics(liveRegion: busy, child: button);
  }
}
