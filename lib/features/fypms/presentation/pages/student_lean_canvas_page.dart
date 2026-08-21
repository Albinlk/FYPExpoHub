import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/fypms_rpc_service.dart';
import '../widgets/fypms_loading_widget.dart';
import '../widgets/student_record_workspace.dart';

/// Standard Lean Canvas (F13) blocks.
const List<({String key, String label, String hint})> fypmsLeanCanvasBlocks = [
  (key: 'problem', label: 'Problem', hint: 'Top 3 problems your project addresses'),
  (
    key: 'customerSegments',
    label: 'Customer Segments',
    hint: 'Target customers / beneficiaries',
  ),
  (
    key: 'uniqueValueProposition',
    label: 'Unique Value Proposition',
    hint: 'Single, clear, compelling message',
  ),
  (key: 'solution', label: 'Solution', hint: 'How you solve each problem'),
  (key: 'channels', label: 'Channels', hint: 'Path to your customers'),
  (key: 'revenueStreams', label: 'Revenue Streams', hint: 'How value is captured'),
  (key: 'costStructure', label: 'Cost Structure', hint: 'Your operating costs'),
  (key: 'keyMetrics', label: 'Key Metrics', hint: 'Key numbers to track'),
  (key: 'unfairAdvantage', label: 'Unfair Advantage', hint: 'Not easily copied'),
];

class StudentLeanCanvasPage extends ConsumerWidget {
  const StudentLeanCanvasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StudentRecordWorkspace(
      title: 'Lean Canvas',
      builder: (context, ref, record) {
        final canvas = ref.watch(fypLeanCanvasProvider(record.id));
        return canvas.when(
          loading: () => const FypmsLoadingWidget(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (existing) {
            final initialBlocks = existing?.blocks ?? const <String, dynamic>{};
            return _CanvasEditor(
              fypRecordId: record.id,
              existingVersion: existing?.canvasVersion ?? 0,
              initialBlocks: initialBlocks,
            );
          },
        );
      },
    );
  }
}

class _CanvasEditor extends ConsumerStatefulWidget {
  final String fypRecordId;
  final int existingVersion;
  final Map<String, dynamic> initialBlocks;

  const _CanvasEditor({
    required this.fypRecordId,
    required this.existingVersion,
    required this.initialBlocks,
  });

  @override
  ConsumerState<_CanvasEditor> createState() => _CanvasEditorState();
}

class _CanvasEditorState extends ConsumerState<_CanvasEditor> {
  late final Map<String, TextEditingController> _controllers;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final block in fypmsLeanCanvasBlocks)
        block.key: TextEditingController(
          text: (widget.initialBlocks[block.key] as String?) ?? '',
        ),
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final blocks = <String, dynamic>{
      for (final block in fypmsLeanCanvasBlocks)
        block.key: _controllers[block.key]!.text.trim(),
    };
    try {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.saveLeanCanvas(fypRecordId: widget.fypRecordId, blocks: blocks);
      if (mounted) {
        ref.invalidate(fypLeanCanvasProvider(widget.fypRecordId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lean Canvas saved.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(DesignSystem.gutter),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.existingVersion > 0
                      ? 'Revision ${widget.existingVersion + 1} (saving creates a new version)'
                      : 'Draft your Lean Canvas (F13)',
                  style: DesignSystem.h2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: DesignSystem.spaceSm),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Save Canvas'),
                style: FilledButton.styleFrom(
                  backgroundColor: DesignSystem.secondary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1100 ? 3 : 2;
              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: DesignSystem.gutter),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: DesignSystem.spaceMd,
                  mainAxisSpacing: DesignSystem.spaceMd,
                  childAspectRatio: columns == 3 ? 1.1 : 0.9,
                ),
                itemCount: fypmsLeanCanvasBlocks.length,
                itemBuilder: (context, index) {
                  final block = fypmsLeanCanvasBlocks[index];
                  return _CanvasBlockCard(
                    label: block.label,
                    hint: block.hint,
                    controller: _controllers[block.key]!,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CanvasBlockCard extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _CanvasBlockCard({
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: DesignSystem.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: DesignSystem.bodyMd.copyWith(
                fontWeight: FontWeight.bold,
                color: DesignSystem.primary,
              ),
            ),
            const SizedBox(height: DesignSystem.spaceXs),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
    );
  }
}