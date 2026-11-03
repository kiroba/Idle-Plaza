import 'package:flutter_test/flutter_test.dart';
import 'package:idle_plaza/src/idle_engine.dart';

void main() {
  const t0 = 1793500000000;

  test('inactive skill earns nothing and re-anchors', () {
    final s = SkillState(skill: 'mining');
    final a = IdleEngine.claim(s, t0 + 60000);
    expect(a.isEmpty, isTrue);
    expect(s.lastClaimMs, t0 + 60000);
  });

  test('earns 15 XP per 2 s of wall-clock time', () {
    final s = SkillState(skill: 'mining');
    IdleEngine.start(s, t0);
    final a = IdleEngine.claim(s, t0 + 10000);
    expect(a.xpGained, 75);
    expect(s.exp, 75);
  });

  test('keeps the sub-tick remainder for the next claim', () {
    final s = SkillState(skill: 'mining');
    IdleEngine.start(s, t0);
    IdleEngine.claim(s, t0 + 3000); // 1 tick, 1 s left over
    final a = IdleEngine.claim(s, t0 + 4000); // the leftover makes a 2nd tick
    expect(a.xpGained, 15);
    expect(s.exp, 30);
  });

  test('many short claims equal one long claim', () {
    final a = SkillState(skill: 'mining');
    final b = SkillState(skill: 'mining');
    IdleEngine.start(a, t0);
    IdleEngine.start(b, t0);
    for (var t = t0; t <= t0 + 3600000; t += 700) {
      IdleEngine.claim(a, t);
    }
    IdleEngine.claim(a, t0 + 3600000);
    IdleEngine.claim(b, t0 + 3600000);
    expect(a.level, b.level);
    expect(a.exp, b.exp);
  });

  test('offline time counts and levels carry overflow', () {
    final s = SkillState(skill: 'mining');
    IdleEngine.start(s, t0);
    final a = IdleEngine.claim(s, t0 + 60 * 60 * 1000); // 1 h = 1800 ticks = 27000 XP
    expect(a.xpGained, 27000);
    // Total XP is conserved: sum of thresholds passed + current exp.
    var spent = 0;
    for (var l = 1; l < s.level; l++) {
      spent += xpToNext(l);
    }
    expect(spent + s.exp, 27000);
    expect(s.exp, lessThan(xpToNext(s.level)));
    expect(a.levelsGained, s.level - 1);
  });

  test('one claim is capped at 24 h', () {
    final s = SkillState(skill: 'mining');
    IdleEngine.start(s, t0);
    final a = IdleEngine.claim(s, t0 + 7 * maxOfflineMs);
    expect(a.capped, isTrue);
    expect(a.xpGained, (maxOfflineMs ~/ tickMs) * xpPerTick);
    expect(s.lastClaimMs, t0 + 7 * maxOfflineMs);
  });

  test('clock moving backwards never removes XP and re-anchors', () {
    final s = SkillState(skill: 'mining');
    IdleEngine.start(s, t0);
    IdleEngine.claim(s, t0 + 10000);
    final exp = s.exp;
    final a = IdleEngine.claim(s, t0 - 50000);
    expect(a.isEmpty, isTrue);
    expect(s.exp, exp);
    expect(s.lastClaimMs, t0 - 50000);
  });

  test('stop claims what was earned, then earns nothing', () {
    final s = SkillState(skill: 'mining');
    IdleEngine.start(s, t0);
    final a = IdleEngine.stop(s, t0 + 4000);
    expect(a.xpGained, 30);
    expect(s.active, isFalse);
    expect(IdleEngine.claim(s, t0 + 999999).isEmpty, isTrue);
  });

  test('state survives a save and load', () {
    final s = SkillState(skill: 'mining', level: 7, exp: 42, active: true, lastClaimMs: t0);
    final r = SkillState.decode(s.encode());
    expect(r.level, 7);
    expect(r.exp, 42);
    expect(r.active, isTrue);
    expect(r.lastClaimMs, t0);
  });

  test('corrupt or missing saves start fresh', () {
    expect(SkillState.decode(null).level, 1);
    expect(SkillState.decode('not json').level, 1);
    expect(SkillState.decode('{"level": -3, "exp": -1}').level, 1);
    expect(SkillState.decode('{"level": -3, "exp": -1}').exp, 0);
  });

  test('formatDuration', () {
    expect(formatDuration(45000), '45 s');
    expect(formatDuration(125000), '2 m');
    expect(formatDuration(2 * 3600000 + 5 * 60000), '2 h 5 m');
    expect(formatDuration(3600000), '1 h');
  });
}
