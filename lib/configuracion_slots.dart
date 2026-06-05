import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
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
  State<PantallaConfiguracionSlots> createState() => _PantallaConfiguracionSlotsState();
}

class _PantallaConfiguracionSlotsState extends State<PantallaConfiguracionSlots> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _pacienteSeleccionadoId;
  
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  String _frecuenciaSeleccionada = 'Cada 8 horas';

  void _abrirDialogoConfiguracion(String docId, String nombrePastilla, Map<String, dynamic> data) {
    _cantidadController.text = (data['cantidad_restante'] ?? '3').toString();
    _horaController.text = data['primera_dosis'] ?? '12:00 PM';
    _frecuenciaSeleccionada = data['repetir_cada'] != null ? "Cada ${data['repetir_cada']} horas" : 'Cada 12 horas';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Configurar $nombrePastilla", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _cantidadController, 
                keyboardType: TextInputType.number, 
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                decoration: const InputDecoration(labelText: "Cantidad (0-10)"),
              ),
              TextField(
                controller: _horaController, 
                readOnly: true, 
                decoration: const InputDecoration(labelText: "Primera Dosis", suffixIcon: Icon(Icons.access_time)), 
                onTap: () async {
                   TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                   if (picked != null && mounted) setDialogState(() => _horaController.text = picked.format(context));
                }
              ),
              DropdownButton<String>(
                value: _frecuenciaSeleccionada, isExpanded: true,
                items: ['Cada 3 horas', 'Cada 8 horas', 'Cada 12 horas', 'Cada 24 horas'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setDialogState(() => _frecuenciaSeleccionada = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () async {
                int? nuevaCantidad = int.tryParse(_cantidadController.text);
                
                // Validación estricta 0-10
                if (nuevaCantidad == null || nuevaCantidad < 0 || nuevaCantidad > 10) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("La cantidad debe ser entre 0 y 10"), backgroundColor: Colors.red));
                  return;
                }

                int horas = int.tryParse(_frecuenciaSeleccionada.replaceAll(RegExp(r'[^0-9]'), '')) ?? 12;
                await _firestore.collection('pastillas').doc(docId).update({
                  'cantidad_restante': nuevaCantidad,
                  'primera_dosis': _horaController.text,
                  'repetir_cada': horas,
                });
                
                if (!mounted) return;
                Navigator.pop(context);
              }, 
              child: const Text("Guardar")
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F1),
      appBar: AppBar(title: const Text("Configuración de Slots", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)), backgroundColor: Colors.transparent, elevation: 0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('pacientes').where('correo_familiar', isEqualTo: widget.correoUsuario.trim()).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LinearProgressIndicator();
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Selecciona al paciente", border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
                  value: _pacienteSeleccionadoId,
                  items: snapshot.data!.docs.map((doc) => DropdownMenuItem(value: doc.id, child: Text(doc['nombre_paciente'] ?? 'Sin nombre'))).toList(),
                  onChanged: (val) => setState(() => _pacienteSeleccionadoId = val),
                );
              },
            ),
          ),
          Expanded(
            child: _pacienteSeleccionadoId == null 
            ? const Center(child: Text("Selecciona un paciente para ver sus slots"))
            : StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('pastillas').where('paciente_id', isEqualTo: _pacienteSeleccionadoId).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      var data = doc.data() as Map<String, dynamic>;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(20), 
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(backgroundColor: Colors.green, child: Text("${index + 1}", style: const TextStyle(color: Colors.white))),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("SLOT ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
                                  Text("Medicamento: ${data['nombre_pastilla'] ?? 'Sin nombre'}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                  Text("Cantidad: ${data['cantidad_restante'] ?? 0} / 10", style: const TextStyle(color: Colors.black54)),
                                  Text("Primera dosis: ${data['primera_dosis'] ?? 'No programada'}", style: const TextStyle(color: Colors.black54)),
                                  Text("Frecuencia: Cada ${data['repetir_cada'] ?? 0} horas", style: const TextStyle(color: Colors.black54)),
                                ],
                              ),
                            ),
                            IconButton(icon: const Icon(Icons.settings, color: Colors.grey), onPressed: () => _abrirDialogoConfiguracion(doc.id, data['nombre_pastilla'], data)),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
          ),
        ],
      ),
      bottomNavigationBar: MenuInferior(nombreUsuario: widget.nombreUsuario, sexoUsuario: widget.sexoUsuario, correoUsuario: widget.correoUsuario, rolUsuario: widget.rolUsuario),
    );
  }
}