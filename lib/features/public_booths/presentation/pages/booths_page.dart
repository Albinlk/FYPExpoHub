import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/state/state_providers.dart';

class BoothsPage extends ConsumerStatefulWidget {
  const BoothsPage({super.key});

  @override
  ConsumerState<BoothsPage> createState() => _BoothsPageState();
}

class _BoothsPageState extends ConsumerState<BoothsPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _selectedDay = 'Day 1 - 06 Aug 2026';
  String _selectedVenue = 'All';
  String _selectedProgram = 'All';

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Static map from Excel booth-number prefix to a human-friendly venue label.
  /// Source: `StudentListName.xlsx` `- List Name` sheets.
  static const Map<String, String> _prettyVenueByPrefix = {
    // CS230 (DS 5-6)
    'DS5': 'DS 5',
    'DS6': 'DS 6',
    // CS266 (DS 7-8)
    'DS7': 'DS 7',
    'DS8': 'DS 8',
    // CS255 (BILIK KULIAH 1 - 4)
    'BK1': 'BK 1',
    'BK2': 'BK 2',
    'BK3': 'BK 3',
    'BK4': 'BK 4',
    // CS251 (BK 5 - 8)
    'BK5': 'BK 5',
    'BK6': 'BK 6',
    'BK7': 'BK 7',
    'BK8': 'BK 8',
  };

  /// Canonical venue order matching the physical hall layout (top to bottom).
  static const List<String> _venueOrder = [
    'BK 1', 'BK 2', 'BK 3', 'BK 4',
    'BK 5', 'BK 6', 'BK 7', 'BK 8',
    'DS 5', 'DS 6', 'DS 7', 'DS 8',
  ];

  /// Returns the venue label for a booth number, e.g. "BK5-03" -> "BK 5".
  String _venueLabelOf(String boothNumber) {
    final dash = boothNumber.indexOf('-');
    if (dash == -1) return boothNumber;
    final prefix = boothNumber.substring(0, dash);
    return _prettyVenueByPrefix[prefix] ?? prefix;
  }

  /// Reusable regexes (hoisted to avoid recompiling per sort invocation).
  static final RegExp _leadingAlphaRegex = RegExp(r'^[A-Za-z]+');
  static final RegExp _venueRegex = RegExp(r'^([A-Za-z]+)\s*(\d+)$');

  /// Per-venue background color for the booth badge.
  /// Derived from the booth-number prefix (course code).
  static final Map<String, Color> _venueBadgeColor = {
    // CS230 (DS 5-6) and CS253 (DS6) — blueGrey
    'DS5': Colors.blueGrey,
    'DS6': Colors.blueGrey,
    // CS266 (DS 7-8) — amber
    'DS7': Colors.amber,
    'DS8': Colors.amber,
    // CS255 (BILIK KULIAH 1 - 4) — green
    'BK1': Colors.green,
    'BK2': Colors.green,
    'BK3': Colors.green,
    'BK4': Colors.green,
    // CS251 (BK 5 - 8) — purple
    'BK5': Colors.purple,
    'BK6': Colors.purple,
    'BK7': Colors.purple,
    'BK8': Colors.purple,
  };

  Color _badgeColorFor(String boothNumber) {
    final prefix = boothNumber.split('-').first;
    return _venueBadgeColor[prefix] ?? DesignSystem.primary;
  }

  /// Returns the stable, canonical day order for grouping.
  /// Days are derived from the `presentation_day` field ("Day N - DD Mon YYYY").
  static final List<String> _dayOrder = [
    'Day 1 - 06 Aug 2026',
    'Day 2 - 07 Aug 2026',
  ];

  /// Projects that pass the current filters: day, venue, program, and search.
  List<Project> _filteredProjects(
    List<Project> projects,
    String filterText,
    String selectedDay,
    String selectedVenue,
    String selectedProgram,
  ) {
    final needle = filterText.toLowerCase();
    final matched = <Project>[];

    for (final p in projects) {
      final day = p.presentationDay;
      if (day == null || day != selectedDay) continue;

      if (selectedVenue != 'All') {
        final venue = _venueLabelOf(p.boothNumber ?? p.boothZone ?? '');
        if (venue != selectedVenue) continue;
      }

      if (selectedProgram != 'All') {
        if (_stripProgram(p.programmeCode) != selectedProgram) continue;
      }

      final titleMatch = p.title.toLowerCase().contains(needle);
      final boothMatch = p.boothNumber?.toLowerCase().contains(needle) ?? false;
      final studentMatch =
          p.teamDisplayNames.any((n) => n.toLowerCase().contains(needle));
      if (needle.isNotEmpty && !(titleMatch || boothMatch || studentMatch)) continue;

      matched.add(p);
    }

    matched.sort((a, b) {
      final cmp = _boothSortKey(a.boothNumber).compareTo(_boothSortKey(b.boothNumber));
      if (cmp != 0) return cmp;
      return a.title.compareTo(b.title);
    });
    return matched;
  }

  int _boothSortKey(String? boothNumber) {
    if (boothNumber == null || boothNumber.isEmpty) return 9999;
    final parts = boothNumber.split('-');
    if (parts.length != 2) return 9999;
    final zone = parts[0].replaceFirst(_leadingAlphaRegex, '');
    final num = int.tryParse(parts[1]) ?? 9999;
    final zoneVal = int.tryParse(zone, radix: 36) ?? 0;
    return zoneVal * 1000 + num;
  }

  /// Sorts venue labels by leading characters first, then the trailing number,
  /// e.g. "BK 1", "BK 2", ..., "DS 5", "DS 6".
  int _venueCompare(String a, String b) {
    final ma = _venueRegex.firstMatch(a);
    final mb = _venueRegex.firstMatch(b);
    final aChars = ma?.group(1) ?? a;
    final bChars = mb?.group(1) ?? b;
    final charCmp = aChars.compareTo(bChars);
    if (charCmp != 0) return charCmp;
    final aNum = int.tryParse(ma?.group(2) ?? '') ?? 0;
    final bNum = int.tryParse(mb?.group(2) ?? '') ?? 0;
    return aNum.compareTo(bNum);
  }

  /// Strips the "M3" prefix from programme codes (e.g. "M3CS2516A" -> "CS2516A").
  String _stripProgram(String code) {
    return code.startsWith('M3') ? code.substring(2) : code;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;

    final projects = ref.watch(publicProjectsProvider);
    final searchNeedle = _searchController.text.toLowerCase();

    // Derive available venues for the selected day.
    final previewProjects = _filteredProjects(
      projects,
      '',
      _selectedDay,
      'All',
      'All',
    );
    final availableVenues = <String>{};
    for (final p in previewProjects) {
      availableVenues.add(_venueLabelOf(p.boothNumber ?? p.boothZone ?? ''));
    }
    final sortedVenues = availableVenues.toList()..sort(_venueCompare);

    // Programs: distinct set from all projects (for full coverage).
    final allPrograms = <String>{};
    for (final p in projects) {
      if (p.programmeCode.isNotEmpty) allPrograms.add(_stripProgram(p.programmeCode));
    }
    final sortedPrograms = allPrograms.toList()..sort();
    final programItems = ['All', ...sortedPrograms];

    final filtered = _filteredProjects(
      projects,
      searchNeedle,
      _selectedDay,
      _selectedVenue,
      _selectedProgram,
    );

    final hasProjects = filtered.isNotEmpty;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: DesignSystem.spaceXl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Find Exhibition Booths', style: DesignSystem.h1.copyWith(color: DesignSystem.primary)),
                  const SizedBox(height: DesignSystem.spaceSm),
                  Text(
                    'Browse booths organized by presentation day and then venue.',
                    style: (isDesktop ? DesignSystem.bodyLg : DesignSystem.bodyLgMobile).copyWith(color: DesignSystem.onSurfaceVariant),
                    softWrap: true,
                  ),
                  const SizedBox(height: DesignSystem.spaceXl),
                  // Top Search & Filter Bar
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(DesignSystem.spaceMd),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _searchController,
                            onChanged: (_) {
                              _searchDebounce?.cancel();
                              _searchDebounce = Timer(
                                const Duration(milliseconds: 250),
                                () => setState(() {}),
                              );
                            },
                            decoration: InputDecoration(
                              hintText: 'Search by booth number, project title, or student name...',
                              prefixIcon: Icon(Icons.search, color: DesignSystem.primary),
                            ),
                          ),
                          const SizedBox(height: DesignSystem.spaceSm),
                          Wrap(
                            spacing: DesignSystem.spaceSm,
                            runSpacing: DesignSystem.spaceXs,
                            children: [
                              SizedBox(
                                width: isDesktop ? 200 : double.infinity,
                                child: DropdownButtonFormField<String>(
                                  initialValue: _selectedDay,
                                  decoration: InputDecoration(
                                    labelText: 'Day',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  onChanged: (val) => setState(() {
                                    _selectedDay = val!;
                                    _selectedVenue = 'All';
                                  }),
                                  items: _dayOrder.map((day) {
                                    return DropdownMenuItem(value: day, child: Text(day, style: DesignSystem.bodySm, softWrap: true));
                                  }).toList(),
                                ),
                              ),
                              SizedBox(
                                width: isDesktop ? 200 : double.infinity,
                                child: DropdownButtonFormField<String>(
                                  initialValue: _selectedVenue,
                                  decoration: InputDecoration(
                                    labelText: 'Venue',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  onChanged: (val) => setState(() => _selectedVenue = val!),
                                  items: ['All', ...sortedVenues].map((v) {
                                    return DropdownMenuItem(value: v, child: Text(v, style: DesignSystem.bodySm, softWrap: true));
                                  }).toList(),
                                ),
                              ),
                              SizedBox(
                                width: isDesktop ? 200 : double.infinity,
                                child: DropdownButtonFormField<String>(
                                  initialValue: _selectedProgram,
                                  decoration: InputDecoration(
                                    labelText: 'Program',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  onChanged: (val) => setState(() => _selectedProgram = val!),
                                  items: programItems.map((prog) {
                                    return DropdownMenuItem(value: prog, child: Text(prog, style: DesignSystem.bodySm, softWrap: true));
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignSystem.spaceXl),
                ],
              ),
            ),
          ),
          if (hasProjects)
            ..._buildDayGroupSlivers(_selectedDay, filtered, isDesktop, padding)
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Text(
                  'No booths found.',
                  style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant),
                ),
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: DesignSystem.spaceLg)),
        ],
      ),
    );
  }


  List<Widget> _buildDayGroupSlivers(
    String dayLabel,
    List<Project> projects,
    bool isDesktop,
    double padding,
  ) {
    // Group projects by venue (Excel-derived), then sort within each venue.
    final Map<String, List<Project>> venueBuckets = {};
    for (final p in projects) {
      final venue = _venueLabelOf(p.boothNumber ?? p.boothZone ?? '—');
      venueBuckets.putIfAbsent(venue, () => []).add(p);
    }
    for (final list in venueBuckets.values) {
      list.sort((a, b) {
        final cmp = _boothSortKey(a.boothNumber).compareTo(_boothSortKey(b.boothNumber));
        if (cmp != 0) return cmp;
        return a.title.compareTo(b.title);
      });
    }

    // Order venues by the canonical hall layout order; any unmapped venue goes last.
    final orderedVenues = <String>[
      for (final v in _venueOrder)
        if (venueBuckets.containsKey(v)) v,
      for (final v in venueBuckets.keys)
        if (!_venueOrder.contains(v)) v,
    ];

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSystem.spaceMd,
              vertical: DesignSystem.spaceSm,
            ),
            decoration: BoxDecoration(
              color: DesignSystem.primaryContainer.withValues(alpha: 0.15),
              borderRadius: DesignSystem.radiusLg,
              border: Border.all(color: DesignSystem.primary.withValues(alpha: 0.2)),
            ),
            child: Text(
              dayLabel,
              style: (isDesktop ? DesignSystem.h3 : DesignSystem.h3Mobile).copyWith(
                color: DesignSystem.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: DesignSystem.spaceSm)),
      for (final venue in orderedVenues) ...[
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Text(
              venue,
              style: DesignSystem.bodySm.copyWith(
                color: DesignSystem.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              softWrap: true,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: DesignSystem.spaceXs)),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          sliver: SliverList.separated(
            itemCount: venueBuckets[venue]!.length,
            separatorBuilder: (_, __) => const SizedBox(height: DesignSystem.spaceSm),
            itemBuilder: (context, index) {
              final p = venueBuckets[venue]![index];

              final boothNumber = p.boothNumber ?? '—';
              final badgeColor = _badgeColorFor(boothNumber);
              final classGroup = _stripProgram(p.programmeCode);
              final studentName = p.teamDisplayNames.isNotEmpty
                  ? p.teamDisplayNames.first
                  : p.supervisorDisplayName;

              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  onTap: () => context.go('/projects/${p.id}'),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      '/booth_images/booth-$boothNumber.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      cacheWidth: 88,
                      cacheHeight: 88,
                      errorBuilder: (_, _, _) => CircleAvatar(
                        backgroundColor: badgeColor.withValues(alpha: 0.2),
                        child: Text(
                          boothNumber,
                          style: DesignSystem.bodySm.copyWith(
                            color: badgeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    p.title,
                    style: DesignSystem.bodyMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: DesignSystem.primary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                  subtitle: Text(
                    '$studentName • $classGroup',
                    style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                  trailing: isDesktop
                      ? const Icon(Icons.arrow_forward_ios, size: 16, color: DesignSystem.primary)
                      : null,
                ),
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: DesignSystem.spaceSm)),
      ],
    ];
  }
}
