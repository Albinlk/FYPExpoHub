import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/site_hosts.dart';
import '../../../../app/theme/theme.dart';

/// The one place the public site points to the FYP Workspace (CSP600 /
/// CSP650), which is for signed-in students and lecturers only.
class WorkspaceBand extends ConsumerWidget {
  const WorkspaceBand({super.key, required this.padding});

  final double padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FYP WORKSPACE',
          style: DesignSystem.labelCaps.copyWith(color: DesignSystem.secondary),
        ),
        const SizedBox(height: DesignSystem.spaceXs),
        Text(
          'CSP600 Project Formulation and CSP650 Final Year Project',
          style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary),
        ),
        const SizedBox(height: DesignSystem.spaceXs),
        Text(
          'Forms, supervision, presentations and marks. For students and lecturers.',
          style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
        ),
      ],
    );
    final button = FilledButton.icon(
      key: const Key('workspace-band-open'),
      onPressed: () => openCspWorkspace(context, ref),
      icon: const Icon(Icons.arrow_forward, size: 18),
      // Signed-out visitors sign in first, then land in their own workspace.
      label: const Text('Open FYP Workspace'),
    );
    return Container(
      key: const Key('workspace-band'),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: DesignSystem.surfaceContainerLow,
        border: Border(top: BorderSide(color: DesignSystem.outlineVariant)),
      ),
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: DesignSystem.spaceXl),
      child: isDesktop
          ? Row(
              children: [
                Expanded(child: text),
                const SizedBox(width: DesignSystem.spaceLg),
                button,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [text, const SizedBox(height: DesignSystem.spaceMd), button],
            ),
    );
  }
}
