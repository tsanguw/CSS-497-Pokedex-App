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
        GROUP_CONCAT(T.type_name, ', ') AS types,
        B.b_hp,
        B.b_atk,
        B.b_def,
        B.b_sp_atk,
        B.b_sp_def,
        B.b_speed
      FROM 
        POKEMON P
      JOIN 
        POKEMON_BEARS_TYPE PBT ON P.pok_id = PBT.pok_id
      JOIN 
        TYPE T ON PBT.type_id = T.type_id
      JOIN 
        BASE_STATS B ON P.pok_id = B.pok_id
      GROUP BY 
        P.pok_id, P.pok_name
      ORDER BY 
        P.pok_id ASC
    ''');
    return result;
  }

  Future<Map<String, dynamic>> getPokemonDetails(int pokId) async {
    final db = await database;

    final pokemonResult = await db.rawQuery('''
      SELECT 
        P.pok_id,
        P.pok_name,
        P.pok_height,
        P.pok_weight,
        GROUP_CONCAT(T.type_name, ', ') AS types,
        B.b_hp,
        B.b_atk,
        B.b_def,
        B.b_sp_atk,
        B.b_sp_def,
        B.b_speed
      FROM 
        POKEMON P
      JOIN 
        POKEMON_BEARS_TYPE PBT ON P.pok_id = PBT.pok_id
      JOIN 
        TYPE T ON PBT.type_id = T.type_id
      JOIN 
        BASE_STATS B ON P.pok_id = B.pok_id
      WHERE
        P.pok_id = ?
      GROUP BY 
        P.pok_id, P.pok_name
    ''', [pokId]);

    final evolutionsResult = await db.rawQuery('''
      SELECT 
        E.pre_evol_pok_id,
        PE.pok_name AS pre_evol_pok_name,
        E.evol_pok_id,
        CE.pok_name AS evol_pok_name,
        E.evol_min_lvl,
        EM.evol_method_name
      FROM 
        EVOLUTION E
      LEFT JOIN 
        POKEMON PE ON E.pre_evol_pok_id = PE.pok_id
      LEFT JOIN 
        POKEMON CE ON E.evol_pok_id = CE.pok_id
      LEFT JOIN 
        EVOLUTION_METHOD EM ON E.evol_method_id = EM.evol_method_id
      WHERE
        E.pre_evol_pok_id = ? OR E.evol_pok_id = ?
    ''', [pokId, pokId]);

    // Create a mutable list of evolution results
    List<Map<String, dynamic>> mutableEvolutionsResult = List.from(evolutionsResult);

    // Create a set to track unique evolution entries
    Set<String> uniqueEvolutions = mutableEvolutionsResult.map((evolution) {
      return '${evolution['pre_evol_pok_id']}-${evolution['evol_pok_id']}-${evolution['evol_method_name']}';
    }).toSet();

    // Create a set of evolution IDs
    Set<int> evolutionIds = mutableEvolutionsResult.expand((evolution) {
      return [
        evolution['pre_evol_pok_id'] as int?,
        evolution['evol_pok_id'] as int?
      ].whereType<int>().toSet();
    }).toSet();

    for (int id in evolutionIds) {
      final additionalEvolutions = await db.rawQuery('''
        SELECT 
          E.pre_evol_pok_id,
          PE.pok_name AS pre_evol_pok_name,
          E.evol_pok_id,
          CE.pok_name AS evol_pok_name,
          E.evol_min_lvl,
          EM.evol_method_name
        FROM 
          EVOLUTION E
        LEFT JOIN 
          POKEMON PE ON E.pre_evol_pok_id = PE.pok_id
        LEFT JOIN 
          POKEMON CE ON E.evol_pok_id = CE.pok_id
        LEFT JOIN 
          EVOLUTION_METHOD EM ON E.evol_method_id = EM.evol_method_id
        WHERE
          E.pre_evol_pok_id = ? OR E.evol_pok_id = ?
      ''', [id, id]);

      for (var evolution in additionalEvolutions) {
        String evolutionKey = '${evolution['pre_evol_pok_id']}-${evolution['evol_pok_id']}-${evolution['evol_method_name']}';
        if (!uniqueEvolutions.contains(evolutionKey)) {
          mutableEvolutionsResult.add(evolution);
          uniqueEvolutions.add(evolutionKey);
        }
      }
    }

    final abilitiesResult = await db.rawQuery('''
      SELECT 
        A.abi_name,
        PA.is_hidden
      FROM 
        POKEMON_POSSESSES_ABILITY PA
      JOIN 
        ABILITIES A ON PA.abi_id = A.abi_id
      WHERE 
        PA.pok_id = ?
    ''', [pokId]);

    final typeIdsResult = await db.rawQuery('''
      SELECT
        PBT.type_id
      FROM
        POKEMON_BEARS_TYPE PBT
      WHERE
        PBT.pok_id = ?
    ''', [pokId]);

    // Extract type IDs
    List<int> typeIds = typeIdsResult.map((type) => type['type_id'] as int).toList();

    // Fetch weaknesses and resistances
    final typeEfficacyResults = await db.rawQuery('''
      SELECT
        T.type_name,
        TE.target_type_id,
        (TE.dmg_factor / 100.0) as effectiveness
      FROM
        TYPE_EFFICACY TE
      JOIN
        TYPE T ON TE.target_type_id = T.type_id
      WHERE
        TE.type_id IN (${typeIds.join(', ')})
    ''');

    Map<String, double> typeEffectiveness = {};

    for (var result in typeEfficacyResults) {
      String? typeName = result['type_name'] as String?;
      double? effectiveness = result['effectiveness'] as double?;

      if (typeName != null && effectiveness != null) {
        if (typeEffectiveness.containsKey(typeName)) {
          typeEffectiveness[typeName] = typeEffectiveness[typeName]! * effectiveness;
        } else {
          typeEffectiveness[typeName] = effectiveness;
        }
      }
    }

    List<Map<String, dynamic>> weaknesses = [];
    List<Map<String, dynamic>> resistances = [];

    typeEffectiveness.forEach((type, effectiveness) {
      if (effectiveness > 1) {
        weaknesses.add({'type_name': type, 'effectiveness': effectiveness});
      } else if (effectiveness < 1) {
        resistances.add({'type_name': type, 'effectiveness': effectiveness});
      }
    });

    return {
      'pokemon': pokemonResult.isNotEmpty ? pokemonResult.first : null,
      'evolutions': mutableEvolutionsResult,
      'abilities': abilitiesResult,
      'weaknesses': weaknesses,
      'resistances': resistances,
    };
  }

  Future<List<Map<String, dynamic>>> getAllMoves() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        M.move_name,
        M.move_type,
        M.move_power,
        M.move_accuracy,
        M.move_pp,
        M.move_effect,
        M.type_id,
        T.type_name
      FROM 
        MOVE M
      JOIN 
        TYPE T ON M.type_id = T.type_id
    ''');
    return result;
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

  Future<Map<String, dynamic>> getGymLeaderDetails(int trainerId) async {
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
        trainer_id = ?
    ''', [trainerId]);

    return result.isNotEmpty ? result.first : {};
  }
}