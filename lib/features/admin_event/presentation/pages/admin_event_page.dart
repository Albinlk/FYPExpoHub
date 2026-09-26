import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/utils/schedule_format.dart';
import '../../../../core/widgets/admin_actions.dart';

class AdminEventPage extends ConsumerStatefulWidget {
  const AdminEventPage({super.key});

  @override
  ConsumerState<AdminEventPage> createState() => _AdminEventPageState();
}

class _AdminEventPageState extends ConsumerState<AdminEventPage> {
  final _titleController = TextEditingController();
  final _sessionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _venueController = TextEditingController();
  // Calendar days (Malaysia time) picked for the event; the saved instants
  // keep the event's existing daily start/end times.
  late DateTime _startDay;
  late DateTime _endDay;
  bool _dirty = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadEvent();
    for (final c in [_titleController, _sessionController, _venueController]) {
      c.addListener(_markDirty);
    }
  }

  void _markDirty() => _dirty = true;

  @override
  void dispose() {
    _titleController.dispose();
    _sessionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  void _loadEvent() {
    final event = ref.read(eventProvider);
    _titleController.text = event.title;
    _sessionController.text = event.sessionLabel;
    _setStartDay(mytDate(event.startAt));
    _setEndDay(mytDate(event.endAt));
    _venueController.text = event.venue;
    // Programmatic fills above aren't edits.
    _dirty = false;
  }

  String _monthName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[m - 1];
  }

  String _formatDay(DateTime d) => '${d.day} ${_monthName(d.month)} ${d.year}';

  void _setStartDay(DateTime d) {
    _startDay = d;
    _startDateController.text = _formatDay(d);
  }

  void _setEndDay(DateTime d) {
    _endDay = d;
    _endDateController.text = _formatDay(d);
  }

  Future<void> _pickDay({required bool start}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: start ? _startDay : _endDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _dirty = true;
      if (start) {
        _setStartDay(picked);
        // Keep the range valid: a start after the end drags the end along.
        if (_endDay.isBefore(picked)) _setEndDay(picked);
      } else {
        _setEndDay(picked);
      }
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    final event = ref.read(eventProvider);
    final startAt = withMytDate(event.startAt, _startDay);
    final endAt = withMytDate(event.endAt, _endDay);
    if (!endAt.isAfter(startAt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The end date must not be before the start date.')),
      );
      return;
    }
    final updated = event.copyWith(
      title: _titleController.text.trim(),
      sessionLabel: _sessionController.text.trim(),
      startAt: startAt,
      endAt: endAt,
      venue: _venueController.text.trim(),
      updatedAt: DateTime.now(),
    );
    setState(() => _saving = true);
    final ok = await runAdminWrite(
      context,
      () => ref.read(eventProvider.notifier).updateEvent(updated),
      success: 'Event information saved.',
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) _dirty = false;
  }

  @override
  Widget build(BuildContext context) {
    // Refill from the provider when the live event arrives — but never over
    // the admin's unsaved edits. (This used to re-run on EVERY frame, which
    // wiped whatever was being typed whenever the page rebuilt.)
    ref.listen(eventProvider, (_, _) {
      if (!_dirty) _loadEvent();
    });

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignSystem.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Update Event Information', style: DesignSystem.h2Mobile.copyWith(color: DesignSystem.primary)),
            const SizedBox(height: 4),
            Text('Modify basic details, venue, dates, and exhibition poster.', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
            const SizedBox(height: DesignSystem.spaceXl),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('General Information Form', style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary)),
                    const Divider(height: 32),

                    Text('Exhibition Title', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.primary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(hintText: 'Please enter the title'),
                    ),
                    const SizedBox(height: 16),

                    Text('Session / Semester Label', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.primary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _sessionController,
                      decoration: const InputDecoration(hintText: 'e.g. Semester 2026/1'),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start Date', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.primary)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _startDateController,
                                readOnly: true,
                                onTap: () => _pickDay(start: true),
                                decoration: const InputDecoration(prefixIcon: Icon(Icons.calendar_month)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('End Date', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.primary)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _endDateController,
                                readOnly: true,
                                onTap: () => _pickDay(start: false),
                                decoration: const InputDecoration(prefixIcon: Icon(Icons.calendar_month)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text('Primary Venue / Hall', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.primary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _venueController,
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.room)),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                      ),
                      child: const Text('Save Changes'),
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
