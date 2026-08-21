import 'package:flutter/material.dart';
import '../../../../app/theme/theme.dart';

class FypmsPlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;

  const FypmsPlaceholderPage({
    super.key,
    required this.title,
    required this.icon,
    this.description = 'This module is being built. Check back soon.',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          title,
          style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: DesignSystem.onSurfaceVariant),
              const SizedBox(height: DesignSystem.spaceMd),
              Text(title, style: DesignSystem.h3),
              const SizedBox(height: DesignSystem.spaceSm),
              Text(
                description,
                style: DesignSystem.bodyMd,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}