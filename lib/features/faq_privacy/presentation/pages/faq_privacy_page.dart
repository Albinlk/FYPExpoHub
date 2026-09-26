import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/state_providers.dart';

class FaqPrivacyPage extends ConsumerWidget {
  final bool showPrivacyOnly;

  const FaqPrivacyPage({super.key, this.showPrivacyOnly = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(eventProvider);
    final contactEmail = event.publicContactEmail.trim().isNotEmpty ? event.publicContactEmail.trim() : 'fskmfypexpo@uitm.edu.my';
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: DesignSystem.spaceXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showPrivacyOnly) ...[
              _buildPrivacyContent(context, contactEmail),
            ] else ...[
              Text('Frequently Asked Questions (FAQ)', style: DesignSystem.pageTitle(context).copyWith(color: DesignSystem.primary)),
              const SizedBox(height: DesignSystem.spaceSm),
              Text('Get quick answers to common questions about the exhibition.', style: DesignSystem.bodyLg.copyWith(color: DesignSystem.onSurfaceVariant), softWrap: true),
              const SizedBox(height: DesignSystem.spaceXl),
              _buildFaqList([for (final f in event.faqItems) {'q': f.question, 'a': f.answer}]),
            ],
          ],
        ),
      ),
    );
  }

  /// The event's own FAQ items first, then the standard ones it doesn't cover.
  Widget _buildFaqList(List<Map<String, String>> eventFaqs) {
    final List<Map<String, String>> standard = [
      {
        'q': 'Is this exhibition open to the public?',
        'a': 'Yes, the exhibition is fully open to all students, lecturers, parents, and industry partners free of admission charges.'
      },
      {
        'q': 'How do I locate a specific exhibition booth?',
        'a': 'Open Booths on this portal, choose the presentation day, and search by booth number, project title or student name. Projects are grouped by venue.'
      },
      {
        'q': 'Is visitor parking available on campus?',
        'a': 'Yes, external visitors may park in designated visitor lots near the FSKM complex or at the UiTM main multi-story parking deck.'
      },
    ];

    final asked = {for (final f in eventFaqs) f['q']!.trim().toLowerCase()};
    final faqs = [
      ...eventFaqs,
      for (final f in standard)
        if (!asked.contains(f['q']!.trim().toLowerCase())) f,
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        final faq = faqs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
          child: ExpansionTile(
            title: Text(faq['q']!, style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary), softWrap: true),
            children: [
              Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceMd),
                child: Text(faq['a']!, style: DesignSystem.bodyMd.copyWith(height: 1.5), softWrap: true),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrivacyContent(BuildContext context, String contactEmail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Privacy Policy', style: DesignSystem.pageTitle(context).copyWith(color: DesignSystem.primary)),
        const SizedBox(height: DesignSystem.spaceSm),
        Text('Last updated: August 2026', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
        const SizedBox(height: DesignSystem.spaceXl),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(DesignSystem.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1. Introduction', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
                const SizedBox(height: DesignSystem.spaceSm),
                Text(
                  'FSKM is committed to safeguarding your personal privacy. This document outlines how personal information belonging to students, supervisors, and visitors is collected, processed, and protected in compliance with the Personal Data Protection Act (PDPA) 2010.',
                  style: DesignSystem.bodyMd.copyWith(height: 1.6),
                  softWrap: true,
                ),
                const SizedBox(height: DesignSystem.spaceLg),
                Text('2. Student Data Policy & Exhibition Information', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
                const SizedBox(height: DesignSystem.spaceSm),
                Text(
                  'Matric number may be displayed as approved FYP exhibition project information. Personal contact details, confidential evaluations, internal notes, login information, and private administrative records are not publicly displayed.',
                  style: DesignSystem.bodyMd.copyWith(height: 1.6),
                  softWrap: true,
                ),
                const SizedBox(height: DesignSystem.spaceLg),
                Text('3. Contact Us', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
                const SizedBox(height: DesignSystem.spaceSm),
                Text(
                  'If you have any questions or concerns regarding our privacy practices or personal data management, please contact system support at $contactEmail.',
                  style: DesignSystem.bodyMd.copyWith(height: 1.6),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
