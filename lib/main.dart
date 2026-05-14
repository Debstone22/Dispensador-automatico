import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Importante
import 'firebase_options.dart'; // El archivo generado por el CLI
import 'login.dart';


Future<void> main() async {
  // 1. Garantiza que los servicios de Flutter estén listos
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa Firebase con las opciones de tu proyecto
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Arranca la interfaz
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
      home: const PantallaLogin(),
    );
  }
}
 