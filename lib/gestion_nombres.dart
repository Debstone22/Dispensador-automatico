import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';
import 'menu_inferior.dart';
import 'datos_medicamentos.dart';

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

  // Obtiene el UID único del usuario autenticado en Firebase
  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // VALIDACIÓN: Verifica si el rol tiene permisos (Familiar o Administrador)
  bool _tienePermisosDeEdicion() {
    return widget.rolUsuario == 'familiar' ||
        widget.rolUsuario == 'administrador';
  }

  void _mostrarDialogo({String? idDocumento, String? nombreActual}) {
    // CANDADO DE SEGURIDAD 1: Si es paciente, bloquea la apertura del diálogo
    if (!_tienePermisosDeEdicion()) {
      _mostrarAvisoPermisos(
          "Los pacientes no pueden añadir ni editar medicamentos.");
      return;
    }

    if (idDocumento != null && nombreActual != null) {
      _controller.text = nombreActual;
    } else {
      _controller.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(idDocumento == null ? "Agregar Medicamento" : "Editar Nombre"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: "Ej. Amoxicilina"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_controller.text.isNotEmpty) {
                try {
                  if (idDocumento == null) {
                    // Guarda insertando el id_usuario correspondiente
                    await _firebaseService.agregarMedicamento(
                      userId: _currentUserId,
                      nombrePastilla: _controller.text,
                    );
                  } else {
                    // Actualiza el nombre del medicamento existente
                    await FirebaseFirestore.instance
                        .collection('pastillas')
                        .doc(idDocumento)
                        .update({'nombre_pastilla': _controller.text});
                  }
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error al guardar en Firebase: $e"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  // FUNCIÓN AUXILIAR: Muestra un SnackBar si un paciente intenta burlar la seguridad
  void _mostrarAvisoPermisos(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Variable booleana para identificar de forma limpia si es paciente
    final bool esPaciente = widget.rolUsuario == 'paciente';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text(
          "Gestión de Medicamentos",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firebaseService
                    .streamMedicamentosPorUsuario(_currentUserId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("No tienes medicamentos registrados"),
                    );
                  }

                  nombresPastillasGlobal = snapshot.data!.docs.map((doc) {
                    final datos = doc.data() as Map<String, dynamic>?;
                    if (datos == null) return 'Sin nombre';

                    if (datos.containsKey('nombre_pastilla')) {
                      return datos['nombre_pastilla'].toString();
                    } else if (datos.containsKey('nombre')) {
                      return datos['nombre'].toString();
                    }
                    return 'Medicamento sin nombre';
                  }).toList();

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var documento = snapshot.data!.docs[index];
                      String idDoc = documento.id;

                      final datosDoc =
                          documento.data() as Map<String, dynamic>?;
                      String nombreMedicamento = 'Medicamento sin nombre';

                      if (datosDoc != null) {
                        if (datosDoc.containsKey('nombre_pastilla')) {
                          nombreMedicamento =
                              datosDoc['nombre_pastilla'].toString();
                        } else if (datosDoc.containsKey('nombre')) {
                          nombreMedicamento = datosDoc['nombre'].toString();
                        }
                      }

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(
                            nombreMedicamento,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          // CANDADO VISUAL 1: Oculta por completo la sección de botones si es paciente
                          trailing: esPaciente
                              ? null
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () => _mostrarDialogo(
                                        idDocumento: idDoc,
                                        nombreActual: nombreMedicamento,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.redAccent),
                                      onPressed: () async {
                                        // CANDADO DE SEGURIDAD 2: Protección extra antes de borrar en Firebase
                                        if (!_tienePermisosDeEdicion()) {
                                          _mostrarAvisoPermisos(
                                              "No tienes permisos para eliminar.");
                                          return;
                                        }

                                        try {
                                          await FirebaseFirestore.instance
                                              .collection('pastillas')
                                              .doc(idDoc)
                                              .delete();
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      "Error al eliminar: $e")),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // CANDADO VISUAL 2: Si el usuario es un paciente, el botón de añadir no se renderiza (null)
      floatingActionButton: esPaciente
          ? null
          : FloatingActionButton(
              backgroundColor: const Color(0xFF4CAF50),
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
