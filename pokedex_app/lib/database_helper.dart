import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'async_cache.dart';
import 'search_filter.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  // Bump this whenever assets/pokedex.db is replaced so devices re-copy it.
  static const int _assetDbVersion = 3;
  static const String _assetDbVersionKey = 'assetDbVersion';

  // The saved items list is derived from the bundled DB, so its key carries
  // the DB version: replacing the DB (bumping the version above) invalidates
  // it. Saving also deletes copies left by older versions, including the
  // original unversioned 'cachedItems'.
  static const String _itemsCachePrefix = 'cachedItems';
  static const String _itemsCacheKey = '${_itemsCachePrefix}_v$_assetDbVersion';

  // Comma-joined type names for the row's POKEMON alias `P`, in slot order
  // (primary type first). POKEMON_BEARS_TYPE rows are inserted in slot order,
  // so ordering by rowid keeps that; a plain join sorts by type_id instead.
  static const String _typesSql =
      '''(SELECT GROUP_CONCAT(type_name, ', ') FROM (
        SELECT T2.type_name AS type_name
        FROM POKEMON_BEARS_TYPE PBT2
        JOIN TYPE T2 ON PBT2.type_id = T2.type_id
        WHERE PBT2.pok_id = P.pok_id
        ORDER BY PBT2.rowid))''';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'pokedex.db');

    // Only copy the bundled database on first launch or when it has changed.
    final prefs = await SharedPreferences.getInstance();
    final installedVersion = prefs.getInt(_assetDbVersionKey);
    if (installedVersion != _assetDbVersion || !await File(path).exists()) {
      await _copyDatabaseFromAssets(path);
      await prefs.setInt(_assetDbVersionKey, _assetDbVersion);
    }

    // No `version` here: sqflite would try to write PRAGMA user_version,
    // which fails on a read-only database.
    return await openDatabase(path, readOnly: true);
  }

  Future<void> _copyDatabaseFromAssets(String path) async {
    try {
      // Close any open handle and clear stale files before overwriting.
      await databaseFactory.deleteDatabase(path);

      ByteData data = await rootBundle.load(join('assets', 'pokedex.db'));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    } catch (e) {
      throw Exception("Error copying database: $e");
    }
  }

  // The whole Pokemon list, loaded once per app run. The database is bundled
  // and read-only, so it can't go stale. Searching filters this in memory.
  final AsyncCache<List<Map<String, dynamic>>> _pokemonCache = AsyncCache();

  Future<List<Map<String, dynamic>>> getAllPokemon(
      {String searchQuery = ''}) async {
    final all = await _pokemonCache.get(_queryAllPokemon);
    return filterByName(all, 'pok_name', searchQuery);
  }

  // Only the columns the list screens read; the detail screen loads the
  // rest (height, weight, base stats) through getPokemonDetails.
  Future<List<Map<String, dynamic>>> _queryAllPokemon() =>
      _loadList('Pokemon', '''
      SELECT
        P.pok_id,
        P.pok_name,
        $_typesSql AS types
      FROM
        POKEMON P
      ORDER BY
        P.pok_id ASC
    ''');

  // Runs [sql] once for a list that is then kept for the rest of the run. In
  // debug builds it logs how long that one load took.
  Future<List<Map<String, dynamic>>> _loadList(String label, String sql) async {
    final db = await database;
    final timer = Stopwatch()..start();
    final result = await db.rawQuery(sql);
    if (kDebugMode) {
      debugPrint('[pokedex] loaded ${result.length} $label in '
          '${timer.elapsedMilliseconds} ms (cached for this run)');
    }
    return List.unmodifiable(result);
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
      $_typesSql AS types,
      B.b_hp,
      B.b_atk,
      B.b_def,
      B.b_sp_atk,
      B.b_sp_def,
      B.b_speed
    FROM
      POKEMON P
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

    // Print type IDs
    // print('Type IDs: $typeIds');

    // Fetch type effectiveness
    final typeEfficacyResults = await db.rawQuery('''
    SELECT
      SourceType.type_name AS source_type_name,
      TE.type_id,
      TargetType.type_name AS target_type_name,
      TE.target_type_id,
      TE.dmg_factor
    FROM
      TYPE_EFFICACY TE
    JOIN
      TYPE SourceType ON TE.type_id = SourceType.type_id
    JOIN
      TYPE TargetType ON TE.target_type_id = TargetType.type_id
    WHERE
      TE.target_type_id IN (${typeIds.join(', ')})
  ''');

    Map<String, double> typeEffectiveness = {};

    // Calculate type effectiveness considering multiple types
    for (var result in typeEfficacyResults) {
      String? typeName = result['source_type_name'] as String?;
      double dmgFactor = result['dmg_factor'] as double;

      if (typeName != null) {
        double effectiveness = dmgFactor; // Convert dmg_factor to a multiplier

        // Combine effectiveness across multiple types
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

    // Print type effectiveness calculations
    // print('Type Effectiveness Calculations:');
    // typeEffectiveness.forEach((type, effectiveness) {
    //   print('$type: $effectiveness');
    // });

    // Print weaknesses, resistances, immunities
    // print('Weaknesses: $weaknesses');
    // print('Resistances: $resistances');
    // print('Immunities: $immunities');

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
        T.type_name AS move_type_name,
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
      LEFT JOIN
        TYPE T ON M.type_id = T.type_id
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

  final AsyncCache<List<Map<String, dynamic>>> _movesCache = AsyncCache();

  Future<List<Map<String, dynamic>>> getAllMoves(
      {String searchQuery = ''}) async {
    final all = await _movesCache.get(_queryAllMoves);
    return filterByName(all, 'move_name', searchQuery);
  }

  Future<List<Map<String, dynamic>>> _queryAllMoves() => _loadList('moves', '''
      SELECT
        M.move_id,
        M.move_name,
        M.move_power,
        M.move_accuracy,
        M.move_pp,
        T.type_name
      FROM
        MOVE M
      JOIN
        TYPE T ON M.type_id = T.type_id
      ORDER BY
        M.move_name ASC
    ''');

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
        $_typesSql AS types
      FROM
        POKEMON P
      JOIN
        MOVESET MS ON P.pok_id = MS.pok_id
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

  final AsyncCache<List<Map<String, dynamic>>> _abilitiesCache = AsyncCache();

  Future<List<Map<String, dynamic>>> getAllAbilities(
      {String searchQuery = ''}) async {
    final all = await _abilitiesCache.get(_queryAllAbilities);
    return filterByName(all, 'abi_name', searchQuery);
  }

  Future<List<Map<String, dynamic>>> _queryAllAbilities() =>
      _loadList('abilities', '''
      SELECT
        abi_id,
        abi_name,
        abi_desc
      FROM
        ABILITIES
      ORDER BY
        abi_name ASC
    ''');

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
        $_typesSql AS types
      FROM
        POKEMON P
      JOIN
        POKEMON_POSSESSES_ABILITY PA ON P.pok_id = PA.pok_id
      WHERE
        PA.abi_id = ?
      GROUP BY 
        P.pok_id, P.pok_name
      ORDER BY 
        P.pok_id
    ''', [abilityId]);

    return result;
  }

  final AsyncCache<List<Map<String, dynamic>>> _naturesCache = AsyncCache();

  Future<List<Map<String, dynamic>>> getAllNatures(
      {String searchQuery = ''}) async {
    final all = await _naturesCache.get(_queryAllNatures);
    return filterByName(all, 'nat_name', searchQuery);
  }

  Future<List<Map<String, dynamic>>> _queryAllNatures() =>
      _loadList('natures', '''
      SELECT
        nat_id,
        nat_name,
        nat_increase,
        nat_decrease
      FROM
        NATURE
      ORDER BY
        nat_name ASC
    ''');

  Future<bool> _imageExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  final AsyncCache<List<Map<String, dynamic>>> _itemsCache = AsyncCache();

  Future<List<Map<String, dynamic>>> getAllItems(
      {String searchQuery = ''}) async {
    final all = await _itemsCache.get(_loadAllItems);
    return filterByName(all, 'item_name', searchQuery);
  }

  // The items that have a sprite, in name order. Checking which sprites exist
  // loads one asset per item, which is slow, so the result is also saved to
  // SharedPreferences and reused on later runs.
  Future<List<Map<String, dynamic>>> _loadAllItems() async {
    final saved = await _loadCachedItems();
    if (saved != null) return List.unmodifiable(saved);

    final items = await _loadList('items', '''
      SELECT
        I.item_id,
        I.item_name,
        I.item_desc,
        IC.item_cat_name
      FROM
        ITEM I
      JOIN
        ITEM_CATEGORY IC ON I.item_cat_id = IC.item_cat_id
      ORDER BY
        I.item_name ASC
    ''');

    final withSprites = <Map<String, dynamic>>[];
    for (final item in items) {
      if (await _imageExists('assets/sprites/items/${item['item_name']}.png')) {
        withSprites.add(item);
      }
    }
    await _saveCachedItems(withSprites);
    return List.unmodifiable(withSprites);
  }

  Future<void> _saveCachedItems(List<Map<String, dynamic>> items) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedItems = jsonEncode(items);
    await prefs.setString(_itemsCacheKey, encodedItems);
    final stale = prefs
        .getKeys()
        .where((k) => k.startsWith(_itemsCachePrefix) && k != _itemsCacheKey)
        .toList();
    for (final key in stale) {
      await prefs.remove(key);
    }
  }

  Future<List<Map<String, dynamic>>?> _loadCachedItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? encodedItems = prefs.getString(_itemsCacheKey);
    if (encodedItems != null) {
      List<dynamic> decodedItems = jsonDecode(encodedItems);
      return decodedItems.cast<Map<String, dynamic>>();
    }
    return null;
  }

  final AsyncCache<List<Map<String, dynamic>>> _gymLeadersCache = AsyncCache();

  Future<List<Map<String, dynamic>>> getAllGymLeaders(
      {String searchQuery = ''}) async {
    final all = await _gymLeadersCache.get(_queryAllGymLeaders);
    return filterByName(all, 'trainer_name', searchQuery);
  }

  Future<List<Map<String, dynamic>>> _queryAllGymLeaders() =>
      _loadList('gym leaders', '''
      SELECT
        trainer_id,
        trainer_name,
        trainer_gym_name,
        trainer_game,
        trainer_gen
      FROM
        TRAINER
      ORDER BY
        trainer_id ASC
    ''');

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

  Future<List<Map<String, dynamic>>> getPokemonAbilities(int pokId) async {
    final db = await database;
    final abilities = await db.rawQuery('''
    SELECT 
      A.abi_id, A.abi_name, A.abi_desc, PA.is_hidden
    FROM 
      POKEMON_POSSESSES_ABILITY PA
    JOIN 
      ABILITIES A ON PA.abi_id = A.abi_id
    WHERE 
      PA.pok_id = ?
  ''', [pokId]);

    return abilities;
  }

  Future<List<Map<String, dynamic>>> getPokemonItems() async {
    final db = await database;
    final items = await db.rawQuery('''
    SELECT 
      item_id, item_name, item_desc
    FROM 
      ITEM
  ''');

    return items;
  }

  /// Items by ID, from the full item table (the item picker lists every item,
  /// including ones without a sprite that the Items screen leaves out).
  Future<List<Map<String, dynamic>>> getItemsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final db = await database;
    final marks = List.filled(ids.length, '?').join(', ');
    return db.rawQuery('''
      SELECT
        item_id, item_name, item_desc
      FROM
        ITEM
      WHERE
        item_id IN ($marks)
    ''', ids);
  }
}
