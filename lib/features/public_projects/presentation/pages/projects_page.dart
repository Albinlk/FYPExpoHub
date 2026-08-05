import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/widgets/project_card.dart';

class ProjectsPage extends ConsumerStatefulWidget {
  const ProjectsPage({super.key});

  @override
  ConsumerState<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends ConsumerState<ProjectsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedProgramme = 'All';
  String _selectedCategory = 'All';
  bool _calonIndustriOnly = false;
  bool _initialized = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_initialized) {
        _initialized = true;
        final searchQuery =
            GoRouterState.of(context).uri.queryParameters['search'] ?? '';
        if (searchQuery.isNotEmpty) {
          _searchController.text = searchQuery;
          setState(() {});
        }
      }
    });
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  final List<String> _programmes = [
    'All',
    'CS230',
    'CS251',
    'CS253',
    'CS255',
    'CS266',
  ];
  final List<String> _categories = [
    'All',
    'Computer Science',
    'Networking & Communication',
    'Cybersecurity',
    'Network Security & Infrastructure',
    'Software Engineering & Applications',
  ];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final padding = isDesktop
        ? DesignSystem.marginDesktop
        : DesignSystem.marginMobile;

    final allProjects = ref.watch(publicProjectsProvider);
    final publishedProjects = allProjects
        .where((p) => p.publicationStatus == 'published')
        .toList();

    // Filter projects logic
    final filteredProjects = publishedProjects.where((project) {
      final searchLower = _searchController.text.toLowerCase();
      final matchesSearch =
          searchLower.isEmpty ||
          project.title.toLowerCase().contains(searchLower) ||
          project.teamDisplayNames.any(
            (name) => name.toLowerCase().contains(searchLower),
          ) ||
          project.supervisorDisplayName.toLowerCase().contains(searchLower) ||
          (project.examinerDisplayName?.toLowerCase().contains(searchLower) ??
              false);
      final matchesProgramme =
          _selectedProgramme == 'All' ||
          project.programmeCode.contains(_selectedProgramme);
      final matchesCategory =
          _selectedCategory == 'All' || project.category == _selectedCategory;
      final matchesCalon = !_calonIndustriOnly || project.calonIndustri;
      return matchesSearch &&
          matchesProgramme &&
          matchesCategory &&
          matchesCalon;
    }).toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(publicProjectsProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: DesignSystem.spaceXl,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Project Catalogue',
                            style: DesignSystem.h1.copyWith(
                              color: DesignSystem.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Refresh projects',
                          onPressed: () =>
                              ref.read(publicProjectsProvider.notifier).refresh(),
                          icon: const Icon(
                            Icons.refresh,
                            color: DesignSystem.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignSystem.spaceSm),
                    Text(
                      'Explore all final year projects presented by FSKM students.',
                      style:
                          (isDesktop
                                  ? DesignSystem.bodyLg
                                  : DesignSystem.bodyLgMobile)
                              .copyWith(color: DesignSystem.onSurfaceVariant),
                      softWrap: true,
                    ),
                    const SizedBox(height: DesignSystem.spaceXl),

                    // Search & Filter Panel
                    _buildSearchAndFilters(isDesktop),
                  ],
                ),
              ),
            ),

            if (filteredProjects.isEmpty)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                sliver: SliverToBoxAdapter(child: _buildEmptyState(isDesktop)),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: padding,
                ).copyWith(bottom: DesignSystem.spaceXl),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 3 : 1,
                    crossAxisSpacing: DesignSystem.spaceMd,
                    mainAxisSpacing: DesignSystem.spaceMd,
                    childAspectRatio: isDesktop ? 1.55 : 1.35,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final project = filteredProjects[index];
                    return ProjectCard(
                      project: project,
                      onTap: () => context.go('/projects/${project.id}'),
                    );
                  }, childCount: filteredProjects.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(bool isDesktop) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceMd),
        child: Column(
          children: [
            // Search Input Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText:
                          'Search by project title, student, or supervisor...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: DesignSystem.primary,
                      ),
                    ),
                  ),
                ),
                if (isDesktop) ...[
                  const SizedBox(width: DesignSystem.spaceMd),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _searchController.clear();
                      _selectedProgramme = 'All';
                      _selectedCategory = 'All';
                      _calonIndustriOnly = false;
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.surfaceContainer,
                      foregroundColor: DesignSystem.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: DesignSystem.radiusLg,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Reset Filters'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: DesignSystem.spaceMd),

            // Filters Dropdowns
            isDesktop
                ? Row(
                    children: [
                      Expanded(
                        child: _buildDropdownFilter(
                          'Academic Program',
                          _selectedProgramme,
                          _programmes,
                          (val) {
                            setState(() => _selectedProgramme = val!);
                          },
                        ),
                      ),
                      const SizedBox(width: DesignSystem.spaceMd),
                      Expanded(
                        child: _buildDropdownFilter(
                          'Project Category',
                          _selectedCategory,
                          _categories,
                          (val) {
                            setState(() => _selectedCategory = val!);
                          },
                        ),
                      ),
                      const SizedBox(width: DesignSystem.spaceMd),
                      _buildCalonChip(),
                    ],
                  )
                : Column(
                    children: [
                      _buildDropdownFilter(
                        'Academic Program',
                        _selectedProgramme,
                        _programmes,
                        (val) {
                          setState(() => _selectedProgramme = val!);
                        },
                      ),
                      const SizedBox(height: DesignSystem.spaceMd),
                      _buildDropdownFilter(
                        'Project Category',
                        _selectedCategory,
                        _categories,
                        (val) {
                          setState(() => _selectedCategory = val!);
                        },
                      ),
                      const SizedBox(height: DesignSystem.spaceMd),
                      _buildCalonChip(),
                      const SizedBox(height: DesignSystem.spaceMd),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => setState(() {
                            _searchController.clear();
                            _selectedProgramme = 'All';
                            _selectedCategory = 'All';
                            _calonIndustriOnly = false;
                          }),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignSystem.surfaceContainer,
                            foregroundColor: DesignSystem.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: DesignSystem.radiusLg,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                          child: const Text('Reset Filters'),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
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
                  child: Text(item, style: DesignSystem.bodySm, softWrap: true),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalonChip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Industry Candidate', style: DesignSystem.labelCaps),
        const SizedBox(height: 6),
        FilterChip(
          selected: _calonIndustriOnly,
          onSelected: (val) => setState(() => _calonIndustriOnly = val),
          avatar: Icon(
            Icons.workspace_premium,
            size: 16,
            color: _calonIndustriOnly ? Colors.white : DesignSystem.tertiary,
          ),
          label: Text(
            _calonIndustriOnly ? 'Showing only' : 'Show only',
            style: DesignSystem.bodySm.copyWith(
              color: _calonIndustriOnly
                  ? Colors.white
                  : DesignSystem.onSurfaceVariant,
            ),
          ),
          selectedColor: DesignSystem.tertiary,
          checkmarkColor: Colors.white,
        ),
      ],
    );
  }


  Widget _buildEmptyState(bool isDesktop) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            const Icon(
              Icons.folder_open_outlined,
              size: 64,
              color: DesignSystem.outlineVariant,
            ),
            const SizedBox(height: DesignSystem.spaceSm),
            Text(
              'No Projects Found',
              style: (isDesktop ? DesignSystem.h3 : DesignSystem.h3Mobile)
                  .copyWith(color: DesignSystem.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              'Please check your search keywords or reset filters.',
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
