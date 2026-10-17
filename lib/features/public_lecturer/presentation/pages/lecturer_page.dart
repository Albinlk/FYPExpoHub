import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/widgets/project_card.dart';
import '../../../../core/utils/url_state.dart';
import '../../../../core/widgets/page_heading.dart';
import '../../../public_booths/presentation_days.dart';

class LecturerPage extends ConsumerStatefulWidget {
  const LecturerPage({super.key});

  @override
  ConsumerState<LecturerPage> createState() => _LecturerPageState();
}

class _LecturerPageState extends ConsumerState<LecturerPage> with UrlStateSync<LecturerPage> {
  final TextEditingController _nameController = TextEditingController();
  Timer? _searchDebounce;
  String _selectedRole = 'All';
  String _selectedDay = 'All';
  bool _calonIndustriOnly = false;
  bool _readQuery = false;

  static const _roles = ['All', 'Supervisor', 'Examiner'];
  /// 'All' plus the presentation days, rebuilt from the data / event every
  /// build (see [presentationDayOptions]).
  List<String> _days = const ['All'];

  /// [_selectedDay] while it is still one of [_days], else 'All'.
  String get _effectiveDay => _days.contains(_selectedDay) ? _selectedDay : 'All';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A shared or refreshed link restores the search and filters; unknown
    // values are ignored so a stale link cannot break a dropdown.
    if (_readQuery) return;
    _readQuery = true;
    final params = GoRouterState.of(context).uri.queryParameters;
    _nameController.text = params['name'] ?? '';
    final role = params['role'];
    if (_roles.contains(role)) _selectedRole = role!;
    // Days come from the data, which may not have loaded yet; a day that
    // never appears falls back to 'All' (see [_effectiveDay]).
    final day = params['day'];
    if (day != null && day.isNotEmpty) _selectedDay = day;
    _calonIndustriOnly = params['industry'] == 'true';
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // `publicProjectsProvider` already only exposes `published` projects.
    final allProjects = ref.watch(publicProjectsProvider);
    final event = ref.watch(eventProvider);
    _days = [
      'All',
      ...presentationDayOptions(
        allProjects.map((p) => p.presentationDay),
        eventStart: event.startAt,
        eventEnd: event.endAt,
      ),
    ];
    final selectedDay = _effectiveDay;
    syncUrl({
      'name': _nameController.text,
      'role': _selectedRole == 'All' ? null : _selectedRole,
      'day': selectedDay == 'All' ? null : selectedDay,
      'industry': _calonIndustriOnly ? 'true' : null,
    });
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;

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
      if (selectedDay != 'All') {
        if (project.presentationDay != selectedDay) return false;
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
                  PageHeading('Find Projects by Lecturer'),
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
                                    hintText: 'Enter your full name…',
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
                                Expanded(child: _buildDropdown('Role', _selectedRole, _roles, (val) => setState(() => _selectedRole = val!))),
                                const SizedBox(width: DesignSystem.spaceMd),
                                Expanded(child: _buildDropdown('Day', selectedDay, _days, (val) => setState(() => _selectedDay = val!))),
                                const SizedBox(width: DesignSystem.spaceMd),
                                Expanded(child: _buildDropdown('Type', _calonIndustriOnly ? 'Industry Candidate' : 'All', ['All', 'Industry Candidate'], (val) => setState(() => _calonIndustriOnly = val == 'Industry Candidate'))),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _buildDropdown('Role', _selectedRole, _roles, (val) => setState(() => _selectedRole = val!)),
                                const SizedBox(height: DesignSystem.spaceSm),
                                _buildDropdown('Day', selectedDay, _days, (val) => setState(() => _selectedDay = val!)),
                                const SizedBox(height: DesignSystem.spaceSm),
                                _buildDropdown('Type', _calonIndustriOnly ? 'Industry Candidate' : 'All', ['All', 'Industry Candidate'], (val) => setState(() => _calonIndustriOnly = val == 'Industry Candidate')),
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
                    Text('Found ${filteredProjects.length} ${filteredProjects.length == 1 ? 'project' : 'projects'}:', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.primary)),
                ],
              ),
            ),
          ),
          if (_nameController.text.isNotEmpty && filteredProjects.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              sliver: SliverGrid(
                gridDelegate: ProjectCard.gridDelegate(MediaQuery.sizeOf(context).width, textScale: MediaQuery.textScalerOf(context).scale(1), extraBodyHeight: 40),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final project = filteredProjects[index];
                    return ProjectCard(
                      project: project,
                      onTap: () => context.push('/projects/${project.slug}?from=lecturer'),
                      showStaff: true,
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
      // initialValue is only read once; re-key when the value or the options
      // change (the Day options arrive with the data).
      key: ValueKey('$label|$value|${options.join('|')}'),
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
