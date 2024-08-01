import 'dart:io';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
      print("Database copied successfully from assets to $path");
    } catch (e) {
      print("Error copying database: $e");
      throw Exception("Error copying database: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getAllPokemon(
      {String searchQuery = ''}) async {
    final db = await database;
    String query = '''
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
    ''';

    if (searchQuery.isNotEmpty) {
      query += '''
        WHERE P.pok_name LIKE '%$searchQuery%'
      ''';
    }

    query += '''
      GROUP BY 
        P.pok_id, P.pok_name
      ORDER BY 
        P.pok_id ASC
    ''';

    final result = await db.rawQuery(query);
    return result;
  }

  Future<Map<String, dynamic>> getPokemonDetails(int pokId) async {
    final db = await database;

    // Fetch Pokémon details
    final pokemonResult = await db.rawQuery('''
    SELECT 
      P.pok_id,
      P.pok_name,
      P.pok_height,
      P.pok_weight,
      GROUP_CONCAT(T.type_name, ', ') AS types,
      GROUP_CONCAT(T.type_id, ', ') AS type_ids,
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

    // Fetch evolutions
    final evolutionResults = await db.rawQuery('''
    SELECT 
      E.pok_id,
      P.pok_name AS current_pok_name,
      E.pre_evol_pok_id,
      PreEvol.pok_name AS pre_evol_pok_name,
      E.evol_pok_id,
      Evol.pok_name AS evol_pok_name,
      E.evol_min_lvl,
      EM.evol_method_name
    FROM 
      EVOLUTION E
    LEFT JOIN 
      POKEMON P ON E.pok_id = P.pok_id
    LEFT JOIN 
      POKEMON PreEvol ON E.pre_evol_pok_id = PreEvol.pok_id
    LEFT JOIN 
      POKEMON Evol ON E.evol_pok_id = Evol.pok_id
    LEFT JOIN 
      EVOLUTION_METHOD EM ON E.evol_method_id = EM.evol_method_id
    WHERE
      E.pok_id = ? OR E.pre_evol_pok_id = ? OR E.evol_pok_id = ?
  ''', [pokId, pokId, pokId]);

    // Organize evolution chain
    List<Map<String, dynamic>> evolutions = [];
    for (var result in evolutionResults) {
      evolutions.add({
        'current_pok_id': result['pok_id'],
        'current_pok_name': result['current_pok_name'],
        'pre_evol_pok_id': result['pre_evol_pok_id'],
        'pre_evol_pok_name': result['pre_evol_pok_name'],
        'evol_pok_id': result['evol_pok_id'],
        'evol_pok_name': result['evol_pok_name'],
        'evol_min_lvl': result['evol_min_lvl'],
        'evol_method_name': result['evol_method_name']
      });
    }

    // Fetch abilities
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

    // Extract type IDs
    final typeIdsResult = await db.rawQuery('''
    SELECT
      PBT.type_id
    FROM
      POKEMON_BEARS_TYPE PBT
    WHERE
      PBT.pok_id = ?
  ''', [pokId]);

    List<int> typeIds =
        typeIdsResult.map((type) => type['type_id'] as int).toList();

    // Fetch type effectiveness
    final typeEfficacyResults = await db.rawQuery('''
    SELECT
      T.type_name,
      TE.type_id,
      TE.target_type_id,
      TE.dmg_factor
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
      double? effectiveness = result['dmg_factor'] as double?;

      if (typeName != null && effectiveness != null) {
        if (typeEffectiveness.containsKey(typeName)) {
          typeEffectiveness[typeName] =
              typeEffectiveness[typeName]! * effectiveness;
        } else {
          typeEffectiveness[typeName] = effectiveness;
        }
      }
    }

    List<Map<String, dynamic>> weaknesses = [];
    List<Map<String, dynamic>> resistances = [];
    List<Map<String, dynamic>> immunities = [];

    typeEffectiveness.forEach((type, effectiveness) {
      if (effectiveness == 0) {
        immunities.add({'type_name': type});
      } else if (effectiveness > 1) {
        weaknesses.add({'type_name': type, 'effectiveness': effectiveness});
      } else if (effectiveness < 1) {
        resistances.add({'type_name': type, 'effectiveness': effectiveness});
      }
    });

    return {
      'pokemon': pokemonResult.isNotEmpty ? pokemonResult.first : null,
      'evolutions': evolutionResults,
      'abilities': abilitiesResult,
      'weaknesses': weaknesses,
      'resistances': resistances,
      'immunities': immunities,
    };
  }

  Future<List<Map<String, dynamic>>> getPokemonMoveset(int pokId,
      {int? generation, int? method}) async {
    final db = await database;

    String query = '''
      SELECT 
        M.move_id,
        M.move_name,
        M.move_type,
        M.move_power,
        M.move_accuracy,
        M.move_pp,
        MM.move_method_name,
        G.gen_name,
        MS.level_learned
      FROM 
        MOVESET MS
      JOIN 
        MOVE M ON MS.move_id = M.move_id
      JOIN 
        MOVE_METHOD MM ON MS.method_id = MM.move_method_id
      JOIN 
        GENERATION G ON MS.gen_id = G.gen_id
      WHERE 
        MS.pok_id = ?
    ''';

    List<dynamic> args = [pokId];

    if (generation != null) {
      query += ' AND MS.gen_id = ?';
      args.add(generation);
    }

    if (method != null) {
      query += ' AND MS.method_id = ?';
      args.add(method);
    }

    query +=
        ' ORDER BY MS.level_learned, G.gen_name, MM.move_method_name, M.move_name';

    // Debugging: Print the query and parameters
    // print('Query: $query');
    // print('Arguments: $args');

    final result = await db.rawQuery(query, args);

    // Debugging: Print the result
    // print('Result: $result');

    return result;
  }

  Future<List<Map<String, dynamic>>> getAllMoves(
      {String searchQuery = ''}) async {
    final db = await database;
    String query = '''
      SELECT 
        M.move_id,
        M.move_name,
        M.move_power,
        M.move_accuracy,
        T.type_name
      FROM 
        MOVE M
      JOIN 
        TYPE T ON M.type_id = T.type_id
    ''';

    if (searchQuery.isNotEmpty) {
      query += '''
        WHERE M.move_name LIKE '%$searchQuery%'
      ''';
    }

    query += '''
      ORDER BY 
        M.move_name ASC
    ''';

    final result = await db.rawQuery(query);
    return result;
  }

  Future<Map<String, dynamic>> getMoveDetails(int moveId) async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT 
        M.move_id,
        M.move_name,
        T.type_name,
        M.move_power,
        M.move_accuracy,
        M.move_pp,
        M.move_effect
      FROM 
        MOVE M
      JOIN 
        TYPE T ON M.type_id = T.type_id
      WHERE 
        M.move_id = ?
    ''', [moveId]);

    return result.isNotEmpty ? result.first : {};
  }

  Future<List<Map<String, dynamic>>> getPokemonWithMove(int moveId,
      {int? generation, int? method}) async {
    final db = await database;

    String query = '''
      SELECT 
        P.pok_id,
        P.pok_name,
        GROUP_CONCAT(T.type_name, ', ') AS types
      FROM 
        POKEMON P
      JOIN 
        MOVESET MS ON P.pok_id = MS.pok_id
      JOIN 
        POKEMON_BEARS_TYPE PBT ON P.pok_id = PBT.pok_id
      JOIN 
        TYPE T ON PBT.type_id = T.type_id
      WHERE 
        MS.move_id = ?
    ''';

    List<dynamic> args = [moveId];

    if (generation != null) {
      query += ' AND MS.gen_id = ?';
      args.add(generation);
    }

    if (method != null) {
      query += ' AND MS.method_id = ?';
      args.add(method);
    }

    query += ' GROUP BY P.pok_id, P.pok_name ORDER BY P.pok_id';

    final result = await db.rawQuery(query, args);

    return result;
  }

  Future<List<Map<String, dynamic>>> getAllAbilities(
      {String searchQuery = ''}) async {
    final db = await database;
    String query = '''
      SELECT 
        abi_id,
        abi_name,
        abi_desc
      FROM 
        ABILITIES
    ''';

    if (searchQuery.isNotEmpty) {
      query += '''
        WHERE abi_name LIKE '%$searchQuery%'
      ''';
    }

    query += '''
      ORDER BY 
        abi_name ASC
    ''';

    final result = await db.rawQuery(query);
    return result;
  }

  Future<Map<String, dynamic>> getAbilityDetails(int abilityId) async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT 
        abi_id,
        abi_name,
        abi_desc
      FROM 
        ABILITIES
      WHERE 
        abi_id = ?
    ''', [abilityId]);

    return result.isNotEmpty ? result.first : {};
  }

  Future<List<Map<String, dynamic>>> getPokemonWithAbility(
      int abilityId) async {
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
        POKEMON_POSSESSES_ABILITY PA ON P.pok_id = PA.pok_id
      JOIN 
        POKEMON_BEARS_TYPE PBT ON P.pok_id = PBT.pok_id
      JOIN 
        TYPE T ON PBT.type_id = T.type_id
      WHERE 
        PA.abi_id = ?
      GROUP BY 
        P.pok_id, P.pok_name
      ORDER BY 
        P.pok_id
    ''', [abilityId]);

    return result;
  }

  Future<List<Map<String, dynamic>>> getAllNatures(
      {String searchQuery = ''}) async {
    final db = await database;
    String query = '''
      SELECT 
        nat_id,
        nat_name,
        nat_increase,
        nat_decrease
      FROM 
        NATURE
    ''';

    if (searchQuery.isNotEmpty) {
      query += '''
        WHERE nat_name LIKE '%$searchQuery%'
      ''';
    }

    query += '''
      ORDER BY 
        nat_name ASC
    ''';

    final result = await db.rawQuery(query);
    return result;
  }

  Future<bool> _imageExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  List<Map<String, dynamic>>? _cachedItems;

  Future<List<Map<String, dynamic>>> getAllItems(
      {String searchQuery = ''}) async {
    // Try to load the cached list from shared preferences if available and the search query is empty
    if (_cachedItems == null && searchQuery.isEmpty) {
      _cachedItems = await _loadCachedItems();
    }

    // Return the cached list if available and the search query is empty
    if (_cachedItems != null && searchQuery.isEmpty) {
      return _cachedItems!;
    }

    final db = await database;
    String query = '''
      SELECT 
        I.item_id,
        I.item_name,
        I.item_desc,
        IC.item_cat_name
      FROM 
        ITEM I
      JOIN 
        ITEM_CATEGORY IC ON I.item_cat_id = IC.item_cat_id
    ''';

    if (searchQuery.isNotEmpty) {
      query += '''
        WHERE I.item_name LIKE '%$searchQuery%'
      ''';
    }

    query += '''
      ORDER BY 
        I.item_name ASC
    ''';

    final result = await db.rawQuery(query);

    List<Map<String, dynamic>> filteredResult = [];
    for (var item in result) {
      final imagePath = 'assets/sprites/items/${item['item_name']}.png';
      if (await _imageExists(imagePath)) {
        filteredResult.add(item);
      }
    }

    // Cache and persist the filtered list if the search query is empty
    if (searchQuery.isEmpty) {
      _cachedItems = filteredResult;
      await _saveCachedItems(filteredResult);
    }

    return filteredResult;
  }

  Future<void> _saveCachedItems(List<Map<String, dynamic>> items) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedItems = jsonEncode(items);
    await prefs.setString('cachedItems', encodedItems);
  }

  Future<List<Map<String, dynamic>>?> _loadCachedItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? encodedItems = prefs.getString('cachedItems');
    if (encodedItems != null) {
      List<dynamic> decodedItems = jsonDecode(encodedItems);
      return decodedItems.cast<Map<String, dynamic>>();
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllGymLeaders(
      {String searchQuery = ''}) async {
    final db = await database;
    String query = '''
      SELECT 
        trainer_id,
        trainer_name,
        trainer_gym_name,
        trainer_game,
        trainer_gen
      FROM 
        TRAINER
    ''';

    if (searchQuery.isNotEmpty) {
      query += '''
        WHERE trainer_name LIKE '%$searchQuery%'
      ''';
    }

    query += '''
      ORDER BY 
        trainer_name ASC
    ''';

    final result = await db.rawQuery(query);
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

    final teamResult = await db.rawQuery('''
      SELECT 
        T.trainer_id,
        T.pok_id,
        T.pok_lvl,
        P.pok_name,
        T.position,
        M1.move_name AS move1,
        M2.move_name AS move2,
        M3.move_name AS move3,
        M4.move_name AS move4
      FROM 
        TEAM T
      JOIN 
        POKEMON P ON T.pok_id = P.pok_id
      LEFT JOIN 
        MOVE M1 ON T.move1_id = M1.move_id
      LEFT JOIN 
        MOVE M2 ON T.move2_id = M2.move_id
      LEFT JOIN 
        MOVE M3 ON T.move3_id = M3.move_id
      LEFT JOIN 
        MOVE M4 ON T.move4_id = M4.move_id
      WHERE 
        T.trainer_id = ?
      ORDER BY 
        T.position
    ''', [trainerId]);

    return {
      'gym_leader': result.isNotEmpty ? result.first : {},
      'team': teamResult
    };
  }
}
