import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/admin_actions.dart';
import '../../../../core/supabase/supabase_client_provider.dart';
import '../../../../core/domain/models/import_models.dart';
import '../../../../core/state/state_providers.dart';
import '../../domain/import_checks.dart';

class ImportDetailPage extends ConsumerStatefulWidget {
  final String importId;

  const ImportDetailPage({super.key, required this.importId});

  @override
  ConsumerState<ImportDetailPage> createState() => _ImportDetailPageState();
}

class _ImportDetailPageState extends ConsumerState<ImportDetailPage> {
  final Map<String, String> _decisions = {};
  bool _isPublishing = false;

  void _setDecision(String candidateId, String action) {
    setState(() {
      _decisions[candidateId] = action;
    });
  }

  Future<void> _publish() async {
    final user = ref.read(currentAuthUserProvider);
    if (user == null) return;

    final ok = await confirmAction(
      context,
      title: 'Publish this import?',
      message: 'Rows marked Publish are added to the public schedule and awards. '
          'Rows marked Replace existing first remove the live item they match '
          '(same day and title, or the same venue at an overlapping time; for awards, '
          'the same award and team). An import can only be published once.',
      confirmLabel: 'Publish',
    );
    if (!ok || !mounted) return;

    setState(() => _isPublishing = true);

    try {
      final db = ref.read(supabaseDbServiceProvider);
      // Keys are 'sch_<uuid>' / 'aw_<uuid>' (see the two list builders);
      // the prefix carries the candidate type, the rest is the row id.
      final decisionList = _decisions.entries.map((e) {
        final isSchedule = e.key.startsWith('sch_');
        return {
          'id': const Uuid().v4(),
          'import_id': widget.importId,
          'candidate_id': e.key.substring(isSchedule ? 4 : 3),
          'candidate_type': isSchedule ? 'schedule' : 'award',
          'action': e.value,
          'reviewed_by': user.id,
        };
      }).toList();

      if (decisionList.isNotEmpty) {
        await db.insertReviewDecisions(decisionList);
      }

      final rpc = ref.read(supabaseRpcServiceProvider);
      final res = await rpc.publishApprovedImportChanges(importId: widget.importId);

      // Refresh schedule, awards, and imports providers
      ref.invalidate(scheduleProvider);
      ref.invalidate(publicScheduleProvider);
      ref.invalidate(awardsProvider);
      ref.invalidate(publicAwardsProvider);
      ref.invalidate(importsProvider);

      final replaced = ((res['replaced_schedules'] as num?) ?? 0) + ((res['replaced_awards'] as num?) ?? 0);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Import published! ${res["published_schedules"] ?? 0} schedule items & '
              '${res["published_awards"] ?? 0} awards added'
              '${replaced > 0 ? ', $replaced old items replaced' : ''}.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/admin/imports');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Publish error: $e'), backgroundColor: DesignSystem.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(scheduleCandidatesProvider(widget.importId));
    final awardsAsync = ref.watch(awardCandidatesProvider(widget.importId));
    final skipsAsync = ref.watch(privacySkipsProvider(widget.importId));
    final issuesAsync = ref.watch(validationIssuesProvider(widget.importId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Master File Import'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to imports',
          onPressed: () => context.go('/admin/imports'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignSystem.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Staged Import Candidates', style: DesignSystem.h2Mobile.copyWith(color: DesignSystem.primary)),
                ElevatedButton.icon(
                  onPressed: _isPublishing ? null : _publish,
                  icon: _isPublishing
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_circle),
                  label: const Text('Approve & Publish Selected'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignSystem.spaceLg),

            // G-06: what the checks found, before anything is published.
            issuesAsync.when(
              data: (issues) => issues.isEmpty ? const SizedBox.shrink() : _IssuesCard(issues: issues),
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Text('Error loading validation issues: $e'),
            ),

            // Schedule Candidates
            Card(
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Schedule Candidates (TENTATIF)', style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary)),
                    const Divider(height: 24),
                    scheduleAsync.when(
                      data: (list) {
                        if (list.isEmpty) return const Text('No schedule candidates found.');
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: list.length,
                          separatorBuilder: (_, _) => const Divider(),
                          itemBuilder: (context, i) {
                            final c = list[i];
                            final idKey = 'sch_${c.id}';
                            final currentDecision = _decisions.putIfAbsent(
                              idKey,
                              () => defaultImportAction(comparisonStatus: c.comparisonStatus, isDuplicate: c.isDuplicate),
                            );
                            return ListTile(
                              title: Text('${c.startAt} - ${c.endAt} — ${c.title}', style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Venue: ${c.venue} • Audience: ${c.audience}', style: DesignSystem.bodySm),
                                  _Badges(
                                    comparisonStatus: c.comparisonStatus,
                                    isDuplicate: c.isDuplicate,
                                    isOverlapping: c.isOverlapping,
                                  ),
                                ],
                              ),
                              trailing: DropdownButton<String>(
                                value: currentDecision,
                                items: const [
                                  DropdownMenuItem(value: 'publish', child: Text('Publish')),
                                  DropdownMenuItem(value: 'replace_existing', child: Text('Replace Existing')),
                                  DropdownMenuItem(value: 'skip', child: Text('Skip')),
                                ],
                                onChanged: (val) {
                                  if (val != null) _setDecision(idKey, val);
                                },
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error loading schedule candidates: $e'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DesignSystem.spaceLg),

            // Award Candidates
            Card(
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Award Candidates (PEMENANG ANUGERAH)', style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary)),
                    const Divider(height: 24),
                    awardsAsync.when(
                      data: (list) {
                        if (list.isEmpty) return const Text('No award candidates found.');
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: list.length,
                          separatorBuilder: (_, _) => const Divider(),
                          itemBuilder: (context, i) {
                            final c = list[i];
                            final idKey = 'aw_${c.id}';
                            final currentDecision = _decisions.putIfAbsent(
                              idKey,
                              () => c.isSkip ? 'skip' : 'publish',
                            );
                            return ListTile(
                              title: Text('${c.awardCategory}: ${c.teamDisplayName}', style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Supervisor: ${c.supervisorDisplayName} • Programme: ${c.programmeCode}', style: DesignSystem.bodySm),
                                  if (c.isSkip) const _Badges(comparisonStatus: 'new', isDuplicate: true, isOverlapping: false),
                                ],
                              ),
                              trailing: DropdownButton<String>(
                                value: currentDecision,
                                items: const [
                                  DropdownMenuItem(value: 'publish', child: Text('Publish')),
                                  DropdownMenuItem(value: 'replace_existing', child: Text('Replace Existing')),
                                  DropdownMenuItem(value: 'skip', child: Text('Skip')),
                                ],
                                onChanged: (val) {
                                  if (val != null) _setDecision(idKey, val);
                                },
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error loading award candidates: $e'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DesignSystem.spaceLg),

            // Privacy Skips & Issues
            Card(
              color: DesignSystem.surfaceContainer,
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Audit & Privacy Protection Skips', style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary)),
                    const Divider(height: 24),
                    skipsAsync.when(
                      data: (list) {
                        if (list.isEmpty) return const Text('No confidential columns or sheets were detected/skipped.');
                        return Column(
                          children: list.map((s) {
                            return ListTile(
                              leading: const Icon(Icons.shield, color: DesignSystem.tertiary),
                              title: Text('${s.worksheetName} — ${s.skipType}', style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.bold)),
                              subtitle: Text(s.reason, style: DesignSystem.bodySm),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error loading skips: $e'),
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

/// The staged validation issues, errors and warnings first.
class _IssuesCard extends StatelessWidget {
  const _IssuesCard({required this.issues});

  final List<ValidationIssue> issues;

  static const _rank = {'error': 0, 'warning': 1, 'info': 2};

  @override
  Widget build(BuildContext context) {
    final sorted = [...issues]..sort((a, b) {
        final r = (_rank[a.severity] ?? 3).compareTo(_rank[b.severity] ?? 3);
        return r != 0 ? r : (a.rowNumber ?? 0).compareTo(b.rowNumber ?? 0);
      });
    final warnings = issues.where((i) => i.severity != 'info').length;
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignSystem.spaceLg),
      child: Card(
        key: const Key('import-issues'),
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Checks: $warnings to review, ${issues.length - warnings} notes',
                style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary),
              ),
              const Divider(height: 24),
              for (final i in sorted)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    switch (i.severity) {
                      'error' => Icons.error_outline,
                      'warning' => Icons.warning_amber,
                      _ => Icons.info_outline,
                    },
                    color: i.severity == 'info' ? DesignSystem.onSurfaceVariant : DesignSystem.error,
                  ),
                  title: Text(i.message, style: DesignSystem.bodySm),
                  subtitle: Text(
                    '${i.worksheetName}${(i.rowNumber ?? 0) > 0 ? ' · row ${i.rowNumber}' : ''}',
                    style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small flags on a staged row: already live, changes a live item,
/// duplicate in the file, overlaps another item.
class _Badges extends StatelessWidget {
  const _Badges({required this.comparisonStatus, required this.isDuplicate, required this.isOverlapping});

  final String comparisonStatus;
  final bool isDuplicate;
  final bool isOverlapping;

  @override
  Widget build(BuildContext context) {
    final labels = [
      if (comparisonStatus == 'unchanged') 'Already live',
      if (comparisonStatus == 'updated') 'Changes a live item',
      if (isDuplicate && comparisonStatus != 'unchanged') 'Duplicate in file',
      if (isOverlapping) 'Overlaps another item',
    ];
    if (labels.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          for (final l in labels)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: DesignSystem.secondaryContainer,
                borderRadius: DesignSystem.radiusSm,
              ),
              child: Text(l, style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSecondaryContainer)),
            ),
        ],
      ),
    );
  }
}
