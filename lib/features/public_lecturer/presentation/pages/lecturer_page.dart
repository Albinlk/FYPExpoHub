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
  String _selectedRole = 'Both';
  String _selectedDay = 'All';
  bool _calonIndustriOnly = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;

    final allProjects = ref.watch(publicProjectsProvider);
    final publishedProjects = allProjects.where((p) => p.publicationStatus == 'published').toList();

    final filteredProjects = publishedProjects.where((project) {
      final query = _nameController.text.toLowerCase().trim();
      if (query.isEmpty) return false;

      final supervisorMatch = project.supervisorDisplayName.toLowerCase().contains(query);
      final examinerMatch = (project.examinerDisplayName?.toLowerCase().contains(query) ?? false);

      final roleMatch = _selectedRole == 'Supervisor'
          ? supervisorMatch
          : _selectedRole == 'Examiner'
              ? examinerMatch
              : supervisorMatch || examinerMatch;
      if (!roleMatch) return false;
      if (_selectedDay != 'All') {
        final dayLabel = project.presentationDay?.split(' - ').first;
        if (dayLabel != _selectedDay) return false;
      }
      if (_calonIndustriOnly && !project.calonIndustri) return false;
      return true;
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
              style: (isDesktop ? DesignSystem.bodyLg : DesignSystem.bodyLgMobile).copyWith(color: DesignSystem.onSurfaceVariant),
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
                        const SizedBox(width: DesignSystem.spaceMd),
                        Text('Day: ', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant)),
                        _buildDayChip('All'),
                        _buildDayChip('Day 1'),
                        _buildDayChip('Day 2'),
                        const SizedBox(width: DesignSystem.spaceMd),
                        FilterChip(
                          selected: _calonIndustriOnly,
                          onSelected: (val) => setState(() => _calonIndustriOnly = val),
                          avatar: Icon(
                            Icons.workspace_premium,
                            size: 14,
                            color: _calonIndustriOnly ? Colors.white : DesignSystem.tertiary,
                          ),
                          label: Text(
                               'Industry Candidate',
                            style: DesignSystem.bodySm.copyWith(
                              color: _calonIndustriOnly ? Colors.white : DesignSystem.onSurfaceVariant,
                            ),
                          ),
                          selectedColor: DesignSystem.tertiary,
                          checkmarkColor: Colors.white,
                        ),
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
                  childAspectRatio: isDesktop ? 2.2 : 1.9,
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

  Widget _buildDayChip(String day) {
    final isSelected = _selectedDay == day;
    return ChoiceChip(
      label: Text(day),
      selected: isSelected,
      onSelected: (val) => setState(() => _selectedDay = day),
      selectedColor: DesignSystem.secondary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : DesignSystem.onSurfaceVariant,
        fontSize: 12,
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: project.calonIndustri ? DesignSystem.tertiaryContainer.withValues(alpha: 0.15) : null,
      surfaceTintColor: project.calonIndustri ? DesignSystem.tertiary : null,
      child: InkWell(
        onTap: () => context.push('/projects/${project.id}?from=lecturer'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Unique cover on the left
            SizedBox(
              width: 100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProjectCoverImage(
                    title: project.title,
                    category: project.category,
                    imageUrl: project.coverImageUrl,
                    fit: BoxFit.cover,
                  ),
                  if (project.calonIndustri)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: DesignSystem.tertiary,
                          borderRadius: DesignSystem.radiusSm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.workspace_premium, size: 11, color: Colors.white),
                            const SizedBox(width: 3),
                            Text(
                            'Industry Candidate',
                              style: DesignSystem.labelCaps.copyWith(color: Colors.white, fontSize: 8),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
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
                        Expanded(
                          child: Text(
                            project.programmeCode,
                            style: DesignSystem.labelCaps.copyWith(color: DesignSystem.secondary, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ),
                        if (project.boothNumber != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: DesignSystem.secondaryContainer,
                              borderRadius: DesignSystem.radiusSm,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.room, size: 13, color: DesignSystem.onSecondaryContainer),
                                const SizedBox(width: 3),
                                Text(
                                  project.boothNumber!,
                                  style: DesignSystem.bodySm.copyWith(
                                    color: DesignSystem.onSecondaryContainer,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (project.presentationDay != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: DesignSystem.primaryContainer,
                              borderRadius: DesignSystem.radiusSm,
                            ),
                            child: Text(
                              project.presentationDay!.split(' - ').first,
                              style: DesignSystem.labelCaps.copyWith(
                                color: DesignSystem.onPrimaryContainer,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Student(s): ${project.teamDisplayNames.join(', ')}',
                      style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant, height: 1.3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Supervisor: ${project.supervisorDisplayName}',
                      style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant, height: 1.3),
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
            ),
          ],
        ),
      ),
    );
  }
}
