import 'package:flutter/material.dart';
import 'menu_inferior.dart';
import 'datos_medicamentos.dart'; // IMPORTANTE: Importar la lista global

class PantallaGestionNombres extends StatefulWidget {
  final String nombreUsuario; // 👈 Agregamos la variable para el nombre
  final String sexoUsuario; // 👈 Agregamos la variable para el sexo

  const PantallaGestionNombres({
    super.key,
    required this.nombreUsuario, // 👈 Lo hacemos requerido en el constructor
    required this.sexoUsuario, // 👈 Lo hacemos requerido en el constructor
  });

  @override
  State<PantallaGestionNombres> createState() => _PantallaGestionNombresState();
}

class _PantallaGestionNombresState extends State<PantallaGestionNombres> {
  final TextEditingController _controller = TextEditingController();

  void _mostrarDialogo({int? index}) {
    if (index != null) {
      _controller.text = nombresPastillasGlobal[index];
    } else {
      _controller.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? "Agregar Medicamento" : "Editar Nombre"),
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
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                setState(() {
                  if (index == null) {
                    nombresPastillasGlobal.add(_controller.text);
                  } else {
                    nombresPastillasGlobal[index] = _controller.text;
                  }
                });
                Navigator.pop(context);
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
              child: ListView.builder(
                itemCount: nombresPastillasGlobal.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(
                        nombresPastillasGlobal[index],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _mostrarDialogo(index: index),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              setState(
                                () => nombresPastillasGlobal.removeAt(index),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
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
      // 👈 Quitamos el const y pasamos el nombre del widget al menú
      bottomNavigationBar: MenuInferior(
        nombreUsuario: widget.nombreUsuario,
        sexoUsuario: widget.sexoUsuario,
        correoUsuario: '',
        rolUsuario: '',
      ),
    );
  }
}
