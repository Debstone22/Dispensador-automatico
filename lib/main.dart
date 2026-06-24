import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 
import 'login.dart';

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
      home: const PantallaLogin(),
    );
  }
}
