import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/widgets/search_results.dart';

void main() {
  late List<String> queries;
  late Map<String, Completer<Rows>> pending;

  Future<Rows> load(String q) {
    queries.add(q);
    return (pending[q] = Completer<Rows>()).future;
  }

  Widget host(String query) => MaterialApp(
        home: Scaffold(
          body: SearchResults(
            searchQuery: query,
            load: load,
            emptyMessage: 'nothing here',
            builder: (context, rows) => ListView(
              children: [for (final r in rows) Text('${r['name']}')],
            ),
          ),
        ),
      );

  setUp(() {
    queries = [];
    pending = {};
  });

  testWidgets('runs the query once, however often it rebuilds', (tester) async {
    await tester.pumpWidget(host('char'));
    for (var i = 0; i < 5; i++) {
      await tester.pumpWidget(host('char'));
    }
    expect(queries, ['char']);
  });

  testWidgets('runs a new query only when the search term changes',
      (tester) async {
    await tester.pumpWidget(host('c'));
    await tester.pumpWidget(host('ch'));
    await tester.pumpWidget(host('ch'));
    expect(queries, ['c', 'ch']);
  });

  testWidgets('keeps the previous rows on screen while the next set loads',
      (tester) async {
    await tester.pumpWidget(host('c'));
    pending['c']!.complete([
      {'name': 'Charmander'},
    ]);
    await tester.pump();
    expect(find.text('Charmander'), findsOneWidget);

    await tester.pumpWidget(host('ch')); // new query still in flight
    expect(find.text('Charmander'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    pending['ch']!.complete([
      {'name': 'Charizard'},
    ]);
    await tester.pumpAndSettle();
    expect(find.text('Charizard'), findsOneWidget);
    expect(find.text('Charmander'), findsNothing);
  });

  testWidgets('shows the empty message and a spinner at the right times',
      (tester) async {
    await tester.pumpWidget(host('zzz'));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    pending['zzz']!.complete(<Map<String, dynamic>>[]);
    await tester.pump();
    expect(find.text('nothing here'), findsOneWidget);
  });
}
