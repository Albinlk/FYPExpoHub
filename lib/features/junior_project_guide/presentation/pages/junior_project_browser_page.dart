import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/state/state_providers.dart';
import '../../domain/csp600_csv_loader.dart';
import '../../domain/project_similarity.dart';
import '../widgets/project_row_widget.dart';
import '../widgets/redundancy_cluster_widget.dart';

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
    extends ConsumerState<JuniorProjectBrowserPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSection = 'all';
  String _selectedProgramme = 'All';
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    final csp650Async = ref.watch(publicProjectsProvider);
    final csp600Async = ref.watch(csp600ProposalsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          bottom: const TabBar(
            indicatorColor: Colors.white70,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: TextStyle(fontSize: 14),
            tabs: [
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
        body: csp600Async.when(
          data: (csp600Proposals) {
            final csp650Projects = csp650Async;
            final combined = _buildCombined(csp650Projects, csp600Proposals);
            final visible = _applyFilters(combined);
            final projList = visible.map((sp) => sp.project).toList();

            return Column(
              children: [
                _buildSearchAndFilters(isDesktop, combined),
                const SizedBox(height: 4),
                _buildSectionSummary(visible, isDesktop),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildBrowseTab(visible, projList, isDesktop),
                      _buildReportTab(projList, isDesktop),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              'Error loading CSP600 data: $e',
              style: DesignSystem.bodyMd.copyWith(color: DesignSystem.error),
            ),
          ),
        ),
      ),
    );
  }

  List<SectionedProject> _buildCombined(
    List<Project> csp650Projects,
    List<Project> csp600Projects,
  ) {
    final result = <SectionedProject>[];
    for (final p in csp650Projects) {
      if (p.publicationStatus == 'published') {
        result.add(SectionedProject(project: p, section: 'CSP650'));
      }
    }
    for (final p in csp600Projects) {
      result.add(SectionedProject(project: p, section: 'CSP600'));
    }
    return result;
  }

  List<SectionedProject> _applyFilters(List<SectionedProject> all) {
    final searchLower = _searchController.text.toLowerCase();

    return all.where((sp) {
      final p = sp.project;

      final matchesSection =
          _selectedSection == 'all' || sp.section == _selectedSection;

      final matchesSearch = searchLower.isEmpty ||
          p.title.toLowerCase().contains(searchLower) ||
          p.supervisorDisplayName.toLowerCase().contains(searchLower) ||
          p.technologyTags
              .any((t) => t.toLowerCase().contains(searchLower));

      final matchesProgramme =
          _selectedProgramme == 'All' || p.programmeCode == _selectedProgramme;

      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;

      return matchesSection &&
          matchesSearch &&
          matchesProgramme &&
          matchesCategory;
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

  List<String> _allCategories(List<SectionedProject> all) {
    final seen = <String>{};
    for (final sp in all) {
      if (sp.project.category.isNotEmpty) {
        seen.add(sp.project.category);
      }
    }
    return seen.toList()..sort();
  }

  Widget _buildSearchAndFilters(
    bool isDesktop,
    List<SectionedProject> all,
  ) {
    final programmes = _allProgrammes(all);
    final categories = _allCategories(all);

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile,
        vertical: DesignSystem.spaceMd,
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceMd),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search by project title, supervisor, or tech tags...',
                prefixIcon:
                    const Icon(Icons.search, color: DesignSystem.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: DesignSystem.spaceMd),
            isDesktop
                ? _buildDesktopFilters(programmes, categories)
                : _buildMobileFilters(programmes, categories),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopFilters(
    List<String> programmes,
    List<String> categories,
  ) {
    return Row(
      children: [
        Wrap(
          spacing: 8,
          children: [
            _buildSectionPill('All', 'all'),
            _buildSectionPill('CSP650', 'CSP650'),
            _buildSectionPill('CSP600', 'CSP600'),
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
        const SizedBox(width: DesignSystem.spaceLg),
        Expanded(
          child: _buildDropdownFilter(
            'Project Category',
            _selectedCategory,
            ['All', ...categories],
            (v) => setState(() => _selectedCategory = v!),
          ),
        ),
        const SizedBox(width: DesignSystem.spaceLg),
        TextButton(
          onPressed: () => setState(() {
            _searchController.clear();
            _selectedSection = 'all';
            _selectedProgramme = 'All';
            _selectedCategory = 'All';
          }),
          child: const Text('Reset Filters'),
        ),
      ],
    );
  }

  Widget _buildMobileFilters(
    List<String> programmes,
    List<String> categories,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: [
            _buildSectionPill('All', 'all'),
            _buildSectionPill('CSP650', 'CSP650'),
            _buildSectionPill('CSP600', 'CSP600'),
          ],
        ),
        const SizedBox(height: DesignSystem.spaceMd),
        _buildDropdownFilter(
          'Academic Program',
          _selectedProgramme,
          ['All', ...programmes],
          (v) => setState(() => _selectedProgramme = v!),
        ),
        const SizedBox(height: DesignSystem.spaceMd),
        _buildDropdownFilter(
          'Project Category',
          _selectedCategory,
          ['All', ...categories],
          (v) => setState(() => _selectedCategory = v!),
        ),
        const SizedBox(height: DesignSystem.spaceMd),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => setState(() {
              _searchController.clear();
              _selectedSection = 'all';
              _selectedProgramme = 'All';
              _selectedCategory = 'All';
            }),
            child: const Text('Reset Filters'),
          ),
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
      child: Row(
        children: [
          if (csp650Count > 0) ...[
            _buildSummaryBadge('CSP650', csp650Count, DesignSystem.secondaryContainer,
                DesignSystem.onSecondaryContainer, 'projects'),
            const SizedBox(width: 8),
          ],
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
    List<Project> projList,
    bool isDesktop,
  ) {
    if (visible.isEmpty) {
      return _buildEmptyState(isDesktop);
    }

    final padding = isDesktop
        ? DesignSystem.marginDesktop
        : DesignSystem.marginMobile;

    return ListView.separated(
      padding: EdgeInsets.only(
        left: padding,
        right: padding,
        bottom: DesignSystem.spaceLg,
        top: 4,
      ),
      itemCount: visible.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final sp = visible[index];
        return ProjectRowWidget(
          project: sp.project,
          allProjects: projList,
          showSection: true,
          section: sp.section,
        );
      },
    );
  }

  Widget _buildReportTab(
    List<Project> projList,
    bool isDesktop,
  ) {
    final clusters = ProjectSimilarity.buildClusters(projList);

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
          allProjects: projList,
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
              style: (isDesktop ? DesignSystem.h3 : DesignSystem.h3Mobile)
                  .copyWith(color: DesignSystem.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your search keywords or reset filters.',
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
