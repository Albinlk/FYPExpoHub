import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/layout/responsive.dart';
import 'package:fyp_expo_hub/core/widgets/admin_actions.dart';
import 'package:fyp_expo_hub/core/widgets/app_dialog.dart';
import 'package:fyp_expo_hub/core/widgets/async_state.dart';
import 'package:fyp_expo_hub/core/widgets/busy_button.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('friendlyError', () {
    test('network failures get a next step', () {
      expect(
        friendlyError(Exception('ClientException: Failed to fetch')),
        'Could not reach the server. Check your connection and try again.',
      );
    });

    test('strips the Exception prefix', () {
      expect(friendlyError(Exception('Form not found')), 'Form not found');
    });
  });

  group('AsyncValueUi.whenUi', () {
    testWidgets('loading shows a spinner, not data', (tester) async {
      await tester.pumpWidget(_host(
        const AsyncLoading<List<int>>().whenUi(
          data: (d) => Text('rows ${d.length}'),
          onRetry: () {},
        ),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.textContaining('rows'), findsNothing);
    });

    testWidgets('error hides the raw exception and retries', (tester) async {
      var retried = 0;
      await tester.pumpWidget(_host(
        AsyncError<List<int>>(Exception('PostgrestException(boom)'), StackTrace.empty).whenUi(
          data: (d) => Text('rows ${d.length}'),
          onRetry: () => retried++,
          what: 'the audit log',
        ),
      ));
      expect(find.text("Couldn't load the audit log."), findsOneWidget);
      expect(find.textContaining('Exception:'), findsNothing);
      await tester.tap(find.text('Try Again'));
      expect(retried, 1);
    });

    testWidgets('data renders the builder', (tester) async {
      await tester.pumpWidget(_host(
        const AsyncData<List<int>>([1, 2]).whenUi(
          data: (d) => Text('rows ${d.length}'),
          onRetry: () {},
        ),
      ));
      expect(find.text('rows 2'), findsOneWidget);
    });
  });

  group('BusyButton', () {
    testWidgets('is disabled while busy and keeps a label', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_host(
        BusyButton(label: 'Save', busy: true, onPressed: () => taps++),
      ));
      expect(find.text('Save…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(FilledButton));
      expect(taps, 0);
    });

    testWidgets('fires when idle', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_host(
        BusyButton(label: 'Save', busy: false, onPressed: () => taps++),
      ));
      await tester.tap(find.text('Save'));
      expect(taps, 1);
    });
  });

  group('showFormDialog', () {
    testWidgets('outside tap does not close; dirty back asks to discard', (tester) async {
      var dirty = true;
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showFormDialog<void>(
                context: context,
                isDirty: () => dirty,
                builder: (_) => const AlertDialog(content: Text('form')),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('form'), findsOneWidget);

      await tester.tapAt(const Offset(2, 2));
      await tester.pumpAndSettle();
      expect(find.text('form'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Discard Changes?'), findsOneWidget);

      await tester.tap(find.text('Keep Editing'));
      await tester.pumpAndSettle();
      expect(find.text('form'), findsOneWidget);

      dirty = false;
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('form'), findsNothing);
    });
  });

  group('responsive', () {
    testWidgets('Breakpoints and dialogWidth follow the screen width', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      late BuildContext captured;
      Future<void> pumpAt(double width) async {
        tester.view.physicalSize = Size(width, 800);
        await tester.pumpWidget(MaterialApp(
          home: Builder(builder: (c) {
            captured = c;
            return const SizedBox();
          }),
        ));
      }

      await pumpAt(360);
      expect(Breakpoints.isCompact(captured), isTrue);
      expect(Breakpoints.isNarrow(captured), isTrue);
      expect(dialogWidth(captured, 620), 264);

      await pumpAt(1280);
      expect(Breakpoints.isDesktop(captured), isTrue);
      expect(Breakpoints.isWide(captured), isTrue);
      expect(dialogWidth(captured, 620), 620);
    });
  });

  testWidgets('confirmAction destructive styles the confirm button', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => confirmAction(
            context,
            title: 'Remove?',
            message: 'Gone for good.',
            confirmLabel: 'Remove',
            destructive: true,
          ),
          child: const Text('go'),
        ),
      ),
    ));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    final button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Remove'));
    expect(button.style?.backgroundColor?.resolve({}), isNotNull);
  });
}
