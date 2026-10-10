import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';

/// A page's main title, announced to screen readers as a heading so they can
/// jump straight to it. Same look as before: [DesignSystem.pageTitle] in the
/// primary colour.
class PageHeading extends StatelessWidget {
  const PageHeading(this.text, {super.key, this.textAlign});

  final String text;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        textAlign: textAlign,
        style: DesignSystem.pageTitle(context).copyWith(color: DesignSystem.primary),
      ),
    );
  }
}
