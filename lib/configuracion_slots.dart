import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'esp32_service.dart'; // <--- IMPORTAMOS EL SERVICIO AQUÍ

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
  
  // Variables para controlar la hora exacta y los días
  TimeOfDay _horaSeleccionada = TimeOfDay.now();
  List<bool> _diasSeleccionados = List.generate(7, (index) => false);
  final List<String> _nombresDias = ['D', 'L', 'M', 'X', 'J', 'V', 'S']; // Índices 0=Dom, 1=Lun...

<<<<<<< HEAD
  void _abrirDialogoConfiguracion(String docId, String nombrePastilla, Map<String, dynamic> data) {
    _cantidadController.text = (data['cantidad_restante'] ?? '3').toString();
    _horaController.text = data['primera_dosis'] ?? '12:00 PM';
    _frecuenciaSeleccionada = data['repetir_cada'] != null ? "Cada ${data['repetir_cada']} horas" : 'Cada 12 horas';
=======
  // Ahora recibe el número de slot (1 o 2)
  void _abrirDialogoConfiguracion(String docId, String nombrePastilla, Map<String, dynamic> data, int slot) {
    _cantidadController.text = (data['cantidad_restante'] ?? '3').toString();
    _horaController.text = data['primera_dosis'] ?? '12:00 PM';
    
    // Cargar los días guardados desde Firestore si existen
    if (data['dias_activos'] != null) {
      _diasSeleccionados = List<bool>.from(data['dias_activos']);
    } else {
      _diasSeleccionados = List.generate(7, (index) => false);
    }
>>>>>>> origin/rama-prueba

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
<<<<<<< HEAD
          title: Text("Configurar $nombrePastilla", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
=======
          title: Text("Configurar Slot $slot: $nombrePastilla", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
>>>>>>> origin/rama-prueba
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
<<<<<<< HEAD
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
=======
              const SizedBox(height: 10),
              TextField(
                controller: _horaController, 
                readOnly: true, 
                decoration: const InputDecoration(labelText: "Hora de Dosis", suffixIcon: const Icon(Icons.access_time)), 
                onTap: () async {
                   TimeOfDay? picked = await showTimePicker(context: context, initialTime: _horaSeleccionada);
                   if (picked != null && mounted) {
                     setDialogState(() {
                       _horaSeleccionada = picked;
                       _horaController.text = picked.format(context);
                     });
                   }
                }
              ),
              const SizedBox(height: 20),
              const Text("Días de la semana", style: TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 10),
              // Selector de Días de la semana interactivo
              Wrap(
                spacing: 4,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: List.generate(7, (index) {
                  return FilterChip(
                    label: Text(_nombresDias[index], style: TextStyle(color: _diasSeleccionados[index] ? Colors.white : Colors.black87)),
                    selected: _diasSeleccionados[index],
                    selectedColor: const Color(0xFF2E7D32),
                    showCheckmark: false,
                    onSelected: (bool selected) {
                      setDialogState(() {
                        _diasSeleccionados[index] = selected;
                      });
                    },
                  );
                }),
>>>>>>> origin/rama-prueba
              ),
            ],
          ),
          actions: [
<<<<<<< HEAD
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () async {
                int? nuevaCantidad = int.tryParse(_cantidadController.text);
                
                // Validación estricta 0-10
=======
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
              onPressed: () async {
                int? nuevaCantidad = int.tryParse(_cantidadController.text);
                
>>>>>>> origin/rama-prueba
                if (nuevaCantidad == null || nuevaCantidad < 0 || nuevaCantidad > 10) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("La cantidad debe ser entre 0 y 10"), backgroundColor: Colors.red));
                  return;
                }

<<<<<<< HEAD
                int horas = int.tryParse(_frecuenciaSeleccionada.replaceAll(RegExp(r'[^0-9]'), '')) ?? 12;
                await _firestore.collection('pastillas').doc(docId).update({
                  'cantidad_restante': nuevaCantidad,
                  'primera_dosis': _horaController.text,
                  'repetir_cada': horas,
=======
                // 1. Formatear la hora a HH:MM (24 horas) para el ESP32
                String hora24 = "${_horaSeleccionada.hour.toString().padLeft(2, '0')}:${_horaSeleccionada.minute.toString().padLeft(2, '0')}";
                
                // 2. Instanciamos el servicio y enviamos la petición segura
                Esp32Service servicio = Esp32Service();
                bool hardwareOk = await servicio.configurarAlarma(
                  slot: slot,
                  hora: hora24,
                  diasActivos: _diasSeleccionados,
                );

                // 3. Guardar en Firestore
                await _firestore.collection('pastillas').doc(docId).update({
                  'cantidad_restante': nuevaCantidad,
                  'primera_dosis': _horaController.text, // Hora visual
                  'dias_activos': _diasSeleccionados, // Guardamos el arreglo de booleanos
                  'hora_24': hora24, 
>>>>>>> origin/rama-prueba
                });
                
                if (!mounted) return;
                Navigator.pop(context);
<<<<<<< HEAD
              }, 
              child: const Text("Guardar")
=======

                // Notificar al usuario el resultado de la operación dual
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(hardwareOk 
                      ? "Hardware y Nube actualizados con éxito" 
                      : "Guardado en Nube. (El hardware está desconectado)"),
                    backgroundColor: hardwareOk ? const Color(0xFF2E7D32) : Colors.orange,
                  )
                );
              }, 
              child: const Text("Guardar", style: TextStyle(color: Colors.white))
>>>>>>> origin/rama-prueba
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
                  initialValue: _pacienteSeleccionadoId,
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
<<<<<<< HEAD
=======
                      
                      // Interpretar los días activos para la vista
                      String diasTexto = "No programada";
                      if (data['dias_activos'] != null) {
                         List<bool> dias = List<bool>.from(data['dias_activos']);
                         List<String> diasNombres = [];
                         for(int i=0; i<7; i++) { if(dias[i]) diasNombres.add(_nombresDias[i]); }
                         diasTexto = diasNombres.isNotEmpty ? diasNombres.join(', ') : "Ninguno";
                      }

>>>>>>> origin/rama-prueba
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
<<<<<<< HEAD
                                  Text("Primera dosis: ${data['primera_dosis'] ?? 'No programada'}", style: const TextStyle(color: Colors.black54)),
                                  Text("Frecuencia: Cada ${data['repetir_cada'] ?? 0} horas", style: const TextStyle(color: Colors.black54)),
                                ],
                              ),
                            ),
                            IconButton(icon: const Icon(Icons.settings, color: Colors.grey), onPressed: () => _abrirDialogoConfiguracion(doc.id, data['nombre_pastilla'], data)),
=======
                                  Text("Hora: ${data['primera_dosis'] ?? 'No programada'}", style: const TextStyle(color: Colors.black54)),
                                  Text("Días: $diasTexto", style: const TextStyle(color: Colors.black54)),
                                ],
                              ),
                            ),
                            // Se envía el index + 1 para indicar si es el Slot 1 o Slot 2
                            IconButton(icon: const Icon(Icons.settings, color: Colors.grey), onPressed: () => _abrirDialogoConfiguracion(doc.id, data['nombre_pastilla'], data, index + 1)),
>>>>>>> origin/rama-prueba
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