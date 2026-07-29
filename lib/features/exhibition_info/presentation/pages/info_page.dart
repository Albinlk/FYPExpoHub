import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/event.dart';
import '../../../../core/state/state_providers.dart';

class InfoPage extends ConsumerWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final padding = isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;

    final event = ref.watch(eventProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: DesignSystem.spaceXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Exhibition Information', style: DesignSystem.h1.copyWith(color: DesignSystem.primary)),
            const SizedBox(height: DesignSystem.spaceSm),
            Text(
              'Discover more details about the FSKM Final Year Project Exhibition.',
              style: (isDesktop ? DesignSystem.bodyLg : DesignSystem.bodyLgMobile).copyWith(color: DesignSystem.onSurfaceVariant),
              softWrap: true,
            ),
            const SizedBox(height: DesignSystem.spaceXl),

            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildInfoDetails(event, isDesktop)),
                      const SizedBox(width: DesignSystem.spaceXl),
                      Expanded(flex: 2, child: _buildLocationMap(event, isDesktop)),
                    ],
                  )
                : Column(
                    children: [
                      _buildInfoDetails(event, isDesktop),
                      const SizedBox(height: DesignSystem.spaceXl),
                      _buildLocationMap(event, isDesktop),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoDetails(Event event, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard('Background', event.description, isDesktop),
        const SizedBox(height: DesignSystem.spaceMd),
        _buildSectionCard('Main Objectives', event.objectives.map((o) => '• $o').join('\n'), isDesktop),
        const SizedBox(height: DesignSystem.spaceMd),
        _buildSectionCard(
          'Competition Categories',
          '1. Computer Science & Software Development\n2. Networking & Cyber Security\n3. Mathematics & Actuarial Sciences\n4. Artificial Intelligence & Data Analytics',
          isDesktop,
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, String content, bool isDesktop) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: (isDesktop ? DesignSystem.h3 : DesignSystem.h3Mobile).copyWith(color: DesignSystem.primary, fontWeight: FontWeight.bold), softWrap: true),
            const SizedBox(height: DesignSystem.spaceMd),
            Text(content, style: DesignSystem.bodyMd.copyWith(height: 1.6), softWrap: true),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationMap(Event event, bool isDesktop) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Exhibition Location', style: (isDesktop ? DesignSystem.h3 : DesignSystem.h3Mobile).copyWith(color: DesignSystem.primary)),
            const SizedBox(height: DesignSystem.spaceMd),
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: DesignSystem.primary.withValues(alpha: 0.05),
                borderRadius: DesignSystem.radiusLg,
                border: Border.all(color: DesignSystem.surfaceContainer),
              ),
              child: const Center(
                child: Icon(Icons.map, size: 48, color: DesignSystem.primaryContainer),
              ),
            ),
            const SizedBox(height: DesignSystem.spaceMd),
            Text(event.venue, style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold), softWrap: true),
            const SizedBox(height: 4),
            Text(event.locationDetails, style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant), softWrap: true),
          ],
        ),
      ),
    );
  }
}
