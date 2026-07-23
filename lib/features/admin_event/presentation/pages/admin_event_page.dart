import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/domain/models/event.dart';

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
    _startDateController.text = '${event.startAt.day} ${_monthName(event.startAt.month)} ${event.startAt.year}';
    _endDateController.text = '${event.endAt.day} ${_monthName(event.endAt.month)} ${event.endAt.year}';
    _venueController.text = event.venue;
  }

  String _monthName(int m) {
    const months = ['Jan', 'Feb', 'Mac', 'Apr', 'Mei', 'Jun', 'Jul', 'Ogos', 'Sep', 'Okt', 'Nov', 'Dis'];
    return months[m - 1];
  }

  void _save() {
    final event = ref.read(eventProvider);
    final updated = event.copyWith(
      title: _titleController.text,
      sessionLabel: _sessionController.text,
      venue: _venueController.text,
      updatedAt: DateTime.now(),
    );
    ref.read(eventProvider.notifier).updateEvent(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event information saved to Firestore!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(eventProvider, (_, __) => _loadEvent());
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEvent());

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignSystem.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Update Event Information', style: DesignSystem.h2.copyWith(color: DesignSystem.primary)),
            const SizedBox(height: 4),
            Text('Modify basic details, venue, dates, and exhibition poster.', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
            const SizedBox(height: DesignSystem.spaceXl),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('General Information Form', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
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
                      onPressed: _save,
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
