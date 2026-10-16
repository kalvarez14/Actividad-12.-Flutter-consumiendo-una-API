# Pokédex Flutter

Aplicación Flutter para explorar Pokémon con datos de [PokéAPI](https://pokeapi.co/).
Incluye una interfaz adaptable con tema claro/oscuro, búsqueda por nombre o
número, tarjeta coleccionable animada, estadísticas, tipos, habilidades y
movimientos.

## Ejecutar

```bash
flutter pub get
flutter run
```

La aplicación carga inicialmente el Pokémon con ID `1`. Usa el buscador para
consultar otro nombre o número, o pulsa **Sorpréndeme** para elegir uno al azar.
La conexión a Internet es necesaria para consultar PokéAPI y cargar el arte.

## Verificaciones

```bash
flutter analyze
flutter test
```
