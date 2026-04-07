import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/smoke_entry.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'breathing_room.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE smoke_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp INTEGER NOT NULL,
            cost REAL NOT NULL
          )
        ''');
      },
    );
  }

  // ── Create ──

  static Future<int> insertEntry(SmokeEntry entry) async {
    final db = await database;
    return db.insert('smoke_entries', entry.toMap());
  }

  // ── Read ──

  static Future<List<SmokeEntry>> getEntriesForDay(DateTime day) async {
    final db = await database;
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    final maps = await db.query(
      'smoke_entries',
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ],
      orderBy: 'timestamp DESC',
    );

    return maps.map(SmokeEntry.fromMap).toList();
  }

  static Future<List<SmokeEntry>> getEntriesInRange(
      DateTime from, DateTime to) async {
    final db = await database;
    final maps = await db.query(
      'smoke_entries',
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [
        from.millisecondsSinceEpoch,
        to.millisecondsSinceEpoch,
      ],
      orderBy: 'timestamp ASC',
    );
    return maps.map(SmokeEntry.fromMap).toList();
  }

  // ── Delete ──

  static Future<int> deleteEntry(int id) async {
    final db = await database;
    return db.delete('smoke_entries', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteAllEntries() async {
    final db = await database;
    return db.delete('smoke_entries');
  }
}
