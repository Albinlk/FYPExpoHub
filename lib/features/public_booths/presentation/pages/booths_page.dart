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

  final List<String> _zones = ['All', 'Zon A', 'Zon B', 'Zon C'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;

    final booths = ref.watch(boothsProvider);
    final projects = ref.watch(projectsProvider);

    final filteredBooths = booths.where((booth) {
      final associatedProj = projects.cast<Project?>().firstWhere(
        (p) => p?.id == booth.projectId,
        orElse: () => null,
      );
      final projectTitle = associatedProj?.title ?? '';

      final matchesSearch = booth.boothNumber.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          projectTitle.toLowerCase().contains(_searchController.text.toLowerCase());
      
      final matchesZone = _selectedZone == 'All' || booth.zone.contains(_selectedZone);
      return matchesSearch && matchesZone;
    }).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: DesignSystem.spaceXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Find Exhibition Booths', style: DesignSystem.h1.copyWith(color: DesignSystem.primary)),
            const SizedBox(height: DesignSystem.spaceSm),
            Text('Locate your selected project booth inside the main hall.', style: DesignSystem.bodyLg.copyWith(color: DesignSystem.onSurfaceVariant), softWrap: true),
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
                    if (isDesktop) ...[
                      const SizedBox(width: DesignSystem.spaceMd),
                      SizedBox(
                        width: 260,
                        child: DropdownButtonFormField<String>(
                          value: _selectedZone,
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                          onChanged: (val) => setState(() => _selectedZone = val!),
                          items: _zones.map((zone) {
                            return DropdownMenuItem(value: zone, child: Text(zone, style: DesignSystem.bodySm, softWrap: true));
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (!isDesktop) ...[
              const SizedBox(height: DesignSystem.spaceMd),
              DropdownButtonFormField<String>(
                value: _selectedZone,
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                onChanged: (val) => setState(() => _selectedZone = val!),
                items: _zones.map((zone) {
                  return DropdownMenuItem(value: zone, child: Text(zone, style: DesignSystem.bodySm, softWrap: true));
                }).toList(),
              ),
            ],

            const SizedBox(height: DesignSystem.spaceXl),

            // Main Split Grid Map vs Cards
            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildBoothsList(filteredBooths, projects)),
                      const SizedBox(width: DesignSystem.spaceLg),
                      Expanded(flex: 2, child: _buildHallLayoutPlan()),
                    ],
                  )
                : Column(
                    children: [
                      _buildBoothsList(filteredBooths, projects),
                      const SizedBox(height: DesignSystem.spaceLg),
                      _buildHallLayoutPlan(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoothsList(List<Booth> filteredBooths, List<Project> projects) {
    if (filteredBooths.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text('No booths found.', style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredBooths.length,
      itemBuilder: (context, index) {
        final booth = filteredBooths[index];
        final associatedProj = projects.cast<Project?>().firstWhere(
          (p) => p?.id == booth.projectId,
          orElse: () => null,
        );

        return Card(
          margin: const EdgeInsets.only(bottom: DesignSystem.spaceSm),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: DesignSystem.secondaryContainer,
              child: Text(booth.boothNumber, style: const TextStyle(color: DesignSystem.onSecondaryContainer, fontWeight: FontWeight.bold)),
            ),
            title: Text(
              '${booth.boothNumber} - ${associatedProj?.title ?? "No Project Assigned"}',
              style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary),
              softWrap: true,
            ),
            subtitle: Text(booth.zone, style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant), softWrap: true),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16, color: DesignSystem.primary),
              onPressed: () {
                if (associatedProj != null) {
                  context.go('/projects/${associatedProj.id}');
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHallLayoutPlan() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hall Layout Plan', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
            const SizedBox(height: 4),
            Text('Level 1 Plan, Blok Kuliah, FSKM', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
            const SizedBox(height: DesignSystem.spaceMd),
            Container(
              height: 280,
              decoration: BoxDecoration(
                color: DesignSystem.primary.withValues(alpha: 0.04),
                borderRadius: DesignSystem.radiusLg,
                border: Border.all(color: DesignSystem.surfaceContainer),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(Icons.map_outlined, size: 80, color: DesignSystem.primary.withValues(alpha: 0.15)),
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    child: _buildBoothMapNode('Zon A (CS)', Colors.blue.shade100, Colors.blue.shade900),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: _buildBoothMapNode('Zon B (Software)', Colors.amber.shade100, Colors.amber.shade900),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: _buildBoothMapNode('Zon C (NetSec)', Colors.teal.shade100, Colors.teal.shade900),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: _buildBoothMapNode('Stage / Main Hall', Colors.purple.shade100, Colors.purple.shade900),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignSystem.spaceMd),
            Text(
              'Tap any booth card to inspect project details or view interactive booth map.',
              style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant, fontStyle: FontStyle.italic),
              softWrap: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoothMapNode(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: DesignSystem.radiusSm,
      ),
      child: Text(label, style: DesignSystem.bodySm.copyWith(color: textColor, fontWeight: FontWeight.bold), softWrap: true),
    );
  }
}
