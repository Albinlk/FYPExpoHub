import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/event.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/utils/external_link.dart';
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
  final _hoursController = TextEditingController();
  final _locationController = TextEditingController();
  final _mapUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();
  final _heroController = TextEditingController();
  final _posterController = TextEditingController();
  String _status = 'active';
  // FAQ rows being edited (question, answer controllers).
  final List<(TextEditingController, TextEditingController)> _faq = [];
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
    for (final c in _textControllers) {
      c.addListener(_markDirty);
    }
  }

  void _markDirty() => _dirty = true;

  List<TextEditingController> get _textControllers => [
        _titleController,
        _sessionController,
        _venueController,
        _hoursController,
        _locationController,
        _mapUrlController,
        _descriptionController,
        _contactController,
        _heroController,
        _posterController,
      ];

  static const _statuses = {
    'draft': 'Draft',
    'upcoming': 'Upcoming',
    'active': 'Active (running)',
    'completed': 'Completed',
    'archived': 'Archived',
  };

  void _clearFaq() {
    for (final (q, a) in _faq) {
      q.dispose();
      a.dispose();
    }
    _faq.clear();
  }

  void _addFaq([FaqItem? item]) {
    final q = TextEditingController(text: item?.question ?? '')..addListener(_markDirty);
    final a = TextEditingController(text: item?.answer ?? '')..addListener(_markDirty);
    _faq.add((q, a));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sessionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    for (final c in _textControllers.skip(3)) {
      c.dispose();
    }
    _venueController.dispose();
    _clearFaq();
    super.dispose();
  }

  void _loadEvent() {
    final event = ref.read(eventProvider);
    _titleController.text = event.title;
    _sessionController.text = event.sessionLabel;
    _setStartDay(mytDate(event.startAt));
    _setEndDay(mytDate(event.endAt));
    _venueController.text = event.venue;
    _hoursController.text = event.dailyHours;
    _locationController.text = event.locationDetails;
    _mapUrlController.text = event.mapUrl ?? '';
    _descriptionController.text = event.description;
    _contactController.text = event.publicContactEmail;
    _heroController.text = event.heroImageUrl;
    _posterController.text = event.posterUrl;
    _status = _statuses.containsKey(event.status) ? event.status : 'active';
    _clearFaq();
    for (final f in event.faqItems) {
      _addFaq(f);
    }
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
    final problem = _validate();
    if (problem != null) {
      // Replace, don't queue: the admin is fixing one problem at a time.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(problem)));
      return;
    }
    final mapUrl = _mapUrlController.text.trim();
    final updated = event.copyWith(
      title: _titleController.text.trim(),
      sessionLabel: _sessionController.text.trim(),
      startAt: startAt,
      endAt: endAt,
      venue: _venueController.text.trim(),
      dailyHours: _hoursController.text.trim(),
      locationDetails: _locationController.text.trim(),
      mapUrl: mapUrl.isEmpty ? null : mapUrl,
      description: _descriptionController.text.trim(),
      publicContactEmail: _contactController.text.trim(),
      heroImageUrl: _heroController.text.trim(),
      posterUrl: _posterController.text.trim(),
      status: _status,
      faqItems: [
        for (final (q, a) in _faq)
          if (q.text.trim().isNotEmpty) FaqItem(question: q.text.trim(), answer: a.text.trim()),
      ],
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

  /// First problem with the form, or null. Links must be http(s) (the
  /// public pages refuse anything else) and FAQ questions need answers.
  String? _validate() {
    if (_titleController.text.trim().isEmpty) return 'The exhibition title is required.';
    final event = ref.read(eventProvider);
    for (final (label, c, saved) in [
      ('Map link', _mapUrlController, event.mapUrl ?? ''),
      ('Hero image', _heroController, event.heroImageUrl),
      ('Poster', _posterController, event.posterUrl),
    ]) {
      final v = c.text.trim();
      // Only what the admin changes is checked: a legacy non-link value
      // (the seed's "assets/images/banner.jpg") must not block saving.
      if (v.isNotEmpty && v != saved && safeExternalUri(v) == null) return '$label must be an http(s) link.';
    }
    final email = _contactController.text.trim();
    if (email.isNotEmpty && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'The contact email is not valid.';
    }
    for (final (q, a) in _faq) {
      if (q.text.trim().isNotEmpty && a.text.trim().isEmpty) {
        return 'FAQ "${q.text.trim()}" needs an answer.';
      }
    }
    return null;
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: DesignSystem.labelCaps.copyWith(color: DesignSystem.primary)),
      );

  Widget _field(String label, TextEditingController c, {String? hint, IconData? icon, int maxLines = 1, Key? key}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(label),
            TextFormField(
              key: key,
              controller: c,
              maxLines: maxLines,
              decoration: InputDecoration(hintText: hint, prefixIcon: icon == null ? null : Icon(icon)),
            ),
          ],
        ),
      );

  Widget _faqEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Event FAQ', style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary)),
        const SizedBox(height: 4),
        Text(
          'Shown on the public FAQ page above the general questions.',
          style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
        ),
        const SizedBox(height: DesignSystem.spaceSm),
        for (var i = 0; i < _faq.length; i++)
          Card(
            key: ValueKey(_faq[i].$1),
            color: DesignSystem.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(DesignSystem.spaceSm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        TextField(
                          key: Key('faq-q-$i'),
                          controller: _faq[i].$1,
                          decoration: const InputDecoration(labelText: 'Question'),
                        ),
                        TextField(
                          key: Key('faq-a-$i'),
                          controller: _faq[i].$2,
                          maxLines: 3,
                          minLines: 1,
                          decoration: const InputDecoration(labelText: 'Answer'),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove question',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => setState(() {
                      final (q, a) = _faq.removeAt(i);
                      q.dispose();
                      a.dispose();
                      _dirty = true;
                    }),
                  ),
                ],
              ),
            ),
          ),
        TextButton.icon(
          onPressed: () => setState(() {
            _addFaq();
            _dirty = true;
          }),
          icon: const Icon(Icons.add),
          label: const Text('Add question'),
        ),
      ],
    );
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
            Text('Dates, hours, venue, status, images and the event FAQ.', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
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

                    _field('Daily Hours', _hoursController, hint: 'e.g. 9:00 AM – 5:00 PM', icon: Icons.schedule, key: const Key('event-hours')),
                    _field('Primary Venue / Hall', _venueController, icon: Icons.room),
                    _field('Location Details', _locationController, hint: 'Building, floor, parking…', maxLines: 2),
                    _field('Map Link', _mapUrlController, hint: 'https://maps.google.com/…', icon: Icons.map, key: const Key('event-map')),
                    _field('Description', _descriptionController, maxLines: 4),
                    _field('Public Contact Email', _contactController, icon: Icons.email_outlined, key: const Key('event-email')),
                    _field('Hero Image URL', _heroController, hint: 'https://…', icon: Icons.image_outlined, key: const Key('event-hero')),
                    _field('Poster URL', _posterController, hint: 'https://…', icon: Icons.picture_as_pdf_outlined),
                    _label('Event Status'),
                    DropdownButtonFormField<String>(
                      key: const Key('event-status'),
                      initialValue: _status,
                      isExpanded: true,
                      items: [
                        for (final e in _statuses.entries) DropdownMenuItem(value: e.key, child: Text(e.value)),
                      ],
                      onChanged: (v) => setState(() {
                        _status = v ?? _status;
                        _dirty = true;
                      }),
                    ),
                    const Divider(height: 40),
                    _faqEditor(),
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
