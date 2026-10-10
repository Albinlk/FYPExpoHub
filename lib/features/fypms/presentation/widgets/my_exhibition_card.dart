import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/state/state_providers.dart';

/// A CSP650 student's view of their exhibition entry (portal plan P8): whether
/// the coordinator has published it yet and, once published, the booth, day
/// and public project page. The exhibition is part of CSP650 in the FSKM
/// handbook (F10 is scored there) and attendance is required.
class MyExhibitionCard extends ConsumerWidget {
  const MyExhibitionCard({super.key, required this.record});

  final FypRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (record.currentCourseCode != 'CSP650') return const SizedBox.shrink();
    final publications = ref.watch(fypExpoPublicationsProvider);
    final projects = ref.watch(projectsMapProvider);

    final mine = [for (final p in publications.value ?? const []) if (p.fypRecordId == record.id) p];
    final published = mine.where((p) => p.status == 'published').firstOrNull;
    final project = published?.publishedProjectId == null ? null : projects[published!.publishedProjectId];

    final String status;
    final String detail;
    if (publications.isLoading && !publications.hasValue) {
      status = 'Checking…';
      detail = '';
    } else if (publications.hasError && !publications.hasValue) {
      status = 'Could not check';
      detail = 'Try again later, or ask the FYP coordinator.';
    } else if (project != null) {
      status = 'Published';
      detail = [
        if (project.boothNumber?.isNotEmpty == true) 'Booth ${project.boothNumber}',
        if (project.presentationDay?.isNotEmpty == true) project.presentationDay!,
      ].join(' · ');
    } else if (published != null) {
      status = 'Published';
      detail = 'Your booth and day will appear here once the exhibition list updates.';
    } else if (mine.isNotEmpty) {
      status = 'Being prepared';
      detail = 'The coordinator is preparing your exhibition page.';
    } else {
      status = 'Not published yet';
      detail = 'The coordinator publishes CSP650 projects to the exhibition before the event.';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storefront_outlined, color: DesignSystem.secondary),
                const SizedBox(width: DesignSystem.spaceSm),
                Expanded(
                  child: Text('My Exhibition', style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold)),
                ),
                Text(
                  status,
                  key: const Key('my-exhibition-status'),
                  style: DesignSystem.bodySm.copyWith(
                    color: project != null ? DesignSystem.tertiary : DesignSystem.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (detail.isNotEmpty) ...[
              const SizedBox(height: DesignSystem.spaceXs),
              Text(detail, style: DesignSystem.bodySm),
            ],
            const SizedBox(height: DesignSystem.spaceXs),
            Text(
              'Attending the exhibition is required: no presentation means an F (FSKM handbook).',
              style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
            ),
            if (project != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/projects/${project.slug}'),
                  child: const Text('View My Exhibition Page'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
