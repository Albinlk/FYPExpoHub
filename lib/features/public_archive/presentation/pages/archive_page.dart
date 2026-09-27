import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/widgets/project_card.dart';
import '../../archive_data.dart';

/// Public list of past exhibitions (backlog S7). The current one is the rest
/// of the site; earlier ones keep their projects and award winners here.
class ArchivePage extends ConsumerWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(exhibitionsProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile,
        vertical: DesignSystem.spaceXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Past Exhibitions', style: DesignSystem.pageTitle(context).copyWith(color: DesignSystem.primary)),
          const SizedBox(height: DesignSystem.spaceSm),
          Text(
            'Projects and award winners from earlier FSKM FYP exhibitions.',
            style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant),
          ),
          const SizedBox(height: DesignSystem.spaceLg),
          events.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text("Couldn't load past exhibitions. Check your connection and try again.",
                style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant)),
            data: (list) {
              final past = [for (final e in list) if (!e.isCurrent) e];
              if (past.isEmpty) {
                return Text('No past exhibitions yet.', style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant));
              }
              return Column(
                children: [
                  for (final e in past)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.history_edu, color: DesignSystem.primary),
                        title: Text(e.title, style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Text('${e.year}${e.venue == null ? '' : ' · ${e.venue}'}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go('/archive/${e.slug}'),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// One past exhibition: its projects (read-only) and award winners.
class ArchivedEventPage extends ConsumerWidget {
  const ArchivedEventPage({super.key, required this.slug});

  final String slug;

  void _showProject(BuildContext context, Project p) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(p.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.teamDisplayNames.join(', '), style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.w600)),
              Text('${p.programmeName} · Supervisor: ${p.supervisorDisplayName}', style: DesignSystem.bodySm),
              const SizedBox(height: DesignSystem.spaceSm),
              Text(p.shortDescription),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(archivedEventProvider(slug));
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final pad = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;
    return data.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.spaceLg),
          child: Text('This exhibition could not be found.', style: DesignSystem.bodyMd),
        ),
      ),
      data: (d) {
        final (event, projects, winners) = d;
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(pad, DesignSystem.spaceXl, pad, DesignSystem.spaceMd),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: () => context.go('/archive'),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Past exhibitions'),
                    ),
                    Text(event.title, style: DesignSystem.pageTitle(context).copyWith(color: DesignSystem.primary)),
                    Text('${event.year}${event.venue == null ? '' : ' · ${event.venue}'} · ${projects.length} projects',
                        style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant)),
                    if (winners.isNotEmpty) ...[
                      const SizedBox(height: DesignSystem.spaceLg),
                      Text('Award winners', style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary)),
                      for (final w in winners)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.emoji_events, color: DesignSystem.secondary),
                          title: Text(w.projectTitle),
                          subtitle: Text(w.teamDisplayName ?? ''),
                        ),
                    ],
                    const SizedBox(height: DesignSystem.spaceLg),
                    Text('Projects', style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary)),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(pad, 0, pad, DesignSystem.spaceXl),
              sliver: SliverGrid(
                gridDelegate: ProjectCard.gridDelegate(MediaQuery.sizeOf(context).width),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => ProjectCard(project: projects[i], onTap: () => _showProject(context, projects[i])),
                  childCount: projects.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
