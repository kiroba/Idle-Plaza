/// ============================================================================
/// PLAZA LIVE LOGIC (pure Dart — no Flutter imports)
/// ============================================================================
/// The testable core of the live Plaza stage: real-time day/night phases
/// from the device clock, the phase tint table, and the animal rotation
/// schedule. PlazaSceneScreen owns the timers and widgets; everything that
/// can be decided without a UI lives here so it can be unit-tested.
/// Colours are raw ARGB ints so this file never imports Flutter.
/// ============================================================================

import 'dart:math';

/// Day/night phases of the Plaza, driven by the device's local clock.
enum PlazaPhase { night, dawn, day, dusk }

/// Phase for a local hour of day (0–23):
/// night 21:00–05:00, dawn 05:00–08:00, day 08:00–17:00, dusk 17:00–21:00.
PlazaPhase phaseForHour(int hour) {
  if (hour >= 21 || hour < 5) return PlazaPhase.night;
  if (hour < 8) return PlazaPhase.dawn;
  if (hour < 17) return PlazaPhase.day;
  return PlazaPhase.dusk;
}

/// Phase for a specific moment, using its local hour.
PlazaPhase phaseForTime(DateTime t) => phaseForHour(t.hour);

/// How a phase tints the Plaza backdrop: an ARGB colour laid over the
/// scene at [opacity]. The colour-drift overlay still runs underneath, so
/// the phase sets the mood and the drift keeps it gently moving.
class PlazaPhaseVisual {
  final int tintArgb;
  final double opacity;

  const PlazaPhaseVisual(this.tintArgb, this.opacity);
}

/// Tint per phase. Night is a deep blue dim (the lamps glow through it);
/// dawn is a light warm rose; day is clear — no tint at all, the baked
/// render already reads as daylight; dusk is a soft amber.
const Map<PlazaPhase, PlazaPhaseVisual> plazaPhaseVisuals = {
  PlazaPhase.night: PlazaPhaseVisual(0xFF0B1026, 0.45),
  PlazaPhase.dawn: PlazaPhaseVisual(0xFFFF9E7A, 0.18),
  PlazaPhase.day: PlazaPhaseVisual(0x00000000, 0.0),
  PlazaPhase.dusk: PlazaPhaseVisual(0xFFFF8C42, 0.22),
};

/// Seconds between animal rotations on the live stage.
const int plazaRotationIntervalSeconds = 45;

/// How many animals are present on the stage at once (pool permitting).
const int plazaPresentCount = 5;

/// The opening presence: [plazaPresentCount] distinct ids drawn from
/// [poolIds] with [rng] (fewer when the pool itself is smaller).
/// Deterministic for a seeded [Random].
List<String> initialPresence(List<String> poolIds, Random rng) {
  final pool = List<String>.of(poolIds);
  final count = min(plazaPresentCount, pool.length);
  final present = <String>[];
  for (var i = 0; i < count; i++) {
    present.add(pool.removeAt(rng.nextInt(pool.length)));
  }
  return present;
}

/// One rotation step: exactly one present animal leaves and one absent
/// animal arrives, so the result differs from [present] by one swap and
/// never contains duplicates. When the pool has nobody left to rotate in
/// (pool size <= present size), [present] is returned unchanged.
/// Deterministic for a seeded [Random].
List<String> rotatePresence(
    List<String> present, List<String> poolIds, Random rng) {
  if (poolIds.length <= present.length) return List<String>.of(present);
  final absent = poolIds.where((id) => !present.contains(id)).toList();
  if (absent.isEmpty) return List<String>.of(present);
  final next = List<String>.of(present);
  next.removeAt(rng.nextInt(next.length));
  next.add(absent[rng.nextInt(absent.length)]);
  return next;
}

/// ============================================================================
/// TRAVEL + FISH MATH (Live Plaza 2)
/// ============================================================================
/// Rotation swaps are journeys, not cuts: the departing animal walks (or,
/// for birds, flies an arc) to the stage edge while the arriving one makes
/// the reverse trip. Fish never leave the pond — they drift on small ovals
/// inside the water's fish-safe ellipse. All of that geometry is decided
/// here, in backdrop fractions, so it is unit-testable without a UI.
/// ============================================================================

/// A point in backdrop fractions: dx right, dy DOWN, (0,0) top-left of the
/// square stage. The pure-Dart stand-in for Flutter's Offset.
class PlazaPoint {
  final double dx;
  final double dy;

  const PlazaPoint(this.dx, this.dy);

  @override
  bool operator ==(Object other) =>
      other is PlazaPoint && other.dx == dx && other.dy == dy;

  @override
  int get hashCode => Object.hash(dx, dy);

  @override
  String toString() => 'PlazaPoint($dx, $dy)';
}

/// Linear interpolation: t = 0 gives [a], t = 1 gives [b].
double lerpDouble(double a, double b, double t) => a + (b - a) * t;

/// The point travelling in a straight line from [from] to [to] at
/// progress [t] (0 = at [from], 1 = at [to]).
PlazaPoint travelPoint(PlazaPoint from, PlazaPoint to, double t) => PlazaPoint(
    lerpDouble(from.dx, to.dx, t), lerpDouble(from.dy, to.dy, t));

/// The point travelling from [from] to [to] along a flight arc: the
/// straight line plus a lift of [arcHeight] backdrop fractions that peaks
/// mid-flight (dy is down, so the lift subtracts). Birds rotate this way.
PlazaPoint flyArcPoint(
    PlazaPoint from, PlazaPoint to, double t, double arcHeight) {
  final p = travelPoint(from, to, t);
  return PlazaPoint(p.dx, p.dy - sin(pi * t) * arcHeight);
}

/// Where an animal standing at [spot] (bottom-centre anchor, sprite
/// [spriteWidth] wide) leaves the stage: straight out the nearer left or
/// right edge at the spot's own height, ending just past the edge so the
/// sprite is fully out of frame.
PlazaPoint stageExitPoint(PlazaPoint spot, double spriteWidth) {
  final margin = spriteWidth / 2 + 0.02;
  return PlazaPoint(spot.dx < 0.5 ? -margin : 1.0 + margin, spot.dy);
}

/// Seconds an animal spends travelling to or from its spot on a swap.
const double plazaTravelSeconds = 1.6;

/// Height of a bird's flight arc, in backdrop fractions.
const double plazaFlyArcHeight = 0.15;

/// How many fish are in the pond at once (species pool permitting).
const int plazaFishPresentCount = 2;

/// A point on a swim oval: [centre] plus radii (rx, ry) at [angle]
/// radians. cos drives dx and sin drives dy (down), so at [angle] the
/// horizontal travel direction is the sign of -sin(angle) — the screen
/// flips fish sprites on exactly that.
PlazaPoint fishSwimOffset(
        PlazaPoint centre, double rx, double ry, double angle) =>
    PlazaPoint(centre.dx + rx * cos(angle), centre.dy + ry * sin(angle));

/// ============================================================================
/// WANDERING (ambient life)
/// ============================================================================
/// Rotation journeys alone read as arrivals and departures; wandering is
/// what makes the stage feel lived-in between them. A settled ground
/// animal occasionally strolls to a different free GROUND spot and settles
/// there — that spot becomes its home until it rotates out. Perch spots
/// (the songbird's bench backrest, the owl's and crow's lamp caps) are
/// never wander targets, and the perchers themselves never wander. The
/// duck is the exception that proves the rule: a bird by its fly frames,
/// but a ground waddler in the scene, so it wanders like the land animals.
///
/// Pacing is battery discipline, decided here so it is testable: at most
/// one wander at a time (the screen enforces it), a check every
/// [plazaWanderIntervalSeconds], a [plazaWanderChance] probability per
/// eligible check, and at least [plazaWanderCooldownChecks] checks of
/// quiet after a wander completes before the next can start.
/// ============================================================================

/// Seconds between wander checks on the live stage.
const int plazaWanderIntervalSeconds = 7;

/// Probability that an eligible wander check actually starts a wander.
const double plazaWanderChance = 0.5;

/// Wander checks that must pass after a wander completes before another
/// wander may start.
const int plazaWanderCooldownChecks = 2;

/// Fastest wander journey, in seconds (short hops). The slowest is
/// [plazaTravelSeconds], reached at [plazaWanderRefDistance].
const double plazaWanderMinSeconds = 0.8;

/// Spot-to-spot distance (backdrop fractions) at which a wander journey
/// takes the full [plazaTravelSeconds]. The longest ground-spot hop in
/// the catalog is about half the stage width.
const double plazaWanderRefDistance = 0.5;

/// Whether the animal [id] may wander between spots. Land animals may;
/// birds may not — they perch — EXCEPT the duck, which waddles on the
/// ground despite having fly frames for its rotation journeys. [isBird]
/// is the catalog's bird flag (PlazaAnimal.isBird in plaza_foundations).
bool wanderEligible(String id, {required bool isBird}) =>
    !isBird || id == 'duck';

/// Pick which present animal wanders, from the already-eligible settled
/// ids. Null when nobody is eligible. Deterministic for a seeded [rng].
String? pickWanderer(List<String> eligibleIds, Random rng) {
  if (eligibleIds.isEmpty) return null;
  return eligibleIds[rng.nextInt(eligibleIds.length)];
}

/// Choose a wander target spot index: one of [groundSpots] that is not in
/// [occupiedSpots] (every present animal's current spot, plus any spot
/// reserved as a journey target) and is not the wanderer's own
/// [currentSpot]. Null when no ground spot is free. Deterministic for a
/// seeded [rng].
int? chooseWanderTarget({
  required int currentSpot,
  required Set<int> occupiedSpots,
  required List<int> groundSpots,
  required Random rng,
}) {
  final free = [
    for (final s in groundSpots)
      if (s != currentSpot && !occupiedSpots.contains(s)) s,
  ];
  if (free.isEmpty) return null;
  return free[rng.nextInt(free.length)];
}

/// Where an animal rotating IN takes its place: its own catalog spot
/// ([ownSpot]) when that spot is unoccupied once the departing animal's
/// claim is released ([occupiedAfterDeparture] excludes the vacated
/// spot); otherwise a free spot from [groundSpots]; otherwise the
/// just-vacated spot itself, so an arrival never has nowhere to land.
int arrivalSpot({
  required int ownSpot,
  required Set<int> occupiedAfterDeparture,
  required List<int> groundSpots,
  required int vacatedSpot,
}) {
  if (!occupiedAfterDeparture.contains(ownSpot)) return ownSpot;
  for (final s in groundSpots) {
    if (!occupiedAfterDeparture.contains(s)) return s;
  }
  return vacatedSpot;
}

/// How long a wander journey from [from] to [to] takes: linear in the
/// distance between [plazaWanderMinSeconds] (a hop in place) and
/// [plazaTravelSeconds] (a full [plazaWanderRefDistance] trek or more).
double wanderTravelSeconds(PlazaPoint from, PlazaPoint to) {
  final dx = to.dx - from.dx;
  final dy = to.dy - from.dy;
  final distance = sqrt(dx * dx + dy * dy);
  final f = (distance / plazaWanderRefDistance).clamp(0.0, 1.0);
  return lerpDouble(plazaWanderMinSeconds, plazaTravelSeconds, f);
}
