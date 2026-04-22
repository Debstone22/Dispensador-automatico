import 'package:flutter/material.dart';
import 'menu_inferior.dart'; // ¡REUTILIZAMOS EL MENÚ AQUÍ!

class PantallaConfiguracionSlots extends StatefulWidget {
  const PantallaConfiguracionSlots({super.key});

  @override
  State<PantallaConfiguracionSlots> createState() => _PantallaConfiguracionSlotsState();
}

class _PantallaConfiguracionSlotsState extends State<PantallaConfiguracionSlots> {
  // Lista de medicamentos para los ComboBox (Dropdown)
  final List<String> _medicamentos = [
    'Seleccionar medicamento',
    'Paracetamol',
    'Naproxeno',
    'Ibuprofeno',
    'Deflazacort',
  ];

  // Variables para guardar la selección de cada Slot
  String _seleccionSlot1 = 'Paracetamol';
  String _seleccionSlot2 = 'Naproxeno';
  String _seleccionSlot3 = 'Seleccionar medicamento';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9), // Fondo verde claro
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // --- HEADER ---
              const Text("Hola, María", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              const Text("Configuración de Slot", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // --- LISTA DE SLOTS (Hacemos que esta parte sea scrolleable) ---
              Expanded(
                child: ListView(
                  children: [
                    // SLOT P1
                    _buildSlotCard(
                      titulo: "Slot P1",
                      medicamentoSeleccionado: _seleccionSlot1,
                      cantidad: "10",
                      hora: "08:00 AM",
                      onMedicamentoChanged: (nuevoValor) {
                        setState(() { _seleccionSlot1 = nuevoValor!; });
                      },
                    ),
                    const SizedBox(height: 15),
                    
                    // SLOT P2
                    _buildSlotCard(
                      titulo: "Slot P2",
                      medicamentoSeleccionado: _seleccionSlot2,
                      cantidad: "10",
                      hora: "12:00 PM",
                      onMedicamentoChanged: (nuevoValor) {
                        setState(() { _seleccionSlot2 = nuevoValor!; });
                      },
                    ),
                    const SizedBox(height: 15),

                    // SLOT P3
                    _buildSlotCard(
                      titulo: "Slot P3",
                      medicamentoSeleccionado: _seleccionSlot3,
                      cantidad: "10",
                      hora: "08:00 AM",
                      onMedicamentoChanged: (nuevoValor) {
                        setState(() { _seleccionSlot3 = nuevoValor!; });
                      },
                    ),
                    
                    const SizedBox(height: 25),

                    // --- BOTÓN AGREGAR SLOT ---
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text("Agregar Slot"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // --- ¡AQUÍ ESTÁ LA REUTILIZACIÓN MAGICA! ---
      // Llamamos a la clase que creaste antes
      bottomNavigationBar: const MenuInferior(), 
    );
  }

  // --- WIDGET AUXILIAR PARA CREAR CADA TARJETA DE SLOT (Reusable) ---
  Widget _buildSlotCard({
    required String titulo,
    required String medicamentoSeleccionado,
    required String cantidad,
    required String hora,
    required ValueChanged<String?> onMedicamentoChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Título del Slot
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Icon(Icons.keyboard_arrow_down, color: Colors.green),
            ],
          ),
          const SizedBox(height: 15),

          // --- COMBO BOX (DropdownButton) ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: medicamentoSeleccionado,
                isExpanded: true, // Ocupa todo el ancho
                icon: const Icon(Icons.unfold_more, color: Colors.grey),
                items: _medicamentos.map((String medicamento) {
                  return DropdownMenuItem<String>(
                    value: medicamento,
                    child: Text(medicamento),
                  );
                }).toList(),
                onChanged: onMedicamentoChanged,
              ),
            ),
          ),
          const SizedBox(height: 15),

          // --- FILA DE CANTIDAD Y HORA ---
          Row(
            children: [
              const Text("Cantidad", style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 10),
              // Cuadro de Cantidad
              _buildInputCuadrado(cantidad),
              const Spacer(),
              // Cuadro de Hora
              _buildInputCuadrado(hora),
            ],
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para los cuadros grises pequeños (cantidad y hora)
  Widget _buildInputCuadrado(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(texto, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}