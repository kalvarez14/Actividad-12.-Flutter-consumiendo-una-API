import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/pokemon_model.dart';
import '../services/pokemon_service.dart';

const _accent = Color(0xFF9B85FF);
const _typeColors = <String, Color>{
  'fire': Color(0xFFFF7557),
  'water': Color(0xFF55A7FF),
  'grass': Color(0xFF53C98B),
  'electric': Color(0xFFFFC84A),
  'psychic': Color(0xFFEE70A6),
  'ice': Color(0xFF62D6D1),
  'dragon': Color(0xFF8870F4),
  'dark': Color(0xFF72718A),
  'fairy': Color(0xFFE98FC7),
  'normal': Color(0xFFB4B3C3),
  'fighting': Color(0xFFE58B50),
  'flying': Color(0xFF8BA8EE),
  'poison': Color(0xFFB278D0),
  'ground': Color(0xFFD3A35D),
  'rock': Color(0xFFB6A16A),
  'bug': Color(0xFF9DC64C),
  'ghost': Color(0xFF8275C8),
  'steel': Color(0xFF91A3B9),
};
const _typeNames = <String, String>{
  'fire': 'Fuego',
  'water': 'Agua',
  'grass': 'Planta',
  'electric': 'Eléctrico',
  'psychic': 'Psíquico',
  'ice': 'Hielo',
  'dragon': 'Dragón',
  'dark': 'Siniestro',
  'fairy': 'Hada',
  'normal': 'Normal',
  'fighting': 'Lucha',
  'flying': 'Volador',
  'poison': 'Veneno',
  'ground': 'Tierra',
  'rock': 'Roca',
  'bug': 'Bicho',
  'ghost': 'Fantasma',
  'steel': 'Acero',
};
const _statDetails = <String, (String, Color)>{
  'hp': ('PS', Color(0xFFFF7185)),
  'attack': ('Ataque', Color(0xFFFF9D5C)),
  'defense': ('Defensa', Color(0xFF69B7FF)),
  'speed': ('Velocidad', Color(0xFFFFD45E)),
};

class PokemonScreen extends StatefulWidget {
  const PokemonScreen({
    super.key,
    this.service,
    this.isDark = true,
    this.onThemeChanged,
  });

  final PokemonService? service;
  final bool isDark;
  final VoidCallback? onThemeChanged;

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  late final PokemonService _service = widget.service ?? PokemonService();
  late final TextEditingController _searchController = TextEditingController(
    text: '1',
  );
  late Future<PokemonModel> _pokemonFuture = _service.getPokemon();
  bool _previewEnabled = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadPokemon(String query) {
    final value = query.trim();
    if (value.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _searchController.text = value;
      _pokemonFuture = _service.getPokemon(value);
    });
  }

  void _loadRandomPokemon() {
    HapticFeedback.mediumImpact();
    _loadPokemon(_service.randomPokemonQuery());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isDark
                ? const [
                    Color(0xFF17182A),
                    Color(0xFF10111B),
                    Color(0xFF151323),
                  ]
                : const [
                    Color(0xFFF0EEFF),
                    Color(0xFFF8F8FC),
                    Color(0xFFEFF7FF),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildTopBar(theme),
                        const SizedBox(height: 26),
                        _buildSearchBar(theme),
                        const SizedBox(height: 20),
                        FutureBuilder<PokemonModel>(
                          future: _pokemonFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const _LoadingCard();
                            }
                            if (snapshot.hasError) {
                              return _ErrorCard(
                                message: snapshot.error.toString(),
                                onRetry: () => _loadPokemon(
                                  _searchController.text.isEmpty
                                      ? '1'
                                      : _searchController.text,
                                ),
                              );
                            }
                            final pokemon = snapshot.data;
                            if (pokemon == null) {
                              return _ErrorCard(
                                message: 'No hay datos disponibles.',
                                onRetry: () => _loadPokemon('1'),
                              );
                            }
                            return _buildPokemonContent(pokemon, theme);
                          },
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFAA92FF), Color(0xFF7254E8)],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: _accent.withValues(alpha: 0.32),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const Icon(
            Icons.catching_pokemon,
            color: Colors.white,
            size: 29,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'POKÉDEX',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.2,
                ),
              ),
              Text(
                'Tu colección, a un toque',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: widget.isDark
              ? 'Cambiar a tema claro'
              : 'Cambiar a tema oscuro',
          onPressed: widget.onThemeChanged,
          icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 4, 5, 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.12 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _loadPokemon,
              decoration: const InputDecoration(
                hintText: 'Busca por nombre o número',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Buscar Pokémon',
            onPressed: () => _loadPokemon(_searchController.text),
            icon: const Icon(Icons.arrow_forward_rounded),
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF785CEB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPokemonContent(PokemonModel pokemon, ThemeData theme) {
    final type = pokemon.types.isEmpty ? 'normal' : pokemon.types.first;
    final color = _typeColors[type] ?? _accent;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      child: Column(
        key: ValueKey(pokemon.id),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPokemonCard(pokemon, color, theme),
          const SizedBox(height: 25),
          _sectionHeading('Estadísticas base', 'DATOS DE COMBATE'),
          const SizedBox(height: 13),
          _buildStatsCard(pokemon, theme),
          const SizedBox(height: 25),
          _sectionHeading('Habilidades', 'LO QUE SABE HACER'),
          const SizedBox(height: 12),
          _buildAbilities(pokemon, theme),
          const SizedBox(height: 25),
          _sectionHeading('Movimientos', 'UN VISTAZO A SU KIT'),
          const SizedBox(height: 12),
          _buildMoves(pokemon, theme),
          const SizedBox(height: 23),
          _buildActions(theme),
          const SizedBox(height: 14),
          Center(
            child: Text(
              'Datos de PokéAPI  ·  #${pokemon.id.toString().padLeft(4, '0')}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPokemonCard(PokemonModel pokemon, Color color, ThemeData theme) {
    return Container(
      height: 320,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.96),
            color.withValues(alpha: 0.68),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -38,
            top: -72,
            child: _orb(245, Colors.white.withValues(alpha: 0.09)),
          ),
          Positioned(
            left: 130,
            bottom: -105,
            child: _orb(230, Colors.black.withValues(alpha: 0.06)),
          ),
          Positioned(
            right: 15,
            top: 15,
            child: Text(
              '#${pokemon.id.toString().padLeft(4, '0')}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.72),
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 29,
            right: 115,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POKÉMON',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _capitalize(pokemon.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 13),
                Wrap(
                  spacing: 7,
                  runSpacing: 6,
                  children: pokemon.types
                      .map((item) => _TypeChip(type: item))
                      .toList(),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: Row(
              children: [
                _measurement(
                  'ALTURA',
                  '${(pokemon.height / 10).toStringAsFixed(1)} m',
                ),
                const SizedBox(width: 22),
                _measurement(
                  'PESO',
                  '${(pokemon.weight / 10).toStringAsFixed(1)} kg',
                ),
              ],
            ),
          ),
          Positioned(
            right: 2,
            bottom: 23,
            child: IconButton(
              tooltip: _previewEnabled
                  ? 'Pausar animación'
                  : 'Activar animación',
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _previewEnabled = !_previewEnabled);
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
              ),
              icon: Icon(
                _previewEnabled
                    ? Icons.animation_rounded
                    : Icons.motion_photos_off,
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 73,
            bottom: 64,
            child: SizedBox(
              width: 205,
              child: _previewEnabled
                  ? TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) => Transform.scale(
                        scale: 0.82 + value * 0.18,
                        child: child,
                      ),
                      child: _pokemonImage(pokemon),
                    )
                  : _pokemonImage(pokemon),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pokemonImage(PokemonModel pokemon) {
    if (pokemon.sprite == null) {
      return const Center(
        child: Icon(Icons.catching_pokemon, size: 100, color: Colors.white70),
      );
    }
    return Image.network(
      pokemon.sprite!,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(Icons.catching_pokemon, size: 100, color: Colors.white70),
      ),
    );
  }

  Widget _buildStatsCard(PokemonModel pokemon, ThemeData theme) {
    return _SurfaceCard(
      child: Column(
        children: _statDetails.entries.map((entry) {
          final value = pokemon.stats[entry.key] ?? 0;
          final (label, color) = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _AnimatedStatRow(
              label: label,
              value: value,
              color: color,
              textColor: theme.colorScheme.onSurface,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAbilities(PokemonModel pokemon, ThemeData theme) {
    if (pokemon.abilities.isEmpty) {
      return const _EmptySection(message: 'No hay habilidades disponibles.');
    }
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pokemon.abilities.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final name = pokemon.abilities[index];
          return Container(
            width: 185,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: _accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _formatName(name),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoves(PokemonModel pokemon, ThemeData theme) {
    if (pokemon.moves.isEmpty) {
      return const _EmptySection(message: 'No hay movimientos disponibles.');
    }
    final moves = pokemon.moves.take(12).toList();
    return _SurfaceCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 17),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 15),
          leading: const Icon(Icons.auto_awesome, color: _accent),
          title: Text(
            '${pokemon.moves.length} movimientos',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: const Text('Toca para ver los primeros 12'),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: moves
                  .map(
                    (move) => Chip(
                      label: Text(_formatName(move)),
                      visualDensity: VisualDensity.compact,
                      side: BorderSide.none,
                      backgroundColor: theme.colorScheme.onSurface.withValues(
                        alpha: 0.06,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _loadPokemon(
              _searchController.text.isEmpty ? '1' : _searchController.text,
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Recargar'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: _loadRandomPokemon,
            icon: const Icon(Icons.shuffle_rounded),
            label: const Text('Sorpréndeme'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 52),
              backgroundColor: const Color(0xFF785CEB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeading(String title, String eyebrow) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
        ),
        Text(
          eyebrow,
          style: theme.textTheme.labelSmall?.copyWith(
            color: _accent,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _measurement(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _orb(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  String _capitalize(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

  String _formatName(String value) =>
      value.split('-').map(_capitalize).join(' ');
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final color = _typeColors[type] ?? Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(
        _typeNames[type] ?? _formatType(type),
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          shadows: [Shadow(color: color.withValues(alpha: 0.5), blurRadius: 8)],
        ),
      ),
    );
  }

  String _formatType(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
}

class _AnimatedStatRow extends StatelessWidget {
  const _AnimatedStatRow({
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
  });

  final String label;
  final int value;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          width: 34,
          child: Text(
            '$value',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: (value / 180).clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 850),
            curve: Curves.easeOutCubic,
            builder: (context, progress, child) => ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: textColor.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(17),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 420,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 52,
              height: 52,
              child: CircularProgressIndicator(strokeWidth: 4, color: _accent),
            ),
            const SizedBox(height: 20),
            Text(
              'Preparando tu Pokédex…',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Conectando con PokéAPI',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFF7185).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.wifi_tethering_error_rounded,
            size: 48,
            color: Color(0xFFFF7185),
          ),
          const SizedBox(height: 14),
          Text(
            'No pudimos cargarlo',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Intentar de nuevo'),
          ),
        ],
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) =>
      _SurfaceCard(child: Center(child: Text(message)));
}
