import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/timer_record.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static DatabaseService get instance => _instance;
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'timer_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE timer_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        startTime INTEGER NOT NULL,
        endTime INTEGER,
        duration INTEGER NOT NULL,
        description TEXT,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertRecord(TimerRecord record) async {
    final db = await database;
    return await db.insert('timer_records', record.toMap());
  }

  Future<List<TimerRecord>> getRecordsByDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'timer_records',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'startTime DESC',
    );
    return List.generate(maps.length, (i) => TimerRecord.fromMap(maps[i]));
  }

  Future<List<TimerRecord>> getAllRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'timer_records',
      orderBy: 'startTime DESC',
    );
    return List.generate(maps.length, (i) => TimerRecord.fromMap(maps[i]));
  }

  Future<Map<String, int>> getDailyStats() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT date, SUM(duration) as totalDuration
      FROM timer_records
      GROUP BY date
      ORDER BY date DESC
    ''');
    
    Map<String, int> stats = {};
    for (var row in result) {
      stats[row['date']] = row['totalDuration'];
    }
    return stats;
  }

  Future<void> deleteRecord(int id) async {
    final db = await database;
    await db.delete('timer_records', where: 'id = ?', whereArgs: [id]);
  }
}
