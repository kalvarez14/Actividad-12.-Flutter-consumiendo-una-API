import 'package:actividad_12_flutter/models/pokemon_model.dart';
import 'package:actividad_12_flutter/services/pokemon_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mantiene /api/v2 al construir la URL de PokéAPI', () async {
    Uri? requestedUri;
    final dio = Dio(
      BaseOptions(baseUrl: 'https://pokeapi.co/api/v2/'),
    )..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestedUri = options.uri;
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                data: <String, dynamic>{
                  'id': 1,
                  'name': 'bulbasaur',
                  'height': 7,
                  'weight': 69,
                  'sprites': <String, dynamic>{},
                  'stats': <dynamic>[],
                  'types': <dynamic>[],
                  'abilities': <dynamic>[],
                  'moves': <dynamic>[],
                },
              ),
            );
          },
        ),
      );

    final pokemon = await PokemonService(dio: dio).getPokemon('1');

    expect(requestedUri, Uri.parse('https://pokeapi.co/api/v2/pokemon/1/'));
    expect(pokemon, isA<PokemonModel>());
    expect(pokemon.name, 'bulbasaur');
  });
}
