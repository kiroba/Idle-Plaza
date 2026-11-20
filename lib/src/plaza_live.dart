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
