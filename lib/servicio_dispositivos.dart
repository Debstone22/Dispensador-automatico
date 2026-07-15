import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'servicio_http.dart'; // Asegúrate de importar el servicio que tiene la lógica HTTP

class PantallaDispensador extends StatelessWidget {
  final String usuarioId;
  const PantallaDispensador({super.key, required this.usuarioId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Control de Pastillero")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('dispositivo')
            .where('id_usuario', isEqualTo: usuarioId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var dispositivos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: dispositivos.length,
            itemBuilder: (context, index) {
              var disp = dispositivos[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(disp['nombre_paciente'] ?? 'Sin nombre'),
                subtitle: Text("ID: ${disp['id_dispositivo']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.medication, color: Colors.green),
                      onPressed: () async {
                        // Aquí llamamos al servicio HTTP
                        bool ok = await ServicioDispositivo.dispensar(1);
                        if(context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(ok ? "Dispensando Slot 1" : "Error de conexión")));
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}