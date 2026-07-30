import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/models/statistics_model.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

/// SQLite-based storage for competition history and statistics.
class SqliteStorage {
  Database? _db;

  static const int _version = 1;
  static const String _dbName = 'buzz_master.db';

  static const String _tableCompetitions = 'competitions';

  Future<void> initialize() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    _db = await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    _log.d('SQLite database opened at $path');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableCompetitions (
        id TEXT PRIMARY KEY,
        room_code TEXT NOT NULL,
        competition_name TEXT NOT NULL,
        started_at TEXT NOT NULL,
        ended_at TEXT,
        data TEXT NOT NULL
      )
    ''');
    _log.d('Database tables created');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migration logic here.
  }

  // ─── Competitions ──────────────────────────────────────────────────────────

  /// Save or update a competition's statistics.
  Future<void> saveCompetition(StatisticsModel stats) async {
    if (_db == null) return;
    await _db!.insert(
      _tableCompetitions,
      {
        'id': stats.roomCode + stats.startedAt.toIso8601String(),
        'room_code': stats.roomCode,
        'competition_name': stats.competitionName,
        'started_at': stats.startedAt.toIso8601String(),
        'ended_at': stats.endedAt?.toIso8601String(),
        'data': jsonEncode(stats.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Load all competitions from history.
  Future<List<StatisticsModel>> loadAllCompetitions() async {
    if (_db == null) return [];
    final rows = await _db!.query(
      _tableCompetitions,
      orderBy: 'started_at DESC',
    );
    return rows.map((row) {
      try {
        return StatisticsModel.fromJson(
          jsonDecode(row['data'] as String) as Map<String, dynamic>,
        );
      } catch (e) {
        _log.e('Failed to parse competition: $e');
        return null;
      }
    }).whereType<StatisticsModel>().toList();
  }

  /// Load a single competition by room code.
  Future<StatisticsModel?> loadCompetition(String roomCode) async {
    if (_db == null) return null;
    final rows = await _db!.query(
      _tableCompetitions,
      where: 'room_code = ?',
      whereArgs: [roomCode],
      orderBy: 'started_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    try {
      return StatisticsModel.fromJson(
        jsonDecode(rows.first['data'] as String) as Map<String, dynamic>,
      );
    } catch (e) {
      _log.e('Failed to parse competition: $e');
      return null;
    }
  }

  /// Delete a competition by id.
  Future<void> deleteCompetition(String roomCode, DateTime startedAt) async {
    if (_db == null) return;
    await _db!.delete(
      _tableCompetitions,
      where: 'id = ?',
      whereArgs: [roomCode + startedAt.toIso8601String()],
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
