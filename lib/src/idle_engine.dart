/// Idle Plaza's idle loop, in plain Dart (no Flutter), so it can be unit-tested
/// and reused by the Omni-Hub when Idle Plaza runs inside it as a container.
///
/// Progress is based on the wall clock, not on a timer running in the app:
/// while a skill is active it earns [xpPerTick] XP for every [tickMs] of real
/// time since the last claim, including time the app was closed. One claim
/// counts at most [maxOfflineMs] (24 h, the same cap Omni Node's LPE uses for
/// /api/lpe/progress), so leaving a phone for a week doesn't pay out a week.
library idle_engine;

import 'dart:convert';

const int tickMs = 2000;
const int xpPerTick = 15;
const int maxOfflineMs = 24 * 60 * 60 * 1000;

/// XP needed to go from [level] to level + 1.
int xpToNext(int level) => level * 100;

class SkillState {
  SkillState({
    required this.skill,
    this.level = 1,
    this.exp = 0,
    this.active = false,
    this.lastClaimMs = 0,
  });

  final String skill;
  int level;
  int exp;
  bool active;

  /// Wall-clock time (ms since epoch) up to which progress has been counted.
  int lastClaimMs;

  Map<String, dynamic> toJson() => {
        'skill': skill,
        'level': level,
        'exp': exp,
        'active': active,
        'last_claim_ms': lastClaimMs,
      };

  static SkillState fromJson(Map<String, dynamic> j) {
    int asInt(Object? v, int fallback) => v is int ? v : (v is num ? v.toInt() : fallback);
    final level = asInt(j['level'], 1);
    final exp = asInt(j['exp'], 0);
    return SkillState(
      skill: (j['skill'] as String?) ?? 'mining',
      level: level < 1 ? 1 : level,
      exp: exp < 0 ? 0 : exp,
      active: j['active'] == true,
      lastClaimMs: asInt(j['last_claim_ms'], 0),
    );
  }

  String encode() => jsonEncode(toJson());

  static SkillState decode(String? raw, {String skill = 'mining'}) {
    if (raw == null || raw.isEmpty) return SkillState(skill: skill);
    try {
      final j = jsonDecode(raw);
      if (j is Map<String, dynamic>) return fromJson(j);
    } catch (_) {}
    return SkillState(skill: skill);
  }
}

/// What one claim earned.
class Accrual {
  const Accrual({
    this.xpGained = 0,
    this.levelsGained = 0,
    this.countedMs = 0,
    this.capped = false,
  });

  final int xpGained;
  final int levelsGained;

  /// Real time that was turned into XP.
  final int countedMs;

  /// True when more than [maxOfflineMs] had passed and the rest was dropped.
  final bool capped;

  bool get isEmpty => xpGained == 0;
}

class IdleEngine {
  /// Counts the real time since the last claim and adds the XP to [s].
  ///
  /// Leftover time shorter than one tick is kept for the next claim, so short
  /// foreground ticks and long offline gaps add up to the same total.
  static Accrual claim(SkillState s, int nowMs) {
    if (!s.active) {
      s.lastClaimMs = nowMs;
      return const Accrual();
    }
    final elapsed = nowMs - s.lastClaimMs;
    if (elapsed <= 0) {
      // Clock moved backwards (or no time passed): never take XP away,
      // and re-anchor so a clock jump can't be replayed later.
      if (elapsed < 0) s.lastClaimMs = nowMs;
      return const Accrual();
    }
    final capped = elapsed > maxOfflineMs;
    final counted = capped ? maxOfflineMs : elapsed;
    final ticks = counted ~/ tickMs;
    if (capped) {
      s.lastClaimMs = nowMs;
    } else {
      s.lastClaimMs += ticks * tickMs;
    }
    final xp = ticks * xpPerTick;
    final levels = addXp(s, xp);
    return Accrual(xpGained: xp, levelsGained: levels, countedMs: ticks * tickMs, capped: capped);
  }

  /// Adds [xp] and carries any overflow into the next level. Returns levels gained.
  static int addXp(SkillState s, int xp) {
    if (xp <= 0) return 0;
    s.exp += xp;
    var levels = 0;
    while (s.exp >= xpToNext(s.level)) {
      s.exp -= xpToNext(s.level);
      s.level++;
      levels++;
    }
    return levels;
  }

  static void start(SkillState s, int nowMs) {
    if (s.active) return;
    s.active = true;
    s.lastClaimMs = nowMs;
  }

  /// Claims what was earned so far, then stops.
  static Accrual stop(SkillState s, int nowMs) {
    if (!s.active) return const Accrual();
    final a = claim(s, nowMs);
    s.active = false;
    s.lastClaimMs = nowMs;
    return a;
  }
}

/// "2 h 5 m", "45 s"; for the "while you were away" message.
String formatDuration(int ms) {
  final totalS = ms ~/ 1000;
  final h = totalS ~/ 3600;
  final m = (totalS % 3600) ~/ 60;
  final sec = totalS % 60;
  if (h > 0) return m > 0 ? '$h h $m m' : '$h h';
  if (m > 0) return '$m m';
  return '$sec s';
}
