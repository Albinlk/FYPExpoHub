import 'package:flutter/material.dart';
import '../../../../app/theme/theme.dart';

class FaqPrivacyPage extends StatelessWidget {
  final bool showPrivacyOnly;

  const FaqPrivacyPage({super.key, this.showPrivacyOnly = false});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: DesignSystem.spaceXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showPrivacyOnly) ...[
              _buildPrivacyContent(),
            ] else ...[
              Text('Frequently Asked Questions (FAQ)', style: DesignSystem.h1.copyWith(color: DesignSystem.primary)),
              const SizedBox(height: DesignSystem.spaceSm),
              Text('Get quick answers to common questions about the exhibition.', style: DesignSystem.bodyLg.copyWith(color: DesignSystem.onSurfaceVariant), softWrap: true),
              const SizedBox(height: DesignSystem.spaceXl),
              _buildFaqList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFaqList() {
    final List<Map<String, String>> faqs = [
      {
        'q': 'Is this exhibition open to the public?',
        'a': 'Yes, the exhibition is fully open to all students, lecturers, parents, and industry partners free of admission charges.'
      },
      {
        'q': 'How do I locate a specific exhibition booth?',
        'a': 'You can use the "Find Booths" section on this portal to search by booth number or project title and locate it on the hall layout plan.'
      },
      {
        'q': 'Is visitor parking available on campus?',
        'a': 'Yes, external visitors may park in designated visitor lots near the FSKM complex or at the UiTM main multi-story parking deck.'
      },
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

  Widget _buildPrivacyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Privacy Policy', style: DesignSystem.h1.copyWith(color: DesignSystem.primary)),
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
                  'If you have any questions or concerns regarding our privacy practices or personal data management, please contact system support at fskmfypexpo@uitm.edu.my.',
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
