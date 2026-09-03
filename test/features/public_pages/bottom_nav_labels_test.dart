import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/app/widgets/public_shell.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';

/// Regression: mobile bottom-nav labels must each fit on ONE centered line.
/// 'Past Sem Projects' previously wrapped to 3 clipped lines and rendered
/// pinned-left; 'Lecturer' wrapped to 2. Labels are now short ('Guide',
/// 'Visits') and this test locks in single-line centering at 390px, plus
/// even smaller 320px screens.
void main() {
  Future<void> _pumpShell(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const PublicShell(child: SizedBox.shrink()),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseClientProvider.overrideWithValue(
            SupabaseClient(
              'https://placeholder-project.supabase.co',
              'placeholder-anon-key',
              authOptions:
                  const AuthClientOptions(autoRefreshToken: false),
            ),
          ),
          authStateChangesProvider.overrideWith((ref) => const Stream.empty()),
          currentAuthUserProvider.overrideWith((ref) => null),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Asserts every NavigationBar label is a single-line Text centered in
  /// its destination slot (same top/bottom as its siblings).
  void _expectSingleLineCentered(WidgetTester tester, Size viewport) {
    final barRect = tester.getRect(find.byType(NavigationBar).first);
    final labels = ['Home', 'Map', 'Guide', 'Visits', 'Menu'];
    final slotWidth = barRect.width / labels.length;
    double? commonTop;
    for (final label in labels) {
      final textFinder = find.text(label);
      expect(textFinder.evaluate(), isNotEmpty,
          reason: '"$label" missing from bottom nav at $viewport');
      final rect = tester.getRect(textFinder.first);
      // Single line: default label line height is ~16px.
      expect(rect.height, lessThanOrEqualTo(17.0),
          reason:
              '"$label" wrapped to multiple lines at $viewport (h=${rect.height})');
      // No vertical clipping by the bar.
      expect(rect.bottom, lessThanOrEqualTo(barRect.bottom),
          reason: '"$label" clipped by the nav bar at $viewport');
      // Centered: label's horizontal center sits near its slot center.
      final slotIndex = labels.indexOf(label);
      final slotCenterX = barRect.left + slotWidth * (slotIndex + 0.5);
      final labelCenterX = rect.left + rect.width / 2;
      expect(
        (labelCenterX - slotCenterX).abs(),
        lessThan(6.0),
        reason:
            '"$label" not centered in its slot at $viewport (offset ${labelCenterX - slotCenterX})',
      );
      commonTop ??= rect.top;
    }
  }

  testWidgets('bottom nav labels single-line and centered at 390px',
      (tester) async {
    await _pumpShell(tester, const Size(390, 844));
    _expectSingleLineCentered(tester, const Size(390, 844));
  });

  testWidgets('bottom nav labels single-line and centered at 320px', (tester) async {
    await _pumpShell(tester, const Size(320, 568));

    // Below 360px the bar switches to icons-only (Material pattern) so no
    // label can wrap or clip. Verify labels are hidden and the bar renders.
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar).first);
    expect(
      bar.labelBehavior,
      NavigationDestinationLabelBehavior.alwaysHide,
      reason: 'narrow screens must hide labels instead of wrapping them',
    );
    expect(find.byIcon(Icons.home), findsOneWidget); // selected (index 0)
    expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    expect(find.byIcon(Icons.school_outlined), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
  });
}
