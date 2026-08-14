import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/state_providers.dart';

class AdminSettingsPage extends ConsumerStatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  ConsumerState<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends ConsumerState<AdminSettingsPage> {
  final _maxSizeController = TextEditingController();
  final _worksheetsController = TextEditingController();
  final _undoWindowController = TextEditingController(text: '30');
  bool _visitsEnabled = true;
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
    _undoWindowController.dispose();
    super.dispose();
  }

  void _loadSettings() async {
    final db = ref.read(supabaseDbServiceProvider);
    final excelData = await db.getSetting('excel_import');
    final visitData = await db.getSetting('visit_tracker');
    if (mounted) {
      setState(() {
        _maxSizeController.text = excelData?['maxFileSize'] as String? ?? '10 MB';
        _worksheetsController.text = excelData?['mandatoryWorksheets'] as String? ?? 'TENTATIF, PEMENANG ANUGERAH';
        _visitsEnabled = (visitData?['visitsEnabled'] as bool?) ?? true;
        _undoWindowController.text = (visitData?['lecturerUndoWindowMinutes']?.toString()) ?? '30';
        _isLoading = false;
      });
    }
  }

  void _save() async {
    final db = ref.read(supabaseDbServiceProvider);
    try {
      await db.setSetting('excel_import', {
        'maxFileSize': _maxSizeController.text,
        'mandatoryWorksheets': _worksheetsController.text,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await db.setSetting('visit_tracker', {
        'visitsEnabled': _visitsEnabled,
        'allowVisitsBeforeEvent': false,
        'allowVisitsAfterEvent': false,
        'visitOpenAt': null,
        'visitCloseAt': null,
        'lecturerUndoWindowMinutes': int.tryParse(_undoWindowController.text) ?? 30,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings: $e'), backgroundColor: DesignSystem.error),
        );
      }
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
            Text('Portal Settings', style: DesignSystem.h2Mobile.copyWith(color: DesignSystem.primary)),
            const SizedBox(height: 4),
            Text('Configure system preferences, upload limits, and visit tracker configuration.', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
            const SizedBox(height: DesignSystem.spaceXl),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceLg),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Excel Master File Parsing', style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary)),
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

                          Text('Visit Tracker Settings', style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary)),
                          const Divider(height: 32),

                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('Enable Student Project Visits', style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                            subtitle: Text('Allow lecturers to record student visits in real time', style: DesignSystem.bodySm),
                            value: _visitsEnabled,
                            onChanged: (val) => setState(() => _visitsEnabled = val),
                            activeColor: DesignSystem.secondary,
                          ),
                          const SizedBox(height: 12),

                          Text('Lecturer Undo Window (Minutes)', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.primary)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _undoWindowController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(prefixIcon: Icon(Icons.timer_outlined)),
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
