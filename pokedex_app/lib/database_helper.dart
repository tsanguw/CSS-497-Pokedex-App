import 'dart:io';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'pokedex.db');

    // Always copy the database from assets
    await _copyDatabaseFromAssets(path);

    bool fileExists = await File(path).exists();
    print("Database file exists: $fileExists at path: $path");

    return await openDatabase(path, version: 1);
  }

  Future<void> _copyDatabaseFromAssets(String path) async {
    try {
      // Delete the existing database file if it exists
      if (await File(path).exists()) {
        await File(path).delete();
        print("Deleted existing database file at $path");
      }

      ByteData data = await rootBundle.load(join('assets', 'pokedex.db'));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
      print("Database copied successfully from assets to $path");
    } catch (e) {
      print("Error copying database: $e");
      throw Exception("Error copying database: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getAllPokemon() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        P.pok_id,
        P.pok_name,
        P.pok_height,
        P.pok_weight,
        GROUP_CONCAT(T.type_name, ', ') AS types
      FROM 
        POKEMON P
      JOIN 
        POKEMON_BEARS_TYPE PBT ON P.pok_id = PBT.pok_id
      JOIN 
        TYPE T ON PBT.type_id = T.type_id
      GROUP BY 
        P.pok_id, P.pok_name
      ORDER BY 
        P.pok_id ASC
    ''');
    return result;
  }

  Future<List<Map<String, dynamic>>> getAllMoves() async {
    final db = await database;
    return await db.query('MOVE');
  }

  Future<List<Map<String, dynamic>>> getAllAbilities() async {
    final db = await database;
    return await db.query('ABILITIES');
  }

  Future<List<Map<String, dynamic>>> getAllNatures() async {
    final db = await database;
    return await db.query('NATURE');
  }

  Future<List<Map<String, dynamic>>> getAllItems() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        I.item_id,
        I.item_name,
        I.item_desc,
        IC.item_cat_name
      FROM 
        ITEM I
      JOIN 
        ITEM_CATEGORY IC ON I.item_cat_id = IC.item_cat_id
      LIMIT 10
    ''');
    return result;
  }

  Future<List<Map<String, dynamic>>> getAllGymLeaders() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        trainer_id,
        trainer_name,
        trainer_gym_name,
        trainer_game,
        trainer_gen
      FROM 
        TRAINER
      WHERE 
        trainer_gym_name IS NOT NULL
    ''');
    return result;
  }
}
