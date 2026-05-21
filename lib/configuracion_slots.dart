import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menu_inferior.dart';
import 'datos_medicamentos.dart';

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
  // VALIDACIÓN: ¿Puede borrar? (Solo familiar o admin)
  bool _puedeBorrar() {
    return widget.rolUsuario == 'familiar' ||
        widget.rolUsuario == 'administrador';
  }

  Future<void> _eliminarMedicamento(String id, String nombre) async {
    if (!_puedeBorrar()) return; // Doble candado en el código

    bool confirmar = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Confirmar"),
            content: Text("¿Deseas eliminar $nombre?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("No")),
              ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text("Sí")),
            ],
          ),
        ) ??
        false;

    if (confirmar) {
      await firestoreInstance.collection('pastillas').doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de Medicamentos")),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreInstance.collection('pastillas').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              String nombre = data['nombre_pastilla'] ?? 'Sin nombre';

              return ListTile(
                title: Text(nombre),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.edit, color: Colors.blue),
                    // EL BOTÓN SOLO APARECE SI NO ES PACIENTE
                    if (_puedeBorrar())
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminarMedicamento(doc.id, nombre),
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
