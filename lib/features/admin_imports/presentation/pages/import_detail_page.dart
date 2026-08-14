import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/supabase/supabase_client_provider.dart';
import '../../../../core/state/state_providers.dart';

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

    setState(() => _isPublishing = true);

    try {
      final db = ref.read(supabaseDbServiceProvider);
      final decisionList = _decisions.entries.map((e) {
        return {
          'id': const Uuid().v4(),
          'import_id': widget.importId,
          'candidate_id': e.key,
          'candidate_type': e.key.startsWith('sch_') ? 'schedule' : 'award',
          'action': e.value,
          'decided_by': user.id,
          'created_at': DateTime.now().toIso8601String(),
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import published! ${res["published_schedules"] ?? 0} schedule items & ${res["published_awards"] ?? 0} awards added.'),
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
    // ignore: unused_local_variable
    final issuesAsync = ref.watch(validationIssuesProvider(widget.importId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Master File Import'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, i) {
                            final c = list[i];
                            final idKey = c.id;
                            final currentDecision = _decisions[idKey] ?? 'publish';
                            if (!_decisions.containsKey(idKey)) {
                              _decisions[idKey] = 'publish';
                            }
                            return ListTile(
                              title: Text('${c.startAt} - ${c.endAt} — ${c.title}', style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                              subtitle: Text('Venue: ${c.venue} • Audience: ${c.audience}', style: DesignSystem.bodySm),
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
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, i) {
                            final c = list[i];
                            final idKey = c.id;
                            final currentDecision = _decisions[idKey] ?? 'publish';
                            if (!_decisions.containsKey(idKey)) {
                              _decisions[idKey] = 'publish';
                            }
                            return ListTile(
                              title: Text('${c.awardCategory}: ${c.teamDisplayName}', style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                              subtitle: Text('Supervisor: ${c.supervisorDisplayName} • Programme: ${c.programmeCode}', style: DesignSystem.bodySm),
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
