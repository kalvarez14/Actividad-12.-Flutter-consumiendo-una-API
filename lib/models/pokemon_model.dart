class PokemonModel {
  const PokemonModel({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.sprite,
    required this.stats,
    required this.types,
    required this.abilities,
    required this.moves,
  });

  final int id;
  final String name;
  final int height;
  final int weight;
  final String? sprite;
  final Map<String, int> stats;
  final List<String> types;
  final List<String> abilities;
  final List<String> moves;

  factory PokemonModel.fromJson(Map<String, dynamic> json) {
    final rawStats = json['stats'];
    final stats = <String, int>{};
    if (rawStats is List) {
      for (final entry in rawStats.whereType<Map>()) {
        final stat = entry['stat'];
        final name = stat is Map ? stat['name'] : null;
        final value = entry['base_stat'];
        if (name is String && value is num) {
          stats[name] = value.toInt();
        }
      }
    }

    final rawSprites = json['sprites'];
    final rawOther = rawSprites is Map ? rawSprites['other'] : null;
    final rawArtwork = rawOther is Map ? rawOther['official-artwork'] : null;
    final artwork = rawArtwork is Map ? rawArtwork['front_default'] : null;
    final defaultSprite = rawSprites is Map
        ? rawSprites['front_default']
        : null;

    return PokemonModel(
      id: _readInt(json['id'], 'id'),
      name: _readString(json['name'], 'name'),
      height: _readInt(json['height'], 'height'),
      weight: _readInt(json['weight'], 'weight'),
      sprite: artwork is String && artwork.isNotEmpty
          ? artwork
          : defaultSprite is String && defaultSprite.isNotEmpty
          ? defaultSprite
          : null,
      stats: Map.unmodifiable(stats),
      types: _readNamedEntries(json['types'], 'type'),
      abilities: _readNamedEntries(json['abilities'], 'ability'),
      moves: _readNamedEntries(json['moves'], 'move'),
    );
  }

  static int _readInt(dynamic value, String field) {
    if (value is num) return value.toInt();
    throw FormatException('El campo "$field" no es un número válido.');
  }

  static String _readString(dynamic value, String field) {
    if (value is String && value.isNotEmpty) return value;
    throw FormatException('El campo "$field" no es un texto válido.');
  }

  static List<String> _readNamedEntries(dynamic value, String key) {
    if (value is! List) return const [];
    return List.unmodifiable(
      value
          .whereType<Map>()
          .map((entry) => entry[key])
          .whereType<Map>()
          .map((entry) => entry['name'])
          .whereType<String>(),
    );
  }
}
