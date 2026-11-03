import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Saves Idle Plaza progress on this phone (a small key-value table in SQLite).
/// If the database can't open, the app keeps working in memory and says so.
class IdleStore {
  Database? _db;
  bool get isPersistent => _db != null;

  Future<void> open() async {
    try {
      final dir = await getDatabasesPath();
      _db = await openDatabase(
        p.join(dir, 'idle_plaza.db'),
        version: 1,
        onCreate: (db, _) => db.execute('CREATE TABLE kv (k TEXT PRIMARY KEY, v TEXT NOT NULL)'),
      );
    } catch (_) {
      _db = null;
    }
  }

  Future<String?> read(String key) async {
    final db = _db;
    if (db == null) return null;
    try {
      final rows = await db.query('kv', columns: ['v'], where: 'k = ?', whereArgs: [key], limit: 1);
      return rows.isEmpty ? null : rows.first['v'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String key, String value) async {
    final db = _db;
    if (db == null) return;
    try {
      await db.insert('kv', {'k': key, 'v': value}, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {}
  }
}
