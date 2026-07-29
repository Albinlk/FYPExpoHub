import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
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
              title: Text('Tambah Pensyarah', style: (isDesktop ? DesignSystem.h3 : DesignSystem.bodyLg)),
              content: SizedBox(
                width: isDesktop ? 400 : MediaQuery.of(context).size.width * 0.85,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Emel UiTM',
                        hintText: 'contoh@uitm.edu.my',
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Penuh',
                        hintText: 'NAMA SEPERTI DALAM PROJEK',
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Kata Laluan Sementara',
                        hintText: 'Minimum 6 aksara',
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
                  child: const Text('Batal'),
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
                              const SnackBar(content: Text('Sila isi semua ruangan.')),
                            );
                            return;
                          }

                          setState(() => creating = true);

                          try {
                            final functions = FirebaseFunctions.instance;
                            final result = await functions.httpsCallable('createLecturerAccount').call({
                              'email': email,
                              'displayName': name,
                              'password': password,
                            });

                            if (dialogContext.mounted) Navigator.of(dialogContext).pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Pensyarah ${result.data['displayName']} berjaya ditambah!')),
                            );
                          } on FirebaseFunctionsException catch (e) {
                            setState(() => creating = false);
                            final msg = e.code == 'already-exists'
                                ? 'Emel ini sudah wujud dalam sistem.'
                                : e.message ?? 'Ralat tidak dijangka.';
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                          } catch (e) {
                            setState(() => creating = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ralat: Gagal menyambung ke pelayan.')),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.secondary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Tambah'),
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
          title: const Text('Padam Pensyarah', style: DesignSystem.h3),
          content: Text('Adakah anda pasti mahu memadam $name? Tindakan ini tidak boleh dibatalkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  final functions = FirebaseFunctions.instance;
                  await functions.httpsCallable('deleteLecturerAccount').call({
                    'lecturerUid': uid,
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$name berjaya dipadam.')),
                    );
                  }
                } on FirebaseFunctionsException catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.message ?? 'Ralat memadam pensyarah.')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ralat: Gagal menyambung ke pelayan.')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Padam'),
            ),
          ],
        );
      },
    );
  }

  void _backfillLecturerIds(BuildContext context) async {
    final functions = FirebaseFunctions.instance;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mengemas kini ID pensyarah dalam tugasan...')),
    );
    try {
      final result = await functions.httpsCallable('backfillLecturerIds').call();
      final data = result.data as Map<String, dynamic>;
      final patched = data['patched'] ?? 0;
      final skipped = data['skipped'] ?? 0;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selesai! $patched tugasan dikemas kini, $skipped dilangkau.')),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Ralat semasa backfill.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ralat: Gagal menyambung ke pelayan.')),
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
                      _buildPageTitle('Pengurusan Pensyarah', 'Daftar pensyarah untuk akses mod Lawatan Saya.'),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _showAddLecturerDialog(context, ref),
                            icon: const Icon(Icons.person_add),
                            label: const Text('Tambah Pensyarah'),
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
                      _buildPageTitle('Pengurusan Pensyarah', 'Daftar pensyarah untuk akses mod Lawatan Saya.'),
                      const SizedBox(height: DesignSystem.spaceMd),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddLecturerDialog(context, ref),
                          icon: const Icon(Icons.person_add),
                          label: const Text('Tambah Pensyarah'),
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
                    Text('Pensyarah Berdaftar', style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary)),
                    const Divider(height: 32),

                    lecturersAsync.when(
                      data: (lecturers) {
                        if (lecturers.isEmpty && hardcodedEntries.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text('Tiada pensyarah berdaftar.', style: DesignSystem.bodyMd),
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
                                'Firestore tidak tersedia. Hanya pensyarah lalai dipaparkan.',
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
                              text: 'Pensyarah boleh log masuk menggunakan emel UiTM dan kata laluan yang telah ditetapkan. '
                                  'Pastikan pensyarah mempunyai projek yang ditugaskan (SV/EX) untuk menggunakan mod Lawatan Saya.\n\n',
                            ),
                            TextSpan(
                              text: 'Backfill Lecturer IDs: ',
                              style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                              text: 'Gunakan butang ini selepas menambah pensyarah baharu untuk '
                                  'memautkan ID pensyarah ke tugasan projek sedia ada (bagi memastikan '
                                  'pensyarah hanya melihat projek mereka sendiri).',
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
                'LALAI',
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
              tooltip: 'Padam pensyarah',
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
