import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/widgets/page_heading.dart';

void main() {
  testWidgets('PageHeading is announced as a heading', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PageHeading('Project Catalogue'))));
    expect(
      tester.getSemantics(find.text('Project Catalogue')),
      matchesSemantics(label: 'Project Catalogue', isHeader: true),
    );
    handle.dispose();
  });
}
