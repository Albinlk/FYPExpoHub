import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';

class AdminImportsPage extends StatefulWidget {
  const AdminImportsPage({super.key});

  @override
  State<AdminImportsPage> createState() => _AdminImportsPageState();
}

class _AdminImportsPageState extends State<AdminImportsPage> {
  bool _isDragging = false;
  bool _isUploading = false;
  String? _selectedFileName;

  void _selectFile() async {
    // In actual code, we use file_picker to pick .xlsx workbooks
    setState(() {
      _selectedFileName = 'master_file_fyp_v1.xlsx';
    });
  }

  void _uploadAndProcess() {
    if (_selectedFileName == null) return;
    setState(() {
      _isUploading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        // On successful parse, navigate to Staging review dashboard (ID: IMP-2026-001)
        context.go('/admin/imports/IMP-2026-001');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignSystem.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Import Master File', style: DesignSystem.h2.copyWith(color: DesignSystem.primary)),
            const SizedBox(height: 4),
            Text('Upload the Excel Master Workbook (.xlsx) to initiate the parsing, staging, and publication workflows.', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
            const SizedBox(height: DesignSystem.spaceXl),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceLg),
                child: Column(
                  children: [
                    // DRAG & DROP ZONE
                    GestureDetector(
                      onTap: _selectFile,
                      child: Container(
                        height: 240,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _isDragging ? DesignSystem.secondaryContainer.withOpacity(0.05) : DesignSystem.primary.withOpacity(0.02),
                          borderRadius: DesignSystem.radiusLg,
                          border: Border.all(
                            color: _isDragging ? DesignSystem.secondary : DesignSystem.outlineVariant,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_upload_outlined, size: 64, color: DesignSystem.primary),
                            const SizedBox(height: DesignSystem.spaceMd),
                            Text(
                              _selectedFileName ?? 'Drag & Drop Your Excel File Here, or Click to Browse',
                              style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary),
                            ),
                            const SizedBox(height: 4),
                            Text('Only .xlsx files (Master Workbook) are allowed. Max size: 10MB.', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ),

                    if (_selectedFileName != null) ...[
                      const SizedBox(height: DesignSystem.spaceLg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isUploading ? null : _uploadAndProcess,
                            icon: _isUploading
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.play_circle_fill),
                            label: Text(_isUploading ? 'Processing Workbook...' : 'Initiate Parsing & Staging'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignSystem.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: _isUploading ? null : () => setState(() => _selectedFileName = null),
                            style: OutlinedButton.styleFrom(foregroundColor: DesignSystem.error, side: const BorderSide(color: DesignSystem.error)),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
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
