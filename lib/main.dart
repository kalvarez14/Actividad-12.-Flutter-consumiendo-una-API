import 'package:flutter/material.dart';

import 'screens/pokemon_screen.dart';
import 'services/pokemon_service.dart';

void main() {
  runApp(const PokedexApp());
}

class PokedexApp extends StatefulWidget {
  const PokedexApp({super.key, this.pokemonService});

  final PokemonService? pokemonService;

  @override
  State<PokedexApp> createState() => _PokedexAppState();
}

class _PokedexAppState extends State<PokedexApp> {
  bool _isDark = true;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF7C5CFC);
    return MaterialApp(
      title: 'Pokédex',
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
          surface: const Color(0xFF141522),
        ),
        scaffoldBackgroundColor: const Color(0xFF10111B),
        fontFamily: 'Roboto',
      ),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          surface: const Color(0xFFF7F7FC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7FC),
        fontFamily: 'Roboto',
      ),
      home: PokemonScreen(
        service: widget.pokemonService,
        isDark: _isDark,
        onThemeChanged: () => setState(() => _isDark = !_isDark),
      ),
    );
  }
}
