import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/widgets/admin_actions.dart';
import '../../../../core/widgets/async_state.dart';

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
  // Enforced by mark_student_project_visited: by default lecturers can only
  // mark visits on the exhibition days.
  bool _allowBefore = false;
  bool _allowAfter = false;
  // Kept as loaded (no editor yet) so saving doesn't wipe them.
  Object? _visitOpenAt;
  Object? _visitCloseAt;
  bool _isLoading = true;
  Object? _loadError;

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

  Future<void> _loadSettings() async {
    final db = ref.read(supabaseDbServiceProvider);
    final Map<String, dynamic>? excelData;
    final Map<String, dynamic>? visitData;
    try {
      excelData = await db.getSettingStrict('excel_import');
      visitData = await db.getSettingStrict('visit_tracker');
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e;
          _isLoading = false;
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _maxSizeController.text = excelData?['maxFileSize'] as String? ?? '10 MB';
        _worksheetsController.text = excelData?['mandatoryWorksheets'] as String? ?? 'TENTATIF, PEMENANG ANUGERAH';
        _visitsEnabled = (visitData?['visitsEnabled'] as bool?) ?? true;
        _allowBefore = (visitData?['allowVisitsBeforeEvent'] as bool?) ?? false;
        _allowAfter = (visitData?['allowVisitsAfterEvent'] as bool?) ?? false;
        _visitOpenAt = visitData?['visitOpenAt'];
        _visitCloseAt = visitData?['visitCloseAt'];
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
        'allowVisitsBeforeEvent': _allowBefore,
        'allowVisitsAfterEvent': _allowAfter,
        'visitOpenAt': _visitOpenAt,
        'visitCloseAt': _visitCloseAt,
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
          SnackBar(content: Text('Error saving settings: ${friendlyError(e)}'), backgroundColor: DesignSystem.error),
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
                    ? const AsyncLoadingView(what: 'settings')
                    : _loadError != null
                    ? AsyncErrorView(
                        error: _loadError!,
                        what: 'settings',
                        onRetry: () {
                          setState(() {
                            _loadError = null;
                            _isLoading = true;
                          });
                          _loadSettings();
                        },
                      )
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
                            activeThumbColor: DesignSystem.secondary,
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('Allow visits before the exhibition', style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                            subtitle: Text('Off: lecturers can mark visits from the first exhibition day', style: DesignSystem.bodySm),
                            value: _allowBefore,
                            onChanged: (val) => setState(() => _allowBefore = val),
                            activeThumbColor: DesignSystem.secondary,
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('Allow visits after the exhibition', style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                            subtitle: Text('Off: marking closes at the end of the last exhibition day', style: DesignSystem.bodySm),
                            value: _allowAfter,
                            onChanged: (val) => setState(() => _allowAfter = val),
                            activeThumbColor: DesignSystem.secondary,
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
