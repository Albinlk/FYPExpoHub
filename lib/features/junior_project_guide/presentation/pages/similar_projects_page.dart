import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../domain/title_similarity.dart';

/// Full list of projects a given [target] was flagged similar to — opened
/// from the Browse tab's STATUS badge ("N similar") so a reader can see
/// exactly which projects triggered that count and why, instead of just
/// the number.
class SimilarProjectsPage extends StatelessWidget {
  final Project target;
  final List<SimilarProjectMatch> matches;

  const SimilarProjectsPage({
    super.key,
    required this.target,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Similar to "${target.title}"',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: matches.isEmpty
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
    return InkWell(
      borderRadius: DesignSystem.radiusLg,
      onTap: () => context.go('/projects/${p.slug}'),
      child: Container(
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
              ],
            ),
          ],
        ),
      ),
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
