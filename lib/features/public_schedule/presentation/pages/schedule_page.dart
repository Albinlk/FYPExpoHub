import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/schedule_item.dart';
import '../../../../core/state/state_providers.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _days = ['Day 1 (6 Ogos)', 'Day 2 (7 Ogos)'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _days.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;

    final allScheduleItems = ref.watch(scheduleProvider);
    final publishedItems = allScheduleItems.where((item) => item.publicationStatus == 'published').toList();

    // Group items by day
    final day1Items = publishedItems.where((item) => item.date.day == 6).toList();
    final day2Items = publishedItems.where((item) => item.date.day == 7).toList();

    // Sort items chronologically by their start time string
    // In production, we'd use robust time parsing, but simple string sorting is fine for well-formatted times.
    day1Items.sort((a, b) => a.startAt.compareTo(b.startAt));
    day2Items.sort((a, b) => a.startAt.compareTo(b.startAt));

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: DesignSystem.spaceXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event Schedule', style: DesignSystem.h1.copyWith(color: DesignSystem.primary)),
            const SizedBox(height: DesignSystem.spaceSm),
            Text(
              'Full timeline schedule for all exhibition days.',
              style: DesignSystem.bodyLg.copyWith(color: DesignSystem.onSurfaceVariant),
              softWrap: true,
            ),
            const SizedBox(height: DesignSystem.spaceXl),

            // Tab Bar
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: isDesktop ? TabAlignment.center : TabAlignment.start,
              tabs: _days.map((day) => Tab(text: day)).toList(),
              labelStyle: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold),
              unselectedLabelColor: DesignSystem.onSurfaceVariant,
              labelColor: DesignSystem.primary,
              indicatorColor: DesignSystem.secondary,
              indicatorSize: TabBarIndicatorSize.tab,
            ),
            const SizedBox(height: DesignSystem.spaceLg),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDayTimeline(day1Items, isDesktop),
                  _buildDayTimeline(day2Items, isDesktop),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayTimeline(List<ScheduleItem> items, bool isDesktop) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.spaceLg),
          child: Text(
            'No schedule slots available for this day.',
            style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isInternal = item.visibility == 'internal';
        final isOngoing = false; // We can set this if time is within bounds, default to false.

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Time info
              SizedBox(
                width: isDesktop ? 95 : 75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.startAt,
                      style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary),
                      softWrap: true,
                    ),
                    Text(
                      item.endAt,
                      style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant, fontSize: 12),
                      softWrap: true,
                    ),
                  ],
                ),
              ),

              // Middle: Line dot
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isOngoing ? DesignSystem.secondaryContainer : DesignSystem.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                  if (index != items.length - 1)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: DesignSystem.surfaceContainer,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: DesignSystem.spaceSm),

              // Right: Details Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(DesignSystem.spaceMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isInternal || isOngoing)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  if (isInternal)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: DesignSystem.tertiaryContainer,
                                        borderRadius: DesignSystem.radiusSm,
                                      ),
                                      child: Text(
                                        'Internal',
                                        style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onTertiaryContainer, fontSize: 10),
                                      ),
                                    ),
                                  if (isOngoing)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: DesignSystem.secondaryContainer,
                                        borderRadius: DesignSystem.radiusSm,
                                      ),
                                      child: Text(
                                        'Ongoing',
                                        style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSecondaryContainer, fontSize: 10),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          Text(
                            item.title,
                            style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary),
                            softWrap: true,
                          ),
                          if (item.description != null && item.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                              child: Text(
                                item.description!,
                                style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                              ),
                            ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on, size: 14, color: DesignSystem.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      item.venue,
                                      style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.groups, size: 14, color: DesignSystem.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      item.audience,
                                      style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
