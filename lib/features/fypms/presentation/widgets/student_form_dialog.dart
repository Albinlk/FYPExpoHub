import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/fypms_form_definitions.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/fypms_rpc_service.dart';
import '../../../../core/widgets/admin_actions.dart';

/// Student: choose a form and answer its questions (backlog U1; replaces
/// the raw-JSON payload box). Answers are checked before submitting.
class StudentFormDialog extends ConsumerStatefulWidget {
  const StudentFormDialog({super.key, required this.fypRecordId, required this.formCodes});

  final String fypRecordId;

  /// Form codes the student may submit now (course / special evaluation).
  final List<String> formCodes;

  @override
  ConsumerState<StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends ConsumerState<StudentFormDialog> {
  late final List<String> _codes = [for (final c in widget.formCodes) if (kStudentFormDefinitions.containsKey(c)) c];
  late String? _code = _codes.firstOrNull;
  final Map<String, TextEditingController> _controllers = {};
  bool _submitted = false;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controller(String key) => _controllers.putIfAbsent(key, TextEditingController.new);

  FormDefinition? get _def => _code == null ? null : kStudentFormDefinitions[_code];

  Map<String, String> get _answers => {for (final e in _controllers.entries) e.key: e.value.text};

  Future<void> _submit() async {
    final def = _def!;
    setState(() => _submitted = true);
    if (def.fields.any((f) => formFieldProblem(f, _controller(f.key).text) != null)) return;
    setState(() => _busy = true);
    try {
      await ref.read(supabaseRpcServiceProvider).submitFypForm(
            fypRecordId: widget.fypRecordId,
            formCode: def.code,
            payload: formPayload(def, _answers),
          );
      ref.invalidate(fypFormSubmissionsProvider(widget.fypRecordId));
      if (!mounted) return;
      final m = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      m.showSnackBar(SnackBar(content: Text('${def.code} ${def.title} submitted.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit: ${friendlyError(e)}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final def = _def;
    final ownPage = [for (final c in widget.formCodes) if (kFormsWithOwnPage.containsKey(c)) c];
    return AlertDialog(
      title: const Text('Submit Form'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                key: const Key('form-code'),
                initialValue: _code,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Form'),
                items: [
                  for (final c in _codes)
                    DropdownMenuItem(value: c, child: Text('$c — ${kStudentFormDefinitions[c]!.title}', overflow: TextOverflow.ellipsis)),
                ],
                onChanged: _busy
                    ? null
                    : (v) => setState(() {
                          _code = v;
                          _submitted = false;
                        }),
              ),
              if (ownPage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    [for (final c in ownPage) '$c is submitted on the ${kFormsWithOwnPage[c]}.'].join(' '),
                    style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                  ),
                ),
              if (def != null) ...[
                const SizedBox(height: DesignSystem.spaceSm),
                Text(def.purpose, style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
                for (final f in def.fields)
                  Padding(
                    padding: const EdgeInsets.only(top: DesignSystem.spaceSm),
                    child: TextField(
                      key: Key('field-${f.key}'),
                      controller: _controller(f.key),
                      onChanged: (_) => _submitted ? setState(() {}) : null,
                      minLines: f.kind == FormFieldKind.longText ? 3 : 1,
                      maxLines: f.kind == FormFieldKind.longText ? 8 : 1,
                      keyboardType: switch (f.kind) {
                        FormFieldKind.number => TextInputType.number,
                        FormFieldKind.url => TextInputType.url,
                        FormFieldKind.longText => TextInputType.multiline,
                        FormFieldKind.text => TextInputType.text,
                      },
                      decoration: InputDecoration(
                        labelText: '${f.label}${f.required ? '' : ' (optional)'}',
                        helperText: f.help,
                        errorText: _submitted ? formFieldProblem(f, _controller(f.key).text) : null,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: def == null || _busy ? null : _submit, child: const Text('Submit')),
      ],
    );
  }
}

/// A submitted form's answers as label / value lines (for students and the
/// staff evaluating it).
class FormAnswersView extends StatelessWidget {
  const FormAnswersView({super.key, required this.formCode, required this.payload});

  final String formCode;
  final Map<String, dynamic> payload;

  @override
  Widget build(BuildContext context) {
    final answers = formAnswers(formCode, payload);
    if (answers.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (label, value) in answers)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.w600)),
                SelectableText(value, style: DesignSystem.bodySm),
              ],
            ),
          ),
      ],
    );
  }
}
