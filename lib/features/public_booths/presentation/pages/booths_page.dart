import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/booth.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/state/state_providers.dart';

class BoothsPage extends ConsumerStatefulWidget {
  const BoothsPage({super.key});

  @override
  ConsumerState<BoothsPage> createState() => _BoothsPageState();
}

class _BoothsPageState extends ConsumerState<BoothsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedZone = 'All';

  final List<String> _zones = ['All', 'Zone A', 'Zone B', 'Zone C'];

   @override
  void dispose() {
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

  /// Excel-faithful venue label, e.g. "BK5-03" -> "BK 5 - 03".
  /// Split only on the first `-`, so booth numbers like "BK7-01" map correctly.
  String _excelVenueLabel(String boothNumber) {
    final dash = boothNumber.indexOf('-');
    if (dash == -1) return boothNumber;
    final prefix = boothNumber.substring(0, dash);
    final suffix = boothNumber.substring(dash + 1);
    final pretty = _prettyVenueByPrefix[prefix] ?? prefix;
    return '$pretty - $suffix';
  }

  /// Returns the venue label for a booth number, e.g. "BK5-03" -> "BK 5".
  String _venueLabelOf(String boothNumber) {
    final dash = boothNumber.indexOf('-');
    if (dash == -1) return boothNumber;
    final prefix = boothNumber.substring(0, dash);
    return _prettyVenueByPrefix[prefix] ?? prefix;
  }

  /// Returns the stable, canonical day order for grouping.
  /// Days are derived from the `presentation_day` field ("Day N - DD Mon YYYY").
  static final List<String> _dayOrder = [
    'Day 1 - 06 Aug 2026',
    'Day 2 - 07 Aug 2026',
  ];

  /// Projects that belong to a given day (and pass search/zone filters).
  List<Project> _projectsForDay(
    List<Project> projects,
    List<Booth> booths,
    String dayLabel,
    String filterText,
    String selectedZone,
  ) {
    final needle = filterText.toLowerCase();
    final matched = <Project>[];
    final byId = {for (final b in booths) b.id: b};
    final byNum = {for (final b in booths) b.boothNumber: b};

    for (final p in projects) {
      if (p.presentationDay != dayLabel) continue;
      final booth = byId[p.boothId] ?? byNum[p.boothNumber];

      if (selectedZone != 'All' &&
          booth != null &&
          !booth.zone.contains(selectedZone)) {
        continue;
      }

      final titleMatch =
          p.title.toLowerCase().contains(needle);
      final boothMatch = p.boothNumber?.toLowerCase().contains(needle) ?? false;
      if (needle.isNotEmpty && !(titleMatch || boothMatch)) continue;

      matched.add(p);
    }
    matched.sort((a, b) {
      final aNo = _boothSortKey(a.boothNumber);
      final bNo = _boothSortKey(b.boothNumber);
      final cmp = aNo.compareTo(bNo);
      if (cmp != 0) return cmp;
      return a.title.compareTo(b.title);
    });
    return matched;
  }

  int _boothSortKey(String? boothNumber) {
    if (boothNumber == null || boothNumber.isEmpty) return 9999;
    final parts = boothNumber.split('-');
    if (parts.length != 2) return 9999;
    final zone = parts[0].replaceFirst(RegExp(r'^[A-Za-z]+'), '');
    final num = int.tryParse(parts[1]) ?? 9999;
    final zoneVal = int.tryParse(zone, radix: 36) ?? 0;
    return zoneVal * 1000 + num;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;

    final booths = ref.watch(publicBoothsProvider);
    final projects = ref.watch(publicProjectsProvider);

    final searchNeedle = _searchController.text.toLowerCase();

    // Build day -> projects map (only days that have projects).
    final Map<String, List<Project>> dayBuckets = {};
    for (final day in _dayOrder) {
      final dayProjects = _projectsForDay(
        projects,
        booths,
        day,
        searchNeedle,
        _selectedZone,
      );
      if (dayProjects.isNotEmpty) {
        dayBuckets[day] = dayProjects;
      }
    }

    final visibleDays = dayBuckets.keys.toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: DesignSystem.spaceXl),
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
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Search by booth number or project title...',
                          prefixIcon: Icon(Icons.search, color: DesignSystem.primary),
                        ),
                      ),
                    ),
                    if (isDesktop)
                      const SizedBox(width: DesignSystem.spaceMd),
                    if (isDesktop)
                      SizedBox(
                        width: 260,
                        child: DropdownButtonFormField<String>(
                          value: _selectedZone,
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                          onChanged: (val) => setState(() => _selectedZone = val!),
                          items: _zones.map((zone) {
                            return DropdownMenuItem(
                              value: zone,
                              child: Text(zone, style: DesignSystem.bodySm, softWrap: true),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            if (!isDesktop)
              Column(
                children: [
                  const SizedBox(height: DesignSystem.spaceMd),
                  DropdownButtonFormField<String>(
                    value: _selectedZone,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                    onChanged: (val) => setState(() => _selectedZone = val!),
                    items: _zones.map((zone) {
                      return DropdownMenuItem(
                        value: zone,
                        child: Text(zone, style: DesignSystem.bodySm, softWrap: true),
                      );
                    }).toList(),
                  ),
                ],
              ),

            const SizedBox(height: DesignSystem.spaceXl),

            visibleDays.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Text(
                        'No booths found.',
                        style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (final day in visibleDays)
                        _buildDayGroup(
                          day,
                          dayBuckets[day]!,
                          booths,
                          isDesktop,
                        ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayGroup(String dayLabel, List<Project> projects, List<Booth> booths, bool isDesktop) {
    final boothById = <String, Booth>{};
    final boothByNumber = <String, Booth>{};
    for (final b in booths) {
      boothById[b.id] = b;
      boothByNumber[b.boothNumber] = b;
    }

    Booth? boothFor(Project p) {
      if (p.boothId != null && boothById.containsKey(p.boothId)) return boothById[p.boothId];
      if (p.boothNumber != null && boothByNumber.containsKey(p.boothNumber)) return boothByNumber[p.boothNumber];
      return null;
    }

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
        const SizedBox(height: DesignSystem.spaceSm),
        for (final venue in orderedVenues) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spaceSm, vertical: DesignSystem.spaceXs),
            child: Text(
              venue,
              style: DesignSystem.bodySm.copyWith(
                color: DesignSystem.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              softWrap: true,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: venueBuckets[venue]!.length,
            itemBuilder: (context, index) {
              final p = venueBuckets[venue]![index];
              final booth = boothFor(p);

              return Card(
                margin: const EdgeInsets.only(bottom: DesignSystem.spaceSm),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: DesignSystem.secondaryContainer,
                    child: Text(
                      p.boothNumber ?? '—',
                      style: const TextStyle(
                        color: DesignSystem.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    '${_excelVenueLabel(p.boothNumber ?? "—")} • ${p.title}',
                    style: DesignSystem.bodyMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: DesignSystem.primary,
                    ),
                    softWrap: true,
                  ),
                  subtitle: Text(
                    '${booth?.zone ?? p.boothZone ?? "—"} • ${p.supervisorDisplayName}',
                    style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                    softWrap: true,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16, color: DesignSystem.primary),
                    onPressed: () {
                      context.go('/projects/${p.id}');
                    },
                  ),
                ),
              );
            },
          ),
        ],
        const SizedBox(height: DesignSystem.spaceLg),
      ],
    );
  }
}
