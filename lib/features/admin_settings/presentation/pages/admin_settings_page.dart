import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/firebase/firebase_providers.dart';
import '../../../../core/firebase/firestore_service.dart';

class AdminSettingsPage extends ConsumerStatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  ConsumerState<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends ConsumerState<AdminSettingsPage> {
  final _maxSizeController = TextEditingController();
  final _worksheetsController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _maxSizeController.dispose();
    _worksheetsController.dispose();
    super.dispose();
  }

  void _loadSettings() async {
    final data = await FirestoreService.instance.getSetting('excel_import');
    if (mounted) {
      setState(() {
        _maxSizeController.text = data?['maxFileSize'] as String? ?? '10 MB';
        _worksheetsController.text = data?['mandatoryWorksheets'] as String? ?? 'SCHEDULE, AWARD WINNERS, COMMITTEE';
        _isLoading = false;
      });
    }
  }

  void _save() async {
    await FirestoreService.instance.setSetting('excel_import', {
      'maxFileSize': _maxSizeController.text,
      'mandatoryWorksheets': _worksheetsController.text,
      'updatedAt': DateTime.now(),
      'updatedBy': ref.read(firebaseAuthProvider).currentUser?.email ?? 'unknown',
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved to Firestore!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignSystem.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Portal Settings', style: DesignSystem.h2.copyWith(color: DesignSystem.primary)),
            const SizedBox(height: 4),
            Text('Configure system preferences, upload limits, and environment variables.', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
            const SizedBox(height: DesignSystem.spaceXl),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceLg),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Excel File Parsing Settings', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
                          const Divider(height: 32),

                          Text('Maximum File Size Limit', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.primary)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _maxSizeController,
                            decoration: const InputDecoration(prefixIcon: Icon(Icons.line_weight)),
                          ),
                          const SizedBox(height: 16),

                          Text('Mandatory Worksheet Names', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.primary)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _worksheetsController,
                            decoration: const InputDecoration(prefixIcon: Icon(Icons.table_chart)),
                          ),
                          const SizedBox(height: 24),

                          ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignSystem.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                            ),
                            child: const Text('Save Configuration'),
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
