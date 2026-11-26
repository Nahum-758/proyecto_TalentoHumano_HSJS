import 'package:flutter/material.dart';
import 'package:talento_humano/src/core/hospital_theme.dart';
import 'package:talento_humano/src/core/talento_humano_store.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _prepararApp();
  }

  Future<void> _prepararApp() async {
    // Dispara la sincronización en segundo plano sin bloquear más de lo necesario
    final syncFuture = TalentoHumanoStore.instance.sincronizarDesdeSupabase();

    // Tiempo mínimo breve para mostrar la identidad visual y dar margen de carga
    await Future.any([
      Future.wait([
        syncFuture,
        Future.delayed(const Duration(milliseconds: 900)),
      ]),
      Future.delayed(const Duration(seconds: 3)),
    ]);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'imagenes/logoHSJS.png',
                  height: 112,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                const Text(
                  HospitalBranding.nombre,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: HospitalBranding.grisInstitucional,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '“${HospitalBranding.lema}”',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: HospitalBranding.azulMarino,
                  ),
                ),
                const SizedBox(height: 28),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    color: HospitalBranding.azulMarino,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Cargando sistema...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}