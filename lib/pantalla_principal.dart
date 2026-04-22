import 'package:flutter/material.dart';
import 'menu_inferior.dart';
import 'configuracion_slots.dart';

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});


@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF1F8E9),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // --- HEADER (Saludo y Perfil) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hola,", style: TextStyle(fontSize: 18)),
                    Text("María", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  ],
                ),
                // Circulo de avatar
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ], // Cierre de children del Row
            ), // Cierre del Row del Header

            const SizedBox(height: 30),

            // --- TARJETA DE ALERTA (Amarilla) ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9C4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 30),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      "Tienes medicamentos por agotarse",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- SECCIÓN INVENTARIO (Tarjeta Blanca) ---
            const Text(
              "Capacidad de tus pastillas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    _buildProgressBar("Paracetamol", 0.3, Colors.redAccent),
                    _buildProgressBar("Naproxeno", 0.8, Colors.green),
                    _buildProgressBar("Ibuprofeno", 0.5, Colors.orange),
                    _buildProgressBar("Deflazacort", 0.3, Colors.redAccent),
                    _buildProgressBar("Diclofenaco", 0.7, Colors.green),
                    _buildProgressBar("Coltaire", 0.1, Colors.orange),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        // Navigator.push crea la transición a la nueva pantalla
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PantallaConfiguracionSlots(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("Ver detalles"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ], // Cierre de children de la Column principal
        ), // Cierre de la Column principal
      ), // Cierre del Padding
    ), // Cierre del SafeArea
    bottomNavigationBar: const MenuInferior(),
  ); // Cierre del Scaffold
  
}


  // Widget auxiliar para las barras de progreso
  Widget _buildProgressBar(String nombre, double valor, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(nombre, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: valor,
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ],
      ),
    );
  }

}