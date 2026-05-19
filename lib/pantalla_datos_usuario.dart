import 'package:flutter/material.dart';

class PantallaDatosUsuario extends StatelessWidget {
  final String nombre;
  final String correo;
  final String sexo;
  final String rol;

  const PantallaDatosUsuario({
    super.key,
    required this.nombre,
    required this.correo,
    required this.sexo,
    required this.rol,
  });

  @override
  Widget build(BuildContext context) {
    final String urlImagen = (sexo == 'H')
        ? 'https://e7.pngegg.com/pngimages/348/800/png-clipart-man-wearing-blue-shirt-illustration-computer-icons-avatar-user-login-avatar-blue-child-thumbnail.png'
        : 'https://thumbs.dreamstime.com/b/mujer-de-render-d-png-trabajando-en-tecnolog%C3%ADa-avatar-digital-port%C3%A1til-contra-fondo-transparente-384935566.jpg';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(urlImagen),
                ),
                const SizedBox(height: 15),
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  rol.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.email_outlined, "Correo", correo),
                    const Divider(),
                    _buildInfoRow(
                      Icons.wc_outlined,
                      "Sexo",
                      sexo == 'H' ? "Hombre" : "Mujer",
                    ),
                    const Divider(),
                    _buildInfoRow(
                      Icons.admin_panel_settings_outlined,
                      "Rol",
                      rol,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
