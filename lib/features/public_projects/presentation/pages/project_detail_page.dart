import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/state/state_providers.dart';

class ProjectDetailPage extends ConsumerWidget {
  final String slug;

  const ProjectDetailPage({super.key, required this.slug});

  void _goBack(BuildContext context) {
    final from = GoRouterState.of(context).uri.queryParameters['from'];
    if (from == 'lecturer') {
      context.go('/lecturer');
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;

    final allProjects = ref.watch(projectsProvider);
    // Find project by ID or Slug
    final project = allProjects.cast<Project?>().firstWhere(
      (p) => p != null && (p.id == slug || p.slug == slug),
      orElse: () => null,
    );

    if (project != null) {
      ref.read(projectVisitCountsProvider.notifier).recordVisit(project.id);
    }

    if (project == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _goBack(context),
          ),
          title: const Text('Projek Tidak Dijumpai'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: DesignSystem.outlineVariant),
              const SizedBox(height: 16),
              Text('Projek tidak ditemui.', style: DesignSystem.h3.copyWith(color: DesignSystem.onSurfaceVariant)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _goBack(context),
                child: const Text('Kembali ke Katalog'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _goBack(context),
        ),
        title: Text('Project Details', style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: DesignSystem.spaceXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            ClipRRect(
              borderRadius: DesignSystem.radiusLg,
              child: Image.network(
                project.coverImageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    color: DesignSystem.primary.withValues(alpha: 0.04),
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
              ),
            ),
            const SizedBox(height: DesignSystem.spaceLg),

            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: DesignSystem.spaceMd,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: DesignSystem.secondaryContainer,
                            borderRadius: DesignSystem.radiusSm,
                          ),
                          child: Text(
                            project.category,
                            style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSecondaryContainer),
                            softWrap: true,
                          ),
                        ),
                        if (project.boothNumber != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: DesignSystem.tertiaryContainer,
                              borderRadius: DesignSystem.radiusSm,
                            ),
                            child: Text(
                              'Booth ${project.boothNumber}',
                              style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onTertiaryContainer),
                              softWrap: true,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    Text(
                      project.title,
                      style: DesignSystem.h2.copyWith(color: DesignSystem.primary),
                      softWrap: true,
                    ),
                    const SizedBox(height: DesignSystem.spaceSm),
                    Text(
                      'Program: ${project.programmeName}',
                      style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: DesignSystem.spaceLg),

            // Content Split Column
            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildProjectMainDetails(project)),
                      const SizedBox(width: DesignSystem.spaceLg),
                      Expanded(flex: 2, child: _buildProjectSidebar(context, project)),
                    ],
                  )
                : Column(
                    children: [
                      _buildProjectMainDetails(project),
                      const SizedBox(height: DesignSystem.spaceLg),
                      _buildProjectSidebar(context, project),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectMainDetails(Project project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(DesignSystem.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Project Abstract & Description', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
                const SizedBox(height: DesignSystem.spaceMd),
                Text(
                  project.shortDescription,
                  style: DesignSystem.bodyMd.copyWith(height: 1.6),
                  softWrap: true,
                ),
                const SizedBox(height: DesignSystem.spaceLg),
                Text('Key Technologies Used', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
                const SizedBox(height: DesignSystem.spaceMd),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: project.technologyTags.map((t) {
                    return Chip(
                      label: Text(t, style: DesignSystem.bodySm.copyWith(color: DesignSystem.primary, fontWeight: FontWeight.w500)),
                      backgroundColor: DesignSystem.surfaceContainer,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusFull),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectSidebar(BuildContext context, Project project) {
    return Column(
      children: [
        // Team details card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(DesignSystem.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.people, color: DesignSystem.primary),
                    SizedBox(width: 8),
                    Text('Student Team', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: DesignSystem.primary)),
                  ],
                ),
                const SizedBox(height: DesignSystem.spaceMd),
                ... project.teamDisplayNames.map((name) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 16, color: DesignSystem.secondary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(name, style: DesignSystem.bodyMd, softWrap: true)),
                      ],
                    ),
                  );
                }).toList(),
                const Divider(height: 24),
                Row(
                  children: const [
                    Icon(Icons.person_pin, color: DesignSystem.primary),
                    SizedBox(width: 8),
                    Text('Project Supervisor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: DesignSystem.primary)),
                  ],
                ),
                const SizedBox(height: DesignSystem.spaceSm),
                Padding(
                  padding: const EdgeInsets.only(left: 32.0),
                  child: Text(project.supervisorDisplayName, style: DesignSystem.bodyMd.copyWith(fontStyle: FontStyle.italic), softWrap: true),
                ),
                if (project.examinerDisplayName != null) ...[
                  const Divider(height: 24),
                  Row(
                    children: const [
                      Icon(Icons.rate_review, color: DesignSystem.primary),
                      SizedBox(width: 8),
                      Text('Examiner', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: DesignSystem.primary)),
                    ],
                  ),
                  const SizedBox(height: DesignSystem.spaceSm),
                  Padding(
                    padding: const EdgeInsets.only(left: 32.0),
                    child: Text(project.examinerDisplayName!, style: DesignSystem.bodyMd.copyWith(fontStyle: FontStyle.italic), softWrap: true),
                  ),
                ],
                if (project.matricId != null) ...[
                  const Divider(height: 24),
                  Row(
                    children: const [
                      Icon(Icons.badge, color: DesignSystem.primary),
                      SizedBox(width: 8),
                      Text('Matric ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: DesignSystem.primary)),
                    ],
                  ),
                  const SizedBox(height: DesignSystem.spaceSm),
                  Padding(
                    padding: const EdgeInsets.only(left: 32.0),
                    child: Text(project.matricId!, style: DesignSystem.bodyMd, softWrap: true),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: DesignSystem.spaceMd),

        // Booth locator card
        if (project.boothNumber != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(DesignSystem.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booth Location Details', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
                  const SizedBox(height: DesignSystem.spaceMd),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.room, color: DesignSystem.secondary, size: 28),
                    title: Text('Booth ${project.boothNumber}', style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text(project.boothZone ?? 'Zon A', style: DesignSystem.bodySm, softWrap: true),
                    trailing: OutlinedButton(
                      onPressed: () => context.go('/booths?search=${project.boothNumber}'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: DesignSystem.secondary,
                        side: const BorderSide(color: DesignSystem.secondary),
                        shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                      ),
                      child: const Text('Map'),
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: DesignSystem.spaceMd),

        // Action links card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(DesignSystem.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Links & Demos', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
                const SizedBox(height: DesignSystem.spaceMd),
                _buildActionLinkButton(Icons.launch, 'Live Demo / Slides', project.demoUrl ?? ''),
                const SizedBox(height: DesignSystem.spaceSm),
                _buildActionLinkButton(Icons.code, 'GitHub Repository', project.repositoryUrl ?? ''),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionLinkButton(IconData icon, String label, String url) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: url.isEmpty ? null : () {},
        icon: Icon(icon, size: 18),
        label: Text(label, softWrap: true),
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignSystem.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
        ),
      ),
    );
  }
}
