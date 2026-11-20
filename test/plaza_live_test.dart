import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:idle_plaza/src/plaza_live.dart';

void main() {
  group('phaseForHour', () {
    test('phase boundaries follow the ruled clock', () {
      expect(phaseForHour(4), PlazaPhase.night); // 04:59 is still night
      expect(phaseForHour(5), PlazaPhase.dawn);
      expect(phaseForHour(7), PlazaPhase.dawn);
      expect(phaseForHour(8), PlazaPhase.day);
      expect(phaseForHour(16), PlazaPhase.day);
      expect(phaseForHour(17), PlazaPhase.dusk);
      expect(phaseForHour(20), PlazaPhase.dusk);
      expect(phaseForHour(21), PlazaPhase.night);
      expect(phaseForHour(0), PlazaPhase.night);
      expect(phaseForHour(23), PlazaPhase.night);
    });
  });

  group('phaseForTime', () {
    test('uses the local hour of the given moment', () {
      expect(phaseForTime(DateTime(2026, 11, 16, 4, 59)), PlazaPhase.night);
      expect(phaseForTime(DateTime(2026, 11, 16, 5, 0)), PlazaPhase.dawn);
      expect(phaseForTime(DateTime(2026, 11, 16, 12, 30)), PlazaPhase.day);
      expect(phaseForTime(DateTime(2026, 11, 16, 20, 59)), PlazaPhase.dusk);
      expect(phaseForTime(DateTime(2026, 11, 16, 21, 0)), PlazaPhase.night);
    });
  });

  group('phase visuals', () {
    test('every phase has a tint entry; day is clear', () {
      for (final p in PlazaPhase.values) {
        expect(plazaPhaseVisuals[p], isNotNull, reason: p.name);
      }
      expect(plazaPhaseVisuals[PlazaPhase.day]!.opacity, 0.0);
      expect(plazaPhaseVisuals[PlazaPhase.night]!.opacity, greaterThan(0.0));
    });
  });

  group('rotation', () {
    final pool = [for (var i = 0; i < 10; i++) 'animal-$i'];

    test('initial presence is plazaPresentCount unique pool members', () {
      final present = initialPresence(pool, Random(7));
      expect(present, hasLength(plazaPresentCount));
      expect(present.toSet(), hasLength(present.length));
      for (final id in present) {
        expect(pool, contains(id));
      }
    });

    test('rotate swaps exactly one member and never duplicates', () {
      final present = initialPresence(pool, Random(7));
      final next = rotatePresence(present, pool, Random(7));
      expect(next, hasLength(present.length));
      expect(next.toSet(), hasLength(next.length));
      final removed = present.where((id) => !next.contains(id)).toList();
      final added = next.where((id) => !present.contains(id)).toList();
      expect(removed, hasLength(1));
      expect(added, hasLength(1));
      expect(pool, contains(added.single));
    });

    test('seeded rng makes presence and rotation deterministic', () {
      final a = initialPresence(pool, Random(42));
      final b = initialPresence(pool, Random(42));
      expect(a, b);
      expect(rotatePresence(a, pool, Random(42)),
          rotatePresence(b, pool, Random(42)));
    });

    test('small pool: presence is the whole pool, rotation is a no-op', () {
      final small = ['a', 'b', 'c'];
      final present = initialPresence(small, Random(1));
      expect(present, hasLength(3));
      expect(present.toSet(), small.toSet());
      final next = rotatePresence(present, small, Random(1));
      expect(next, hasLength(3));
      expect(next.toSet(), present.toSet());
    });
  });

  group('travel math', () {
    const from = PlazaPoint(0.2, 0.6);
    const to = PlazaPoint(0.8, 0.4);

    test('lerpDouble hits endpoints and midpoint', () {
      expect(lerpDouble(2, 6, 0), 2);
      expect(lerpDouble(2, 6, 1), 6);
      expect(lerpDouble(2, 6, 0.5), 4);
      expect(lerpDouble(6, 2, 0.25), 5);
    });

    test('travelPoint is at from at t=0 and at to at t=1', () {
      expect(travelPoint(from, to, 0), from);
      expect(travelPoint(from, to, 1), to);
      final mid = travelPoint(from, to, 0.5);
      expect(mid.dx, closeTo(0.5, 1e-9));
      expect(mid.dy, closeTo(0.5, 1e-9));
    });

    test('flyArcPoint keeps the endpoints and lifts the midpoint', () {
      const arc = 0.15;
      expect(flyArcPoint(from, to, 0, arc), from);
      final end = flyArcPoint(from, to, 1, arc);
      expect(end.dx, closeTo(to.dx, 1e-9));
      expect(end.dy, closeTo(to.dy, 1e-9));
      final mid = flyArcPoint(from, to, 0.5, arc);
      final straight = travelPoint(from, to, 0.5);
      expect(mid.dx, closeTo(straight.dx, 1e-9));
      // dy is down, so the arc peak is arcHeight ABOVE the straight line.
      expect(mid.dy, closeTo(straight.dy - arc, 1e-9));
      // Quarter points are lifted less than the peak.
      final quarter = flyArcPoint(from, to, 0.25, arc);
      expect(quarter.dy, greaterThan(mid.dy));
      expect(quarter.dy, lessThan(travelPoint(from, to, 0.25).dy));
    });

    test('stageExitPoint leaves by the nearer edge at the spot height', () {
      final left = stageExitPoint(const PlazaPoint(0.3, 0.6), 0.1);
      expect(left.dx, lessThan(0));
      expect(left.dy, 0.6);
      final right = stageExitPoint(const PlazaPoint(0.7, 0.5), 0.1);
      expect(right.dx, greaterThan(1));
      expect(right.dy, 0.5);
      // Fully out of frame: the margin covers half the sprite + a gap.
      expect(left.dx, lessThanOrEqualTo(-0.05));
      expect(right.dx, greaterThanOrEqualTo(1.05));
    });
  });

  group('fish swim oval', () {
    const centre = PlazaPoint(0.402, 0.4725);
    const rx = 0.045;
    const ry = 0.0175;

    test('angle 0 is the right-hand point of the oval', () {
      final p = fishSwimOffset(centre, rx, ry, 0);
      expect(p.dx, closeTo(centre.dx + rx, 1e-9));
      expect(p.dy, closeTo(centre.dy, 1e-9));
    });

    test('sampled angles stay within the oval radii', () {
      for (var i = 0; i < 64; i++) {
        final angle = i * 2 * pi / 64;
        final p = fishSwimOffset(centre, rx, ry, angle);
        expect((p.dx - centre.dx).abs(), lessThanOrEqualTo(rx + 1e-9),
            reason: 'angle $angle');
        expect((p.dy - centre.dy).abs(), lessThanOrEqualTo(ry + 1e-9),
            reason: 'angle $angle');
        // And the point lies ON the ellipse, not just inside it.
        final nx = (p.dx - centre.dx) / rx;
        final ny = (p.dy - centre.dy) / ry;
        expect(nx * nx + ny * ny, closeTo(1.0, 1e-9), reason: 'angle $angle');
      }
    });
  });

  group('live plaza 2 constants', () {
    test('travel time and fish presence are the specced values', () {
      expect(plazaTravelSeconds, 1.6);
      expect(plazaFishPresentCount, 2);
    });
  });

  group('wandering', () {
    // Roster indices in catalog order: fox 0, dog 1, cat 2, songbird 3,
    // owl 4, rabbit 5, deer 6, bearcub 7, duck 8, crow 9. Ground spots are
    // the wander-eligible owners' indices; 3, 4 and 9 are perches.
    const groundSpots = [0, 1, 2, 5, 6, 7, 8];

    test('eligibility: land animals and the duck wander, perchers do not',
        () {
      expect(wanderEligible('fox', isBird: false), isTrue);
      expect(wanderEligible('bearcub', isBird: false), isTrue);
      expect(wanderEligible('duck', isBird: true), isTrue);
      expect(wanderEligible('songbird', isBird: true), isFalse);
      expect(wanderEligible('owl', isBird: true), isFalse);
      expect(wanderEligible('crow', isBird: true), isFalse);
    });

    test('wander target is a free ground spot, never the animal\'s own',
        () {
      // Fox (spot 0) present with dog (1) and deer (6).
      final occupied = {0, 1, 6};
      for (var seed = 0; seed < 40; seed++) {
        final target = chooseWanderTarget(
          currentSpot: 0,
          occupiedSpots: occupied,
          groundSpots: groundSpots,
          rng: Random(seed),
        );
        expect(target, isNotNull, reason: 'seed $seed');
        expect(groundSpots, contains(target), reason: 'seed $seed');
        expect(occupied, isNot(contains(target)), reason: 'seed $seed');
        expect(target, isNot(0), reason: 'seed $seed');
      }
    });

    test('wander target is null when every ground spot is occupied', () {
      final target = chooseWanderTarget(
        currentSpot: 0,
        occupiedSpots: groundSpots.toSet(),
        groundSpots: groundSpots,
        rng: Random(3),
      );
      expect(target, isNull);
    });

    test('wander choices are deterministic for a seeded rng', () {
      final a = chooseWanderTarget(
        currentSpot: 2,
        occupiedSpots: {1, 2},
        groundSpots: groundSpots,
        rng: Random(42),
      );
      final b = chooseWanderTarget(
        currentSpot: 2,
        occupiedSpots: {1, 2},
        groundSpots: groundSpots,
        rng: Random(42),
      );
      expect(a, b);
      expect(pickWanderer(['fox', 'duck'], Random(42)),
          pickWanderer(['fox', 'duck'], Random(42)));
    });

    test('pickWanderer returns a member, or null when nobody is eligible',
        () {
      expect(pickWanderer(const [], Random(1)), isNull);
      final picked = pickWanderer(['fox', 'cat', 'duck'], Random(5));
      expect(['fox', 'cat', 'duck'], contains(picked));
    });

    test('arrival claims its own spot when free', () {
      final spot = arrivalSpot(
        ownSpot: 4, // owl's perch, held by nobody else ever
        occupiedAfterDeparture: {0, 1, 6},
        groundSpots: groundSpots,
        vacatedSpot: 2,
      );
      expect(spot, 4);
    });

    test('arrival falls back to a free ground spot when its own is taken',
        () {
      // A wanderer is settled on the fox's spot (0) when the fox rotates
      // back in; the cat's spot (2) was just vacated.
      final spot = arrivalSpot(
        ownSpot: 0,
        occupiedAfterDeparture: {0, 1, 6},
        groundSpots: groundSpots,
        vacatedSpot: 2,
      );
      expect(groundSpots, contains(spot));
      expect({0, 1, 6}, isNot(contains(spot)));
    });

    test('wander journey time scales with distance between min and max',
        () {
      const a = PlazaPoint(0.3, 0.6);
      expect(wanderTravelSeconds(a, a), plazaWanderMinSeconds);
      // A full reference-distance trek takes the whole travel time.
      const b = PlazaPoint(0.3 + plazaWanderRefDistance, 0.6);
      expect(wanderTravelSeconds(a, b), closeTo(plazaTravelSeconds, 1e-9));
      // Anything farther is capped, and a half trek sits in between.
      const far = PlazaPoint(1.0, 0.0);
      expect(wanderTravelSeconds(a, far), plazaTravelSeconds);
      const half = PlazaPoint(0.3 + plazaWanderRefDistance / 2, 0.6);
      final mid = wanderTravelSeconds(a, half);
      expect(mid, greaterThan(plazaWanderMinSeconds));
      expect(mid, lessThan(plazaTravelSeconds));
    });

    test('wander pacing constants are the specced values', () {
      expect(plazaWanderIntervalSeconds, 7);
      expect(plazaWanderChance, 0.5);
      expect(plazaWanderCooldownChecks, 2);
      expect(plazaWanderMinSeconds, 0.8);
    });
  });
}
