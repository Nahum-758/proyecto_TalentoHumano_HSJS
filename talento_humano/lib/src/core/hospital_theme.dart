import 'package:flutter/material.dart';

class HospitalBranding {
  static const String nombre = 'Hospital San José Satélite';
  static const String lema = 'Cuidamos la vida con el corazón';
  static const String consorcio = 'Consorcio Mexicano de Hospitales';
  static const String subtituloSistema = 'Gestión de Talento Humano';

  static const Color azulMarino = Color(0xFF133C68);
  static const Color azulRey = Color(0xFF1D2B7A);
  static const Color grisInstitucional = Color(0xFF6D6E71);
  static const Color turquesaAcento = Color(0xFF1EA1C9);
  static const Color verdeAcento = Color(0xFFA6CE39);
  static const Color fondoClaro = Color(0xFFF6F8FB);

  static ThemeData get theme {
    final esquema = ColorScheme.fromSeed(
      seedColor: azulMarino,
      primary: azulMarino,
      secondary: turquesaAcento,
      tertiary: verdeAcento,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: fondoClaro,
      appBarTheme: const AppBarTheme(
        backgroundColor: azulMarino,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: azulMarino,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: azulMarino,
          side: const BorderSide(color: azulMarino),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: turquesaAcento.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontWeight: FontWeight.bold,
              color: azulMarino,
              fontSize: 12,
            );
          }
          return const TextStyle(color: grisInstitucional, fontSize: 12);
        }),
      ),
    );
  }
}