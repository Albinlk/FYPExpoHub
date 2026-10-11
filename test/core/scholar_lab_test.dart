import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/app/theme/theme.dart';
import 'package:fyp_expo_hub/core/widgets/scholar_lab.dart';

/// "Scholar + Lab" building blocks (DESIGN.md §4).
void main() {
  Future<void> pump(WidgetTester tester, Widget child, {double width = 1280}) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: GraphPaper(child: child))));
  }

  testWidgets('section header: mono number, serif title, a rule and an action', (tester) async {
    await pump(
      tester,
      SectionHeader(number: '01', title: 'Featured projects', action: TextButton(onPressed: () {}, child: const Text('View All'))),
    );
    expect(find.text('01'), findsOneWidget);
    final title = tester.widget<Text>(find.text('Featured projects'));
    expect(title.style?.fontFamily, DesignSystem.serif);
    expect(tester.widget<Text>(find.text('01')).style?.fontFamily, DesignSystem.mono);
    expect(find.byType(Divider), findsOneWidget);
    expect(find.text('View All'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('section header fits a phone', (tester) async {
    await pump(tester, const SectionHeader(number: '03', title: 'Past Projects Guide'), width: 360);
    expect(tester.takeException(), isNull);
  });

  testWidgets('code tag renders a booth code in mono; winner variant is apricot', (tester) async {
    await pump(tester, const Column(children: [CodeTag('BK1-07'), CodeTag('Best CS', winner: true)]));
    expect(tester.widget<Text>(find.text('BK1-07')).style?.fontFamily, DesignSystem.mono);
    final winnerBox = tester.widget<Container>(
      find.ancestor(of: find.text('Best CS'), matching: find.byType(Container)).first,
    );
    expect((winnerBox.decoration as BoxDecoration).color, DesignSystem.secondaryContainer);
  });

  testWidgets('stat block reads as one phrase for screen readers', (tester) async {
    await pump(tester, const StatBlock(label: 'Projects', value: '214'));
    expect(find.text('PROJECTS'), findsOneWidget);
    expect(find.bySemanticsLabel('214 Projects'), findsOneWidget);
  });

  testWidgets('brand mark is announced as FYP Expo Hub', (tester) async {
    await pump(tester, const BrandMark(subtitle: 'WORKSPACE · CSP600 · CSP650'));
    expect(find.bySemanticsLabel('FYP Expo Hub'), findsOneWidget);
  });
}
