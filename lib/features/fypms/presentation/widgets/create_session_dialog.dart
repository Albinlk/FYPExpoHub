import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_course_offering.dart';
import '../../../../core/domain/models/fypms/fyp_presentation_session.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/fypms_rpc_service.dart';
import '../../../../core/utils/fypms_format.dart';
import '../../../../core/widgets/admin_actions.dart';

/// Course lecturer / coordinator creates a presentation session for one of
/// the course offerings they manage (`create_presentation_session`).
class CreateSessionDialog extends ConsumerStatefulWidget {
  const CreateSessionDialog({super.key, required this.offerings, this.session});

  final List<FypCourseOffering> offerings;

  /// Set to edit an existing session instead (backlog U5).
  final FypPresentationSession? session;

  @override
  ConsumerState<CreateSessionDialog> createState() => _CreateSessionDialogState();
}

class _CreateSessionDialogState extends ConsumerState<CreateSessionDialog> {
  late final _code = TextEditingController(text: widget.session?.sessionCode ?? '');
  late final _title = TextEditingController(text: widget.session?.sessionTitle ?? '');
  late final _venue = TextEditingController(text: widget.session?.venue ?? '');
  late String? _offeringId = widget.session?.offeringId ?? widget.offerings.firstOrNull?.id;
  late String _type = widget.session?.sessionType ?? 'defence';
  late DateTime? _date = widget.session?.startAt.toLocal();
  late TimeOfDay _start = widget.session == null ? const TimeOfDay(hour: 9, minute: 0) : TimeOfDay.fromDateTime(widget.session!.startAt.toLocal());
  late TimeOfDay _end = widget.session == null ? const TimeOfDay(hour: 13, minute: 0) : TimeOfDay.fromDateTime(widget.session!.endAt.toLocal());
  bool get _editing => widget.session != null;
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    _title.dispose();
    _venue.dispose();
    super.dispose();
  }

  DateTime _at(TimeOfDay t) => DateTime(_date!.year, _date!.month, _date!.day, t.hour, t.minute);

  bool get _validWindow =>
      _date != null && (_end.hour * 60 + _end.minute) > (_start.hour * 60 + _start.minute);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime(bool start) async {
    final picked = await showTimePicker(context: context, initialTime: start ? _start : _end);
    if (picked != null) setState(() => start ? _start = picked : _end = picked);
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      if (_editing) {
        await ref.read(supabaseRpcServiceProvider).updatePresentationSession(
              sessionId: widget.session!.id,
              sessionTitle: _title.text.trim(),
              startAt: _at(_start),
              endAt: _at(_end),
              venue: _venue.text.trim().isEmpty ? null : _venue.text.trim(),
              sessionType: _type,
            );
        ref.invalidate(fypPresentationSessionsProvider);
        if (!mounted) return;
        final m = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        m.showSnackBar(const SnackBar(content: Text('Session updated.')));
        return;
      }
      await ref.read(createPresentationSessionProvider)(
        offeringId: _offeringId!,
        sessionCode: _code.text.trim(),
        sessionTitle: _title.text.trim(),
        startAt: _at(_start),
        endAt: _at(_end),
        venue: _venue.text.trim().isEmpty ? null : _venue.text.trim(),
        sessionType: _type,
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Session created.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${friendlyError(e)}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = _offeringId != null &&
        _code.text.trim().isNotEmpty &&
        _title.text.trim().isNotEmpty &&
        _validWindow &&
        !_busy;
    return AlertDialog(
      backgroundColor: DesignSystem.surfaceContainerLowest,
      title: Text(_editing ? 'Edit Session' : 'New Session', style: DesignSystem.h2),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _offeringId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Course'),
                items: [
                  for (final o in widget.offerings)
                    DropdownMenuItem(value: o.id, child: Text(o.courseCode, overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (v) => setState(() => _offeringId = v),
              ),
              TextField(
                key: const Key('session-code'),
                controller: _code,
                onChanged: (_) => setState(() {}),
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Code (e.g. P2)'),
              ),
              TextField(
                key: const Key('session-title'),
                controller: _title,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              DropdownButtonFormField<String>(
                initialValue: _type,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'defence', child: Text('Presentation / defence')),
                  DropdownMenuItem(value: 'expo', child: Text('Exhibition')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'defence'),
              ),
              TextField(controller: _venue, decoration: const InputDecoration(labelText: 'Venue (optional)')),
              const SizedBox(height: DesignSystem.spaceSm),
              Wrap(
                spacing: DesignSystem.spaceSm,
                runSpacing: DesignSystem.spaceXs,
                children: [
                  OutlinedButton(
                    key: const Key('session-date'),
                    onPressed: _pickDate,
                    child: Text(_date == null ? 'Date' : formatFypDate(_date!)),
                  ),
                  OutlinedButton(onPressed: () => _pickTime(true), child: Text('From ${_start.format(context)}')),
                  OutlinedButton(onPressed: () => _pickTime(false), child: Text('To ${_end.format(context)}')),
                ],
              ),
              if (_date != null && !_validWindow)
                Padding(
                  padding: const EdgeInsets.only(top: DesignSystem.spaceXs),
                  child: Text(
                    'The session must end after it starts.',
                    style: DesignSystem.bodySm.copyWith(color: DesignSystem.error),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: ready ? _submit : null, child: Text(_editing ? 'Save' : 'Create')),
      ],
    );
  }
}
