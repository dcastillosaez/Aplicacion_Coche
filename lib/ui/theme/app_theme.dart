import 'package:flutter/material.dart';

/// Azul petróleo. Deliberadamente distinto del rojo y el azul de los coches,
/// para que las fotos destaquen sobre la interfaz en lugar de competir con ella.
const Color _semilla = Color(0xFF0F5C6B);

const Color _fondoClaro = Color(0xFFF5F7F8);
const Color _superficieClara = Color(0xFFFFFFFF);
const Color _fondoOscuro = Color(0xFF11161A);
const Color _superficieOscura = Color(0xFF1A2126);

class AppTheme {
  const AppTheme._();

  /// Cifras de anchura fija: los kilómetros no bailan al actualizarse.
  static const TextStyle cifras = TextStyle(
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static ThemeData claro() => _base(Brightness.light);

  static ThemeData oscuro() => _base(Brightness.dark);

  static ThemeData _base(Brightness brillo) {
    final claro = brillo == Brightness.light;
    final esquema = ColorScheme.fromSeed(
      seedColor: _semilla,
      brightness: brillo,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: claro ? _fondoClaro : _fondoOscuro,
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: claro ? _superficieClara : _superficieOscura,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: claro ? _fondoClaro : _fondoOscuro,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: claro ? _superficieClara : _superficieOscura,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
