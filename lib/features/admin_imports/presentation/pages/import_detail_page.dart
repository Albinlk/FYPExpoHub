import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/schedule_item.dart';
import '../../../../core/domain/models/award.dart';
import '../../../../core/domain/models/import_models.dart';
import '../../../../core/state/state_providers.dart';

class ImportDetailPage extends ConsumerStatefulWidget {
  final String importId;

  const ImportDetailPage({super.key, required this.importId});

  @override
  ConsumerState<ImportDetailPage> createState() => _ImportDetailPageState();
}

class _ImportDetailPageState extends ConsumerState<ImportDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = [
    'Event Metadata',
    'Schedule (Tentative)',
    'Award Winners',
    'Privacy Skips',
    'Validation Warnings',
    'Change Comparison',
  ];

  // Selected item states for selective publishing
  final Set<String> _selectedScheduleIds = {};
  final Set<String> _selectedAwardIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    // Auto-select all candidates initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final schCandidates = ref.read(scheduleCandidatesProvider(widget.importId));
      final awCandidates = ref.read(awardCandidatesProvider(widget.importId));
      
      setState(() {
        _selectedScheduleIds.addAll(schCandidates.map((c) => c.id));
        _selectedAwardIds.addAll(awCandidates.map((c) => c.id));
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _publishSelective() {
    final schCandidates = ref.read(scheduleCandidatesProvider(widget.importId));
    final awCandidates = ref.read(awardCandidatesProvider(widget.importId));
    final imports = ref.read(importsProvider);

    final currentImport = imports.firstWhere((r) => r.id == widget.importId);

    // 1. Publish selected Schedule Items
    int schCount = 0;
    for (final cand in schCandidates) {
      if (_selectedScheduleIds.contains(cand.id)) {
        final newItem = ScheduleItem(
          id: 'sch-${DateTime.now().millisecondsSinceEpoch}-${schCount++}',
          eventId: 'fskm-fyp-2026',
          title: cand.title,
          date: cand.date,
          startAt: cand.startAt,
          endAt: cand.endAt,
          venue: cand.venue,
          audience: cand.audience,
          description: 'Imported from ${currentImport.sourceFileName}',
          visibility: cand.classification == 'internal' ? 'internal' : 'public',
          publicationStatus: 'published',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          publishedAt: DateTime.now(),
        );
        ref.read(scheduleProvider.notifier).addScheduleItem(newItem);
      }
    }

    // 2. Publish selected Award Winners
    int awCount = 0;
    for (final cand in awCandidates) {
      if (_selectedAwardIds.contains(cand.id)) {
        final newItem = PublishedAwardWinner(
          id: 'aw-${DateTime.now().millisecondsSinceEpoch}-${awCount++}',
          eventId: 'fskm-fyp-2026',
          awardCategoryId: 'cat-imported',
          projectId: 'none',
          projectTitle: cand.projectTitle,
          programmeCode: cand.programmeCode,
          teamDisplayName: cand.teamDisplayName,
          supervisorDisplayName: cand.supervisorDisplayName,
          publicationStatus: 'published',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          publishedAt: DateTime.now(),
        );
        ref.read(awardsProvider.notifier).addWinner(newItem);
      }
    }

    // 3. Mark Import Record as completed/published
    final updatedRecord = currentImport.copyWith(
      status: 'completed',
      publishedAt: DateTime.now(),
      summary: {
        'tentatif': _selectedScheduleIds.length,
        'pemenang': _selectedAwardIds.length,
      },
    );
    ref.read(importsProvider.notifier).updateImport(updatedRecord);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully published ${_selectedScheduleIds.length} schedules and ${_selectedAwardIds.length} award winners!'),
        backgroundColor: Colors.green.shade800,
      ),
    );

    context.go('/admin');
  }

  @override
  Widget build(BuildContext context) {
    final imports = ref.watch(importsProvider);
    final currentImport = imports.firstWhere(
      (r) => r.id == widget.importId,
      orElse: () => ImportRecord(
        id: widget.importId,
        eventId: 'fskm-fyp-2026',
        sourceFilePath: '',
        sourceFileName: 'File Not Found',
        sourceFileHash: '',
        uploadedBy: 'N/A',
        uploadedAt: DateTime.now(),
        parserVersion: 'v1.0.0',
        status: 'completed',
        summary: const {},
        warningCounts: const {},
      ),
    );

    final schCandidates = ref.watch(scheduleCandidatesProvider(widget.importId));
    final awCandidates = ref.watch(awardCandidatesProvider(widget.importId));
    final privacySkips = ref.watch(privacySkipsProvider(widget.importId));
    final validationIssues = ref.watch(validationIssuesProvider(widget.importId));

    final isReviewed = currentImport.status == 'completed';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
        title: Text('Data Matching Dashboard (${widget.importId})', style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          if (!isReviewed) ...[
            ElevatedButton.icon(
              onPressed: _publishSelective,
              icon: const Icon(Icons.publish),
              label: const Text('Publish Selective Items'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.secondaryContainer,
                foregroundColor: DesignSystem.onSecondaryContainer,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-header summary metadata
          Container(
            color: DesignSystem.primaryContainer,
            width: double.infinity,
            padding: const EdgeInsets.all(DesignSystem.spaceMd),
            child: Row(
              children: [
                const Icon(Icons.file_copy, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  'File: ${currentImport.sourceFileName} • Importer: ${currentImport.uploadedBy} • Status: ${currentImport.status == "completed" ? "Successfully Published" : "Pending Review"}',
                  style: DesignSystem.bodySm.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),

          // Tab controller bar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            labelStyle: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.bold),
            unselectedLabelColor: DesignSystem.onSurfaceVariant,
            labelColor: DesignSystem.primary,
            indicatorColor: DesignSystem.secondary,
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEventMetadataTab(),
                _buildScheduleTab(schCandidates, isReviewed),
                _buildAwardsTab(awCandidates, isReviewed),
                _buildPrivacySkipsTab(privacySkips),
                _buildValidationWarningsTab(validationIssues),
                _buildChangeComparisonTab(schCandidates, awCandidates),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. EVENT INFO TAB
  Widget _buildEventMetadataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignSystem.spaceLg),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Event Metadata Candidate vs Live', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
              const Divider(height: 32),
              _buildMetadataComparisonRow('Exhibition Title', 'Final Year Project Exhibition (FYP Expo) FSKM', 'FYP Exhibition FSKM v1'),
              _buildMetadataComparisonRow('Session / Semester', 'October 2026 - February 2027 Session', 'October 2026 - March 2027'),
              _buildMetadataComparisonRow('Primary Venue', 'Blok Kuliah, FSKM', 'Blok Kuliah, FSKM'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataComparisonRow(String fieldName, String candidateValue, String currentValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(fieldName, style: DesignSystem.labelCaps.copyWith(color: DesignSystem.primary)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.04), border: Border.all(color: Colors.green.withValues(alpha: 0.2)), borderRadius: DesignSystem.radiusLg),
                  child: Text('Candidate (New): $candidateValue', style: DesignSystem.bodySm),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: DesignSystem.surfaceContainer, borderRadius: DesignSystem.radiusLg),
                  child: Text('Live Value: $currentValue', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
                ),
              ),
              const SizedBox(width: 12),
              Checkbox(value: true, onChanged: null), // Visual indicator
            ],
          ),
        ],
      ),
    );
  }

  // 2. SCHEDULE TAB
  Widget _buildScheduleTab(List<ScheduleCandidate> candidates, bool isReviewed) {
    if (candidates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text('No schedule candidates found in this workbook.', style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(DesignSystem.spaceLg),
      itemCount: candidates.length,
      itemBuilder: (context, index) {
        final item = candidates[index];
        final isSelected = _selectedScheduleIds.contains(item.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: item.isOverlapping ? Colors.red.shade100 : DesignSystem.primaryContainer,
              child: Icon(
                item.isOverlapping ? Icons.warning : Icons.schedule,
                color: item.isOverlapping ? DesignSystem.error : DesignSystem.primary,
                size: 16,
              ),
            ),
            title: Text(item.title, style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text('Classification: ${item.classification} • Venue: ${item.venue} • Time: ${item.startAt} - ${item.endAt}', style: DesignSystem.bodySm),
            trailing: isReviewed
                ? const Icon(Icons.check_circle, color: Colors.green, size: 24)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: item.isOverlapping ? Colors.red.shade100 : Colors.green.shade100,
                          borderRadius: DesignSystem.radiusSm,
                        ),
                        child: Text(
                          item.isOverlapping ? 'OVERLAP' : 'READY',
                          style: TextStyle(
                            color: item.isOverlapping ? Colors.red.shade900 : Colors.green.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Checkbox(
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedScheduleIds.add(item.id);
                            } else {
                              _selectedScheduleIds.remove(item.id);
                            }
                          });
                        },
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  // 3. AWARDS TAB
  Widget _buildAwardsTab(List<AwardCandidate> candidates, bool isReviewed) {
    if (candidates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text('No award winner candidates found in this workbook.', style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(DesignSystem.spaceLg),
      itemCount: candidates.length,
      itemBuilder: (context, index) {
        final item = candidates[index];
        final isSelected = _selectedAwardIds.contains(item.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.emoji_events, color: DesignSystem.secondary, size: 28),
            title: Text(item.awardCategory, style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text('Project: ${item.projectTitle} • Students: ${item.teamDisplayName}', style: DesignSystem.bodySm),
            trailing: isReviewed
                ? const Icon(Icons.check_circle, color: Colors.green, size: 24)
                : Checkbox(
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedAwardIds.add(item.id);
                        } else {
                          _selectedAwardIds.remove(item.id);
                        }
                      });
                    },
                  ),
          ),
        );
      },
    );
  }

  // 4. PRIVACY SKIPS TAB
  Widget _buildPrivacySkipsTab(List<PrivacySkip> skips) {
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spaceLg),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.privacy_tip, color: Colors.orange, size: 28),
                  SizedBox(width: 8),
                  Text('Privacy Filter Summary (PDPA)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: DesignSystem.primary)),
                ],
              ),
              const Divider(height: 32),
              Text(
                'The system automatically filters and skips sensitive personal fields during workbook parsing to maintain high PDPA 2010 isolation standards.',
                style: DesignSystem.bodyMd,
              ),
              const SizedBox(height: 24),
              if (skips.isEmpty)
                Text('No personal data filters triggered in this workbook.', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant))
              else
                ...skips.map((skip) => _buildSkipRow(skip.skipType, '${skip.count} items filtered (${skip.reason})')).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipRow(String type, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '$type: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: desc),
                ],
              ),
              style: DesignSystem.bodySm,
            ),
          ),
        ],
      ),
    );
  }

  // 5. VALIDATION WARNINGS TAB
  Widget _buildValidationWarningsTab(List<ValidationIssue> issues) {
    if (issues.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No validation issues found. Excel data is fully verified!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(DesignSystem.spaceLg),
      itemCount: issues.length,
      itemBuilder: (context, index) {
        final issue = issues[index];
        final isWarning = issue.severity == 'warning';

        return Card(
          color: isWarning ? DesignSystem.errorContainer.withValues(alpha: 0.1) : DesignSystem.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(DesignSystem.spaceLg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(isWarning ? Icons.warning : Icons.info, color: isWarning ? DesignSystem.error : DesignSystem.primary, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Worksheet: ${issue.worksheetName} (Row ${issue.rowNumber})',
                        style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(issue.message, style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 6. CHANGE COMPARISON TAB
  Widget _buildChangeComparisonTab(List<ScheduleCandidate> sch, List<AwardCandidate> aw) {
    final int newItems = sch.where((c) => c.comparisonStatus == 'new').length + aw.length; // all awards are new
    final int updatedItems = sch.where((c) => c.comparisonStatus == 'updated').length;

    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spaceLg),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Change Comparison Summary Indicators', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildComparisonBadge('New Records', '$newItems records', Colors.green),
                  _buildComparisonBadge('Updated Records', '$updatedItems records', Colors.blue),
                  _buildComparisonBadge('No Changes', '0 records', Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonBadge(String label, String count, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(DesignSystem.spaceMd),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.06), border: Border.all(color: color.withValues(alpha: 0.2)), borderRadius: DesignSystem.radiusLg),
      child: Column(
        children: [
          Text(count, style: DesignSystem.h3.copyWith(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
        ],
      ),
    );
  }
}
