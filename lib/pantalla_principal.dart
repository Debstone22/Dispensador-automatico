import 'package:flutter/material.dart';
import 'menu_inferior.dart';
import 'configuracion_slots.dart';



class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Configuramos el latido: dura 400ms y se repite infinitamente
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..repeat(reverse: true); 
  }
  @override
  void dispose() {
    _controller.dispose(); // IMPORTANTE: Cerramos el controlador al salir de la pantalla
    super.dispose();
  }
  
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
                    Text("Hola,María", style: TextStyle(fontSize: 20)),
                  ],
                ),
                // Circulo de avatar
                CircleAvatar(
                  radius: 25,
                  backgroundImage: const NetworkImage(
                  'https://thumbs.dreamstime.com/b/mujer-de-render-d-png-trabajando-en-tecnolog%C3%ADa-avatar-digital-port%C3%A1til-contra-fondo-transparente-384935566.jpg', 
                  ),
                ),
              ], // Cierre de children del Row
            ), // Cierre del Row del Header

            const SizedBox(height: 30),

            // Tarjeta de Alerta
            ScaleTransition(
                 scale: Tween(begin: 1.0, end: 1.1).animate(
                   CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
                 ),
                 child: _construirTarjetaAlerta(),
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
                    _buildProgressBar("Paracetamol", 0.3, Colors.amber),
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

// Método auxiliar para que el código sea más limpio (Clean Code)
  Widget _construirTarjetaAlerta() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.orange.withOpacity(0.2), blurRadius: 10)
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 30),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              "Tienes medicamentos por agotarse",
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF856404)),
            ),
          ),
        ],
      ),
    );
  }
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
