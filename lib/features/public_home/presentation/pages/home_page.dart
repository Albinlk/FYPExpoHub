import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/state/state_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late Timer _timer;
  Duration _timeRemaining = const Duration();
  final DateTime _eventDate = DateTime(2026, 8, 6, 9, 0);

  @override
  void initState() {
    super.initState();
    _calculateTimeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimeRemaining();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _calculateTimeRemaining() {
    final now = DateTime.now();
    if (_eventDate.isAfter(now)) {
      setState(() {
        _timeRemaining = _eventDate.difference(now);
      });
    } else {
      setState(() {
        _timeRemaining = Duration.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;

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
                    style: DesignSystem.bodyLg.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                  const SizedBox(height: DesignSystem.spaceLg),

                  // EXHIBITION DETAILS ABOVE TIMER
                  _buildExhibitionDetails(isDesktop),

                  const SizedBox(height: DesignSystem.spaceLg),

                  // COUNTDOWN TIMER
                  _buildCountdown(isDesktop),

                  const SizedBox(height: DesignSystem.spaceXl),

                  // Hero CTA Buttons & Search
                  SizedBox(
                    width: isDesktop ? 600 : double.infinity,
                    child: Column(
                      children: [
                        TextField(
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
                                context.go('/projects');
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
                              child: Text('Explore Project Catalog', style: DesignSystem.button),
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
                      Text('Featured Projects', style: DesignSystem.h2.copyWith(color: DesignSystem.primary)),
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
                      final display = sorted.take(3).toList();
                      if (display.isEmpty) return const SizedBox.shrink();
                      if (isDesktop) {
                        return Row(
                          children: List.generate(display.length * 2 - 1, (i) {
                            if (i.isOdd) return const SizedBox(width: DesignSystem.spaceMd);
                            return Expanded(child: _buildFeaturedCard(display[i ~/ 2]));
                          }),
                        );
                      }
                      return Column(
                        children: display
                            .map((p) => Padding(
                                  padding: EdgeInsets.only(
                                    bottom: p == display.last ? 0 : DesignSystem.spaceMd,
                                  ),
                                  child: _buildFeaturedCard(p),
                                ))
                            .toList(),
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
                  Text('Exhibition Overview', style: DesignSystem.h2.copyWith(color: DesignSystem.primary)),
                  const SizedBox(height: DesignSystem.spaceLg),
                  isDesktop
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildInfoTile(Icons.calendar_month, 'Exhibition Dates', '06 - 07 Ogos 2026'),
                            _buildInfoTile(Icons.location_on, 'Main Venue', 'Blok Kuliah, FSKM'),
                            _buildInfoTile(Icons.hourglass_top, 'Visiting Hours', '9:00 AM - 5:00 PM'),
                          ],
                        )
                      : Column(
                          children: [
                            _buildInfoTile(Icons.calendar_month, 'Exhibition Dates', '06 - 07 Ogos 2026'),
                            const SizedBox(height: DesignSystem.spaceMd),
                            _buildInfoTile(Icons.location_on, 'Main Venue', 'Blok Kuliah, FSKM'),
                            const SizedBox(height: DesignSystem.spaceMd),
                            _buildInfoTile(Icons.hourglass_top, 'Visiting Hours', '9:00 AM - 5:00 PM'),
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

  Widget _buildExhibitionDetails(bool isDesktop) {
    final items = [
      _buildExhibitionDetailItem(
        Icons.calendar_month_rounded,
        'Date',
        '06 - 07 Ogos 2026',
      ),
      _buildExhibitionDetailItem(
        Icons.access_time_rounded,
        'Time',
        '9:00 AM - 5:00 PM',
      ),
      _buildExhibitionDetailItem(
        Icons.location_on_rounded,
        'Venue',
        'Blok Kuliah, FSKM',
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

  Widget _buildCountdown(bool isDesktop) {
    final days = _timeRemaining.inDays;
    final hours = _timeRemaining.inHours % 24;
    final minutes = _timeRemaining.inMinutes % 60;
    final seconds = _timeRemaining.inSeconds % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCountdownItem(days.toString().padLeft(2, '0'), 'Days'),
        _buildCountdownDivider(),
        _buildCountdownItem(hours.toString().padLeft(2, '0'), 'Hours'),
        _buildCountdownDivider(),
        _buildCountdownItem(minutes.toString().padLeft(2, '0'), 'Mins'),
        _buildCountdownDivider(),
        _buildCountdownItem(seconds.toString().padLeft(2, '0'), 'Secs'),
      ],
    );
  }

  Widget _buildCountdownItem(String value, String label) {
    return Container(
      width: 70,
      padding: const EdgeInsets.all(DesignSystem.spaceSm),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: DesignSystem.radiusLg,
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
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

  Widget _buildFeaturedCard(Project project) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: DesignSystem.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                project.coverImageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.image, size: 48, color: DesignSystem.primaryContainer),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(DesignSystem.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: DesignSystem.secondaryContainer,
                    borderRadius: DesignSystem.radiusSm,
                  ),
                  child: Text(
                    project.category,
                    style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSecondaryContainer, fontSize: 10),
                  ),
                ),
                const SizedBox(height: DesignSystem.spaceSm),
                Text(
                  project.title,
                  style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
                const SizedBox(height: DesignSystem.spaceXs),
                Text(
                  'Student: ${project.teamDisplayNames.join(', ')}',
                  style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                  softWrap: true,
                ),
                Text(
                  'Supervisor: ${project.supervisorDisplayName}',
                  style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant, fontStyle: FontStyle.italic),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      width: 260,
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
