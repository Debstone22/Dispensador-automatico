import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';
import 'encabezado_usuario.dart';
import 'menu_inferior.dart';

class PantallaPrincipal extends StatefulWidget {
  final String nombreUsuario;
  final String sexoUsuario;
  final String correoUsuario;
  final String rolUsuario;

  const PantallaPrincipal({
    super.key,
    required this.nombreUsuario,
    required this.sexoUsuario,
    required this.correoUsuario,
    required this.rolUsuario,
  });

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _pacienteSeleccionadoId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EncabezadoUsuario(
                nombre: widget.nombreUsuario,
                sexo: widget.sexoUsuario,
                correo: widget.correoUsuario,
                rol: widget.rolUsuario,
                pacienteId: '',
              ),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('pacientes')
                    .where('correo_familiar',
                        isEqualTo: widget.correoUsuario.trim())
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const LinearProgressIndicator();
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        labelText: "Seleccionar Paciente",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                        filled: true,
                        fillColor: Colors.white),
                    initialValue: _pacienteSeleccionadoId,
                    hint:
                        const Text("Selecciona un paciente para ver sus datos"),
                    items: snapshot.data!.docs
                        .map((doc) => DropdownMenuItem(
                            value: doc.id,
                            child: Text(
                                "${doc['nombre_paciente'] ?? ''} ${doc['apellido_paciente'] ?? ''}")))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _pacienteSeleccionadoId = val),
                  );
                },
              ),
              const SizedBox(height: 25),
              const Text("Capacidad de tus pastillas",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.all(24),
                child: _pacienteSeleccionadoId == null
                    ? const Center(
                        child: Text(
                            "Selecciona un paciente para ver sus medicamentos"))
                    : StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('pastillas')
                            .where('paciente_id',
                                isEqualTo: _pacienteSeleccionadoId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData)
                            return const CircularProgressIndicator();
                          var docs = snapshot.data!.docs;
                          if (docs.isEmpty)
                            return const Text(
                                "No hay medicamentos registrados para este paciente");

                          return Column(
                            children: docs.map((doc) {
                              var data = doc.data() as Map<String, dynamic>;
                              String nombre =
                                  data['nombre_pastilla'] ?? 'Sin nombre';
                              int cantRestante = int.tryParse(
                                      data['cantidad_restante']?.toString() ??
                                          '0') ??
                                  0;
                              double pct = (cantRestante / 10).clamp(0.0, 1.0);
                              int pctTexto = (pct * 100).toInt();

                              Color colorBarra = (pctTexto == 0)
                                  ? Colors.red
                                  : (pctTexto <= 30
                                      ? Colors.orange
                                      : Colors.green);

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                        width: 90,
                                        child: Text(nombre,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14),
                                            overflow: TextOverflow.ellipsis)),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: LinearProgressIndicator(
                                            value: pct,
                                            backgroundColor: Colors.grey[100],
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    colorBarra),
                                            minHeight: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    SizedBox(
                                        width: 50,
                                        child: Text("$pctTexto%",
                                            style: TextStyle(
                                                color: colorBarra,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13),
                                            textAlign: TextAlign.right)),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
              ),
            ],
          ),
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
