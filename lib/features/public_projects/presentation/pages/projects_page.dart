import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/widgets/project_cover_image.dart';

class ProjectsPage extends ConsumerStatefulWidget {
  const ProjectsPage({super.key});

  @override
  ConsumerState<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends ConsumerState<ProjectsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedProgramme = 'All';
  String _selectedCategory = 'All';

  final List<String> _programmes = ['All', 'CS230', 'CS251', 'CS253', 'CS255', 'CS266'];
  final List<String> _categories = ['All', 'Computer Science', 'Networking & Communication', 'Cybersecurity', 'Network Security & Infrastructure', 'Software Engineering & Applications'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;

    final allProjects = ref.watch(projectsProvider);
    final publishedProjects = allProjects.where((p) => p.publicationStatus == 'published').toList();

    // Filter projects logic
    final filteredProjects = publishedProjects.where((project) {
      final matchesSearch = project.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          project.teamDisplayNames.any((name) => name.toLowerCase().contains(_searchController.text.toLowerCase())) ||
          project.supervisorDisplayName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          (project.examinerDisplayName?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false);
      final matchesProgramme = _selectedProgramme == 'All' || project.programmeCode.contains(_selectedProgramme);
      final matchesCategory = _selectedCategory == 'All' || project.category == _selectedCategory;
      return matchesSearch && matchesProgramme && matchesCategory;
    }).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: DesignSystem.spaceXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project Catalog', style: DesignSystem.h1.copyWith(color: DesignSystem.primary)),
            const SizedBox(height: DesignSystem.spaceSm),
            Text('Explore all final year projects presented by FSKM students.', style: DesignSystem.bodyLg.copyWith(color: DesignSystem.onSurfaceVariant), softWrap: true),
            const SizedBox(height: DesignSystem.spaceXl),

            // Search & Filter Panel
            _buildSearchAndFilters(isDesktop),

            const SizedBox(height: DesignSystem.spaceXl),

            // Main Projects Grid
            filteredProjects.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 3 : 1,
                      crossAxisSpacing: DesignSystem.spaceMd,
                      mainAxisSpacing: DesignSystem.spaceMd,
                      childAspectRatio: isDesktop ? 1.55 : 1.35,
                    ),
                    itemCount: filteredProjects.length,
                    itemBuilder: (context, index) {
                      final project = filteredProjects[index];
                      return _buildProjectCard(project);
                    },
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
                    onChanged: (val) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search by project title, student, or supervisor...',
                      prefixIcon: Icon(Icons.search, color: DesignSystem.primary),
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
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.surfaceContainer,
                      foregroundColor: DesignSystem.primary,
                      shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                      Expanded(child: _buildDropdownFilter('Academic Program', _selectedProgramme, _programmes, (val) {
                        setState(() => _selectedProgramme = val!);
                      })),
                      const SizedBox(width: DesignSystem.spaceMd),
                      Expanded(child: _buildDropdownFilter('Project Category', _selectedCategory, _categories, (val) {
                        setState(() => _selectedCategory = val!);
                      })),
                    ],
                  )
                : Column(
                    children: [
                      _buildDropdownFilter('Academic Program', _selectedProgramme, _programmes, (val) {
                        setState(() => _selectedProgramme = val!);
                      }),
                      const SizedBox(height: DesignSystem.spaceMd),
                      _buildDropdownFilter('Project Category', _selectedCategory, _categories, (val) {
                        setState(() => _selectedCategory = val!);
                      }),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilter(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant)),
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

  Widget _buildProjectCard(Project project) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/projects/${project.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProjectCoverImage(
                    title: project.title,
                    category: project.category,
                    imageUrl: project.coverImageUrl,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: DesignSystem.radiusSm,
                      ),
                      child: Text(
                        project.category,
                        style: DesignSystem.labelCaps.copyWith(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                  if (project.boothNumber != null)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: DesignSystem.radiusSm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.room, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(project.boothNumber!, style: DesignSystem.labelCaps.copyWith(color: Colors.white, fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: DesignSystem.bodyMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: DesignSystem.primary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    project.programmeCode,
                    style: DesignSystem.labelCaps.copyWith(
                      color: DesignSystem.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Student(s): ${project.teamDisplayNames.join(', ')}',
                    style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant, height: 1.3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Supervisor: ${project.supervisorDisplayName}',
                    style: DesignSystem.bodySm.copyWith(
                      color: DesignSystem.onSurfaceVariant,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (project.examinerDisplayName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Examiner: ${project.examinerDisplayName}',
                      style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant, height: 1.3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            const Icon(Icons.folder_open_outlined, size: 64, color: DesignSystem.outlineVariant),
            const SizedBox(height: DesignSystem.spaceSm),
            Text('No Projects Found', style: DesignSystem.h3.copyWith(color: DesignSystem.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text('Please check your search keywords or reset filters.', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
