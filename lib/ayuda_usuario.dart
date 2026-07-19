import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AyudaUsuario extends StatelessWidget {
  const AyudaUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("Ayuda al Usuario"),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.support_agent,
              size: 80,
              color: Color(0xFF2E7D32),
            ),
            const SizedBox(height: 15),
            const Text(
              "Centro de Ayuda",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Si tienes alguna duda o inconveniente con MiniDoc, puedes comunicarte con nuestro equipo de soporte.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 3,
              child: ListTile(
                leading: Icon(Icons.chat, color: Colors.green.shade700),
                title: const Text("WhatsApp"),
                subtitle: const Text("+51 904 186 908"),
              ),
            ),
            const SizedBox(height: 15),
            Card(
              elevation: 3,
              child: ListTile(
                leading: Icon(Icons.email, color: Colors.green.shade700),
                title: const Text("Correo electrónico"),
                subtitle: const Text("soporte@minidoc.pe"),
              ),
            ),
            const SizedBox(height: 15),
            Card(
              elevation: 3,
              child: ListTile(
                leading: Icon(Icons.access_time, color: Colors.green.shade700),
                title: const Text("Horario de atención"),
                subtitle: const Text(
                  "Lunes a Viernes\n08:00 AM - 06:00 PM",
                ),
              ),
            ),
            const SizedBox(height: 15),
            Card(
              elevation: 3,
              child: ListTile(
                leading: Icon(Icons.timer, color: Colors.green.shade700),
                title: const Text("Tiempo de respuesta"),
                subtitle: const Text(
                  "Nuestro tiempo promedio de respuesta es menor a 24 horas.",
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // <-- 2. Añade el async aquí
                  // Formateamos el número sin espacios para el enlace de WhatsApp
                  final Uri whatsappUrl = Uri.parse(
                      "https://wa.me/51904186908?text=Hola,%20necesito%20ayuda%20con%20MiniDoc");

                  if (await launchUrl(whatsappUrl,
                      mode: LaunchMode.externalApplication)) {
                    // Abre exitosamente la app externa de WhatsApp
                  } else {
                    // Por si ocurre un error o el dispositivo no tiene internet/la app instalada
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("No se pudo abrir WhatsApp")),
                    );
                  }
                },
                icon: const Icon(Icons.chat),
                label: const Text("Contactar por WhatsApp"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
