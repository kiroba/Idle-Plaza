import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idle_plaza/idle_plaza_home.dart';
import 'package:idle_plaza/plaza_scene_screen.dart';
import 'package:idle_plaza/src/plaza_foundations.dart';

/// Phone-sized viewport checks for the two findings from Kiro's Nov 25
/// phone test: the cabinet detail sheets ran behind the Android system
/// nav bar, and the Arcade screen and hub had no visual anchor.
///
/// The viewport is 360x800 logical (1080x2400 physical at 3.0 dpr) with a
/// 48-logical-pixel system nav bar at the bottom — the shape of the phone
/// the screenshots came from.
void main() {
  void setPhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    // FakeViewPadding takes physical pixels: 48 logical * 3.0.
    tester.view.viewPadding = const FakeViewPadding(bottom: 144);
    tester.view.padding = const FakeViewPadding(bottom: 144);
    addTearDown(tester.view.reset);
  }

  Future<void> openArcadeTab(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: IdlePlazaHome()));
    await tester.pumpAndSettle();
    // Two 'The Arcade' texts: the hub tile and the bottom-nav label.
    await tester.tap(find.text('The Arcade').last);
    await tester.pumpAndSettle();
  }

  testWidgets('Arcade screen shows the storefront scene render',
      (tester) async {
    setPhoneViewport(tester);
    await openArcadeTab(tester);
    // The storefront scene is embedded as base64 (see
    // lib/src/arcade_scene_image.dart), so it arrives as a MemoryImage.
    expect(
      find.byWidgetPredicate(
          (w) => w is Image && w.image is MemoryImage),
      findsOneWidget,
    );
  });

  testWidgets('hub shows the Plaza scene render', (tester) async {
    setPhoneViewport(tester);
    await tester.pumpWidget(const MaterialApp(home: IdlePlazaHome()));
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((w) =>
          w is Image &&
          w.image is AssetImage &&
          (w.image as AssetImage).assetName == plazaSceneAsset.assetPath),
      findsOneWidget,
    );
  });

  testWidgets('Brawler sheet last line clears the system nav bar',
      (tester) async {
    setPhoneViewport(tester);
    await openArcadeTab(tester);
    await tester.scrollUntilVisible(find.text('OmniBrawler'), 200);
    await tester.tap(find.text('OmniBrawler'));
    await tester.pumpAndSettle();
    // Exact text: textContaining also matches the Text's inner RichText.
    final lastLine = find.text(
      'Boss: Ophiuchus, the 13th sign — unplayable by design. '
      'Beat all 12 fighters plus Ophiuchus to unlock the secret character.',
    );
    // The sheet is the topmost scrollable; the Arcade list sits behind it.
    await tester.scrollUntilVisible(lastLine, 200,
        scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    final rect = tester.getRect(lastLine);
    // Logical viewport is 800 tall; the nav bar takes the bottom 48.
    expect(rect.bottom, lessThanOrEqualTo(800 - 48));
  });

  testWidgets('9x9 sheet last line clears the system nav bar',
      (tester) async {
    setPhoneViewport(tester);
    await openArcadeTab(tester);
    await tester.scrollUntilVisible(find.text('9x9'), 200);
    await tester.tap(find.text('9x9'));
    await tester.pumpAndSettle();
    final lastLine =
        find.text('A run: Waking → Descent → Learning → Deep → Heart → Leaving.');
    // The sheet is the topmost scrollable; the Arcade list sits behind it.
    await tester.scrollUntilVisible(lastLine, 200,
        scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    final rect = tester.getRect(lastLine);
    expect(rect.bottom, lessThanOrEqualTo(800 - 48));
  });

  testWidgets('Foundations list bottom padding clears the nav bar',
      (tester) async {
    setPhoneViewport(tester);
    await tester.pumpWidget(
      const MaterialApp(home: PlazaSceneScreen()),
    );
    await tester.pump();
    final listView = tester.widget<ListView>(find.byType(ListView).first);
    final padding = listView.padding as EdgeInsets;
    expect(padding.bottom, 16 + 48);
  });
}
