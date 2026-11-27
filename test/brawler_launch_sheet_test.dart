import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idle_plaza/idle_plaza_home.dart';
import 'package:idle_plaza/src/brawler_launch.dart';
import 'package:url_launcher/url_launcher.dart';

/// Widget checks for the Brawler launch wiring: Play on the Brawler
/// cabinet opens the installed game, and shows the install fallback
/// (never a fake launch) when the Brawler is not on the phone. The
/// 9x9 and coming-soon cabinets get no Play button at all.
///
/// Same phone-sized viewport as the sheet safe-area tests: 360x800
/// logical (1080x2400 physical at 3.0 dpr) with a 48-logical-pixel
/// system nav bar at the bottom.
void main() {
  void setPhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    tester.view.viewPadding = const FakeViewPadding(bottom: 144);
    tester.view.padding = const FakeViewPadding(bottom: 144);
    addTearDown(tester.view.reset);
  }

  Future<void> openArcadeTab(
      WidgetTester tester, BrawlerLauncher launcher) async {
    await tester.pumpWidget(
        MaterialApp(home: IdlePlazaHome(brawlerLauncher: launcher)));
    await tester.pumpAndSettle();
    // Two 'The Arcade' texts: the hub tile and the bottom-nav label.
    await tester.tap(find.text('The Arcade').last);
    await tester.pumpAndSettle();
  }

  Future<void> openCabinetSheet(WidgetTester tester, String name) async {
    await tester.scrollUntilVisible(find.text(name), 200);
    // scrollUntilVisible can leave a bottom-row card half below the
    // fold, where the tap would miss: make it fully visible first.
    await tester.ensureVisible(find.text(name));
    await tester.pumpAndSettle();
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  Future<void> tapPlayButton(WidgetTester tester) async {
    // The Play button sits at the bottom of the Brawler sheet.
    await tester.scrollUntilVisible(find.text('Play OmniBrawler'), 200,
        scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('Play OmniBrawler'));
    await tester.pumpAndSettle();
  }

  BrawlerLauncher fakeLauncher({
    required bool installed,
    required void Function(Uri uri, LaunchMode mode) onOpenUrl,
  }) {
    return BrawlerLauncher(
      intentFactory: () => _FakeIntent(resolves: installed),
      openUrl: (uri, {mode = LaunchMode.platformDefault}) async {
        onOpenUrl(uri, mode);
        return true;
      },
    );
  }

  const bossLine = 'Boss: Ophiuchus, the 13th sign — unplayable by design. '
      'Beat all 12 fighters plus Ophiuchus to unlock the secret character.';

  testWidgets('Play with the Brawler installed opens it, no fallback',
      (tester) async {
    setPhoneViewport(tester);
    var urlOpened = false;
    final launcher = fakeLauncher(
      installed: true,
      onOpenUrl: (_, __) => urlOpened = true,
    );
    await openArcadeTab(tester, launcher);
    await openCabinetSheet(tester, 'OmniBrawler');
    await tapPlayButton(tester);
    // The cabinet sheet closed (the game took over) and no fallback
    // sheet appeared — the Plaza never shows "not installed" for a
    // launch that succeeded.
    expect(find.text("OmniBrawler isn't installed"), findsNothing);
    expect(find.text(bossLine), findsNothing);
    expect(urlOpened, isFalse);
  });

  testWidgets('Play without the Brawler shows the install fallback',
      (tester) async {
    setPhoneViewport(tester);
    Uri? openedUri;
    LaunchMode? openedMode;
    final launcher = fakeLauncher(
      installed: false,
      onOpenUrl: (uri, mode) {
        openedUri = uri;
        openedMode = mode;
      },
    );
    await openArcadeTab(tester, launcher);
    await openCabinetSheet(tester, 'OmniBrawler');
    await tapPlayButton(tester);
    expect(find.text("OmniBrawler isn't installed"), findsOneWidget);
    expect(find.text('Open tester page'), findsOneWidget);
    await tester.tap(find.text('Open tester page'));
    await tester.pumpAndSettle();
    expect(openedUri, testerPageUri);
    expect(openedMode, LaunchMode.externalApplication);
  });

  // One test per cabinet: an open cabinet sheet lingers in the tree
  // across re-pumps, so each cabinet gets its own fresh test.
  for (final name in ['9x9', 'Janken Markov AI', 'Spades Lounge']) {
    testWidgets('$name cabinet has no Play button', (tester) async {
      setPhoneViewport(tester);
      final launcher = fakeLauncher(installed: true, onOpenUrl: (_, __) {});
      await openArcadeTab(tester, launcher);
      await openCabinetSheet(tester, name);
      expect(find.text('Play OmniBrawler'), findsNothing);
    });
  }
}

class _FakeIntent implements BrawlerIntent {
  _FakeIntent({required this.resolves});

  final bool resolves;

  @override
  Future<bool> canResolveActivity() async => resolves;

  @override
  Future<void> launch() async {}
}
