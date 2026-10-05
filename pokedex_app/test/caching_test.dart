import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/async_cache.dart';
import 'package:pokedex_app/search_filter.dart';

void main() {
  group('AsyncCache', () {
    test('runs the load once for repeated calls', () async {
      final cache = AsyncCache<int>();
      var loads = 0;
      Future<int> load() async => ++loads;

      expect(await cache.get(load), 1);
      expect(await cache.get(load), 1);
      expect(await cache.get(load), 1);
      expect(loads, 1);
    });

    test('shares one load between calls made while it is still running',
        () async {
      final cache = AsyncCache<String>();
      final gate = Completer<String>();
      var loads = 0;
      Future<String> load() {
        loads++;
        return gate.future;
      }

      final a = cache.get(load);
      final b = cache.get(load);
      gate.complete('rows');

      expect(await a, 'rows');
      expect(await b, 'rows');
      expect(loads, 1);
    });

    test('forgets a failed load so the next call tries again', () async {
      final cache = AsyncCache<int>();
      var attempts = 0;
      Future<int> flaky() async {
        attempts++;
        if (attempts == 1) throw StateError('database not ready');
        return 42;
      }

      await expectLater(cache.get(flaky), throwsStateError);
      expect(await cache.get(flaky), 42);
      expect(await cache.get(flaky), 42); // and now it is cached
      expect(attempts, 2);
    });
  });

  group('filterByName', () {
    final rows = <Map<String, dynamic>>[
      {'pok_id': 4, 'pok_name': 'charmander'},
      {'pok_id': 6, 'pok_name': 'charizard'},
      {'pok_id': 25, 'pok_name': 'pikachu'},
      {'pok_id': 474, 'pok_name': 'porygon-z'},
    ];
    List<int> ids(String q) => filterByName(rows, 'pok_name', q)
        .map((r) => r['pok_id'] as int)
        .toList();

    test('an empty or blank query returns the rows unchanged', () {
      expect(identical(filterByName(rows, 'pok_name', ''), rows), isTrue);
      expect(identical(filterByName(rows, 'pok_name', '   '), rows), isTrue);
    });

    test('matches substrings anywhere, ignoring case', () {
      expect(ids('char'), [4, 6]);
      expect(ids('CHAR'), [4, 6]);
      expect(ids('ARD'), [6]);
      expect(ids('kac'), [25]);
    });

    test('trims the query and keeps the original order', () {
      expect(ids('  char  '), [4, 6]);
    });

    test('treats hyphens, apostrophes and wildcard characters literally', () {
      expect(ids('gon-z'), [474]);
      expect(ids("'"), isEmpty);
      expect(ids('%'), isEmpty);
      expect(ids('_'), isEmpty);
    });

    test('returns nothing when nothing matches', () {
      expect(ids('zzz'), isEmpty);
    });
  });
}
