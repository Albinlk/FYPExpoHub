import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/firebase/firestore_service.dart';
import '../../../../core/state/state_providers.dart';

class AdminLecturersPage extends ConsumerWidget {
  const AdminLecturersPage({super.key});

  void _showAddLecturerDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    final passwordController = TextEditingController();
    var creating = false;

    showDialog(
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
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Temporary Password',
                        hintText: 'Minimum 6 characters',
                      ),
                      obscureText: true,
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
                          final email = emailController.text.trim();
                          final name = nameController.text.trim().toUpperCase();
                          final password = passwordController.text;

                          if (email.isEmpty || name.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill in all fields.')),
                            );
                            return;
                          }

                          setState(() => creating = true);

                          try {
                            final uid = const Uuid().v4();
                            await FirestoreService.instance.setLecturer(uid, {
                              'uid': uid,
                              'email': email,
                              'displayName': name,
                              'createdAt': FieldValue.serverTimestamp(),
                            });

                            if (dialogContext.mounted) Navigator.of(dialogContext).pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lecturer $name added successfully!')),
                            );
                          } catch (e) {
                            setState(() => creating = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
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
    final name = lecturer['displayName'] as String? ?? '';
    final uid = lecturer['uid'] as String? ?? '';

    showDialog(
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
                try {
                  await FirestoreService.instance.deleteLecturer(uid);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$name deleted successfully.')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
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

  Future<void> _backfillLecturerIds(BuildContext context) async {
    final db = FirebaseFirestore.instance;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Updating lecturer IDs in assignments...')),
    );
    try {
      final lecturersSnap = await db.collection('lecturers').get();
      final lecturers = <String, String>{};
      for (final doc in lecturersSnap.docs) {
        final data = doc.data();
        final name = (data['displayName'] as String? ?? '').trim().toUpperCase();
        final uid = data['uid'] as String? ?? '';
        if (name.isNotEmpty && uid.isNotEmpty) {
          lecturers[name] = uid;
        }
      }

      final assignmentsSnap = await db.collection('projectLecturerAssignments').get();
      int patched = 0;
      int skipped = 0;

      for (final doc in assignmentsSnap.docs) {
        final data = doc.data();
        final lecturerId = data['lecturerId'] as String? ?? '';
        final lecturerName = (data['lecturerDisplayName'] as String? ?? '').trim().toUpperCase();

        if (lecturerName.isEmpty) {
          skipped++;
          continue;
        }

        if (lecturerId.isNotEmpty) {
          skipped++;
          continue;
        }

        final matchedUid = lecturers[lecturerName];
        if (matchedUid != null) {
          await doc.reference.update({'lecturerId': matchedUid});
          patched++;
        } else {
          skipped++;
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Done! $patched assignments updated, $skipped skipped.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
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
    final hardcodedEntries = hardcodedLecturerConfig.entries.toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignSystem.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isDesktop
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPageTitle('Lecturer Management', 'Register lecturers for My Visits mode access.'),
                      Row(
                        mainAxisSize: MainAxisSize.min,
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
                          const SizedBox(width: DesignSystem.spaceMd),
                          OutlinedButton.icon(
                            onPressed: () => _backfillLecturerIds(context),
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
                          onPressed: () => _backfillLecturerIds(context),
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

            // Firestore lecturers section
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
                        if (lecturers.isEmpty && hardcodedEntries.isEmpty) {
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
                              final email = doc['email'] as String? ?? '';
                              final name = doc['displayName'] as String? ?? '';
                              final uid = doc['uid'] as String? ?? '';
                              return _buildLecturerRow(context, ref, email, name, uid, false);
                            }),
                            if (hardcodedEntries.isNotEmpty && lecturers.isNotEmpty)
                              const Divider(height: 24),
                            ...hardcodedEntries.map((entry) {
                              return _buildLecturerRow(
                                context, ref, entry.key, entry.value, '', true,
                              );
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
                      error: (err, _) {
                        return Column(
                          children: [
                            ...hardcodedEntries.map((entry) {
                              return _buildLecturerRow(
                                context, ref, entry.key, entry.value, '', true,
                              );
                            }),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                 'Firestore unavailable. Only default lecturers shown.',
                                style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: DesignSystem.spaceLg),

            // Info card
            Card(
              color: DesignSystem.tertiaryContainer.withValues(alpha: 0.2),
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceMd),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: DesignSystem.tertiary),
                    const SizedBox(width: DesignSystem.spaceSm),
                    Expanded(
                      child:                       Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Lecturers can sign in using their UiTM email and the password set. '
                                  'Ensure lecturers have projects assigned (SV/EX) to use the My Visits mode.\n\n',
                            ),
                            TextSpan(
                              text: 'Backfill Lecturer IDs: ',
                              style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                              text: 'Use this button after adding new lecturers to link lecturer IDs to existing project assignments '
                                  '(ensuring lecturers only see their own projects).',
                            ),
                          ],
                        ),
                        style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
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
    bool isHardcoded,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHardcoded
                  ? DesignSystem.surfaceContainer
                  : DesignSystem.secondaryContainer,
              borderRadius: DesignSystem.radiusLg,
            ),
            child: Icon(
              Icons.person,
              color: isHardcoded
                  ? DesignSystem.onSurfaceVariant
                  : DesignSystem.onSecondaryContainer,
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
          if (isHardcoded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: DesignSystem.surfaceContainer,
                borderRadius: DesignSystem.radiusSm,
              ),
              child: Text(
                 'DEFAULT',
                style: DesignSystem.labelCaps.copyWith(
                  color: DesignSystem.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ),
          if (!isHardcoded) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete, size: 18, color: DesignSystem.error),
              tooltip: 'Delete lecturer',
              onPressed: () {
                _confirmDeleteLecturer(context, ref, {
                  'displayName': name,
                  'uid': uid,
                });
              },
            ),
          ],
        ],
      ),
    );
  }
}
