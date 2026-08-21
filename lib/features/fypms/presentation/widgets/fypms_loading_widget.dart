import 'package:flutter/material.dart';
import '../../../../app/theme/theme.dart';

class FypmsLoadingWidget extends StatelessWidget {
  const FypmsLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSystem.spaceLg),
        child: CircularProgressIndicator(),
      ),
    );
  }
}