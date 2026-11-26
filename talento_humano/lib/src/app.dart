import 'package:flutter/material.dart';
import 'package:talento_humano/src/core/hospital_theme.dart';
import 'package:talento_humano/src/features/dashboard/presentacion/admin_dashboard.dart';
import 'package:talento_humano/src/features/dashboard/presentacion/employee_dashboard.dart';
import 'package:talento_humano/src/features/auth/presentation/login_screen.dart';

const bool kModoDemo = true;

class TalentoHumanoApp extends StatelessWidget {
  const TalentoHumanoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${HospitalBranding.nombre} — Talento Humano',
      debugShowCheckedModeBanner: false,
      theme: HospitalBranding.theme,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/employee-dashboard': (_) => const EmployeeDashboard(),
        '/admin-dashboard': (_) => const AdminDashboard(),
      },
    );
  }
}