import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/widgets/project_cover_image.dart';

void main() {
  group('ProjectCoverImage.isPlaceholderUrl', () {
    test('null / empty urls are placeholders', () {
      expect(ProjectCoverImage.isPlaceholderUrl(null), isTrue);
      expect(ProjectCoverImage.isPlaceholderUrl(''), isTrue);
    });

    test('legacy local placeholder path is detected', () {
      expect(
        ProjectCoverImage.isPlaceholderUrl(
            'assets/images/project_placeholder.jpg'),
        isTrue,
      );
    });

    test('placehold.co links are detected (the old live rewrite)', () {
      expect(
        ProjectCoverImage.isPlaceholderUrl(
            'https://placehold.co/400x250/3b82f6/ffffff?text=Some+Title'),
        isTrue,
      );
    });

    test('other placeholder patterns are detected', () {
      expect(ProjectCoverImage.isPlaceholderUrl('https://via.placeholder.com'),
          isTrue);
      expect(ProjectCoverImage.isPlaceholderUrl('https://picsum.photos/200'),
          isTrue);
      expect(ProjectCoverImage.isPlaceholderUrl('https://x.com/default.png'),
          isTrue);
    });

    test('real uploaded urls are NOT placeholders', () {
      expect(
        ProjectCoverImage.isPlaceholderUrl(
            'https://siedglubjcedkbrpdzgi.supabase.co/storage/v1/object/public/fyp-public-assets/2026/rec/cover.png'),
        isFalse,
      );
      expect(
        ProjectCoverImage.isPlaceholderUrl('https://example.com/cover.webp'),
        isFalse,
      );
    });
  });

  group('ProjectCoverImage widget', () {
    Future<void> _pump(
      WidgetTester tester,
      String? imageUrl, {
      String title = 'AI Health Assistant',
      String category = 'Computer Science',
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 250,
              child: ProjectCoverImage(
                title: title,
                category: category,
                imageUrl: imageUrl,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

  /// Finder for the cover's own CustomPaint (Material injects others).
  Finder _coverPainter() => find
      .descendant(
        of: find.byType(SizedBox),
        matching: find.byType(CustomPaint),
      )
      .first;

    testWidgets('placeholder url renders the generated cover (no network)',
        (tester) async {
      await _pump(tester, 'assets/images/project_placeholder.jpg');
      // Generated content shows the title initials ("AH").
      expect(find.text('AH'), findsOneWidget);
      expect(_coverPainter(), findsOneWidget);
    });

    testWidgets('empty url renders the generated cover', (tester) async {
      await _pump(tester, null);
      expect(find.text('AH'), findsOneWidget);
      expect(_coverPainter(), findsOneWidget);
    });

    testWidgets('different titles produce different initials', (tester) async {
      await _pump(tester, null, title: 'Machine Learning Router');
      expect(find.text('ML'), findsOneWidget);
    });

    testWidgets('single-word title uses the first two letters', (tester) async {
      await _pump(tester, null, title: 'Jelajah');
      expect(find.text('JE'), findsOneWidget);
    });

    testWidgets('different projects paint different seeds (uniqueness)',
        (tester) async {
      // Two titles in the same category should hash to different painter
      // seeds -> distinct geometry even when palettes collide.
      await _pump(tester, null, title: 'Alpha Project One');
      final painter1 =
          tester.widget<CustomPaint>(_coverPainter()).painter;
      await _pump(tester, null, title: 'Beta Project Two');
      final painter2 =
          tester.widget<CustomPaint>(_coverPainter()).painter;
      expect(painter1.hashCode, isNot(painter2.hashCode));
    });
  });
}
