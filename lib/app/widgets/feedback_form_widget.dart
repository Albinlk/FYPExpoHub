import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../app/theme/theme.dart';
import '../../core/domain/models/feedback_entry.dart';
import '../../core/firebase/firebase_providers.dart';
import '../../core/state/state_providers.dart';

class FeedbackFormWidget extends ConsumerStatefulWidget {
  const FeedbackFormWidget({super.key});

  static void show(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: DesignSystem.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: const FeedbackFormWidget(),
      ),
    ).then((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your feedback!')),
        );
      }
    });
  }

  @override
  ConsumerState<FeedbackFormWidget> createState() => _FeedbackFormWidgetState();
}

class _FeedbackFormWidgetState extends ConsumerState<FeedbackFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    final user = ref.read(firebaseAuthProvider).currentUser;
    final now = DateTime.now();

    final entry = FeedbackEntry(
      id: const Uuid().v4(),
      userId: user?.uid,
      eventId: 'fskm-fyp-2026',
      subject: _subjectController.text.trim(),
      message: _messageController.text.trim(),
      rating: _rating > 0 ? _rating : null,
      userAgent: _getUserAgent(),
      status: 'new',
      createdAt: now,
      updatedAt: now,
    );

    try {
      ref.read(feedbackEntriesProvider.notifier).addFeedbackEntry(entry);
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit feedback: $e'), backgroundColor: DesignSystem.errorContainer),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _getUserAgent() {
    return 'Flutter Web';
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final width = isDesktop ? 500.0 : MediaQuery.of(context).size.width * 0.9;

    return Container(
      width: width,
      padding: const EdgeInsets.all(DesignSystem.spaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Send Feedback',
                style: (isDesktop ? DesignSystem.h3 : DesignSystem.bodyLg)
                    .copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spaceSm),
          Text(
            'Share your thoughts, report an issue, or suggest a feature.',
            style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
          ),
          const SizedBox(height: DesignSystem.spaceMd),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Subject is required' : null,
                ),
                const SizedBox(height: DesignSystem.spaceMd),
                TextFormField(
                  controller: _messageController,
                  decoration: const InputDecoration(labelText: 'Message'),
                  maxLines: 5,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Message is required' : null,
                ),
                const SizedBox(height: DesignSystem.spaceMd),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usability Rating (optional)',
                      style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                    ),
                    const SizedBox(height: DesignSystem.spaceXs),
                    Row(
                      children: List.generate(5, (i) {
                        return GestureDetector(
                          onTap: () => setState(() => _rating = i + 1),
                          child: Icon(
                            i < _rating ? Icons.star : Icons.star_border,
                            color: DesignSystem.secondaryContainer,
                            size: 28,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignSystem.spaceLg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: DesignSystem.spaceMd),
                shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
