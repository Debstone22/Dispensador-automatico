import 'package:flutter/material.dart';
import 'login.dart';


void main() {
  runApp(const MiAppSalud());
}

class MiAppSalud extends StatelessWidget {
  const MiAppSalud({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Medicamentos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Usamos un color semilla verde como en tu diseño
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
      ),
      home: const PantallaLogin(),
    );
  }
  
}
 