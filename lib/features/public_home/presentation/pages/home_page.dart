import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/event.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/widgets/project_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;
    final event = ref.watch(eventProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HERO BANNER SECTION
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [DesignSystem.primary, DesignSystem.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: isDesktop ? 80.0 : 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: DesignSystem.secondary,
                      borderRadius: DesignSystem.radiusFull,
                    ),
                    child: Text(
                      'FSKM FINAL YEAR PROJECT EXHIBITION',
                      style: DesignSystem.labelCaps.copyWith(color: Colors.white),
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(height: DesignSystem.spaceMd),
                  Text(
                    'FYP Expo Hub',
                    style: (isDesktop ? DesignSystem.h1 : DesignSystem.h1Mobile).copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                  const SizedBox(height: DesignSystem.spaceSm),
                  Text(
                    'Exploring Innovation, Empowering Academic Futures',
                    style: (isDesktop ? DesignSystem.bodyLg : DesignSystem.bodyLgMobile).copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                  const SizedBox(height: DesignSystem.spaceLg),

                  // EXHIBITION DETAILS ABOVE TIMER
                  _buildExhibitionDetails(isDesktop, event),

                  const SizedBox(height: DesignSystem.spaceLg),

                  // COUNTDOWN TIMER / EVENT STATUS
                  _CountdownTimer(eventStart: event.startAt, eventEnd: event.endAt),

                  const SizedBox(height: DesignSystem.spaceXl),

                  // Hero CTA Buttons & Search
                  SizedBox(
                    width: isDesktop ? 600 : double.infinity,
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              context.go('/projects?search=$value');
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Search projects, supervisors, or keywords...',
                            prefixIcon: const Icon(Icons.search, color: DesignSystem.primary),
                            suffixIcon: ElevatedButton(
                              onPressed: () {
                                final query = _searchController.text;
                                if (query.isNotEmpty) {
                                  context.go('/projects?search=$query');
                                } else {
                                  context.go('/projects');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DesignSystem.secondaryContainer,
                                foregroundColor: DesignSystem.onSecondaryContainer,
                                shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                              ),
                              child: const Text('Search'),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: DesignSystem.radiusXl,
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: DesignSystem.spaceMd),
                        Wrap(
                          spacing: DesignSystem.spaceMd,
                          runSpacing: DesignSystem.spaceSm,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => context.go('/projects'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DesignSystem.secondaryContainer,
                                foregroundColor: DesignSystem.onSecondaryContainer,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusFull),
                              ),
                              child: Text('Explore Project Catalogue', style: DesignSystem.button),
                            ),
                            ElevatedButton(
                              onPressed: () => context.go('/projects/junior-guide'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DesignSystem.tertiaryContainer,
                                foregroundColor: DesignSystem.onTertiaryContainer,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusFull),
                              ),
                              child: Text('Past Sem Projects', style: DesignSystem.button),
                            ),
                            ElevatedButton(
                              onPressed: () => context.go('/lecturer'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DesignSystem.tertiaryContainer,
                                foregroundColor: DesignSystem.onTertiaryContainer,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusFull),
                              ),
                              child: Text('Lecturer Portal', style: DesignSystem.button),
                            ),
                            OutlinedButton(
                              onPressed: () => context.go('/schedule'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white30, width: 1.5),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusFull),
                              ),
                              child: Text('View Schedule', style: DesignSystem.button),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. FEATURED PROJECTS SECTION
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: DesignSystem.spaceXl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Featured Projects', style: (isDesktop ? DesignSystem.h2 : DesignSystem.h2Mobile).copyWith(color: DesignSystem.primary)),
                      TextButton(
                        onPressed: () => context.go('/projects'),
                        child: Row(
                          children: const [
                            Text('View All', style: TextStyle(fontWeight: FontWeight.bold, color: DesignSystem.secondary)),
                            Icon(Icons.arrow_forward_ios, size: 14, color: DesignSystem.secondary),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignSystem.spaceMd),
                  Consumer(
                    builder: (context, ref, child) {
                      final sorted = ref.watch(mostVisitedProjectsProvider);
                      final display = sorted.take(10).toList();
                      if (display.isEmpty) return const SizedBox.shrink();
                      if (isDesktop) {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: DesignSystem.spaceMd,
                            mainAxisSpacing: DesignSystem.spaceMd,
                            childAspectRatio: 1.55,
                          ),
                          itemCount: display.length,
                          itemBuilder: (context, index) => ProjectCard(
                            project: display[index],
                            onTap: () => context.go('/projects/${display[index].slug}'),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: display.length,
                        itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.only(
                            bottom: index == display.length - 1 ? 0 : DesignSystem.spaceMd,
                          ),
                          child: ProjectCard(
                            project: display[index],
                            imageHeight: 160,
                            onTap: () => context.go('/projects/${display[index].slug}'),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 3. ESSENTIAL INFORMATION SUMMARY
            Container(
              width: double.infinity,
              color: DesignSystem.surfaceContainerLow,
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: DesignSystem.spaceXl),
              child: Column(
                children: [
                  Text('Exhibition Overview', style: (isDesktop ? DesignSystem.h2 : DesignSystem.h2Mobile).copyWith(color: DesignSystem.primary)),
                  const SizedBox(height: DesignSystem.spaceLg),
                  isDesktop
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildInfoTile(Icons.calendar_month, 'Exhibition Dates', _eventDates(event)),
                            _buildInfoTile(Icons.location_on, 'Main Venue', event.venue),
                            _buildInfoTile(Icons.hourglass_top, 'Visiting Hours', event.dailyHours),
                          ],
                        )
                      : Column(
                          children: [
                            _buildInfoTile(Icons.calendar_month, 'Exhibition Dates', _eventDates(event)),
                            const SizedBox(height: DesignSystem.spaceMd),
                            _buildInfoTile(Icons.location_on, 'Main Venue', event.venue),
                            const SizedBox(height: DesignSystem.spaceMd),
                            _buildInfoTile(Icons.hourglass_top, 'Visiting Hours', event.dailyHours),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "06 - 07 August 2026" derived from the live event record.
  String _eventDates(Event event) {
    final s = event.startAt.toLocal();
    final e = event.endAt.toLocal();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    if (s.month == e.month && s.year == e.year) {
      return '${s.day.toString().padLeft(2, '0')} - '
          '${e.day.toString().padLeft(2, '0')} ${months[e.month - 1]} ${e.year}';
    }
    return '${s.day}/${s.month}/${s.year} - ${e.day}/${e.month}/${e.year}';
  }

  Widget _buildExhibitionDetails(bool isDesktop, Event event) {
    final items = [
      _buildExhibitionDetailItem(
        Icons.calendar_month_rounded,
        'Date',
        _eventDates(event),
      ),
      _buildExhibitionDetailItem(
        Icons.access_time_rounded,
        'Time',
        event.dailyHours,
      ),
      _buildExhibitionDetailItem(
        Icons.location_on_rounded,
        'Venue',
        event.venue,
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? DesignSystem.spaceLg : DesignSystem.spaceLg,
        vertical: DesignSystem.spaceMd,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: DesignSystem.radiusXl,
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: isDesktop
          ? IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  items[0],
                  _buildVerticalDivider(),
                  items[1],
                  _buildVerticalDivider(),
                  items[2],
                ],
              ),
            )
          : IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  items[0],
                  const SizedBox(height: DesignSystem.spaceSm),
                  Container(height: 1, color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: DesignSystem.spaceSm),
                  items[1],
                  const SizedBox(height: DesignSystem.spaceSm),
                  Container(height: 1, color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: DesignSystem.spaceSm),
                  items[2],
                ],
              ),
            ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DesignSystem.spaceLg),
      width: 1,
      color: Colors.white.withOpacity(0.15),
    );
  }

  Widget _buildExhibitionDetailItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: DesignSystem.secondaryContainer.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: DesignSystem.secondaryContainer,
            size: 20,
          ),
        ),
        const SizedBox(width: DesignSystem.spaceSm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: DesignSystem.labelCaps.copyWith(
                color: Colors.white60,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: DesignSystem.bodyMd.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
            ),
          ],
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildCountdownDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        ':',
        style: TextStyle(color: Colors.white30, fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }


  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.all(DesignSystem.spaceMd),
      decoration: BoxDecoration(
        color: DesignSystem.surfaceContainerLowest,
        borderRadius: DesignSystem.radiusLg,
        border: Border.all(color: DesignSystem.surfaceContainer),
      ),
      child: Column(
        children: [
          Icon(icon, color: DesignSystem.secondary, size: 36),
          const SizedBox(height: DesignSystem.spaceSm),
          Text(label, style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant), textAlign: TextAlign.center),
          const SizedBox(height: DesignSystem.spaceXs),
          Text(value, style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary), textAlign: TextAlign.center, softWrap: true),
        ],
      ),
    );
  }
}

/// Isolated countdown timer widget — only this rebuilds every second,
/// not the entire HomePage. Shows a "concluded" state after the event ends
/// and stops ticking.
class _CountdownTimer extends StatefulWidget {
  final DateTime eventStart;
  final DateTime eventEnd;

  const _CountdownTimer({required this.eventStart, required this.eventEnd});

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  Timer? _timer;
  Duration _timeRemaining = const Duration();
  bool _concluded = false;
  bool _live = false;

  @override
  void initState() {
    super.initState();
    _calculateTimeRemaining();
    if (!_concluded) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _calculateTimeRemaining();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateTimeRemaining() {
    final now = DateTime.now();
    if (widget.eventEnd.isBefore(now)) {
      // Event finished — stop ticking.
      _timer?.cancel();
      setState(() {
        _concluded = true;
        _live = false;
        _timeRemaining = Duration.zero;
      });
    } else if (widget.eventStart.isBefore(now)) {
      // Event in progress.
      setState(() {
        _live = true;
        _timeRemaining = widget.eventEnd.difference(now);
      });
    } else {
      setState(() {
        _timeRemaining = widget.eventStart.difference(now);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    if (_concluded) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: DesignSystem.radiusXl,
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: DesignSystem.secondaryContainer, size: 20),
            const SizedBox(width: DesignSystem.spaceSm),
            Text(
              'Exhibition Concluded — Thank You for Visiting',
              style: DesignSystem.bodyMd.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (_live) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: DesignSystem.secondaryContainer.withValues(alpha: 0.15),
          borderRadius: DesignSystem.radiusXl,
          border: Border.all(color: DesignSystem.secondaryContainer),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, color: DesignSystem.secondaryContainer, size: 20),
            const SizedBox(width: DesignSystem.spaceSm),
            Text(
              'The Exhibition is Live Now!',
              style: DesignSystem.bodyMd.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    final days = _timeRemaining.inDays;
    final hours = _timeRemaining.inHours % 24;
    final minutes = _timeRemaining.inMinutes % 60;
    final seconds = _timeRemaining.inSeconds % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCountdownItem(days.toString().padLeft(2, '0'), 'Days', isDesktop),
        _buildCountdownDivider(),
        _buildCountdownItem(hours.toString().padLeft(2, '0'), 'Hours', isDesktop),
        _buildCountdownDivider(),
        _buildCountdownItem(minutes.toString().padLeft(2, '0'), 'Mins', isDesktop),
        _buildCountdownDivider(),
        _buildCountdownItem(seconds.toString().padLeft(2, '0'), 'Secs', isDesktop),
      ],
    );
  }

  Widget _buildCountdownItem(String value, String label, bool isDesktop) {
    return Container(
      constraints: const BoxConstraints(minWidth: 60, maxWidth: 80),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: DesignSystem.spaceSm),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: DesignSystem.radiusLg,
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: (isDesktop ? DesignSystem.h3 : DesignSystem.h3Mobile).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: DesignSystem.labelCaps.copyWith(color: Colors.white60, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        ':',
        style: TextStyle(color: Colors.white30, fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
