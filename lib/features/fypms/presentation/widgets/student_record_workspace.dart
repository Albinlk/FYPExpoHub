import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';
import 'fypms_loading_widget.dart';

/// Shared scaffold for student sub-pages that operate on a specific FYP record.
///
/// Handles loading, the "no records" empty state, and a record picker when the
/// student owns more than one record.
class StudentRecordWorkspace extends ConsumerStatefulWidget {
  final String title;
  final Widget Function(BuildContext context, WidgetRef ref, FypRecord record)
      builder;

  const StudentRecordWorkspace({
    super.key,
    required this.title,
    required this.builder,
  });

  @override
  ConsumerState<StudentRecordWorkspace> createState() =>
      _StudentRecordWorkspaceState();
}

class _StudentRecordWorkspaceState extends ConsumerState<StudentRecordWorkspace> {
  String? _selectedRecordId;

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(myFypRecordsProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          widget.title,
          style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: records.when(
        loading: () => const FypmsLoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return _NoRecords();
          }
          final selected = list.firstWhere(
            (r) => r.id == _selectedRecordId,
            orElse: () => list.first,
          );
          if (_selectedRecordId == null) {
            _selectedRecordId = selected.id;
          }
          return Column(
            children: [
              if (list.length > 1)
                _RecordPicker(
                  records: list,
                  selectedId: selected.id,
                  onChanged: (id) => setState(() => _selectedRecordId = id),
                ),
              Expanded(
                child: widget.builder(context, ref, selected),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RecordPicker extends StatelessWidget {
  final List<FypRecord> records;
  final String selectedId;
  final ValueChanged<String> onChanged;

  const _RecordPicker({
    required this.records,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DesignSystem.gutter, vertical: DesignSystem.spaceSm),
      decoration: const BoxDecoration(
        color: DesignSystem.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: DesignSystem.surfaceContainer)),
      ),
      child: Row(
        children: [
          const Icon(Icons.folder_open, size: 18, color: DesignSystem.primary),
          const SizedBox(width: DesignSystem.spaceSm),
          const Expanded(
            child: Text('Active Record', style: DesignSystem.bodySm),
          ),
          DropdownButton<String>(
            value: selectedId,
            underline: const SizedBox.shrink(),
            isDense: true,
            borderRadius: DesignSystem.radiusLg,
            items: [
              for (final r in records)
                DropdownMenuItem(
                  value: r.id,
                  child: Text(
                    r.projectTitle?.isNotEmpty == true
                        ? r.projectTitle!
                        : r.currentCourseCode,
                    overflow: TextOverflow.ellipsis,
                    style: DesignSystem.bodySm,
                  ),
                ),
            ],
            onChanged: (id) {
              if (id != null) onChanged(id);
            },
          ),
        ],
      ),
    );
  }
}

class _NoRecords extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_open, size: 64, color: DesignSystem.onSurfaceVariant),
            const SizedBox(height: DesignSystem.spaceMd),
            Text('No FYP records yet', style: DesignSystem.h3),
            const SizedBox(height: DesignSystem.spaceSm),
            Text(
              'You need an active FYP record before using this page. '
              'Please contact your coordinator.',
              style: DesignSystem.bodyMd,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
