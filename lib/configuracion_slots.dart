import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';
import 'menu_inferior.dart';

class PantallaConfiguracionSlots extends StatefulWidget {
  final String nombreUsuario;
  final String sexoUsuario;
  final String rolUsuario;
  final String correoUsuario;

  const PantallaConfiguracionSlots({
    super.key,
    required this.nombreUsuario,
    required this.sexoUsuario,
    required this.rolUsuario,
    required this.correoUsuario,
  });

  @override
  State<PantallaConfiguracionSlots> createState() =>
      _PantallaConfiguracionSlotsState();
}

class _PantallaConfiguracionSlotsState
    extends State<PantallaConfiguracionSlots> {
  final FirebaseService _firebaseService = FirebaseService();

  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  String _frecuenciaSeleccionada = 'Cada 8 horas';

  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // VALIDACIÓN: ¿Puede editar? (Solo familiar o admin)
  bool _puedeBorrar() {
    return widget.rolUsuario == 'familiar' ||
        widget.rolUsuario == 'administrador';
  }

  void _abrirDialogoConfiguracion(
      String docId, String nombrePastilla, Map<String, dynamic> data) {
    _cantidadController.text = (data['cantidad_restante'] ?? '3').toString();
    _horaController.text =
        data['primera_dose'] ?? data['primera_dosis'] ?? '4:29 PM';
    _frecuenciaSeleccionada = data['repetir_cada'] != null
        ? "Cada ${data['repetir_cada']} horas"
        : 'Cada 12 horas';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Configurar Slot\n$nombrePastilla",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Cantidad Restante (Max 10)",
                style: TextStyle(color: Colors.grey)),
            TextField(
              controller: _cantidadController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Ej. 3"),
            ),
            const SizedBox(height: 15),
            const Text("Hora de Primera Dosis",
                style: TextStyle(color: Colors.grey)),
            TextField(
              controller: _horaController,
              decoration: const InputDecoration(
                hintText: "12:00 PM",
                suffixIcon: Icon(Icons.access_time),
              ),
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  if (mounted) {
                    _horaController.text = picked.format(context);
                  }
                }
              },
            ),
            const SizedBox(height: 15),
            const Text("Repetir cada (Horas)",
                style: TextStyle(color: Colors.grey)),
            DropdownButton<String>(
              value: _frecuenciaSeleccionada,
              isExpanded: true,
              items: <String>[
                'Cada 3 horas',
                'Cada 8 horas',
                'Cada 12 horas',
                'Cada 24 horas'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _frecuenciaSeleccionada = newValue;
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar",
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () async {
              int horas = int.tryParse(_frecuenciaSeleccionada.replaceAll(
                      RegExp(r'[^0-9]'), '')) ??
                  12;
              await FirebaseFirestore.instance
                  .collection('pastillas')
                  .doc(docId)
                  .update({
                'cantidad_restante':
                    int.tryParse(_cantidadController.text) ?? 0,
                'primera_dosis': _horaController.text,
                'repetir_cada': horas,
              });
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F1),
      appBar: AppBar(
        title: const Text("Configuración de Slots",
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firebaseService.streamMedicamentosPorUsuario(_currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("No tienes pastillas vinculadas a este slot."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;

              String nombre = data['nombre_pastilla'] ?? 'Sin nombre';
              int cantidad = data['cantidad_restante'] ?? 0;
              String primeraDosis = data['primera_dosis'] ?? 'No programada';
              int frecuencia = data['repetir_cada'] ?? 0;
              int numeroSlot = index + 1;

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 16,
                      child: Text("$numeroSlot",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("SLOT $numeroSlot",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: 13)),
                          const SizedBox(height: 4),
                          Text("Medicamento:\n$nombre",
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87)),
                          const SizedBox(height: 6),
                          Text("Cantidad: $cantidad / 10 unidades",
                              style: const TextStyle(color: Colors.black54)),
                          Text("Primera dosis: $primeraDosis",
                              style: const TextStyle(color: Colors.black54)),
                          Text("Frecuencia: Cada $frecuencia horas",
                              style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                    // CORREGIDO: Ahora el botón de tuerca solo aparece si el usuario tiene permisos válidos
                    if (_puedeBorrar())
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.grey),
                        onPressed: () =>
                            _abrirDialogoConfiguracion(doc.id, nombre, data),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: MenuInferior(
        nombreUsuario: widget.nombreUsuario,
        sexoUsuario: widget.sexoUsuario,
        correoUsuario: widget.correoUsuario,
        rolUsuario: widget.rolUsuario,
      ),
    );
  }
}
