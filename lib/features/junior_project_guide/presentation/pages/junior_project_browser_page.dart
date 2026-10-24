import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/state/state_providers.dart';
import '../../domain/project_similarity.dart';
import '../../domain/title_similarity.dart';
import '../guide_filter_values.dart';
import '../widgets/guide_browse_list.dart';
import '../widgets/guide_filters.dart';
import '../widgets/guide_report.dart';
import '../providers/junior_guide_providers.dart';
import '../../../../core/utils/url_state.dart';

export '../providers/junior_guide_providers.dart' show csp600ProposalsProvider;
export '../guide_filter_values.dart' show SectionedProject;

/// Debounce delay for the search field: filtering + re-deriving the
/// similarity index on every keystroke is wasted work once the projects
/// list is in the hundreds — this coalesces bursts of typing into one pass.
const _searchDebounce = Duration(milliseconds: 250);

/// The Past Projects Guide: Browse (filtered list) and Redundancy Report tabs.
///
/// This State owns everything that changes: the filter values, the search
/// text, the tab, the URL sync and the similarity cache. The filter panel
/// ([GuideFilters]), the Browse list ([guideBrowseSlivers]) and the report
/// ([guideReportSlivers]) are drawn from what it passes them.
class JuniorProjectBrowserPage extends ConsumerStatefulWidget {
  const JuniorProjectBrowserPage({super.key});

  @override
  ConsumerState<JuniorProjectBrowserPage> createState() =>
      _JuniorProjectBrowserPageState();
}

class _JuniorProjectBrowserPageState
    extends ConsumerState<JuniorProjectBrowserPage>
    with SingleTickerProviderStateMixin, UrlStateSync<JuniorProjectBrowserPage> {
  final TextEditingController _searchController = TextEditingController();
  late final TabController _tabController;
  Timer? _searchDebounceTimer;
  GuideFilterValues _filters = const GuideFilterValues();
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
  Map<String, Set<String>> _cachedCategoryTagIndex = const {};
  Map<String, int> _cachedSimilarityCounts = const {};
  Map<String, String> _cachedIdToSection = const {};
  Map<String, Set<String>> _cachedTitleTokenIndex = const {};
  // Report-tab clusters: built lazily on first view, cleared with the rest.
  List<RedundancyCluster>? _cachedTagClusters;
  List<TitleSimilarCluster>? _cachedTitleClusters;

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _filters = const GuideFilterValues();
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
    _cachedCategoryTagIndex =
        ProjectSimilarity.buildCategoryTagIndex(_cachedFullProjList);
    _cachedTitleTokenIndex =
        TitleSimilarity.buildTitleTokenIndex(_cachedFullProjList);
    // Combined (category-tag OR title-wording) so the Browse-tab badge and
    // the Unique/Has Similar filter agree with both Redundancy Report
    // sections — see computeCombinedSimilarityCounts's doc for why a plain
    // category-only count would miss title-only matches.
    _cachedSimilarityCounts = TitleSimilarity.computeCombinedSimilarityCounts(
      _cachedFullProjList,
      categoryTagIndex: _cachedCategoryTagIndex,
      titleTokenIndex: _cachedTitleTokenIndex,
    );
    _cachedIdToSection = {
      for (final sp in combined) sp.project.id: sp.section,
    };
    _cachedTagClusters = null;
    _cachedTitleClusters = null;
  }

  /// Opens the full list of projects [target] was flagged similar to —
  /// the STATUS badge's "N similar" tap action (see SimilarProjectsPage).
  void _openSimilarProjects(Project target) {
    // A go_router route (not Navigator.push) so the page has a URL: browser
    // back returns here and a refresh keeps the page.
    context.push(
      '/projects/junior-guide/similar/${Uri.encodeComponent(target.id)}',
    );
  }

  /// Applies filters passed via query parameters (a shared or refreshed link,
  /// or another page pre-scoped to a supervisor). Read once on mount; `build`
  /// writes changes back to the address bar through [syncUrl]. Values a
  /// dropdown no longer offers fall back to "All" (see [GuideFilters]).
  void _applyDeepLinkFilters() {
    if (_appliedDeepLinkFilters) return;
    _appliedDeepLinkFilters = true;
    final params = GoRouterState.of(context).uri.queryParameters;
    if (params.isEmpty) return;

    setState(() {
      final search = params['search'];
      if (search != null && search.isNotEmpty) _searchController.text = search;
      _filters = _filters.withQuery(params);
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
    syncUrl(_filters.toQuery(_searchController.text));
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;

    final csp650Async = ref.watch(publicProjectsProvider);
    final csp600Async = ref.watch(csp600ProposalsProvider);

    return Scaffold(
      body: _buildBody(csp650Async, csp600Async, isDesktop),
    );
  }

  /// Title bar: scrolls away with the page and comes back (snaps) as soon as
  /// the reader scrolls up, so it never eats list space on a phone.
  Widget _buildTitleBar(
    List<Project> csp650Projects,
    AsyncValue<List<Project>> csp600Async,
    bool isDesktop,
  ) {
    return SliverAppBar(
      backgroundColor: DesignSystem.primary,
      foregroundColor: Colors.white,
      floating: true,
      snap: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Past Projects Guide',
            style: (isDesktop ? DesignSystem.h2Mobile : DesignSystem.h3Mobile.copyWith(fontFamily: DesignSystem.serif))
                .copyWith(color: Colors.white),
          ),
          // How much there is to browse, in mono ("Scholar + Lab").
          Text(
            [
              '${csp650Projects.length} CSP650',
              if (csp600Async.value != null) '${csp600Async.value!.length} CSP600',
            ].join(' · '),
            key: const Key('guide-counts'),
            style: DesignSystem.kicker.copyWith(color: DesignSystem.onPrimaryContainer),
          ),
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
    );
  }

  TabBar _buildTabBar() => TabBar(
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
      );

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

    // csp650Projects comes from publicProjectsProvider, which already
    // queries published-only rows — no need to re-check publicationStatus.
    final combined = <SectionedProject>[
      for (final p in csp650Projects) SectionedProject(project: p, section: 'CSP650'),
      for (final p in csp600Projects) SectionedProject(project: p, section: 'CSP600'),
    ];

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
    final similarityCounts = _cachedSimilarityCounts;

    final visible =
        _filters.apply(combined, _searchController.text, similarityCounts);

    final onBrowse = _tabController.index == 0;
    return CustomScrollView(
      slivers: [
        _buildTitleBar(csp650Projects, csp600Async, isDesktop),
        SliverPersistentHeader(
          pinned: true,
          delegate: _PinnedTabBar(_buildTabBar()),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The report always covers the whole guide, so the Browse
              // filters would only mislead there.
              if (onBrowse) ...[
                GuideFilters(
                  isDesktop: isDesktop,
                  all: combined,
                  values: _filters,
                  onChanged: (v) => setState(() => _filters = v),
                  searchController: _searchController,
                  onSearchChanged: _onSearchChanged,
                  onClearSearch: () => setState(() => _searchController.clear()),
                  onReset: _resetFilters,
                  mobileExpanded: _mobileFiltersExpanded,
                  onMobileExpandedChanged: (v) =>
                      setState(() => _mobileFiltersExpanded = v),
                ),
                const SizedBox(height: 4),
                GuideSectionSummary(visible: visible, isDesktop: isDesktop),
              ],
              if (csp600Async.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Loading CSP600 proposals…',
                    textAlign: TextAlign.center,
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
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: DesignSystem.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (onBrowse)
          ...guideBrowseSlivers(
            visible: visible,
            similarityCounts: similarityCounts,
            isDesktop: isDesktop,
            onOpenSimilar: _openSimilarProjects,
          )
        else
          // Clusters are the expensive O(n^2) part of this feature — only
          // computed while this tab is selected, so typing in search while
          // on Browse doesn't pay for it. Scoped to the full corpus (not
          // the Browse filters) so the report reflects the whole guide.
          // Both passes are cached in state and only rebuilt when the
          // underlying project lists change (_ensureSimilarityCache clears
          // them), not on every search keystroke.
          ...guideReportSlivers(
            tagClusters: _cachedTagClusters ??= buildGuideTagClusters(
                _cachedFullProjList, _cachedCategoryTagIndex, _cachedIdToSection),
            titleClusters: _cachedTitleClusters ??= buildGuideTitleClusters(
                _cachedFullProjList, _cachedTitleTokenIndex, _cachedIdToSection),
            similarityCounts: similarityCounts,
            categoryTagIndex: _cachedCategoryTagIndex,
            idToSection: _cachedIdToSection,
            isDesktop: isDesktop,
          ),
      ],
    );
  }
}

/// The Browse / Redundancy Report tabs: the only part of the header that
/// stays pinned while the list scrolls.
class _PinnedTabBar extends SliverPersistentHeaderDelegate {
  _PinnedTabBar(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Material(color: DesignSystem.primary, child: tabBar);

  @override
  bool shouldRebuild(_PinnedTabBar oldDelegate) => oldDelegate.tabBar != tabBar;
}
