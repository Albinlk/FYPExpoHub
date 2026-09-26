import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../domain/csp600_csv_loader.dart';
import '../../domain/title_similarity.dart';
import '../providers/junior_guide_providers.dart';

/// Full list of projects a given project was flagged similar to — opened
/// from the Browse tab's STATUS badge ("N similar") so a reader can see
/// exactly which projects triggered that count and why, instead of just
/// the number. A real route (/projects/junior-guide/similar/:projectId), so
/// browser back and refresh work.
class SimilarProjectsPage extends ConsumerWidget {
  final String projectId;

  const SimilarProjectsPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(similarProjectsProvider(projectId));
    final target = result.asData?.value?.$1;
    final matches = result.asData?.value?.$2 ?? const <SimilarProjectMatch>[];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to the project guide',
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go('/projects/junior-guide'),
        ),
        title: Text(
          target == null ? 'Similar projects' : 'Similar to "${target.title}"',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: result.isLoading
          ? const Center(child: CircularProgressIndicator())
          : target == null
              ? const Center(child: Text('Project not found.'))
              : matches.isEmpty
                  ? const Center(child: Text('No similar projects found.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: matches.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => _MatchTile(match: matches[index]),
                    ),
    );
  }
}

class _MatchTile extends StatelessWidget {
  final SimilarProjectMatch match;

  const _MatchTile({required this.match});

  @override
  Widget build(BuildContext context) {
    final p = match.project;
    // See Csp600CsvLoader.isCsp600: those proposals have no detail page, so
    // they're shown read-only instead of as a link to "Project not found".
    final hasDetailPage = !Csp600CsvLoader.isCsp600(p);

    final content = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DesignSystem.surfaceContainerLowest,
        borderRadius: DesignSystem.radiusLg,
        border: Border.all(color: DesignSystem.surfaceContainer, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p.title,
            style: DesignSystem.bodyMd.copyWith(
              fontWeight: FontWeight.w700,
              color: DesignSystem.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            p.teamDisplayNames.join(', '),
            style: DesignSystem.bodySm
                .copyWith(color: DesignSystem.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (match.byCategory)
                _reasonChip(
                  'Shared categories: ${match.sharedCategories.join(', ')}',
                ),
              if (match.byTitle)
                _reasonChip(
                  'Shared title words: ${match.sharedTitleWords.join(', ')}',
                ),
              if (!hasDetailPage)
                _reasonChip('CSP600 proposal — no detail page yet'),
            ],
          ),
        ],
      ),
    );

    if (!hasDetailPage) return content;
    return InkWell(
      borderRadius: DesignSystem.radiusLg,
      onTap: () => context.go('/projects/${p.slug}'),
      child: content,
    );
  }

  Widget _reasonChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: DesignSystem.primary.withValues(alpha: 0.07),
        borderRadius: DesignSystem.radiusFull,
        border: Border.all(color: DesignSystem.primary.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: DesignSystem.labelCaps.copyWith(
          color: DesignSystem.primary,
          fontSize: 10,
        ),
      ),
    );
  }
}
