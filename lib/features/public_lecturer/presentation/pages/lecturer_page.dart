import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/widgets/project_card.dart';

class LecturerPage extends ConsumerStatefulWidget {
  const LecturerPage({super.key});

  @override
  ConsumerState<LecturerPage> createState() => _LecturerPageState();
}

class _LecturerPageState extends ConsumerState<LecturerPage> {
  final TextEditingController _nameController = TextEditingController();
  Timer? _searchDebounce;
  String _selectedRole = 'All';
  String _selectedDay = 'All';
  bool _calonIndustriOnly = false;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;

    // `publicProjectsProvider` already only exposes `published` projects.
    final allProjects = ref.watch(publicProjectsProvider);

    final filteredProjects = allProjects.where((project) {
      final query = _nameController.text.toLowerCase().trim();
      if (query.isEmpty) return false;

      final supervisorMatch = project.supervisorDisplayName.toLowerCase().contains(query);
      final examinerMatch = (project.examinerDisplayName?.toLowerCase().contains(query) ?? false);

      final roleMatch = _selectedRole == 'All'
          ? supervisorMatch || examinerMatch
          : _selectedRole == 'Supervisor'
              ? supervisorMatch
              : examinerMatch;
      if (!roleMatch) return false;
      if (_selectedDay != 'All') {
        if (project.presentationDay != _selectedDay) return false;
      }
      if (_calonIndustriOnly && !project.calonIndustri) return false;
      return true;
    }).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
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
                                  onChanged: (_) {
                                    _searchDebounce?.cancel();
                                    _searchDebounce = Timer(
                                      const Duration(milliseconds: 250),
                                      () => setState(() {}),
                                    );
                                  },
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
                          if (isDesktop)
                            Row(
                              children: [
                                Expanded(child: _buildDropdown('Role', _selectedRole, ['All', 'Supervisor', 'Examiner'], (val) => setState(() => _selectedRole = val!))),
                                const SizedBox(width: DesignSystem.spaceMd),
                                Expanded(child: _buildDropdown('Day', _selectedDay, ['All', 'Day 1 - 06 Aug 2026', 'Day 2 - 07 Aug 2026'], (val) => setState(() => _selectedDay = val!))),
                                const SizedBox(width: DesignSystem.spaceMd),
                                Expanded(child: _buildDropdown('Type', _calonIndustriOnly ? 'Industry' : 'All', ['All', 'Industry Candidate'], (val) => setState(() => _calonIndustriOnly = val == 'Industry Candidate'))),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _buildDropdown('Role', _selectedRole, ['All', 'Supervisor', 'Examiner'], (val) => setState(() => _selectedRole = val!)),
                                const SizedBox(height: DesignSystem.spaceSm),
                                _buildDropdown('Day', _selectedDay, ['All', 'Day 1 - 06 Aug 2026', 'Day 2 - 07 Aug 2026'], (val) => setState(() => _selectedDay = val!)),
                                const SizedBox(height: DesignSystem.spaceSm),
                                _buildDropdown('Type', _calonIndustriOnly ? 'Industry' : 'All', ['All', 'Industry Candidate'], (val) => setState(() => _calonIndustriOnly = val == 'Industry Candidate')),
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
                            Text('Please enter your name to find your projects', textAlign: TextAlign.center, style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    )
                  else if (filteredProjects.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(DesignSystem.spaceXl),
                        child: Text('No projects found for this name and role.', textAlign: TextAlign.center, style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant)),
                      ),
                    )
                  else
                    Text('Found ${filteredProjects.length} projects:', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.primary)),
                ],
              ),
            ),
          ),
          if (_nameController.text.isNotEmpty && filteredProjects.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 3 : 1,
                  crossAxisSpacing: DesignSystem.spaceMd,
                  mainAxisSpacing: DesignSystem.spaceMd,
                  childAspectRatio: isDesktop ? 1.55 : 1.35,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final project = filteredProjects[index];
                    return ProjectCard(
                      project: project,
                      onTap: () => context.push('/projects/${project.slug}?from=lecturer'),
                    );
                  },
                  childCount: filteredProjects.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: DesignSystem.spaceXl)),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt, style: DesignSystem.bodySm))).toList(),
      onChanged: onChanged,
    );
  }
}
