import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'src/plaza_foundations.dart';
import 'src/plaza_live.dart';

/// ============================================================================
/// PLAZA FOUNDATIONS SCREEN — with the LIVE PLAZA STAGE
/// ============================================================================
/// The top card is a live composite, not a single baked image: the
/// no-animals Plaza backdrop render (plazaSceneAsset) with animal sprites
/// from the catalog roster (plazaAnimals) laid over it at their spots.
/// Animals idle-animate from their shipped idle frames and rotate in and
/// out on a timer (src/plaza_live.dart decides who is present). Over the
/// backdrop, a gentle colour drift runs under a day/night tint that follows
/// the device clock — dawn, day, dusk, night — cross-fading as the real
/// day turns, with lamp glow at night.
///
/// It is still NOT a live 3D view: the backdrop is one baked render and the
/// animals are 2D sprites, and the caption on the stage says so. Below the
/// stage, the catalog sections show the same foundations as individual
/// renders and sprites.
/// ============================================================================

class PlazaSceneScreen extends StatefulWidget {
  const PlazaSceneScreen({super.key});

  @override
  State<PlazaSceneScreen> createState() => _PlazaSceneScreenState();
}

class _PlazaSceneScreenState extends State<PlazaSceneScreen> {
  final Random _rng = Random();
  late PlazaPhase _phase;
  late List<String> _presentIds;

  /// Master tick: +1 every 125 ms. Drives the idle frames (one sampled
  /// frame per 2 ticks = the source idle's original tempo) and the slow
  /// colour drift (hue advances 2°/s, a full cycle in 3 minutes).
  int _tick = 0;

  Timer? _ticker;
  Timer? _rotationTimer;
  Timer? _phaseTimer;

  static final Map<String, int> _rosterIndex = {
    for (var i = 0; i < plazaAnimals.length; i++) plazaAnimals[i].id: i,
  };

  @override
  void initState() {
    super.initState();
    _phase = phaseForTime(DateTime.now());
    _presentIds =
        initialPresence(plazaAnimals.map((a) => a.id).toList(), _rng);
    _ticker = Timer.periodic(const Duration(milliseconds: 125), (_) {
      if (!mounted) return;
      setState(() => _tick++);
    });
    _rotationTimer = Timer.periodic(
        const Duration(seconds: plazaRotationIntervalSeconds), (_) {
      if (!mounted) return;
      setState(() {
        _presentIds = rotatePresence(
            _presentIds, plazaAnimals.map((a) => a.id).toList(), _rng);
      });
    });
    _phaseTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      final next = phaseForTime(DateTime.now());
      if (next != _phase) setState(() => _phase = next);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _rotationTimer?.cancel();
    _phaseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Plaza Foundations',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF16162A),
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLiveStageCard(),
          const SizedBox(height: 20),
          _buildSection('Figures — Base #3 Soft', plazaFigureAssets),
          const SizedBox(height: 20),
          _buildSection('Companions — Sets #1 + #2', plazaCompanionAssets),
          const SizedBox(height: 20),
          _buildSection('Scenery — Set #1 Pieces', plazaSceneryAssets),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Live stage
  // --------------------------------------------------------------------------

  Widget _buildLiveStageCard() {
    return Card(
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLiveStage(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('The Plaza, live',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(height: 6),
                Text(
                  'This stage is composited live in the app: a baked backdrop render with animal sprites laid over it. '
                  'The animals rotate in and out and idle in place, the colours drift gently, and the light follows your '
                  'device clock — dawn, day, dusk and night tints change as the real day does. It is not a live 3D view; '
                  'the pieces below are the same foundations as individual renders and sprites.',
                  style:
                      TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStage() {
    final visual = plazaPhaseVisuals[_phase]!;
    final phaseColor =
        Color(visual.tintArgb).withAlpha((visual.opacity * 255).round());
    // Hue drifts 2° per second of ticks (0.25° per 125 ms tick).
    final hue = (_tick * 0.25) % 360.0;
    final driftColor =
        HSVColor.fromAHSV(0.07, hue, 0.55, 1.0).toColor();

    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final s = constraints.maxWidth;
          return Stack(
            fit: StackFit.expand,
            children: [
              // (1) Backdrop — the no-animals baked render.
              Image.asset(
                plazaSceneAsset.assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1A1A2E),
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined,
                      color: Colors.grey, size: 32),
                ),
              ),
              // (2) Colour drift — a slow, subtle hue cycle.
              Container(color: driftColor),
              // (3) Day/night phase tint, cross-fading on phase change.
              AnimatedContainer(
                duration: const Duration(milliseconds: 1500),
                color: phaseColor,
              ),
              // (4) Lamp glow, only at night.
              AnimatedOpacity(
                duration: const Duration(milliseconds: 1500),
                opacity: _phase == PlazaPhase.night ? 1.0 : 0.0,
                child: IgnorePointer(
                  child: Stack(
                    children: [
                      _lampGlow(s, 0.335, 0.47),
                      _lampGlow(s, 0.52, 0.50),
                    ],
                  ),
                ),
              ),
              // (5) The animals, each at its catalog spot.
              for (final animal in plazaAnimals) _buildAnimal(animal, s),
            ],
          );
        },
      ),
    );
  }

  Widget _lampGlow(double stageSize, double dx, double dy) {
    final d = stageSize * 0.22;
    return Positioned(
      left: dx * stageSize - d / 2,
      top: dy * stageSize - d / 2,
      width: d,
      height: d,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Color(0x59FFC37A), // warm lamp colour at 35% alpha
              Color(0x00FFC37A),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimal(PlazaAnimal animal, double stageSize) {
    final w = animal.spotWidth * stageSize;
    final present = _presentIds.contains(animal.id);
    // One sampled idle frame per 2 ticks (250 ms) = the 16-frame source
    // idle's original 2-second cycle; offset per animal so the stage does
    // not move in lockstep.
    final frame =
        ((_tick ~/ 2) + (_rosterIndex[animal.id] ?? 0)) % plazaIdleFrameCount;
    return Positioned(
      left: animal.spotDx * stageSize - w / 2,
      top: animal.spotDy * stageSize - w,
      width: w,
      height: w,
      child: IgnorePointer(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: present
              ? Image.asset(
                  animal.idleFramePath(frame),
                  key: ValueKey('animal-${animal.id}'),
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                )
              : SizedBox(key: ValueKey('empty-${animal.id}')),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Catalog sections (unchanged from the foundations slice)
  // --------------------------------------------------------------------------

  Widget _buildSection(String title, List<PlazaFoundationAsset> assets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.82,
          children: [for (final a in assets) _buildAssetCard(a)],
        ),
      ],
    );
  }

  Widget _buildAssetCard(PlazaFoundationAsset asset) {
    return Card(
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: SizedBox(
                  width: double.infinity,
                  child: _assetImage(asset, fit: BoxFit.contain))),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                Text(asset.note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _assetImage(PlazaFoundationAsset asset,
      {required BoxFit fit, double? height}) {
    return Image.asset(
      asset.assetPath,
      fit: fit,
      height: height,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        color: const Color(0xFF1A1A2E),
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined,
            color: Colors.grey, size: 32),
      ),
    );
  }
}
