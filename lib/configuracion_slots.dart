import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'menu_inferior.dart';

class PantallaConfiguracionSlots extends StatefulWidget {
  final String nombreUsuario, sexoUsuario, rolUsuario, correoUsuario;
  const PantallaConfiguracionSlots({super.key, required this.nombreUsuario, required this.sexoUsuario, required this.rolUsuario, required this.correoUsuario});

  @override
  State<PantallaConfiguracionSlots> createState() => _PantallaConfiguracionSlotsState();
}

class _PantallaConfiguracionSlotsState extends State<PantallaConfiguracionSlots> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _pacienteSeleccionadoId;
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  String _frecuenciaSeleccionada = 'Cada 8 horas';

  Future<void> _sincronizarConHardware(int slot, String hora, int frecuencia) async {
    try {
      final url = Uri.parse('http://192.168.0.36/set_config?slot=$slot&hora=$hora&freq=$frecuencia');
      await http.get(url).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint("Error sincronizando: $e");
    }
  }

  void _abrirDialogoConfiguracion(String docId, String nombrePastilla, Map<String, dynamic> data, int index) {
    _cantidadController.text = (data['cantidad_restante'] ?? '3').toString();
    _horaController.text = data['primera_dosis'] ?? '12:00 PM';
    _frecuenciaSeleccionada = data['repetir_cada'] != null ? "Cada ${data['repetir_cada']} horas" : 'Cada 12 horas';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Configurar $nombrePastilla", textAlign: TextAlign.center),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: _cantidadController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Cantidad (0-10)")),
            TextField(controller: _horaController, readOnly: true, decoration: const InputDecoration(labelText: "Primera Dosis", suffixIcon: Icon(Icons.access_time)), onTap: () async {
              TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
              if (picked != null && mounted) setDialogState(() => _horaController.text = picked.format(context));
            }),
            DropdownButton<String>(
              value: _frecuenciaSeleccionada, isExpanded: true,
              items: ['Cada 3 horas', 'Cada 8 horas', 'Cada 12 horas', 'Cada 24 horas'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setDialogState(() => _frecuenciaSeleccionada = val!),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(onPressed: () async {
              int? nuevaCantidad = int.tryParse(_cantidadController.text);
              if (nuevaCantidad == null || nuevaCantidad < 0 || nuevaCantidad > 10) return;
              int horas = int.tryParse(_frecuenciaSeleccionada.replaceAll(RegExp(r'[^0-9]'), '')) ?? 12;
              
              await _firestore.collection('pastillas').doc(docId).update({
                'cantidad_restante': nuevaCantidad, 'primera_dosis': _horaController.text, 'repetir_cada': horas,
              });
              
              await _sincronizarConHardware(index + 1, _horaController.text, horas);
              if (!mounted) return;
              Navigator.pop(context);
            }, child: const Text("Guardar")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F1),
      appBar: AppBar(title: const Text("Configuración de Slots"), backgroundColor: Colors.transparent, elevation: 0),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(15.0), child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('pacientes').where('correo_familiar', isEqualTo: widget.correoUsuario.trim()).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            return DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Selecciona al paciente", border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
              items: snapshot.data!.docs.map((doc) => DropdownMenuItem(value: doc.id, child: Text(doc['nombre_paciente'] ?? ''))).toList(),
              onChanged: (val) => setState(() => _pacienteSeleccionadoId = val),
            );
          },
        )),
        Expanded(child: _pacienteSeleccionadoId == null ? const Center(child: Text("Selecciona un paciente")) : StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('pastillas').where('paciente_id', isEqualTo: _pacienteSeleccionadoId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            return ListView.builder(itemCount: snapshot.data!.docs.length, itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              return ListTile(title: Text(data['nombre_pastilla']), subtitle: Text("Cada ${data['repetir_cada']}h a las ${data['primera_dosis']}"), trailing: IconButton(icon: const Icon(Icons.settings), onPressed: () => _abrirDialogoConfiguracion(doc.id, data['nombre_pastilla'], data, index)));
            });
          },
        )),
      ]),
      bottomNavigationBar: MenuInferior(nombreUsuario: widget.nombreUsuario, sexoUsuario: widget.sexoUsuario, correoUsuario: widget.correoUsuario, rolUsuario: widget.rolUsuario),
    );
  }
}