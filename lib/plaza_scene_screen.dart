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
/// Live Plaza 2: rotation swaps are journeys — the departing animal walks
/// to the stage edge on its move frames while the arriving one walks in;
/// birds fly the trip along an arc on their fly frames. Between swaps,
/// settled ground animals occasionally WANDER to a different free spot
/// (one at a time, on a slow check — see the wandering section of
/// src/plaza_live.dart). The pond layer
/// (plazaPondAsset, placed by plazaPond) sits over the backdrop in front
/// of Storefront A, and its fish (plazaFish) drift on swim ovals inside
/// the water, species rotating on the same timer family.
///
/// It is still NOT a live 3D view: the backdrop is one baked render and the
/// animals are 2D sprites, and the caption on the stage says so. Below the
/// stage, the catalog sections show the same foundations as individual
/// renders and sprites.
/// ============================================================================

/// Whether a stage animal is settled at its spot or travelling: entering
/// or leaving on a rotation swap, or wandering between spots (ambient).
enum _PresenceState { entering, present, leaving, wandering }

/// One animal on the live stage: its roster entry, its presence state,
/// the catalog spot it currently calls home, and — while travelling —
/// the journey's endpoints, start tick and duration in ticks.
///
/// Spots are per-animal in the catalog (plazaAnimals), so a spot is
/// identified by its owner's roster index: [spotIndex] is the index of
/// the plazaAnimals entry whose spot this animal occupies. Wandering
/// changes it; rotation arrivals claim theirs via arrivalSpot.
class _StageAnimal {
  final PlazaAnimal animal;
  _PresenceState state;
  int spotIndex;
  PlazaPoint from;
  PlazaPoint to;
  int travelStartTick;

  /// Journey length in ticks (125 ms each). Rotation journeys use the
  /// standard plazaTravelSeconds; wander journeys scale with distance.
  double travelTicks;

  _StageAnimal.present(this.animal, this.spotIndex)
      : state = _PresenceState.present,
        from = PlazaPoint(animal.spotDx, animal.spotDy),
        to = PlazaPoint(animal.spotDx, animal.spotDy),
        travelStartTick = 0,
        travelTicks = plazaTravelSeconds * 8;

  _StageAnimal.travelling(this.animal, this.state, this.spotIndex, this.from,
      this.to, this.travelStartTick, this.travelTicks);

  /// The point this animal currently calls home (bottom-centre anchor).
  PlazaPoint get spot {
    final s = plazaAnimals[spotIndex];
    return PlazaPoint(s.spotDx, s.spotDy);
  }
}

class PlazaSceneScreen extends StatefulWidget {
  const PlazaSceneScreen({super.key});

  @override
  State<PlazaSceneScreen> createState() => _PlazaSceneScreenState();
}

class _PlazaSceneScreenState extends State<PlazaSceneScreen> {
  final Random _rng = Random();
  late PlazaPhase _phase;

  /// Every animal currently rendered: settled ones plus any mid-journey.
  late List<_StageAnimal> _stage;

  /// Species id per fish slot (slot = index into _fishOrbits).
  late List<String> _presentFishIds;

  /// Rotation ticks so far — fish swap on every second one.
  int _rotationCount = 0;

  /// Wander checks since the last wander completed. Starts past the
  /// cooldown so the first wander is not blocked; a completed wander
  /// resets it to 0 and plazaWanderCooldownChecks quiet checks must pass
  /// before the next wander may start.
  int _wanderChecksSinceLast = plazaWanderCooldownChecks + 1;

  /// Master tick: +1 every 125 ms. Drives the idle frames (one sampled
  /// frame per 2 ticks = the source idle's original tempo), the move/fly/
  /// swim frames (one per tick = their sources' 8 fps), the fish ovals,
  /// travel progress, and the slow colour drift (hue advances 2°/s, a
  /// full cycle in 3 minutes).
  int _tick = 0;

  Timer? _ticker;
  Timer? _rotationTimer;
  Timer? _phaseTimer;

  static final Map<String, int> _rosterIndex = {
    for (var i = 0; i < plazaAnimals.length; i++) plazaAnimals[i].id: i,
  };

  static final Map<String, PlazaAnimal> _animalsById = {
    for (final a in plazaAnimals) a.id: a,
  };

  static final Map<String, PlazaFish> _fishById = {
    for (final f in plazaFish) f.id: f,
  };

  /// Ticks between wander checks (7 s at 8 ticks/s) — checked on the
  /// shared ticker, so wandering needs no timer of its own.
  static const int _wanderCheckTicks = plazaWanderIntervalSeconds * 8;

  /// Roster indices of the GROUND spots: the spots whose catalog animal
  /// may wander (land animals + the duck). Perch spots are never wander
  /// targets, and perchers never wander (see plaza_live.dart).
  static final List<int> _groundSpotIndices = [
    for (var i = 0; i < plazaAnimals.length; i++)
      if (wanderEligible(plazaAnimals[i].id, isBird: plazaAnimals[i].isBird))
        i,
  ];

  /// The backdrop point of the catalog spot at roster [index].
  static PlazaPoint _spotPoint(int index) =>
      PlazaPoint(plazaAnimals[index].spotDx, plazaAnimals[index].spotDy);

  /// Swim ovals for the fish slots, in backdrop fractions. Centres are
  /// offsets from the water centre as a fraction of the fish-safe radii;
  /// radii are fractions of the fish-safe radii too. Offset + radius stays
  /// well inside 1.0 on both axes, so a fish's centre never leaves the
  /// fish-safe ellipse. Slot 1 swims the other way for variety.
  static const List<({double ox, double oy, double rx, double ry, double speed, double phase})>
      _fishOrbits = [
    (ox: -0.35, oy: -0.15, rx: 0.45, ry: 0.45, speed: 0.25, phase: 0.0),
    (ox: 0.30, oy: 0.25, rx: 0.40, ry: 0.40, speed: -0.19, phase: 2.1),
  ];

  @override
  void initState() {
    super.initState();
    _phase = phaseForTime(DateTime.now());
    final opening =
        initialPresence(plazaAnimals.map((a) => a.id).toList(), _rng);
    _stage = [
      for (final id in opening)
        _StageAnimal.present(_animalsById[id]!, _rosterIndex[id]!),
    ];
    final fishPool = plazaFish.map((f) => f.id).toList()..shuffle(_rng);
    _presentFishIds = fishPool.take(plazaFishPresentCount).toList();
    _ticker = Timer.periodic(const Duration(milliseconds: 125), (_) {
      if (!mounted) return;
      setState(() {
        _tick++;
        _advanceTravels();
        if (_tick % _wanderCheckTicks == 0) {
          _wanderChecksSinceLast++;
          _maybeStartWander();
        }
      });
    });
    _rotationTimer = Timer.periodic(
        const Duration(seconds: plazaRotationIntervalSeconds), (_) {
      if (!mounted) return;
      setState(_onRotationTick);
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

  // --------------------------------------------------------------------------
  // Rotation + travel bookkeeping
  // --------------------------------------------------------------------------

  double _travelProgress(_StageAnimal e) =>
      (_tick - e.travelStartTick) / e.travelTicks;

  /// Settle or remove animals whose journeys have finished.
  void _advanceTravels() {
    _stage.removeWhere((e) =>
        e.state == _PresenceState.leaving && _travelProgress(e) >= 1.0);
    for (final e in _stage) {
      if (_travelProgress(e) < 1.0) continue;
      if (e.state == _PresenceState.entering) {
        e.state = _PresenceState.present;
      } else if (e.state == _PresenceState.wandering) {
        // Settled at its new home spot — the wander cooldown restarts.
        e.state = _PresenceState.present;
        _wanderChecksSinceLast = 0;
      }
    }
  }

  /// The ambient wander check (runs on the shared ticker every
  /// plazaWanderIntervalSeconds): with modest probability, send ONE
  /// settled ground animal strolling to a free ground spot. Skipped
  /// while any journey is running — one mover at a time, both for the
  /// look of the scene and for battery discipline — and during the
  /// post-wander cooldown.
  void _maybeStartWander() {
    if (_wanderChecksSinceLast <= plazaWanderCooldownChecks) return;
    if (_stage.any((e) => e.state != _PresenceState.present)) return;
    if (_rng.nextDouble() >= plazaWanderChance) return;
    final eligibleIds = [
      for (final e in _stage)
        if (wanderEligible(e.animal.id, isBird: e.animal.isBird)) e.animal.id,
    ];
    final wandererId = pickWanderer(eligibleIds, _rng);
    if (wandererId == null) return;
    final entry = _stage.firstWhere((e) => e.animal.id == wandererId);
    final occupied = {for (final e in _stage) e.spotIndex};
    final target = chooseWanderTarget(
      currentSpot: entry.spotIndex,
      occupiedSpots: occupied,
      groundSpots: _groundSpotIndices,
      rng: _rng,
    );
    if (target == null) return;
    final from = entry.spot;
    final to = _spotPoint(target);
    entry.state = _PresenceState.wandering;
    entry.from = from;
    entry.to = to;
    entry.spotIndex = target; // the new spot is home from the first step
    entry.travelStartTick = _tick;
    entry.travelTicks = wanderTravelSeconds(from, to) * 8;
  }

  void _onRotationTick() {
    _rotationCount++;
    // Fish rotate on the same timer family: one species swap every
    // second tick, independent of animal journeys.
    if (_rotationCount % 2 == 0) _swapFish();
    // If a journey is still running, let it finish — no new swap starts
    // this tick. (Journeys take 1.6 s of a 45 s interval, so this only
    // matters if the screen was rebuilt mid-travel.)
    if (_stage.any((e) => e.state != _PresenceState.present)) return;
    final poolIds = plazaAnimals.map((a) => a.id).toList();
    final currentIds = _stage.map((e) => e.animal.id).toList();
    final target = rotatePresence(currentIds, poolIds, _rng);
    if (target.toSet().containsAll(currentIds) &&
        currentIds.toSet().containsAll(target)) {
      return; // pool too small to rotate — nobody moves
    }
    final leavingId = currentIds.firstWhere((id) => !target.contains(id));
    final arrivingId = target.firstWhere((id) => !currentIds.contains(id));
    final leaving = _stage.firstWhere((e) => e.animal.id == leavingId);
    leaving.state = _PresenceState.leaving;
    leaving.from = leaving.spot;
    leaving.to = stageExitPoint(leaving.spot, leaving.animal.spotWidth);
    leaving.travelStartTick = _tick;
    leaving.travelTicks = plazaTravelSeconds * 8;
    final arriving = _animalsById[arrivingId]!;
    // The arriver claims its own catalog spot when free (the usual case —
    // perch spots are only ever held by their owners); if a wanderer is
    // settled there, it takes a free ground spot instead.
    final occupiedAfter = {
      for (final e in _stage)
        if (e.animal.id != leavingId) e.spotIndex,
    };
    final arriveSpotIndex = arrivalSpot(
      ownSpot: _rosterIndex[arrivingId]!,
      occupiedAfterDeparture: occupiedAfter,
      groundSpots: _groundSpotIndices,
      vacatedSpot: leaving.spotIndex,
    );
    final arrivePoint = _spotPoint(arriveSpotIndex);
    _stage.add(_StageAnimal.travelling(
      arriving,
      _PresenceState.entering,
      arriveSpotIndex,
      stageExitPoint(arrivePoint, arriving.spotWidth),
      arrivePoint,
      _tick,
      plazaTravelSeconds * 8,
    ));
  }

  /// Swap one pond species for the absent one (slots keep their ovals;
  /// the AnimatedSwitcher in _buildFish cross-fades the change).
  void _swapFish() {
    final absent = plazaFish
        .map((f) => f.id)
        .where((id) => !_presentFishIds.contains(id))
        .toList();
    if (absent.isEmpty) return;
    final next = List<String>.of(_presentFishIds);
    next[_rng.nextInt(next.length)] = absent[_rng.nextInt(absent.length)];
    _presentFishIds = next;
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
        // Bottom padding clears the Android system nav bar: this route
        // has no bottom navigation bar of its own, so without the inset
        // the last rows scroll underneath it and can't be read.
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
        children: [
          _buildLiveStageCard(),
          const SizedBox(height: 20),
          _buildSection('Figures — Base #3 Soft', plazaFigureAssets),
          const SizedBox(height: 20),
          _buildSection(
              'Companions — Sets #1, #2 + Pond Fish', plazaCompanionAssets),
          const SizedBox(height: 20),
          _buildSection(
              'Scenery — Set #1 Pieces & Pond', plazaSceneryAssets),
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
                  'The animals rotate in and out — walking to and from their spots, or flying if they are birds — idle '
                  'in place, and now and then a ground animal strolls to a different spot; fish drift in the pond, the colours drift gently, and the light follows your device clock — '
                  'dawn, day, dusk and night tints change as the real day does. It is not a live 3D view; the pieces below '
                  'are the same foundations as individual renders and sprites.',
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
              // Layer order, bottom to top:
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
              // (2) Pond — the warped top-down layer at its measured rect,
              //     directly over the backdrop so the drift and phase tint
              //     below wash over it like everything else in the scene.
              Positioned(
                left: plazaPond.layerLeft * s,
                top: plazaPond.layerTop * s,
                width: plazaPond.layerWidth * s,
                height: plazaPond.layerHeight * s,
                child: IgnorePointer(
                  child: Image.asset(
                    plazaPondAsset.assetPath,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ),
              // (3) Colour drift — a slow, subtle hue cycle.
              Container(color: driftColor),
              // (4) Day/night phase tint, cross-fading on phase change.
              AnimatedContainer(
                duration: const Duration(milliseconds: 1500),
                color: phaseColor,
              ),
              // (5) Fish — inside the pond's water, tinted with the scene.
              for (var slot = 0; slot < _presentFishIds.length; slot++)
                _buildFish(slot, s),
              // (6) Lamp glow, only at night.
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
              // (7) The animals — settled at their spots or mid-journey.
              for (final entry in _stage) _buildAnimal(entry, s),
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

  Widget _buildAnimal(_StageAnimal entry, double stageSize) {
    final animal = entry.animal;
    final w = animal.spotWidth * stageSize;
    final travelling = entry.state != _PresenceState.present;
    // Where the sprite's bottom-centre anchor sits right now: the spot
    // when settled, or along the journey while travelling — a straight
    // line for walkers (rotation arrivals/departures and wanderers), an
    // arc for birds on rotation journeys.
    final PlazaPoint anchor;
    if (!travelling) {
      anchor = entry.spot;
    } else {
      final t = _travelProgress(entry).clamp(0.0, 1.0);
      anchor = entry.state != _PresenceState.wandering &&
              animal.kind == PlazaAnimalKind.bird
          ? flyArcPoint(entry.from, entry.to, t, plazaFlyArcHeight)
          : travelPoint(entry.from, entry.to, t);
    }
    // Frame choice: settled animals idle (one sampled frame per 2 ticks =
    // the 16-frame source idle's original 2-second cycle); travelling
    // animals play move/fly frames at one per tick (their sources' 8 fps).
    // Wandering is always on the ground — even the duck waddles — so it
    // plays move frames, never fly frames. Offset per animal so the
    // stage does not move in lockstep.
    final offset = _rosterIndex[animal.id] ?? 0;
    final String framePath;
    if (!travelling) {
      framePath =
          animal.idleFramePath(((_tick ~/ 2) + offset) % plazaIdleFrameCount);
    } else if (entry.state != _PresenceState.wandering &&
        animal.kind == PlazaAnimalKind.bird) {
      framePath = animal.flyFramePath((_tick + offset) % plazaFlyFrameCount);
    } else {
      framePath = animal.moveFramePath((_tick + offset) % plazaMoveFrameCount);
    }
    return Positioned(
      left: anchor.dx * stageSize - w / 2,
      top: anchor.dy * stageSize - w,
      width: w,
      height: w,
      child: IgnorePointer(
        child: Image.asset(
          framePath,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) =>
              const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildFish(int slot, double stageSize) {
    final fish = _fishById[_presentFishIds[slot]]!;
    final orbit = _fishOrbits[slot % _fishOrbits.length];
    final w = fish.widthFraction * stageSize;
    // Drift: the slot's oval around an offset point inside the fish-safe
    // ellipse, angle advancing with the shared ticker (125 ms per tick).
    final centre = PlazaPoint(
      plazaPond.waterDx + orbit.ox * plazaPond.usableRx,
      plazaPond.waterDy + orbit.oy * plazaPond.usableRy,
    );
    final angle = orbit.phase + orbit.speed * _tick * 0.125;
    final pos = fishSwimOffset(centre, orbit.rx * plazaPond.usableRx,
        orbit.ry * plazaPond.usableRy, angle);
    // Swim frames at one per 2 ticks (4 fps reads calm at this size);
    // offset per slot. The sprites face LEFT natively, so flip when the
    // fish is travelling right: horizontal velocity is -sin(angle)*speed.
    final frame = ((_tick ~/ 2) + slot * 3) % plazaSwimFrameCount;
    final movingRight = -sin(angle) * orbit.speed > 0;
    return Positioned(
      left: pos.dx * stageSize - w / 2,
      top: pos.dy * stageSize - w / 2,
      width: w,
      height: w,
      child: IgnorePointer(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: Transform(
            key: ValueKey('fish-$slot-${fish.id}'),
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(movingRight ? -1.0 : 1.0, 1, 1),
            child: Image.asset(
              fish.swimFramePath(frame),
              fit: BoxFit.contain,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
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
