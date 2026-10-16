import 'package:actividad_12_flutter/main.dart';
import 'package:actividad_12_flutter/models/pokemon_model.dart';
import 'package:actividad_12_flutter/services/pokemon_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePokemonService extends PokemonService {
  @override
  Future<PokemonModel> getPokemon([String query = '1']) async {
    return const PokemonModel(
      id: 25,
      name: 'pikachu',
      height: 4,
      weight: 60,
      sprite: null,
      stats: {'hp': 35, 'attack': 55, 'defense': 40, 'speed': 90},
      types: ['electric'],
      abilities: ['static'],
      moves: ['thunder-shock'],
    );
  }
}

void main() {
  testWidgets('muestra el Pokémon y permite cambiar el tema', (tester) async {
    await tester.pumpWidget(PokedexApp(pokemonService: _FakePokemonService()));
    await tester.pumpAndSettle();

    expect(find.text('Pikachu'), findsOneWidget);
    expect(find.text('Eléctrico'), findsOneWidget);
    expect(find.text('Estadísticas base'), findsOneWidget);

    await tester.tap(find.byTooltip('Cambiar a tema claro'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Cambiar a tema oscuro'), findsOneWidget);
  });
}
