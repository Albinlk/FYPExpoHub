import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/state_providers.dart';

class AnnouncementsPage extends ConsumerWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;

    final allAnnouncements = ref.watch(announcementsProvider);
    final publishedAnnouncements = allAnnouncements.where((a) => p(a)).toList();

    // Sort announcements: pinned ones first, then by date descending
    publishedAnnouncements.sort((a, b) {
      if (a.pinned && !b.pinned) return -1;
      if (!a.pinned && b.pinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: DesignSystem.spaceXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Announcements', style: DesignSystem.h1.copyWith(color: DesignSystem.primary)),
            const SizedBox(height: DesignSystem.spaceSm),
            Text('Official updates and announcements from the FSKM organizing committee.', style: DesignSystem.bodyLg.copyWith(color: DesignSystem.onSurfaceVariant), softWrap: true),
            const SizedBox(height: DesignSystem.spaceXl),

            publishedAnnouncements.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Text(
                        'No announcements available at this time.',
                        style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: publishedAnnouncements.length,
                    itemBuilder: (context, index) {
                      final ann = publishedAnnouncements[index];
                      final isPinned = ann.pinned;

                      // Format Date
                      final dateText = "${ann.createdAt.day} ${ann.createdAt.month == 7 ? "July" : "August"} ${ann.createdAt.year}";

                      return Card(
                        margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
                        child: Padding(
                          padding: const EdgeInsets.all(DesignSystem.spaceLg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isPinned) ...[
                                          const Icon(Icons.push_pin, color: DesignSystem.secondary, size: 18),
                                          const SizedBox(width: 6),
                                        ],
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isPinned ? DesignSystem.secondaryContainer : DesignSystem.surfaceContainer,
                                              borderRadius: DesignSystem.radiusSm,
                                            ),
                                            child: Text(
                                              ann.category,
                                              style: DesignSystem.labelCaps.copyWith(
                                                color: isPinned ? DesignSystem.onSecondaryContainer : DesignSystem.primary,
                                                fontSize: 10,
                                              ),
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(dateText, style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
                                ],
                              ),
                              const SizedBox(height: DesignSystem.spaceMd),
                              Text(
                                ann.title,
                                style: DesignSystem.h3.copyWith(color: DesignSystem.primary),
                                softWrap: true,
                              ),
                              const SizedBox(height: DesignSystem.spaceSm),
                              Text(
                                ann.body,
                                style: DesignSystem.bodyMd.copyWith(height: 1.6, color: DesignSystem.onBackground),
                                softWrap: true,
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

  bool p(dynamic a) => a.publicationStatus == 'published';
}
