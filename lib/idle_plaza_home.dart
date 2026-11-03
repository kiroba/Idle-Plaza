import 'dart:async';
import 'package:flutter/material.dart';
import 'package:omni_core_ui/omni_core_ui.dart' show OmniOta;

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
/// to 24 h per claim) and is saved on this phone. Not built yet: the Arcade
/// games, other skills, and syncing progress to Omni Node.
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
          BottomNavigationBarItem(icon: Icon(Icons.sports_esports_outlined), label: 'Arcade Lounge'),
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E1A47), Color(0xFF1A1A2E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBB86FC).withOpacity(0.3)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome to Halo Plaza', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 8),
              Text(
                'Home of every Omniverse game. Skills keep earning while the app is closed.',
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Plaza Gathering Destinations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        _buildDestinationTile(
          title: 'Arcade Lounge',
          subtitle: 'Mini-games coming soon: Brawler, 9x9 Maze, Janken, Spades',
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
      ],
    );
  }

  Widget _buildArcadeLoungeView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Arcade Lounge Mini-Games', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 6),
        const Text('These games aren\'t in Idle Plaza yet. They\'ll launch from here.', style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildArcadeGameCard('2D Combat Brawler', 'Arena PvP/PvE Action', Icons.sports_mma, const Color(0xFFFF5252)),
            _buildArcadeGameCard('9x9 Cube Survival', 'Procedural Maze Escape', Icons.grid_4x4, const Color(0xFFFF4081)),
            _buildArcadeGameCard('Janken Markov AI', 'Adaptive RPSLS AI', Icons.psychology, const Color(0xFFE040FB)),
            _buildArcadeGameCard('Spades Lounge', 'Casual Card Strategy', Icons.style, const Color(0xFF7C4DFF)),
          ],
        ),
      ],
    );
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

  Widget _buildArcadeGameCard(String title, String subtitle, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _snack('$title is coming soon to Idle Plaza.', color),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 36, color: color.withOpacity(0.6)),
                const SizedBox(height: 8),
                Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 6),
                const Text('COMING SOON', style: TextStyle(fontSize: 9, letterSpacing: 1.2, color: Colors.orangeAccent)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
