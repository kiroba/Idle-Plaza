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
}
