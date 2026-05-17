import 'package:flutter/material.dart';
import 'menu_inferior.dart';
import 'datos_medicamentos.dart'; // IMPORTANTE: Importamos la lista compartida

class PantallaConfiguracionSlots extends StatefulWidget {
  const PantallaConfiguracionSlots({super.key});

  @override
  State<PantallaConfiguracionSlots> createState() =>
      _PantallaConfiguracionSlotsState();
}

class _PantallaConfiguracionSlotsState
    extends State<PantallaConfiguracionSlots> {
  // Mapa para guardar la configuración temporal de cada medicamento
  // La llave es el nombre del medicamento y el valor es la hora/cantidad configurada
  final Map<String, Map<String, String>> _configuracionSlots = {};

  @override
  void initState() {
    super.initState();
    // Inicializamos el mapa con datos por defecto para cada medicamento de la lista global
    for (var medicamento in nombresPastillasGlobal) {
      _configuracionSlots[medicamento] = {'cantidad': '1', 'hora': '08:00 AM'};
    }
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
              // --- HEADER ---
              const Text(
                "Configura tu MiniDoc",
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              const Text(
                "Establece la cantidad y el horario para cada uno de tus medicamentos registrados.",
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 20),

              // --- LISTA DINÁMICA DE SLOTS ---
              Expanded(
                child: ListView.builder(
                  // Crea tantos slots como medicamentos existan en la lista global
                  itemCount: nombresPastillasGlobal.length,
                  itemBuilder: (context, index) {
                    String medicamento = nombresPastillasGlobal[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: _buildSlotCard(
                        titulo: "Slot ${index + 1}",
                        nombreMedicamento: medicamento,
                        cantidad:
                            _configuracionSlots[medicamento]?['cantidad'] ??
                            '1',
                        hora:
                            _configuracionSlots[medicamento]?['hora'] ??
                            '08:00 AM',
                      ),
                    );
                  },
                ),
              ),

              // --- BOTÓN GUARDAR ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Configuración guardada correctamente'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Guardar Configuración",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MenuInferior(),
    );
  }

  // --- WIDGET DE TARJETA DE SLOT (Actualizado para ser estático por nombre) ---
  Widget _buildSlotCard({
    required String titulo,
    required String nombreMedicamento,
    required String cantidad,
    required String hora,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 14,
                ),
              ),
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Nombre del medicamento (ya no es un Dropdown, es el asignado)
          Text(
            nombreMedicamento,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const Divider(height: 30),

          Row(
            children: [
              // Columna Cantidad
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Cantidad",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    _buildInputCuadrado(cantidad, Icons.medication_liquid),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              // Columna Hora
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Horario",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    _buildInputCuadrado(hora, Icons.access_time),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputCuadrado(String texto, IconData icono) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icono, size: 16, color: Colors.black54),
          const SizedBox(width: 8),
          Text(
            texto,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
