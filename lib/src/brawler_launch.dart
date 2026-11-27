import 'package:android_intent_plus/android_intent.dart';
import 'package:url_launcher/url_launcher.dart';

/// ============================================================================
/// BRAWLER LAUNCH WIRING — the Arcade cabinet opens the game
/// ============================================================================
/// Tapping the OmniBrawler cabinet (Cabinet 01, PLAYABLE) launches the
/// installed Brawler app. The Brawler runs from its own app build — the
/// Plaza never embeds it — so this is a cross-app launch, not a game load.
///
/// Mechanism (verified in code, not guessed): an explicit Android intent
/// for the Brawler's launcher activity. The Brawler's package name comes
/// from its own repo (android/app/build.gradle + AndroidManifest.xml):
/// `com.omniverse.plazabrawler`, MainActivity with ACTION_MAIN +
/// CATEGORY_LAUNCHER, exported. It declares NO deep-link intent filter,
/// so there is no custom scheme to open with url_launcher — the intent
/// for the package is the only way in.
///
/// Install check: `canResolveActivity()` on that intent. On Android 11+
/// that only sees the Brawler because Idle-Plaza's AndroidManifest.xml
/// declares it under `<queries>` — without that entry the check would
/// always report "not installed" even when the game is there.
///
/// If the Brawler is not installed, we do NOT pretend it launched: the
/// caller shows the fallback sheet (install from the tester page) instead.
/// Any failure to resolve or launch lands in the same fallback — the
/// Plaza never claims a launch it did not see succeed.
/// ============================================================================

/// The Brawler's Android package name — read from the Plaza-Brawler repo,
/// never guessed.
const String brawlerAndroidPackage = 'com.omniverse.plazabrawler';

/// Where the Brawler app build lives: the Omniverse tester page, verified
/// live (the Brawler is step 5 there, served from the latest release).
final Uri testerPageUri =
    Uri.parse('https://kiroba.github.io/The-Omniverse/');

/// What tapping Play did.
enum BrawlerLaunchResult {
  /// The Brawler's launcher activity opened.
  launched,

  /// No Brawler to open — not installed (or the launch itself failed).
  /// The caller must show the install fallback, never claim a launch.
  notInstalled,
}

/// The one Android-intent operation the launcher needs, behind an
/// interface so tests can fake it without the plugin.
abstract class BrawlerIntent {
  Future<bool> canResolveActivity();
  Future<void> launch();
}

class _AndroidBrawlerIntent implements BrawlerIntent {
  _AndroidBrawlerIntent()
      : _intent = AndroidIntent(
          action: 'android.intent.action.MAIN',
          category: 'android.intent.category.LAUNCHER',
          package: brawlerAndroidPackage,
        );

  final AndroidIntent _intent;

  @override
  // The plugin returns a nullable bool; a null answer is a "no".
  Future<bool> canResolveActivity() async =>
      await _intent.canResolveActivity() ?? false;

  @override
  Future<void> launch() => _intent.launch();
}

/// Opens the installed Brawler, or reports that there is none to open.
class BrawlerLauncher {
  BrawlerLauncher({
    BrawlerIntent Function()? intentFactory,
    Future<bool> Function(Uri uri, {LaunchMode mode})? openUrl,
  })  : _intentFactory =
            intentFactory ?? (() => _AndroidBrawlerIntent()),
        _openUrl = openUrl ??
            ((uri, {mode = LaunchMode.platformDefault}) =>
                launchUrl(uri, mode: mode));

  final BrawlerIntent Function() _intentFactory;
  final Future<bool> Function(Uri uri, {LaunchMode mode}) _openUrl;

  /// Try to open the Brawler. Returns [BrawlerLaunchResult.launched]
  /// only when the launcher activity actually opened.
  Future<BrawlerLaunchResult> openBrawler() async {
    try {
      final intent = _intentFactory();
      if (!await intent.canResolveActivity()) {
        return BrawlerLaunchResult.notInstalled;
      }
      await intent.launch();
      return BrawlerLaunchResult.launched;
    } catch (_) {
      // A failed resolve or a failed launch is the same outcome for the
      // user: no Brawler opened. The fallback sheet says so honestly.
      return BrawlerLaunchResult.notInstalled;
    }
  }

  /// Open the tester page in the browser, where the Brawler APK lives.
  /// Returns false when the link could not be opened.
  Future<bool> openTesterPage() async {
    try {
      return await _openUrl(testerPageUri,
          mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
