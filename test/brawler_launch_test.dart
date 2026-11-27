import 'package:flutter_test/flutter_test.dart';
import 'package:idle_plaza/src/brawler_launch.dart';
import 'package:url_launcher/url_launcher.dart';

class _FakeIntent implements BrawlerIntent {
  _FakeIntent({
    this.resolves = true,
    this.throwOnResolve = false,
    this.throwOnLaunch = false,
  });

  final bool resolves;
  final bool throwOnResolve;
  final bool throwOnLaunch;
  int launchCalls = 0;

  @override
  Future<bool> canResolveActivity() async {
    if (throwOnResolve) throw StateError('resolve failed');
    return resolves;
  }

  @override
  Future<void> launch() async {
    if (throwOnLaunch) throw StateError('launch failed');
    launchCalls++;
  }
}

void main() {
  group('Brawler launch constants', () {
    test('package name is the Brawler repo applicationId', () {
      // Read from Plaza-Brawler android/app/build.gradle + AndroidManifest.
      expect(brawlerAndroidPackage, 'com.omniverse.plazabrawler');
    });

    test('tester page is the Omniverse tester page', () {
      expect(testerPageUri.toString(), 'https://kiroba.github.io/The-Omniverse/');
    });
  });

  group('BrawlerLauncher.openBrawler', () {
    test('installed Brawler launches once', () async {
      final intent = _FakeIntent(resolves: true);
      final launcher = BrawlerLauncher(intentFactory: () => intent);
      expect(await launcher.openBrawler(), BrawlerLaunchResult.launched);
      expect(intent.launchCalls, 1);
    });

    test('missing Brawler reports notInstalled and never launches', () async {
      final intent = _FakeIntent(resolves: false);
      final launcher = BrawlerLauncher(intentFactory: () => intent);
      expect(await launcher.openBrawler(), BrawlerLaunchResult.notInstalled);
      expect(intent.launchCalls, 0);
    });

    test('a resolve failure reports notInstalled and never launches',
        () async {
      final intent = _FakeIntent(throwOnResolve: true);
      final launcher = BrawlerLauncher(intentFactory: () => intent);
      expect(await launcher.openBrawler(), BrawlerLaunchResult.notInstalled);
      expect(intent.launchCalls, 0);
    });

    test('a launch failure reports notInstalled', () async {
      final intent = _FakeIntent(throwOnLaunch: true);
      final launcher = BrawlerLauncher(intentFactory: () => intent);
      expect(await launcher.openBrawler(), BrawlerLaunchResult.notInstalled);
      expect(intent.launchCalls, 0);
    });
  });

  group('BrawlerLauncher.openTesterPage', () {
    test('opens the tester page in an external browser', () async {
      Uri? openedUri;
      LaunchMode? openedMode;
      final launcher = BrawlerLauncher(
        openUrl: (uri, {mode = LaunchMode.platformDefault}) async {
          openedUri = uri;
          openedMode = mode;
          return true;
        },
      );
      expect(await launcher.openTesterPage(), isTrue);
      expect(openedUri, testerPageUri);
      expect(openedMode, LaunchMode.externalApplication);
    });

    test('a failed open reports false', () async {
      final launcher = BrawlerLauncher(
        openUrl: (uri, {mode = LaunchMode.platformDefault}) async {
          throw StateError('no browser');
        },
      );
      expect(await launcher.openTesterPage(), isFalse);
    });
  });
}
