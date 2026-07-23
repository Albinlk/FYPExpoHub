import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/domain/models/award.dart';
import '../../../../core/state/state_providers.dart';

class AwardsPage extends ConsumerWidget {
  const AwardsPage({super.key});

  String _getAwardTitle(PublishedAwardWinner award) {
    if (award.awardCategoryId == 'cat-manual') {
      return award.projectTitle; // Custom title stored in projectTitle
    }
    if (award.awardCategoryId == 'cat-gold') {
      return 'Gold Innovation Award';
    }
    if (award.awardCategoryId == 'cat-best-innovative') {
      return 'Best Innovative Project Award';
    }
    return 'Final Year Project Award';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;

    final allAwards = ref.watch(awardsProvider);
    final publishedAwards = allAwards.where((a) => a.publicationStatus == 'published').toList();

    final projects = ref.watch(projectsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: DesignSystem.spaceXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: DesignSystem.secondary, size: 36),
                const SizedBox(width: 12),
                Text('Award Winners', style: DesignSystem.h1.copyWith(color: DesignSystem.primary)),
              ],
            ),
            const SizedBox(height: DesignSystem.spaceSm),
            Text('Official showcase of outstanding projects and FSKM innovation award winners.', style: DesignSystem.bodyLg.copyWith(color: DesignSystem.onSurfaceVariant), softWrap: true),
            const SizedBox(height: DesignSystem.spaceXl),

            publishedAwards.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Text(
                        'Award winners have not been published yet. Check back soon!',
                        style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: publishedAwards.length,
                    itemBuilder: (context, index) {
                      final award = publishedAwards[index];
                      final associatedProj = projects.cast<Project?>().firstWhere(
                        (p) => p?.id == award.projectId,
                        orElse: () => null,
                      );

                      final awardTitle = _getAwardTitle(award);
                      final winningProjectTitle = award.awardCategoryId == 'cat-manual'
                          ? (associatedProj?.title ?? 'N/A')
                          : award.projectTitle;

                      final teamName = award.teamDisplayName ?? associatedProj?.teamDisplayNames.join(', ') ?? 'N/A';
                      final supervisor = associatedProj?.supervisorDisplayName ?? award.supervisorDisplayName ?? 'N/A';
                      final progName = associatedProj?.programmeName ?? associatedProj?.programmeCode ?? award.programmeCode ?? 'N/A';

                      return Card(
                        margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
                        child: Padding(
                          padding: const EdgeInsets.all(DesignSystem.spaceLg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: DesignSystem.secondaryContainer,
                                  borderRadius: DesignSystem.radiusSm,
                                  border: Border.all(color: DesignSystem.secondary.withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.emoji_events, color: DesignSystem.onSecondaryContainer, size: 16),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        awardTitle,
                                        style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSecondaryContainer, fontWeight: FontWeight.bold),
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: DesignSystem.spaceMd),
                              Text(
                                winningProjectTitle,
                                style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary),
                                softWrap: true,
                              ),
                              const SizedBox(height: DesignSystem.spaceSm),
                              Text('Student(s): $teamName', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant), softWrap: true),
                              Text('Supervisor: $supervisor', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant, fontStyle: FontStyle.italic), softWrap: true),
                              const SizedBox(height: DesignSystem.spaceMd),
                              const Divider(),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text('Program: $progName', style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.w500), softWrap: true),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: DesignSystem.primaryContainer,
                                        borderRadius: DesignSystem.radiusSm,
                                      ),
                                      child: Text(
                                        'UiTM Official Award',
                                        style: DesignSystem.labelCaps.copyWith(color: Colors.white, fontSize: 8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
