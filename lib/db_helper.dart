

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static const String DB_NAME = 'notes.db';
  static const String TABLE_NAME = 'notes';
  static const String COL_ID = 'id';
  static const String COL_TITLE = 'title';
  static const String COL_CONTENT = 'content';

  static Future<Database> initializeDatabase() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, DB_NAME);

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE $TABLE_NAME(
          $COL_ID INTEGER PRIMARY KEY AUTOINCREMENT,
          $COL_TITLE TEXT,
          $COL_CONTENT TEXT
        )
      ''');
    });
  }

  static Future<int> insertNote(Map<String, dynamic> noteData) async {
    Database db = await initializeDatabase();
    return await db.insert(TABLE_NAME, noteData);
  }

  static Future<List<Map<String, dynamic>>> getNotes() async {
    Database db = await initializeDatabase();
    return await db.query(TABLE_NAME);
  }

  static Future<Map<String, dynamic>?> getNoteById(int id) async {
    Database db = await initializeDatabase();
    List<Map<String, dynamic>> result = await db.query(TABLE_NAME, where: '$COL_ID = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  static Future<int> updateNote(int id, Map<String, dynamic> noteData) async {
    Database db = await initializeDatabase();
    return await db.update(TABLE_NAME, noteData, where: '$COL_ID = ?', whereArgs: [id]);
  }

  static Future<int> deleteNote(int id) async {
    Database db = await initializeDatabase();
    return await db.delete(TABLE_NAME, where: '$COL_ID = ?', whereArgs: [id]);
  }
}
