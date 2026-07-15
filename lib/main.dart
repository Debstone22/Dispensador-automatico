import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 
import 'login.dart';
import 'pantalla_principal.dart';
import 'dashboards/dashboard_admin.dart';
import 'dashboards/dashboard_callcenter.dart';
import 'dashboards/dashboard_monitor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MiAppSalud());
}

class MiAppSalud extends StatelessWidget {
  const MiAppSalud({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minidoc - Gestión de Medicamentos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const PantallaLogin();
        }

        return FutureBuilder<SesionUsuario?>(
          future: AuthService().obtenerSesionActual(),
          builder: (context, sesionSnapshot) {
            if (sesionSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final sesion = sesionSnapshot.data;
            if (sesion == null) {
              return const PantallaLogin();
            }

            switch (sesion.rol) {
              case RolUsuario.administrador:
                return DashboardAdmin(sesion: sesion);
              case RolUsuario.callcenter:
                return DashboardCallCenter(sesion: sesion);
              case RolUsuario.monitor:
                return DashboardMonitor(sesion: sesion);
              case RolUsuario.familiar:
              case RolUsuario.paciente:
              case RolUsuario.desconocido:
                return PantallaPrincipal(
                  nombreUsuario: sesion.nombre,
                  sexoUsuario: sesion.sexo,
                  correoUsuario: sesion.email,
                  rolUsuario: _rolToString(sesion.rol),
                );
            }
          },
        );
      },
    );
  }

  String _rolToString(RolUsuario rol) {
    switch (rol) {
      case RolUsuario.administrador:
        return 'administrador';
      case RolUsuario.monitor:
        return 'monitor';
      case RolUsuario.callcenter:
        return 'callcenter';
      case RolUsuario.familiar:
        return 'familiar';
      case RolUsuario.paciente:
        return 'paciente';
      case RolUsuario.desconocido:
        return 'desconocido';
    }
  }
}
