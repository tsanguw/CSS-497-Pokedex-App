import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/theme/type_colors.dart';
import 'package:pokedex_app/view_mode.dart';
import 'package:pokedex_app/widgets/pokemon_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ViewModePreference', () {
    test('defaults to the list', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await ViewModePreference.loadGrid(), isFalse);
    });

    test('remembers the grid choice and switching back', () async {
      SharedPreferences.setMockInitialValues({});
      await ViewModePreference.saveGrid(true);
      expect(await ViewModePreference.loadGrid(), isTrue);
      await ViewModePreference.saveGrid(false);
      expect(await ViewModePreference.loadGrid(), isFalse);
    });
  });

  group('PokemonCard', () {
    Widget host(Widget child) => MaterialApp(
          home: Scaffold(body: SizedBox(width: 170, height: 218, child: child)),
        );

    testWidgets('shows name and number, colored by the first type',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(host(PokemonCard(
        pokemon: const {
          'pok_id': 6,
          'pok_name': 'charizard',
          'types': 'fire, flying',
        },
        onTap: () => tapped = true,
      )));

      expect(find.text('Charizard'), findsOneWidget);
      expect(find.text('#006'), findsOneWidget);
      expect(find.text('Fire'), findsOneWidget);
      expect(find.text('Flying'), findsOneWidget);

      final ink = tester.widget<Ink>(find.byType(Ink));
      final gradient =
          (ink.decoration! as BoxDecoration).gradient! as LinearGradient;
      expect(gradient.colors.first, typeColor('fire'));

      // Artwork sits in a white halo, and the name is centered.
      final halo = tester.widget<Container>(
          find.byKey(const ValueKey('pokemon-card-halo')));
      expect((halo.decoration! as BoxDecoration).shape, BoxShape.circle);
      expect(tester.widget<Text>(find.text('Charizard')).textAlign,
          TextAlign.center);

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });
  });
}
