import 'dart:math';

import 'package:dio/dio.dart';

import '../models/pokemon_model.dart';

class PokemonService {
  PokemonService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://pokeapi.co/api/v2/',
              connectTimeout: const Duration(seconds: 12),
              receiveTimeout: const Duration(seconds: 12),
              headers: const {'Accept': 'application/json'},
            ),
          );

  final Dio _dio;
  final Random _random = Random();

  Future<PokemonModel> getPokemon([String query = '1']) async {
    final normalized = query.trim().toLowerCase();
    if (!RegExp(r'^[a-z0-9-]+$').hasMatch(normalized)) {
      throw const PokemonServiceException(
        'Escribe un nombre o número de Pokédex válido.',
      );
    }

    try {
      final response = await _dio.get<dynamic>('pokemon/$normalized/');
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const PokemonServiceException(
          'La respuesta de PokéAPI no tiene el formato esperado.',
        );
      }
      return PokemonModel.fromJson(data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const PokemonServiceException(
          'No encontramos ese Pokémon. Revisa el nombre o el número.',
        );
      }
      throw const PokemonServiceException(
        'No se pudo conectar con PokéAPI. Comprueba tu conexión e inténtalo otra vez.',
      );
    } on FormatException catch (error) {
      throw PokemonServiceException(
        'No se pudieron interpretar los datos del Pokémon: ${error.message}',
      );
    }
  }

  String randomPokemonQuery() => '${_random.nextInt(1025) + 1}';
}

class PokemonServiceException implements Exception {
  const PokemonServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
