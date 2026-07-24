import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/widgets/project_cover_image.dart';

class LecturerPage extends ConsumerStatefulWidget {
  const LecturerPage({super.key});

  @override
  ConsumerState<LecturerPage> createState() => _LecturerPageState();
}

class _LecturerPageState extends ConsumerState<LecturerPage> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedRole = 'Both'; // 'Supervisor', 'Examiner', 'Both'

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;

    final allProjects = ref.watch(projectsProvider);
    final publishedProjects = allProjects.where((p) => p.publicationStatus == 'published').toList();

    final filteredProjects = publishedProjects.where((project) {
      final query = _nameController.text.toLowerCase().trim();
      if (query.isEmpty) return false;

      final supervisorMatch = project.supervisorDisplayName.toLowerCase().contains(query);
      final examinerMatch = (project.examinerDisplayName?.toLowerCase().contains(query) ?? false);

      if (_selectedRole == 'Supervisor') return supervisorMatch;
      if (_selectedRole == 'Examiner') return examinerMatch;
      return supervisorMatch || examinerMatch;
    }).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: DesignSystem.spaceXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lecturer Portal', style: DesignSystem.h1.copyWith(color: DesignSystem.primary)),
            const SizedBox(height: DesignSystem.spaceSm),
            Text(
              'Search for projects assigned to you as a supervisor or examiner.',
              style: DesignSystem.bodyLg.copyWith(color: DesignSystem.onSurfaceVariant),
              softWrap: true,
            ),
            const SizedBox(height: DesignSystem.spaceXl),
            
            // Filter Panel
            Card(
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceMd),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            onChanged: (val) => setState(() {}),
                            decoration: const InputDecoration(
                              hintText: 'Enter your full name...',
                              prefixIcon: Icon(Icons.person_search, color: DesignSystem.primary),
                            ),
                          ),
                        ),
                        if (isDesktop) ...[
                          const SizedBox(width: DesignSystem.spaceMd),
                          ElevatedButton(
                            onPressed: () {
                              _nameController.clear();
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignSystem.surfaceContainer,
                              foregroundColor: DesignSystem.primary,
                              shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            ),
                            child: const Text('Clear'),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: DesignSystem.spaceXs,
                      children: [
                        Text('Filter by role: ', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant)),
                        _buildRoleChip('Supervisor'),
                        _buildRoleChip('Examiner'),
                        _buildRoleChip('Both'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DesignSystem.spaceXl),
            
            // Results
            if (_nameController.text.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(DesignSystem.spaceXl),
                  child: Column(
                    children: [
                      const Icon(Icons.search, size: 64, color: DesignSystem.outlineVariant),
                      const SizedBox(height: DesignSystem.spaceMd),
                      Text('Please enter your name to find your projects', style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant)),
                    ],
                  ),
                ),
              )
            else if (filteredProjects.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(DesignSystem.spaceXl),
                  child: Text('No projects found for this name and role.', style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant)),
                ),
              )
            else ...[
              Text('Found ${filteredProjects.length} projects:', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.primary)),
              const SizedBox(height: DesignSystem.spaceMd),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 3 : 1,
                  crossAxisSpacing: DesignSystem.spaceMd,
                  mainAxisSpacing: DesignSystem.spaceMd,
                  childAspectRatio: isDesktop ? 2.5 : 2.2,
                ),
                itemCount: filteredProjects.length,
                itemBuilder: (context, index) {
                  final project = filteredProjects[index];
                  return _buildProjectCard(project);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip(String role) {
    final isSelected = _selectedRole == role;
    return ChoiceChip(
      label: Text(role),
      selected: isSelected,
      onSelected: (val) => setState(() => _selectedRole = role),
      selectedColor: DesignSystem.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : DesignSystem.onSurfaceVariant,
        fontSize: 12,
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/projects/${project.id}?from=lecturer'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Unique cover on the left
            SizedBox(
              width: 100,
              child: ProjectCoverImage(
                title: project.title,
                category: project.category,
                imageUrl: project.coverImageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      project.title,
                      style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          project.programmeCode,
                          style: DesignSystem.labelCaps.copyWith(color: DesignSystem.secondary, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                        const Spacer(),
                        if (project.boothNumber != null) ...[
                          const Icon(Icons.room, size: 12, color: DesignSystem.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            project.boothNumber!,
                            style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant, fontSize: 10),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      project.category,
                      style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
