import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/widgets/collapsible_filter_panel.dart';
import '../../domain/csp600_csv_loader.dart';
import '../../domain/project_similarity.dart';
import '../widgets/project_row_widget.dart';
import '../widgets/redundancy_cluster_widget.dart';

/// Debounce delay for the search field: filtering + re-deriving the
/// similarity index on every keystroke is wasted work once the projects
/// list is in the hundreds — this coalesces bursts of typing into one pass.
const _searchDebounce = Duration(milliseconds: 250);

/// Wraps a [Project] with the section it belongs to.
class SectionedProject {
  final Project project;
  final String section; // 'CSP650' or 'CSP600'

  const SectionedProject({
    required this.project,
    required this.section,
  });
}

class JuniorProjectBrowserPage extends ConsumerStatefulWidget {
  const JuniorProjectBrowserPage({super.key});

  @override
  ConsumerState<JuniorProjectBrowserPage> createState() =>
      _JuniorProjectBrowserPageState();
}

class _JuniorProjectBrowserPageState
    extends ConsumerState<JuniorProjectBrowserPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late final TabController _tabController;
  Timer? _searchDebounceTimer;
  String _selectedSection = 'all';
  String _selectedProgramme = 'All';
  String _selectedCategory = 'All';
  String _selectedTechStack = 'All';
  String _selectedSupervisor = 'All';
  String _selectedSession = 'All';
  String _selectedRedundancy = 'All'; // 'All' | 'Unique' | 'Has Similar'
  bool _industryOnly = false;
  bool _mobileFiltersExpanded = false;
  bool _appliedDeepLinkFilters = false;

  // Similarity cache: recomputing tag normalization + the O(n^2) pairwise
  // pass on every rebuild is wasted work when only a dropdown/chip filter
  // changed and the underlying project data didn't — so this is only
  // recomputed when the source provider lists actually change (see
  // _ensureSimilarityCache), not on every setState.
  List<Project>? _cachedCsp650;
  List<Project>? _cachedCsp600;
  List<Project> _cachedFullProjList = const [];
  Map<String, Set<String>> _cachedTagIndex = const {};
  Map<String, int> _cachedSimilarityCounts = const {};

  /// Number of collapsed filters currently active (drives the toggle badge).
  int get _activeFilterCount {
    var count = 0;
    if (_selectedProgramme != 'All') count++;
    if (_selectedCategory != 'All') count++;
    if (_selectedTechStack != 'All') count++;
    if (_selectedSupervisor != 'All') count++;
    if (_selectedSession != 'All') count++;
    if (_selectedRedundancy != 'All') count++;
    if (_industryOnly) count++;
    return count;
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedSection = 'all';
      _selectedProgramme = 'All';
      _selectedCategory = 'All';
      _selectedTechStack = 'All';
      _selectedSupervisor = 'All';
      _selectedSession = 'All';
      _selectedRedundancy = 'All';
      _industryOnly = false;
    });
  }

  void _onSearchChanged(String _) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_searchDebounce, () {
      if (mounted) setState(() {});
    });
  }

  /// Recomputes the similarity cache only when the source project lists
  /// actually changed (by identity — Riverpod keeps the same List instance
  /// across rebuilds unless the provider's data was refetched/refreshed).
  void _ensureSimilarityCache(
    List<Project> csp650,
    List<Project> csp600,
    List<SectionedProject> combined,
  ) {
    if (identical(csp650, _cachedCsp650) && identical(csp600, _cachedCsp600)) {
      return;
    }
    _cachedCsp650 = csp650;
    _cachedCsp600 = csp600;
    _cachedFullProjList = combined.map((sp) => sp.project).toList();
    _cachedTagIndex = ProjectSimilarity.buildTagIndex(_cachedFullProjList);
    _cachedSimilarityCounts = ProjectSimilarity.computeSimilarityCounts(
      _cachedFullProjList,
      tagIndex: _cachedTagIndex,
    );
  }

  /// Applies filters passed via deep-link query parameters (e.g. a link from
  /// another page pre-scoped to a supervisor), mirroring the read-only
  /// pattern ProjectsPage already uses for `?search=`. This only reads the
  /// URL once on mount — filter changes made in this page are not written
  /// back to the address bar.
  void _applyDeepLinkFilters() {
    if (_appliedDeepLinkFilters) return;
    _appliedDeepLinkFilters = true;
    final params = GoRouterState.of(context).uri.queryParameters;
    if (params.isEmpty) return;

    setState(() {
      final search = params['search'];
      if (search != null && search.isNotEmpty) _searchController.text = search;
      _selectedSection = params['section'] ?? _selectedSection;
      _selectedProgramme = params['programme'] ?? _selectedProgramme;
      _selectedCategory = params['category'] ?? _selectedCategory;
      _selectedTechStack = params['techStack'] ?? _selectedTechStack;
      _selectedSupervisor = params['supervisor'] ?? _selectedSupervisor;
      _selectedSession = params['session'] ?? _selectedSession;
      _selectedRedundancy = params['redundancy'] ?? _selectedRedundancy;
      _industryOnly = params['industry'] == 'true' || _industryOnly;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // The Redundancy Report tab's clusters are only computed while it's
    // selected (see _buildBody) — this listener rebuilds on tab switch so
    // that computation actually happens once the user lands on it.
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _applyDeepLinkFilters();
    });
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    final csp650Async = ref.watch(publicProjectsProvider);
    final csp600Async = ref.watch(csp600ProposalsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Past Sem Projects',
          style: (isDesktop ? DesignSystem.h3 : DesignSystem.h3Mobile)
              .copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white70,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          tabs: const [
            Tab(text: 'Browse'),
            Tab(text: 'Redundancy Report'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(publicProjectsProvider);
              ref.invalidate(csp600ProposalsProvider);
            },
          ),
        ],
      ),
      body: _buildBody(csp650Async, csp600Async, isDesktop),
    );
  }

  Widget _buildBody(
    List<Project> csp650Projects,
    AsyncValue<List<Project>> csp600Async,
    bool isDesktop,
  ) {
    // CSP600: use data if loaded, empty list otherwise. Never block CSP650.
    // `const` so this stays the SAME list instance across rebuilds while
    // still loading — _ensureSimilarityCache compares by identity below.
    final csp600Projects = csp600Async.hasValue
        ? csp600Async.value!
        : const <Project>[];

    final combined = _buildCombined(csp650Projects, csp600Projects);

    // Computed against the FULL (unfiltered) corpus — not the
    // filtered/visible list — and shared by every comparison below.
    // Similarity is a fact about a project relative to the whole guide, so
    // it must not change depending on which other filters (Programme,
    // Supervisor, ...) happen to be active; computing it off the filtered
    // list would let a project's "Unique" badge flip on and off as the
    // comparison pool shrinks, defeating the point of a redundancy check.
    // Cached at the State level so a filter/dropdown change alone (with no
    // change to the underlying project data) doesn't repeat the O(n^2) pass.
    _ensureSimilarityCache(csp650Projects, csp600Projects, combined);
    final fullProjList = _cachedFullProjList;
    final tagIndex = _cachedTagIndex;
    final similarityCounts = _cachedSimilarityCounts;

    final visible = _applyFilters(combined, similarityCounts);

    return Column(
      children: [
        _buildSearchAndFilters(isDesktop, combined),
        const SizedBox(height: 4),
        _buildSectionSummary(visible, isDesktop),
        if (csp600Async.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Loading CSP600 proposals...',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: DesignSystem.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
        if (csp600Async.hasError)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'CSP600 data unavailable — showing CSP650 only.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: DesignSystem.error,
                fontSize: 12,
              ),
            ),
          ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBrowseTab(visible, similarityCounts, isDesktop),
              // Clusters are the expensive O(n^2) part of this feature —
              // only compute them while this tab is actually selected, so
              // typing in search while on Browse doesn't pay for it. Scoped
              // to the full corpus (not the Browse-tab filters) so the
              // report always reflects redundancy across the whole guide.
              _tabController.index == 1
                  ? _buildReportTab(
                      fullProjList, tagIndex, similarityCounts, isDesktop)
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }

  List<SectionedProject> _buildCombined(
    List<Project> csp650Projects,
    List<Project> csp600Projects,
  ) {
    // csp650Projects comes from publicProjectsProvider, which already
    // queries published-only rows — no need to re-check publicationStatus.
    final result = <SectionedProject>[
      for (final p in csp650Projects) SectionedProject(project: p, section: 'CSP650'),
      for (final p in csp600Projects) SectionedProject(project: p, section: 'CSP600'),
    ];
    return result;
  }

  List<SectionedProject> _applyFilters(
    List<SectionedProject> all,
    Map<String, int> similarityCounts,
  ) {
    final searchLower = _searchController.text.toLowerCase();

    return all.where((sp) {
      final p = sp.project;

      final matchesSection =
          _selectedSection == 'all' || sp.section == _selectedSection;

      final matchesSearch = searchLower.isEmpty ||
          p.title.toLowerCase().contains(searchLower) ||
          p.supervisorDisplayName.toLowerCase().contains(searchLower) ||
          ProjectSimilarity.displayTags(p)
              .any((t) => t.toLowerCase().contains(searchLower));

      final matchesProgramme =
          _selectedProgramme == 'All' || p.programmeCode == _selectedProgramme;

      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;

      final matchesTechStack = _selectedTechStack == 'All' ||
          ProjectSimilarity.displayTags(p)
              .any((t) => t.toLowerCase() == _selectedTechStack.toLowerCase());

      final matchesSupervisor = _selectedSupervisor == 'All' ||
          p.supervisorDisplayName == _selectedSupervisor;

      final matchesSession =
          _selectedSession == 'All' || p.presentationDay == _selectedSession;

      final simCount = similarityCounts[p.id] ?? 0;
      final matchesRedundancy = switch (_selectedRedundancy) {
        'Unique' => simCount == 0,
        'Has Similar' => simCount > 0,
        _ => true,
      };

      final matchesIndustry = !_industryOnly || p.calonIndustri;

      return matchesSection &&
          matchesSearch &&
          matchesProgramme &&
          matchesCategory &&
          matchesTechStack &&
          matchesSupervisor &&
          matchesSession &&
          matchesRedundancy &&
          matchesIndustry;
    }).toList();
  }

  List<String> _allProgrammes(List<SectionedProject> all) {
    final seen = <String>{};
    for (final sp in all) {
      if (sp.project.programmeCode.isNotEmpty) {
        seen.add(sp.project.programmeCode);
      }
    }
    return seen.toList()..sort();
  }

  /// Scoped to the currently selected Section — with both cohorts combined,
  /// the supervisor list would otherwise mix CSP650 and CSP600 names the
  /// user isn't browsing, making it longer and less relevant than it needs
  /// to be once a section is picked.
  List<String> _allSupervisors(List<SectionedProject> all) {
    final scoped = _selectedSection == 'all'
        ? all
        : all.where((sp) => sp.section == _selectedSection);
    final seen = <String>{};
    for (final sp in scoped) {
      if (sp.project.supervisorDisplayName.isNotEmpty) {
        seen.add(sp.project.supervisorDisplayName);
      }
    }
    return seen.toList()..sort();
  }

  List<String> _allCategories(List<SectionedProject> all) {
    final seen = <String>{};
    for (final sp in all) {
      if (sp.project.category.isNotEmpty) {
        seen.add(sp.project.category);
      }
    }
    return seen.toList()..sort();
  }

  List<String> _allTechStacks(List<SectionedProject> all) {
    final seen = <String>{};
    for (final sp in all) {
      for (final tag in ProjectSimilarity.displayTags(sp.project)) {
        seen.add(tag);
      }
    }
    return seen.toList()..sort();
  }

  /// Session/time-slot values, populated for CSP600 proposals via
  /// [Project.presentationDay] (see Csp600CsvLoader). CSP650 projects
  /// generally don't carry a session string, so this filter is only
  /// meaningful once CSP600 data is in view.
  List<String> _allSessions(List<SectionedProject> all) {
    final seen = <String>{};
    for (final sp in all) {
      final day = sp.project.presentationDay;
      if (day != null && day.isNotEmpty) seen.add(day);
    }
    return seen.toList()..sort();
  }

  Widget _buildSearchAndFilters(
    bool isDesktop,
    List<SectionedProject> all,
  ) {
    final programmes = _allProgrammes(all);
    final categories = _allCategories(all);
    final techStacks = _allTechStacks(all);
    final supervisors = _allSupervisors(all);
    final sessions = _allSessions(all);

    if (isDesktop) {
      return Card(
        margin: EdgeInsets.symmetric(
          horizontal: DesignSystem.marginDesktop,
          vertical: DesignSystem.spaceMd,
        ),
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.spaceMd),
          child: Column(
            children: [
              // The clear (x) icon needs to react to every keystroke, but
              // filtering the (possibly hundreds-long) list is debounced —
              // listening on the controller directly keeps the icon instant
              // without forcing the expensive parent rebuild on every key.
              ListenableBuilder(
                listenable: _searchController,
                builder: (context, _) => TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search by project title, supervisor, or tech tags...',
                    prefixIcon:
                        const Icon(Icons.search, color: DesignSystem.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            tooltip: 'Clear search',
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: DesignSystem.spaceMd),
              _buildDesktopFilters(
                  programmes, categories, techStacks, supervisors, sessions),
            ],
          ),
        ),
      );
    }

    // Mobile: compact collapsible panel — search + section pills stay
    // visible; the three dropdowns hide behind a badged toggle.
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSystem.marginMobile,
        vertical: DesignSystem.spaceMd,
      ),
      child: CollapsibleFilterPanel(
        header: ListenableBuilder(
          listenable: _searchController,
          builder: (context, _) => TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search title, supervisor, tags...',
              prefixIcon: const Icon(Icons.search, color: DesignSystem.primary),
              isDense: true,
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      tooltip: 'Clear search',
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
        headerTrailing: Wrap(
          spacing: 8,
          children: [
            _buildSectionPill('All', 'all'),
            _buildSectionPill('CSP650', 'CSP650'),
            _buildSectionPill('CSP600', 'CSP600'),
          ],
        ),
        activeCount: _activeFilterCount,
        expanded: _mobileFiltersExpanded,
        onToggle: () =>
            setState(() => _mobileFiltersExpanded = !_mobileFiltersExpanded),
        filterFields: [
          _buildDropdownFilter(
            'Academic Program',
            _selectedProgramme,
            ['All', ...programmes],
            (v) => setState(() => _selectedProgramme = v!),
          ),
          _buildDropdownFilter(
            'Project Category',
            _selectedCategory,
            ['All', ...categories],
            (v) => setState(() => _selectedCategory = v!),
          ),
          _buildDropdownFilter(
            'Tech Stack',
            _selectedTechStack,
            ['All', ...techStacks],
            (v) => setState(() => _selectedTechStack = v!),
          ),
          _buildDropdownFilter(
            'Supervisor',
            _selectedSupervisor,
            ['All', ...supervisors],
            (v) => setState(() => _selectedSupervisor = v!),
          ),
          if (sessions.isNotEmpty)
            _buildDropdownFilter(
              'Session',
              _selectedSession,
              ['All', ...sessions],
              (v) => setState(() => _selectedSession = v!),
            ),
          _buildDropdownFilter(
            'Redundancy Status',
            _selectedRedundancy,
            const ['All', 'Unique', 'Has Similar'],
            (v) => setState(() => _selectedRedundancy = v!),
          ),
          _buildIndustryToggle(),
        ],
        resetControl: TextButton.icon(
          onPressed: () {
            _resetFilters();
            setState(() => _mobileFiltersExpanded = false);
          },
          icon: const Icon(Icons.filter_alt_off, size: 18),
          label: const Text('Reset Filters'),
        ),
      ),
    );
  }

  Widget _buildDesktopFilters(
    List<String> programmes,
    List<String> categories,
    List<String> techStacks,
    List<String> supervisors,
    List<String> sessions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Section', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildSectionPill('All', 'all'),
                    _buildSectionPill('CSP650', 'CSP650'),
                    _buildSectionPill('CSP600', 'CSP600'),
                  ],
                ),
              ],
            ),
            const SizedBox(width: DesignSystem.spaceLg),
            Expanded(
              child: _buildDropdownFilter(
                'Academic Program',
                _selectedProgramme,
                ['All', ...programmes],
                (v) => setState(() => _selectedProgramme = v!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdownFilter(
                'Project Category',
                _selectedCategory,
                ['All', ...categories],
                (v) => setState(() => _selectedCategory = v!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdownFilter(
                'Tech Stack',
                _selectedTechStack,
                ['All', ...techStacks],
                (v) => setState(() => _selectedTechStack = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _buildDropdownFilter(
                'Supervisor',
                _selectedSupervisor,
                ['All', ...supervisors],
                (v) => setState(() => _selectedSupervisor = v!),
              ),
            ),
            if (sessions.isNotEmpty) ...[
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownFilter(
                  'Session',
                  _selectedSession,
                  ['All', ...sessions],
                  (v) => setState(() => _selectedSession = v!),
                ),
              ),
            ],
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdownFilter(
                'Redundancy Status',
                _selectedRedundancy,
                const ['All', 'Unique', 'Has Similar'],
                (v) => setState(() => _selectedRedundancy = v!),
              ),
            ),
            const SizedBox(width: 16),
            _buildIndustryToggle(),
            const SizedBox(width: 12),
            TextButton(
              onPressed: _resetFilters,
              child: const Text('Reset Filters'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIndustryToggle() {
    // calonIndustri is only ever set on CSP650 rows (via the admin panel);
    // Csp600CsvLoader always parses CSP600 proposals with calonIndustri:
    // false, since the CSV has no equivalent column — surface that here
    // rather than leave students wondering why CSP600 never matches.
    final csp600InView =
        _selectedSection == 'all' || _selectedSection == 'CSP600';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Tooltip(
          message: csp600InView
              ? 'Only CSP650 projects can be flagged as an industry candidate — CSP600 proposals never match this filter.'
              : 'Industry Candidate',
          child: Text(
            'Industry Candidate',
            style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 6),
        FilterChip(
          selected: _industryOnly,
          onSelected: (val) => setState(() => _industryOnly = val),
          label: Text(_industryOnly ? 'Showing only' : 'Show only'),
          avatar: Icon(
            Icons.business_center_outlined,
            size: 16,
            color: _industryOnly ? Colors.white : DesignSystem.tertiary,
          ),
          selectedColor: DesignSystem.tertiary,
          checkmarkColor: Colors.white,
          showCheckmark: false,
          labelStyle: DesignSystem.bodySm.copyWith(
            color: _industryOnly ? Colors.white : DesignSystem.onSurfaceVariant,
          ),
          backgroundColor: DesignSystem.surfaceContainerLowest,
          side: BorderSide(color: DesignSystem.outlineVariant),
        ),
      ],
    );
  }

  Widget _buildSectionPill(String label, String value) {
    final selected = _selectedSection == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _selectedSection = value),
      selectedColor: DesignSystem.secondaryContainer,
      backgroundColor: DesignSystem.surfaceContainerLowest,
      labelStyle: DesignSystem.bodySm.copyWith(
        color: selected
            ? DesignSystem.onSecondaryContainer
            : DesignSystem.onSurfaceVariant,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildDropdownFilter(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DesignSystem.labelCaps.copyWith(
            color: DesignSystem.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: DesignSystem.surfaceContainerLowest,
            borderRadius: DesignSystem.radiusLg,
            border: Border.all(color: DesignSystem.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              onChanged: onChanged,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: DesignSystem.bodySm,
                    softWrap: true,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionSummary(
    List<SectionedProject> visible,
    bool isDesktop,
  ) {
    final csp650Count = visible.where((sp) => sp.section == 'CSP650').length;
    final csp600Count = visible.where((sp) => sp.section == 'CSP600').length;

    final padding = EdgeInsets.symmetric(
      horizontal:
          isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile,
      vertical: 8,
    );

    if (csp650Count == 0 && csp600Count == 0) {
      return Padding(
        padding: padding,
        child: Text(
          'No projects match your filters.',
          style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          if (csp650Count > 0)
            _buildSummaryBadge('CSP650', csp650Count, DesignSystem.secondaryContainer,
                DesignSystem.onSecondaryContainer, 'projects'),
          if (csp600Count > 0)
            _buildSummaryBadge('CSP600', csp600Count, DesignSystem.tertiaryContainer,
                DesignSystem.onTertiaryContainer, 'proposals'),
        ],
      ),
    );
  }

  Widget _buildSummaryBadge(
    String label,
    int count,
    Color bg,
    Color fg,
    String noun,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: DesignSystem.radiusSm,
      ),
      child: Text(
        '$label: $count $noun',
        style: DesignSystem.labelCaps.copyWith(
          color: fg,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildBrowseTab(
    List<SectionedProject> visible,
    Map<String, int> similarityCounts,
    bool isDesktop,
  ) {
    if (visible.isEmpty) {
      return _buildEmptyState(isDesktop);
    }

    final padding = isDesktop
        ? DesignSystem.marginDesktop
        : DesignSystem.marginMobile;

    return Column(
      children: [
        if (isDesktop) _buildTableHeader(padding),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.only(
              left: padding,
              right: padding,
              bottom: DesignSystem.spaceLg,
              top: isDesktop ? 8 : 4,
            ),
            itemCount: visible.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final sp = visible[index];
              return ProjectRowWidget(
                project: sp.project,
                simCount: similarityCounts[sp.project.id] ?? 0,
                showSection: true,
                section: sp.section,
                rowIndex: index,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(double horizontalPadding) {
    // Mirrors the flex ratios in ProjectRowWidget._buildDesktopRow
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DesignSystem.surfaceContainer,
        borderRadius: DesignSystem.radiusLg,
        border: Border.all(color: DesignSystem.outlineVariant, width: 0.7),
      ),
      child: Row(
        children: [
          const SizedBox(width: 56), // offset for section pill
          Expanded(
            flex: 34,
            child: _headerLabel('PROJECT TITLE', Icons.article_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 18,
            child: _headerLabel('SUPERVISOR', Icons.person_outline),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 88,
            child: _headerLabel('PROGRAMME', Icons.school_outlined, center: true),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 28,
            child: _headerLabel('TECH STACK', Icons.memory_outlined),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: _headerLabel('STATUS', Icons.verified_outlined, center: true),
          ),
        ],
      ),
    );
  }

  Widget _headerLabel(String text, IconData icon, {bool center = false}) {
    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: DesignSystem.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          text,
          style: DesignSystem.labelCaps.copyWith(
            color: DesignSystem.onSurfaceVariant,
            fontSize: 10,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
    return center ? Center(child: label) : label;
  }

  Widget _buildReportTab(
    List<Project> projList,
    Map<String, Set<String>> tagIndex,
    Map<String, int> similarityCounts,
    bool isDesktop,
  ) {
    final clusters =
        ProjectSimilarity.buildClusters(projList, tagIndex: tagIndex);

    if (clusters.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop
                ? DesignSystem.marginDesktop
                : DesignSystem.marginMobile,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 64,
                color: DesignSystem.outlineVariant,
              ),
              const SizedBox(height: DesignSystem.spaceMd),
              Text(
                'No Redundant Clusters Found',
                style: (isDesktop ? DesignSystem.h3 : DesignSystem.h3Mobile)
                    .copyWith(color: DesignSystem.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text(
                'No groups of projects share 3+ technology tags.',
                style: DesignSystem.bodyMd
                    .copyWith(color: DesignSystem.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final padding = isDesktop
        ? DesignSystem.marginDesktop
        : DesignSystem.marginMobile;

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: DesignSystem.spaceLg,
      ),
      itemCount: clusters.length,
      itemBuilder: (context, index) {
        final cluster = clusters[index];
        return RedundancyClusterWidget(
          cluster: cluster,
          similarityCounts: similarityCounts,
          showSection: true,
          isDesktop: isDesktop,
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDesktop) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_outlined,
              size: 64,
              color: DesignSystem.outlineVariant,
            ),
            const SizedBox(height: DesignSystem.spaceMd),
            Text(
              'No Projects Found',
              textAlign: TextAlign.center,
              style: (isDesktop ? DesignSystem.h3 : DesignSystem.h3Mobile)
                  .copyWith(color: DesignSystem.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your search keywords or reset filters.',
              textAlign: TextAlign.center,
              style: DesignSystem.bodySm.copyWith(
                color: DesignSystem.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final csp600ProposalsProvider = FutureProvider<List<Project>>((ref) async {
  return await Csp600CsvLoader.load();
});
