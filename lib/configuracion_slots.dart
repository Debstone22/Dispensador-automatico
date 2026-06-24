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
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  int _intervaloSeleccionado = 8;

  Future<void> _seleccionarHora(
      BuildContext context, StateSetter setDialogState) async {
    TimeOfDay? horaSeleccionada = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (horaSeleccionada != null && context.mounted) {
      setDialogState(() {
        _horaController.text = horaSeleccionada.format(context);
      });
    }
  }

  void _mostrarDialogoEdicion({
    required String idPastilla,
    required int cantidadActual,
    required String nombrePastilla,
    required String horaActual,
    required int intervaloActual,
  }) {
    _cantidadController.text = cantidadActual.toString();
    _horaController.text = horaActual;
    _intervaloSeleccionado =
        [3, 8, 12].contains(intervaloActual) ? intervaloActual : 8;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Configurar Slot: $nombrePastilla",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _cantidadController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Cantidad Restante (Máx. 10)",
                        hintText: "Ej. 10",
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _horaController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Hora de Primera Dosis",
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      onTap: () => _seleccionarHora(context, setDialogState),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<int>(
                      initialValue: _intervaloSeleccionado,
                      decoration: const InputDecoration(
                          labelText: "Repetir cada (Horas)"),
                      items: const [
                        DropdownMenuItem(value: 3, child: Text("Cada 3 horas")),
                        DropdownMenuItem(value: 8, child: Text("Cada 8 horas")),
                        DropdownMenuItem(
                            value: 12, child: Text("Cada 12 horas")),
                      ],
                      onChanged: (nuevoValor) {
                        if (nuevoValor != null) {
                          setDialogState(() {
                            _intervaloSeleccionado = nuevoValor;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_cantidadController.text.isNotEmpty &&
                        _horaController.text.isNotEmpty) {
                      int nuevaCantidad =
                          int.tryParse(_cantidadController.text) ?? 0;

                      if (nuevaCantidad > 10) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "La cantidad máxima permitida es de 10 pastillas."),
                              backgroundColor: Colors.orangeAccent,
                            ),
                          );
                        }
                        return;
                      }

                      final navigator = Navigator.of(context);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);

                      try {
                        
                        await firestoreInstance
                            .collection('pastillas')
                            .doc(idPastilla)
                            .update({
                          'cantidad_restante': nuevaCantidad,
                          'primera_dosis': _horaController.text,
                          'repetir_cada': _intervaloSeleccionado,
                        });

                        if (!context.mounted) return;
                        navigator.pop();
                      } catch (e) {
                        if (context.mounted) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                                content: Text("Error: $e"),
                                backgroundColor: Colors.redAccent),
                          );
                        }
                      }
                    }
                  },
                  child: const Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text(
          "Configuración de Slots",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: firestoreInstance.collection('pastillas').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text(
                      "No hay medicamentos registrados en la Gestión de Medicamentos."));
            }

            
            nombresPastillasGlobal = snapshot.data!.docs.map((doc) {
              final datos = doc.data() as Map<String, dynamic>?;
              return datos != null && datos.containsKey('nombre_pastilla')
                  ? datos['nombre_pastilla'].toString()
                  : 'Sin nombre';
            }).toList();

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var documento = snapshot.data!.docs[index];
                String idPastilla = documento.id;
                final datos = documento.data() as Map<String, dynamic>?;

                String nombreMedicamento =
                    datos != null && datos.containsKey('nombre_pastilla')
                        ? datos['nombre_pastilla'].toString()
                        : 'Sin nombre';

                int cantidadRestante =
                    datos != null && datos.containsKey('cantidad_restante')
                        ? (datos['cantidad_restante'] as num).toInt()
                        : 0;

                String primeraDosis =
                    datos != null && datos.containsKey('primera_dosis')
                        ? datos['primera_dosis'].toString()
                        : 'No programada';

                int repetirCada =
                    datos != null && datos.containsKey('repetir_cada')
                        ? (datos['repetir_cada'] as num).toInt()
                        : 8;

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  margin: const EdgeInsets.only(bottom: 15),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF4CAF50),
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      "SLOT ${index + 1}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Medicamento: $nombreMedicamento",
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                          Text("Cantidad: $cantidadRestante / 10 unidades",
                              style: TextStyle(
                                  color: cantidadRestante < 3
                                      ? Colors.red
                                      : Colors.black87)),
                          Text("Primera dosis: $primeraDosis",
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.blueGrey)),
                          Text("Frecuencia: Cada $repetirCada horas",
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.blueGrey)),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.settings, color: Colors.blueGrey),
                      onPressed: () => _mostrarDialogoEdicion(
                        idPastilla: idPastilla,
                        cantidadActual: cantidadRestante,
                        nombrePastilla: nombreMedicamento,
                        horaActual: primeraDosis,
                        intervaloActual: repetirCada,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
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
