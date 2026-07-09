import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';
import 'menu_inferior.dart';

class PantallaGestionNombres extends StatefulWidget {
  final String nombreUsuario;
  final String sexoUsuario;
  final String rolUsuario;
  final String correoUsuario;

  const PantallaGestionNombres({
    super.key,
    required this.nombreUsuario,
    required this.sexoUsuario,
    required this.rolUsuario,
    required this.correoUsuario,
  });

  @override
  State<PantallaGestionNombres> createState() => _PantallaGestionNombresState();
}

class _PantallaGestionNombresState extends State<PantallaGestionNombres> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  bool _tienePermisosDeEdicion() => widget.rolUsuario == 'familiar' || widget.rolUsuario == 'administrador';

  void _mostrarDialogo({String? idDocumento, String? nombreActual, String? pacienteIdActual}) {
    if (!_tienePermisosDeEdicion()) return;

    _controller.text = nombreActual ?? '';
    String? pacienteSeleccionado = pacienteIdActual;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(idDocumento == null ? "Agregar Medicamento" : "Editar Medicamento"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller, 
                decoration: const InputDecoration(labelText: "Nombre del Medicamento", border: OutlineInputBorder())
              ),
              const SizedBox(height: 15),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('pacientes')
                    .where('correo_familiar', isEqualTo: widget.correoUsuario.trim())
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  
                  var pacientes = snapshot.data!.docs;
                  if (pacientes.isEmpty) return const Text("No tienes pacientes registrados.");

                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Asignar a Paciente', border: OutlineInputBorder()),
                    initialValue: (pacientes.any((p) => p.id == pacienteSeleccionado)) ? pacienteSeleccionado : null,
                    isExpanded: true,
                    items: pacientes.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text("${data['nombre_paciente'] ?? ''} ${data['apellido_paciente'] ?? ''}"),
                      );
                    }).toList(),
                    onChanged: (val) => setDialogState(() => pacienteSeleccionado = val),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () async {
                if (_controller.text.isNotEmpty && pacienteSeleccionado != null) {
                  try {
                    if (idDocumento == null) {
                      await _firestore.collection('pastillas').add({
                        'nombre_pastilla': _controller.text.trim(),
                        'paciente_id': pacienteSeleccionado,
                        'id_usuario': _currentUserId,
                        'creado_en': FieldValue.serverTimestamp(),
                      });
                    } else {
                      await _firestore.collection('pastillas').doc(idDocumento).update({
                        'nombre_pastilla': _controller.text.trim(),
                        'paciente_id': pacienteSeleccionado,
                      });
                    }
                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool esPaciente = widget.rolUsuario == 'paciente';
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(title: const Text("Gestión de Medicamentos"), backgroundColor: const Color(0xFF2D7A4F), foregroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firebaseService.streamMedicamentosPorUsuario(_currentUserId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(data['nombre_pastilla'] ?? 'Medicamento'),
                  subtitle: Text("ID Asignado: ${data['paciente_id']}"),
                  trailing: esPaciente ? null : IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _mostrarDialogo(
                      idDocumento: doc.id,
                      nombreActual: data['nombre_pastilla'],
                      pacienteIdActual: data['paciente_id'],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: esPaciente ? null : FloatingActionButton(
        backgroundColor: const Color(0xFF2D7A4F),
        onPressed: () => _mostrarDialogo(),
        child: const Icon(Icons.add, color: Colors.white),
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