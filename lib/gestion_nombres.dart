import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  void _mostrarDialogo({String? idDocumento, String? nombreActual}) {
    if (idDocumento != null && nombreActual != null) {
      _controller.text = nombreActual;
    } else {
      _controller.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            idDocumento == null ? "Agregar Medicamento" : "Editar Nombre"),
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
                    await firestoreInstance.collection('pastillas').add({
                      'nombre_pastilla': _controller.text,
                      'descripcion_pastillas':
                          'Medicamento registrado desde la app',
                      'recomendaciones_pastillas':
                          'Sin recomendaciones adicionales'
                    });
                  } else {
                    await firestoreInstance
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text(
          "Gestion de Medicamentos",
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
                stream: firestoreInstance.collection('pastillas').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("No hay medicamentos en Firebase"),
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _mostrarDialogo(
                                  idDocumento: idDoc,
                                  nombreActual: nombreMedicamento,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                onPressed: () async {
                                  try {
                                    await firestoreInstance
                                        .collection('pastillas')
                                        .doc(idDoc)
                                        .delete();
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text("Error al eliminar: $e")),
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
      floatingActionButton: FloatingActionButton(
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