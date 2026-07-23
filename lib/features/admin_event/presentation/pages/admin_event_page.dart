import 'package:flutter/material.dart';
import '../../../../app/theme/theme.dart';

class AdminEventPage extends StatelessWidget {
  const AdminEventPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                      initialValue: 'Final Year Project Exhibition (FYP Expo) FSKM',
                      decoration: const InputDecoration(hintText: 'Please enter the title'),
                    ),
                    const SizedBox(height: 16),

                    Text('Session / Semester Label', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.primary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      initialValue: 'October 2026 - February 2027 Session',
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
                                initialValue: '6 Ogos 2026',
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
                                initialValue: '7 Ogos 2026',
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
                      initialValue: 'Blok Kuliah, FSKM',
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.room)),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: () {},
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
