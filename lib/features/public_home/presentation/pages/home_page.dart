import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/utils/external_link.dart';
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
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [DesignSystem.primary, DesignSystem.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                // Admin-set hero photo (Event → Hero Image URL), tinted with
                // the brand ink so the white hero text keeps its contrast.
                image: safeExternalUri(event.heroImageUrl) == null
                    ? null
                    : DecorationImage(
                        image: NetworkImage(safeExternalUri(event.heroImageUrl)!.toString()),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          DesignSystem.primary.withValues(alpha: 0.8),
                          BlendMode.srcOver,
                        ),
                        onError: (_, _) {},
                      ),
              ),
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: isDesktop ? 80.0 : 28.0),
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
                  SizedBox(height: isDesktop ? DesignSystem.spaceLg : DesignSystem.spaceMd),

                  // EXHIBITION DETAILS ABOVE TIMER
                  _buildExhibitionDetails(isDesktop, event),

                  SizedBox(height: isDesktop ? DesignSystem.spaceLg : DesignSystem.spaceMd),

                  // COUNTDOWN TIMER / EVENT STATUS
                  _CountdownTimer(eventStart: event.startAt, eventEnd: event.endAt, compact: !isDesktop),

                  SizedBox(height: isDesktop ? DesignSystem.spaceXl : DesignSystem.spaceLg),

                  // Hero CTA Buttons & Search
                  SizedBox(
                    width: isDesktop ? 600 : double.infinity,
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              context.go(Uri(path: '/projects', queryParameters: {'search': value}).toString());
                            }
                          },
                          decoration: InputDecoration(
                            hintText: isDesktop
                                ? 'Search projects, supervisors, or keywords...'
                                : 'Search projects...',
                            prefixIcon: const Icon(Icons.search, color: DesignSystem.primary),
                            suffixIcon: ElevatedButton(
                              onPressed: () {
                                final query = _searchController.text;
                                if (query.isNotEmpty) {
                                  context.go(Uri(path: '/projects', queryParameters: {'search': query}).toString());
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
                              child: Text('Explore Projects', style: DesignSystem.button),
                            ),
                            // Past Sem Projects and Lecturer Portal live in the
                            // navigation; the hero keeps one primary action.
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
                    children: [
                      Expanded(
                        child: Text(
                          'Featured Projects',
                          // Centered on mobile to match the Exhibition
                          // Overview section; left on desktop.
                          textAlign:
                              isDesktop ? TextAlign.start : TextAlign.center,
                          style: (isDesktop ? DesignSystem.h2 : DesignSystem.h2Mobile).copyWith(color: DesignSystem.primary),
                        ),
                      ),
                      if (isDesktop)
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
                  if (!isDesktop)
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/projects'),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('View All', style: TextStyle(fontWeight: FontWeight.bold, color: DesignSystem.secondary)),
                            Icon(Icons.arrow_forward_ios, size: 14, color: DesignSystem.secondary),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: DesignSystem.spaceMd),
                  Consumer(
                    builder: (context, ref, child) {
                      final sorted = ref.watch(mostVisitedProjectsProvider);
                      // A short, curated row: the catalogue is for browsing everything.
                      final display = featuredForHome(sorted);
                      if (display.isEmpty) return const SizedBox.shrink();
                      if (isDesktop) {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: ProjectCard.gridDelegate(MediaQuery.sizeOf(context).width),
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
    // Mobile: one compact wrapped line (icon + value, no labels) instead of
    // a three-row boxed block, so the whole hero fits on one screen.
    if (!isDesktop) {
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: DesignSystem.spaceMd,
        runSpacing: DesignSystem.spaceXs,
        children: [
          _buildCompactDetail(Icons.calendar_month_rounded, _eventDates(event)),
          _buildCompactDetail(Icons.access_time_rounded, event.dailyHours),
          _buildCompactDetail(Icons.location_on_rounded, event.venue),
        ],
      );
    }

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
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: DesignSystem.radiusXl,
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: IntrinsicHeight(
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
      ),
    );
  }

  Widget _buildCompactDetail(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: DesignSystem.secondaryContainer, size: 16),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.center,
            softWrap: true,
            style: DesignSystem.bodySm.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DesignSystem.spaceLg),
      width: 1,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }

  Widget _buildExhibitionDetailItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: DesignSystem.secondaryContainer.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: DesignSystem.secondaryContainer,
            size: 20,
          ),
        ),
        const SizedBox(width: DesignSystem.spaceSm),
        // Flexible so long values (e.g. multi-line venue names) wrap within
        // the hero width instead of overflowing the row on narrow screens.
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: DesignSystem.labelCaps.copyWith(
                  color: Colors.white60,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                textAlign: TextAlign.center,
                style: DesignSystem.bodyMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                softWrap: true,
              ),
            ],
          ),
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

  /// Mobile: the concluded / live states render as a small pill.
  final bool compact;

  const _CountdownTimer({required this.eventStart, required this.eventEnd, this.compact = false});

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
      return _statusBadge(
        icon: Icons.emoji_events,
        text: widget.compact ? 'Exhibition concluded — thank you!' : 'Exhibition Concluded — Thank You for Visiting',
        fill: Colors.white.withValues(alpha: 0.08),
        border: Colors.white24,
      );
    }

    if (_live) {
      return _statusBadge(
        icon: Icons.celebration,
        text: 'The Exhibition is Live Now!',
        fill: DesignSystem.secondaryContainer.withValues(alpha: 0.15),
        border: DesignSystem.secondaryContainer,
      );
    }

    final days = _timeRemaining.inDays;
    final hours = _timeRemaining.inHours % 24;
    final minutes = _timeRemaining.inMinutes % 60;
    final seconds = _timeRemaining.inSeconds % 60;

    // FittedBox scales the 4-item strip down on narrow screens instead of
    // overflowing (pre-existing 25px overflow at ~390px).
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
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
      ),
    );
  }

  Widget _statusBadge({required IconData icon, required String text, required Color fill, required Color border}) {
    final compact = widget.compact;
    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
          : const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: compact ? DesignSystem.radiusFull : DesignSystem.radiusXl,
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: DesignSystem.secondaryContainer, size: compact ? 16 : 20),
          SizedBox(width: compact ? 6 : DesignSystem.spaceSm),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              softWrap: true,
              style: (compact ? DesignSystem.bodySm : DesignSystem.bodyMd).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownItem(String value, String label, bool isDesktop) {
    return Container(
      constraints: const BoxConstraints(minWidth: 60, maxWidth: 80),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: DesignSystem.spaceSm),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
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
