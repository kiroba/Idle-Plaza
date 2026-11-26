import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:omni_core_ui/omni_core_ui.dart' show OmniOta;

import 'plaza_scene_screen.dart';
import 'src/arcade_scene_image.dart';
import 'src/arcade_store.dart';
import 'src/plaza_foundations.dart';
import 'src/idle_engine.dart';
import 'src/idle_store.dart';

/// ============================================================================
/// IDLE PLAZA (embeddable root screen)
/// ============================================================================
/// The Plaza hub, Arcade Lounge and RPG Idle Realm. This widget has no
/// MaterialApp of its own, so the Omni-Hub can host it as the Idle Plaza
/// container; lib/main.dart is only a thin standalone wrapper.
///
/// Real today: Mining accrues by wall clock (also while the app is closed, up
/// to 24 h per claim) and is saved on this phone. The Arcade is the Plaza's
/// first store (ground level, Avenue 1): the Brawler cabinet stands first —
/// the game itself still runs from its own app build — and 9x9 second, in
/// design. Not built yet: other skills, launch wiring, and syncing progress
/// to Omni Node.
/// ============================================================================

const String _miningKey = 'skill.mining';

class IdlePlazaHome extends StatefulWidget {
  const IdlePlazaHome({super.key});

  @override
  State<IdlePlazaHome> createState() => _IdlePlazaHomeState();
}

class _IdlePlazaHomeState extends State<IdlePlazaHome> with WidgetsBindingObserver {
  int _currentZoneIndex = 0; // 0: Plaza Hub, 1: Arcade Lounge, 2: RPG Idle Realm

  final IdleStore _store = IdleStore();
  SkillState _mining = SkillState(skill: 'mining');
  bool _loaded = false;
  Timer? _ticker;

  int _now() => DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  Future<void> _load() async {
    await _store.open();
    final s = SkillState.decode(await _store.read(_miningKey));
    final away = IdleEngine.claim(s, _now());
    if (!mounted) return;
    setState(() {
      _mining = s;
      _loaded = true;
    });
    await _save();
    _syncTicker();
    _reportAway(away);
  }

  Future<void> _save() => _store.write(_miningKey, _mining.encode());

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_loaded) return;
    if (state == AppLifecycleState.resumed) {
      final away = IdleEngine.claim(_mining, _now());
      setState(() {});
      _save();
      _syncTicker();
      _reportAway(away);
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _ticker?.cancel();
      _ticker = null;
      IdleEngine.claim(_mining, _now());
      _save();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }

  /// A foreground ticker only refreshes the screen; the wall clock decides XP.
  void _syncTicker() {
    _ticker?.cancel();
    _ticker = null;
    if (!_mining.active) return;
    _ticker = Timer.periodic(const Duration(milliseconds: tickMs), (_) {
      if (!mounted) return;
      final a = IdleEngine.claim(_mining, _now());
      if (a.isEmpty) return;
      setState(() {});
      _save();
      if (a.levelsGained > 0) _snack('LEVEL UP! Mining is now Level ${_mining.level}', const Color(0xFF03DAC6));
    });
  }

  void _reportAway(Accrual a) {
    // Only for real time away, not the few seconds a screen switch takes.
    if (a.isEmpty || a.countedMs < 60 * 1000) return;
    final lv = a.levelsGained > 0 ? ' and ${a.levelsGained} level${a.levelsGained == 1 ? '' : 's'}' : '';
    final cap = a.capped ? ' (24 h max per visit)' : '';
    _snack('While you were away: mined ${formatDuration(a.countedMs)}, +${a.xpGained} XP$lv$cap', const Color(0xFF6200EE));
  }

  void _snack(String text, Color color) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(text), backgroundColor: color));
    });
  }

  void _toggleMining() {
    final now = _now();
    setState(() {
      if (_mining.active) {
        final a = IdleEngine.stop(_mining, now);
        if (a.levelsGained > 0) _snack('LEVEL UP! Mining is now Level ${_mining.level}', const Color(0xFF03DAC6));
      } else {
        IdleEngine.start(_mining, now);
      }
    });
    _save();
    _syncTicker();
  }

  @override
  Widget build(BuildContext context) {
    final saved = !_loaded || _store.isPersistent;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Idle Plaza', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(
              saved ? 'Progress saved on this phone' : 'Progress not saved (storage unavailable)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: saved ? const Color(0xFF03DAC6) : Colors.orangeAccent, fontSize: 11),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF16162A),
        elevation: 2,
        actions: [
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (value) {
              if (value == 'check_updates') OmniOta.checkAndPrompt(context);
            },
            itemBuilder: (_) => const [
              PopupMenuItem<String>(
                value: 'check_updates',
                child: ListTile(
                  leading: Icon(Icons.system_update),
                  title: Text('Check for updates'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildCurrentZoneView(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentZoneIndex,
        backgroundColor: const Color(0xFF16162A),
        selectedItemColor: const Color(0xFFBB86FC),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentZoneIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.location_city_outlined), label: 'Plaza Hub'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_esports_outlined), label: 'The Arcade'),
          BottomNavigationBarItem(icon: Icon(Icons.shield_outlined), label: 'RPG Idle Realm'),
        ],
      ),
    );
  }

  Widget _buildCurrentZoneView() {
    switch (_currentZoneIndex) {
      case 1:
        return _buildArcadeLoungeView();
      case 2:
        return _buildRpgIdleRealmView();
      case 0:
      default:
        return _buildPlazaHubView();
    }
  }

  Widget _buildPlazaHubView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSceneCard(
          image: AssetImage(plazaSceneAsset.assetPath),
          title: 'Welcome to Halo Plaza',
          subtitle: 'Home of every Omniverse game. Skills keep earning while the app is closed.',
        ),
        const SizedBox(height: 20),
        const Text('Plaza Gathering Destinations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        _buildDestinationTile(
          title: 'The Arcade',
          subtitle: 'The Plaza\'s first store — Brawler here, 9x9 in design',
          icon: Icons.sports_esports,
          color: const Color(0xFFBB86FC),
          onTap: () => setState(() => _currentZoneIndex = 1),
        ),
        _buildDestinationTile(
          title: 'RPG Idle Realm',
          subtitle: _mining.active ? 'Mining Lv ${_mining.level}, earning now' : 'Mining Lv ${_mining.level} (more skills coming)',
          icon: Icons.fort_outlined,
          color: const Color(0xFF03DAC6),
          onTap: () => setState(() => _currentZoneIndex = 2),
        ),
        _buildDestinationTile(
          title: 'Plaza Foundations',
          subtitle: 'Low-poly scene, figures & companions — baked renders',
          icon: Icons.landscape_outlined,
          color: const Color(0xFFFFB74D),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PlazaSceneScreen()),
          ),
        ),
      ],
    );
  }

  /// A place card: a baked scene render on top, caption below — the same
  /// language as the Plaza Foundations live stage. The render is what makes
  /// a screen read as a place instead of a list of text cards.
  Widget _buildSceneCard({
    required ImageProvider image,
    required String title,
    required String subtitle,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Image(
              image: image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF1A1A2E),
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image_outlined,
                    color: Colors.grey, size: 32),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 8),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The Arcade — the Plaza's first storefront. Its cabinets come from
  /// [arcadeStorefront], in floor order: the Brawler first (nearly complete,
  /// actually here), 9x9 second (in design), Janken and Spades behind them.
  Widget _buildArcadeLoungeView() {
    final storefront = arcadeStorefront;
    final cabinets = storefront.cabinets;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSceneCard(
          image: MemoryImage(base64Decode(arcadeStorefrontJpegBase64)),
          title: storefront.name,
          subtitle: "The Plaza's first store — ${storefront.placement}. "
              'Cabinet 01 is the Brawler, nearly complete and actually '
              'here. Cabinet 02 is 9x9, in design.',
        ),
        const SizedBox(height: 20),
        const Text('Cabinets',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 12),
        _buildArcadeCabinetCard(cabinets[0], number: 1),
        _buildArcadeCabinetCard(cabinets[1], number: 2),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildArcadeCabinetCard(cabinets[2], number: 3)),
            const SizedBox(width: 12),
            Expanded(child: _buildArcadeCabinetCard(cabinets[3], number: 4)),
          ],
        ),
      ],
    );
  }

  Widget _buildArcadeCabinetCard(ArcadeCabinet cabinet,
      {required int number}) {
    final color = _arcadeCabinetColor(cabinet.id);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showCabinetSheet(cabinet, number: number),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.2),
                child: Icon(_arcadeCabinetIcon(cabinet.id), color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CABINET ${number.toString().padLeft(2, '0')} · ${cabinet.status.label}',
                      style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.2,
                          color: color,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(cabinet.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(cabinet.tagline,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Color _arcadeCabinetColor(String cabinetId) => switch (cabinetId) {
        'brawler' => const Color(0xFFFF5252),
        'nine-by-nine' => const Color(0xFFFF4081),
        'janken' => const Color(0xFFE040FB),
        'spades' => const Color(0xFF7C4DFF),
        _ => const Color(0xFFBB86FC),
      };

  IconData _arcadeCabinetIcon(String cabinetId) => switch (cabinetId) {
        'brawler' => Icons.sports_mma,
        'nine-by-nine' => Icons.grid_4x4,
        'janken' => Icons.psychology,
        'spades' => Icons.style,
        _ => Icons.sports_esports,
      };

  void _showCabinetSheet(ArcadeCabinet cabinet, {required int number}) {
    showModalBottomSheet<void>(
      context: context,
      // Scroll-controlled so tall sheets scroll instead of overflowing.
      // useSafeArea only covers the top/left/right — the bottom needs the
      // explicit SafeArea below, or the sheet runs to the bottom edge of
      // the screen and its last lines sit behind the Android system
      // navigation bar, unreadable.
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          shrinkWrap: true,
          children: [
            Text(
              'CABINET ${number.toString().padLeft(2, '0')} · ${cabinet.status.label}',
              style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.2,
                  color: _arcadeCabinetColor(cabinet.id),
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(cabinet.name,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(cabinet.tagline,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 16),
            for (final detail in cabinet.details)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  ',
                        style: TextStyle(color: Colors.grey)),
                    Expanded(
                      child: Text(detail,
                          style: const TextStyle(
                              fontSize: 13, height: 1.4)),
                    ),
                  ],
                ),
              ),
            if (cabinet.id == 'brawler') ..._buildBrawlerSheetSections(),
            if (cabinet.id == 'nine-by-nine')
              ..._buildNineByNineSheetSections(),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildBrawlerSheetSections() {
    return [
      const SizedBox(height: 8),
      const Text('The roster — 12 fighters',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      for (final element in BrawlerElement.values)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            '${element.label}: ${brawlerFighters.where((f) => f.element == element).map((f) => f.sign).join(', ')}',
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
      const SizedBox(height: 8),
      Text(
        'Boss: $brawlerBossSign, the 13th sign — unplayable by design. '
        'Beat all 12 fighters plus $brawlerBossSign to unlock the secret character.',
        style: const TextStyle(fontSize: 13, height: 1.4),
      ),
    ];
  }

  List<Widget> _buildNineByNineSheetSections() {
    return [
      const SizedBox(height: 8),
      const Text('The design so far',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(
        '${NineByNineDesign.genre}. ${NineByNineDesign.structurePerSide} rooms per side, '
        '${NineByNineDesign.shellCount} shells, ${NineByNineDesign.heartRoomCount} heart rooms. '
        'Escape is a ${NineByNineDesign.escapeRule.toLowerCase()} — stay in the correct room until the exit opens.',
        style: const TextStyle(fontSize: 13, height: 1.4),
      ),
      const SizedBox(height: 8),
      Text(
        'Modes: ${NineByNineDesign.modes.join(', ')}. First- or third-person — your call.',
        style: const TextStyle(fontSize: 13, height: 1.4),
      ),
      const SizedBox(height: 8),
      Text(
        'A run: ${NineByNineDesign.runFlowBeats.join(' → ')}.',
        style: const TextStyle(fontSize: 13, height: 1.4),
      ),
    ];
  }

  Widget _buildRpgIdleRealmView() {
    final need = xpToNext(_mining.level);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RPG Idle Realm - Skilling Hub', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          const Text('Start a task and close the app. It keeps earning for up to 24 h.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Row(
                          children: [
                            Icon(Icons.hardware, color: Color(0xFF03DAC6)),
                            SizedBox(width: 8),
                            Flexible(child: Text('Mining Skill', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      Text('Level ${_mining.level}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF03DAC6))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (_mining.exp / need).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[800],
                    color: const Color(0xFF03DAC6),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text('EXP: ${_mining.exp} / $need  •  $xpPerTick XP every ${tickMs ~/ 1000} s',
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loaded ? _toggleMining : null,
                      icon: Icon(_mining.active ? Icons.pause : Icons.play_arrow),
                      label: Text(_mining.active ? 'Pause Mining' : 'Start Mining Task'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _mining.active ? Colors.redAccent : const Color(0xFF6200EE),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

}
