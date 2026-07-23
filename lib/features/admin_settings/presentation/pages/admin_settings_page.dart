import 'package:flutter/material.dart';
import '../../../../app/theme/theme.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignSystem.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Portal Settings', style: DesignSystem.h2.copyWith(color: DesignSystem.primary)),
            const SizedBox(height: 4),
            Text('Configure system preferences, upload limits, and environment variables.', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
            const SizedBox(height: DesignSystem.spaceXl),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Excel File Parsing Settings', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
                    const Divider(height: 32),

                    Text('Maximum File Size Limit', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.primary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      initialValue: '10 MB',
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.line_weight)),
                    ),
                    const SizedBox(height: 16),

                    Text('Mandatory Worksheet Names', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.primary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      initialValue: 'SCHEDULE, AWARD WINNERS, COMMITTEE',
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.table_chart)),
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
                      child: const Text('Save Configuration'),
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
