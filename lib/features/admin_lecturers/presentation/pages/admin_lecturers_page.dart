import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/widgets/admin_actions.dart';

class AdminLecturersPage extends ConsumerWidget {
  const AdminLecturersPage({super.key});

  void _showAddLecturerDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    var creating = false;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDesktop = MediaQuery.of(context).size.width >= 768;
            return AlertDialog(
              title: Text('Add Lecturer', style: (isDesktop ? DesignSystem.h3 : DesignSystem.bodyLg)),
              content: SizedBox(
                width: isDesktop ? 400 : MediaQuery.of(context).size.width * 0.85,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'UiTM Email',
                        hintText: 'example@uitm.edu.my',
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'NAME AS IN PROJECT',
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    Container(
                      padding: const EdgeInsets.all(DesignSystem.spaceSm),
                      decoration: BoxDecoration(
                        color: DesignSystem.tertiaryContainer.withValues(alpha: 0.2),
                        borderRadius: DesignSystem.radiusLg,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, size: 18, color: DesignSystem.tertiary),
                          const SizedBox(width: DesignSystem.spaceXs),
                          Expanded(
                            child: Text(
                              'The lecturer must already have a sign-in account with this email (Supabase → Authentication → Users). Adding them here gives that account lecturer access.',
                              style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (creating) ...[
                      const SizedBox(height: DesignSystem.spaceMd),
                      const CircularProgressIndicator(),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: creating ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: creating
                      ? null
                      : () async {
                          final email = emailController.text.trim().toLowerCase();
                          final name = nameController.text.trim().toUpperCase();

                          if (email.isEmpty || name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill in all fields.')),
                            );
                            return;
                          }

                          setState(() => creating = true);
                          final db = ref.read(supabaseDbServiceProvider);
                          final rpc = ref.read(supabaseRpcServiceProvider);
                          final ok = await runAdminWrite(
                            context,
                            () async {
                              // profiles.id must be the lecturer's real auth
                              // user id; a made-up id fails the FK.
                              final userId = await db.findProfileIdByEmail(email);
                              if (userId == null) {
                                throw Exception(
                                  'No account found for $email. Create the user in Supabase Authentication first, then add them here.',
                                );
                              }
                              await rpc.createLecturerAccountProfile(
                                userId: userId,
                                email: email,
                                displayName: name,
                              );
                            },
                            success: 'Lecturer $name added.',
                          );
                          if (ok) {
                            ref.invalidate(allLecturersProvider);
                            if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                          } else if (context.mounted) {
                            setState(() => creating = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.secondary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteLecturer(BuildContext context, WidgetRef ref, Map<String, dynamic> lecturer) {
    final name = (lecturer['displayName'] ?? lecturer['display_name']) as String? ?? '';
    final uid = (lecturer['id'] ?? lecturer['uid']) as String? ?? '';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Lecturer', style: DesignSystem.h3),
          content: Text('Are you sure you want to delete $name? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final db = ref.read(supabaseDbServiceProvider);
                final ok = await runAdminWrite(
                  context,
                  () => db.deleteLecturer(uid),
                  success: '$name deleted.',
                );
                if (ok) ref.invalidate(allLecturersProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _backfillLecturerIds(BuildContext context, WidgetRef ref) async {
    final ok = await confirmAction(
      context,
      title: 'Backfill lecturer IDs?',
      message: 'Assignments without a lecturer account are linked to the lecturer whose name matches exactly. '
          'This updates every matching assignment at once.',
      confirmLabel: 'Backfill',
    );
    if (!ok || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Updating lecturer IDs in assignments...')),
    );
    try {
      final db = ref.read(supabaseDbServiceProvider);
      final lecturersList = await db.getLecturersOnce();
      final lecturersMap = <String, String>{};
      for (final doc in lecturersList) {
        final name = (doc['display_name'] as String? ?? '').trim().toUpperCase();
        final uid = (doc['id'] as String? ?? '');
        if (name.isNotEmpty && uid.isNotEmpty) {
          lecturersMap[name] = uid;
        }
      }

      final assignmentsList = await db.getAssignmentsOnce();
      int skipped = 0;
      final updates = <Map<String, dynamic>>[];

      for (final doc in assignmentsList) {
        final id = doc['id'] as String;
        final lecturerId = doc['lecturer_id'] as String? ?? '';
        final lecturerName = (doc['lecturer_display_name'] as String? ?? '').trim().toUpperCase();

        if (lecturerName.isEmpty) {
          skipped++;
          continue;
        }

        if (lecturerId.isNotEmpty) {
          skipped++;
          continue;
        }

        final matchedUid = lecturersMap[lecturerName];
        if (matchedUid != null) {
          updates.add({
            ...doc,
            'id': id,
            'lecturer_id': matchedUid,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          });
        } else {
          skipped++;
        }
      }

      // One bulk upsert instead of a network round trip per assignment.
      await db.setAssignments(updates);
      ref.invalidate(allAssignmentsProvider);

      messenger.showSnackBar(
        SnackBar(content: Text('Done! ${updates.length} assignments updated, $skipped skipped.')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Not saved: ${friendlyError(e)}')),
      );
    }
  }

  Widget _buildPageTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: DesignSystem.h2Mobile.copyWith(color: DesignSystem.primary)),
        const SizedBox(height: 4),
        Text(subtitle, style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final lecturersAsync = ref.watch(allLecturersProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignSystem.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isDesktop
                ? Wrap(
                    spacing: DesignSystem.spaceLg,
                    runSpacing: DesignSystem.spaceMd,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _buildPageTitle('Lecturer Management', 'Register lecturers for My Visits mode access.'),
                      Wrap(
                        spacing: DesignSystem.spaceMd,
                        runSpacing: DesignSystem.spaceMd,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _showAddLecturerDialog(context, ref),
                            icon: const Icon(Icons.person_add),
                            label: const Text('Add Lecturer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignSystem.secondary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _backfillLecturerIds(context, ref),
                            icon: const Icon(Icons.sync),
                            label: const Text('Backfill Lecturer IDs'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: DesignSystem.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPageTitle('Lecturer Management', 'Register lecturers for My Visits mode access.'),
                      const SizedBox(height: DesignSystem.spaceMd),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddLecturerDialog(context, ref),
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add Lecturer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignSystem.secondary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _backfillLecturerIds(context, ref),
                          icon: const Icon(Icons.sync),
                          label: const Text('Backfill Lecturer IDs'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: DesignSystem.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: DesignSystem.spaceXl),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Registered Lecturers', style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary)),
                    const Divider(height: 32),

                    lecturersAsync.when(
                      data: (lecturers) {
                        if (lecturers.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text('No registered lecturers.', style: DesignSystem.bodyMd),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            ...lecturers.map((doc) {
                              final email = (doc['email'] as String?) ?? '';
                              final name = (doc['display_name'] as String?) ?? '';
                              final uid = (doc['id'] as String?) ?? '';
                              return _buildLecturerRow(context, ref, email, name, uid);
                            }),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (err, _) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'Couldn\'t load lecturers: ${friendlyError(err)}',
                            style: DesignSystem.bodyMd.copyWith(color: DesignSystem.error),
                          ),
                        ),
                      ),
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

  Widget _buildLecturerRow(
    BuildContext context,
    WidgetRef ref,
    String email,
    String name,
    String uid,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DesignSystem.secondaryContainer,
              borderRadius: DesignSystem.radiusLg,
            ),
            child: Icon(
              Icons.person,
              color: DesignSystem.onSecondaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: DesignSystem.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: DesignSystem.bodyMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: DesignSystem.primary,
                  ),
                ),
                Text(
                  email,
                  style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete, size: 18, color: DesignSystem.error),
              tooltip: 'Delete lecturer',
              onPressed: () {
                _confirmDeleteLecturer(context, ref, {
                  'displayName': name,
                  'id': uid,
                });
              },
            ),
        ],
      ),
    );
  }
}
