import 'package:flutter/material.dart';

class SeguridadPermisos extends StatelessWidget {
  const SeguridadPermisos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("Seguridad y Permisos"),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.shield_outlined,
              color: Color(0xFF2E7D32),
              size: 80,
            ),
            const SizedBox(height: 15),
            const Text(
              "Tu información está protegida",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "MiniDoc implementa mecanismos de seguridad para proteger tu información personal y médica.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 3,
              child: ListTile(
                leading: Icon(Icons.lock, color: Colors.green.shade700),
                title: const Text("Seguridad de la cuenta"),
                subtitle: const Text(
                  "El acceso a MiniDoc se realiza mediante autenticación con Google y cada usuario accede según su rol asignado.",
                ),
              ),
            ),
            const SizedBox(height: 15),
            Card(
              elevation: 3,
              child: ListTile(
                leading: Icon(Icons.storage, color: Colors.green.shade700),
                title: const Text("Protección de datos"),
                subtitle: const Text(
                  "La información de pacientes y familiares se almacena de forma segura en Firebase.",
                ),
              ),
            ),
            const SizedBox(height: 15),
            Card(
              elevation: 3,
              child: ListTile(
                leading: Icon(Icons.admin_panel_settings,
                    color: Colors.green.shade700),
                title: const Text("Permisos utilizados"),
                subtitle: const Text(
                  "• Acceso a Internet\n"
                  "• Notificaciones\n"
                  "• Inicio de sesión con Google\n"
                  "• Comunicación segura con Firebase",
                ),
              ),
            ),
            const SizedBox(height: 15),
            Card(
              elevation: 3,
              child: ListTile(
                leading:
                    Icon(Icons.verified_user, color: Colors.green.shade700),
                title: const Text("Buenas prácticas"),
                subtitle: const Text(
                  "• No compartas tu cuenta.\n"
                  "• Mantén actualizado tu dispositivo.\n"
                  "• Cierra sesión en equipos compartidos.\n"
                  "• Reporta cualquier actividad sospechosa.",
                ),
              ),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF2E7D32)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "MiniDoc aplica buenas prácticas inspiradas en estándares internacionales para proteger la información de sus usuarios.",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
