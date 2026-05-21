import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';
import 'encabezado_usuario.dart';
import 'menu_inferior.dart';
import 'configuracion_slots.dart'; // Asegúrate que este archivo exista

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
  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F1),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firebaseService.streamMedicamentosPorUsuario(_currentUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            int medicamentosPorAgotarse = 0;
            List<QueryDocumentSnapshot> docs = [];

            if (snapshot.hasData) {
              docs = snapshot.data!.docs;
              for (var doc in docs) {
                var data = doc.data() as Map<String, dynamic>;
                int cant = int.tryParse(
                        data['cantidad_restante']?.toString() ?? '0') ??
                    0;
                if (cant <= 3 && cant > 0) {
                  medicamentosPorAgotarse++;
                }
              }
            }

            return SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
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
                  if (medicamentosPorAgotarse > 0)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9C4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Colors.orange, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Atención! Tienes medicamentos por agotarse ($medicamentosPorAgotarse unidades o menos)",
                              style: const TextStyle(
                                  color: Color(0xFF5D4037),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                          ),
                        ],
                      ),
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
                    child: docs.isEmpty
                        ? const Center(
                            child: Text("No tienes pastillas registradas"))
                        : Column(
                            children: [
                              ...docs.map((doc) {
                                var data = doc.data() as Map<String, dynamic>;
                                String nombre =
                                    data['nombre_pastilla'] ?? 'Sin nombre';
                                int cantRestante = int.tryParse(
                                        data['cantidad_restante']?.toString() ??
                                            '0') ??
                                    0;
                                double pct =
                                    (cantRestante / 10).clamp(0.0, 1.0);
                                int pctTexto = (pct * 100).toInt();

                                Color colorBarra = Colors.green;
                                if (pctTexto == 100) {
                                  colorBarra = (nombre.toLowerCase() ==
                                              'penicilina' ||
                                          nombre.toLowerCase() == 'amoxicilina')
                                      ? Colors.amber
                                      : Colors.green;
                                } else if (pctTexto <= 30 && pctTexto > 0) {
                                  colorBarra = Colors.orange;
                                } else if (pctTexto == 0) {
                                  colorBarra = Colors.red;
                                }

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0),
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
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                              }),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // CORRECCIÓN: Se usa el nombre de clase correcto y se pasan los argumentos
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PantallaConfiguracionSlots(
                                          nombreUsuario: widget.nombreUsuario,
                                          sexoUsuario: widget.sexoUsuario,
                                          rolUsuario: widget.rolUsuario,
                                          correoUsuario: widget.correoUsuario,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF50),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                  ),
                                  child: const Text("Ver detalles",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
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
