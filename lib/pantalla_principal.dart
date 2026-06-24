import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menu_inferior.dart';
import 'configuracion_slots.dart';
import 'datos_medicamentos.dart';
import 'encabezado_usuario.dart';

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

class _PantallaPrincipalState extends State<PantallaPrincipal>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              EncabezadoUsuario(
                nombre: widget.nombreUsuario,
                sexo: widget.sexoUsuario,
                correo: widget.correoUsuario,
                rol: widget.rolUsuario, pacienteId: '',
              ),
              const SizedBox(height: 30),

              
              StreamBuilder<QuerySnapshot>(
                stream: firestoreInstance.collection('pastillas').snapshots(),
                builder: (context, snapshot) {
                  bool mostrarAlerta = false;
                  if (snapshot.hasData) {
                    for (var doc in snapshot.data!.docs) {
                      final datos = doc.data() as Map<String, dynamic>?;

                      
                      if (doc.id == 'info_pastillas') continue;

                      int cantidad = datos != null &&
                              datos.containsKey('cantidad_restante')
                          ? (datos['cantidad_restante'] as num).toInt()
                          : 10;

                      
                      if (cantidad <= 3) {
                        mostrarAlerta = true;
                        break;
                      }
                    }
                  }

                  return mostrarAlerta
                      ? ScaleTransition(
                          scale: Tween(begin: 1.0, end: 1.05).animate(
                            CurvedAnimation(
                                parent: _controller, curve: Curves.easeInOut),
                          ),
                          child: _construirTarjetaAlerta(),
                        )
                      : const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 30),
              const Text(
                "Capacidad de tus pastillas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: firestoreInstance
                              .collection('pastillas')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Text(
                                  "No hay medicamentos registrados",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            }

                            
                            var documentosPastillas =
                                snapshot.data!.docs.where((doc) {
                              return doc.id != 'info_pastillas';
                            }).toList();

                            if (documentosPastillas.isEmpty) {
                              return const Center(
                                child: Text(
                                  "No hay medicamentos activos",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: documentosPastillas.length,
                              itemBuilder: (context, index) {
                                var doc = documentosPastillas[index];
                                final datosPastilla =
                                    doc.data() as Map<String, dynamic>?;

                                String medicamento = datosPastilla != null &&
                                        datosPastilla
                                            .containsKey('nombre_pastilla')
                                    ? datosPastilla['nombre_pastilla']
                                        .toString()
                                    : 'Sin nombre';

                                int cantidadActual = datosPastilla != null &&
                                        datosPastilla
                                            .containsKey('cantidad_restante')
                                    ? (datosPastilla['cantidad_restante']
                                            as num)
                                        .toInt()
                                    : 0;

                                const int capacidadMaxima = 10;
                                double progresoReal =
                                    (cantidadActual / capacidadMaxima)
                                        .clamp(0.0, 1.0);

                                return _buildProgressBar(
                                  medicamento,
                                  progresoReal,
                                  _obtenerColor(index),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PantallaConfiguracionSlots(
                                nombreUsuario: widget.nombreUsuario,
                                sexoUsuario: widget.sexoUsuario,
                                correoUsuario: widget.correoUsuario,
                                rolUsuario: widget.rolUsuario,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text("Ver detalles"),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
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

  Color _obtenerColor(int index) {
    List<Color> colores = [
      Colors.amber,
      Colors.green,
      Colors.orange,
      Colors.redAccent,
      Colors.blue
    ];
    return colores[index % colores.length];
  }

  Widget _construirTarjetaAlerta() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.orange.withOpacity(0.1), blurRadius: 10)
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 30),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              "¡Atención! Tienes medicamentos por agotarse (3 unidades o menos)",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF856404)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String nombre, double valor, Color color) {
    String textoPorcentaje = "${(valor * 100).toInt()}%";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              nombre,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: valor,
                minHeight: 10,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            textoPorcentaje,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
