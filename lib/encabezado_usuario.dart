import 'package:flutter/material.dart';
import 'pantalla_datos_usuario.dart';

class EncabezadoUsuario extends StatelessWidget {
  final String pacienteId; // ID del documento en Firestore
  final String nombre; // Nombre del usuario en sesión
  final String sexo; // Sexo del usuario en sesión
  final String correo; // Correo del usuario en sesión
  final String rol; // Rol del usuario en sesión

  const EncabezadoUsuario({
    super.key,
    required this.pacienteId,
    required this.nombre,
    required this.sexo,
    required this.correo,
    required this.rol,
  });

  @override
  Widget build(BuildContext context) {
    // URL de avatares según el sexo (Mantiene tu lógica original)
    final String urlImagen = (sexo == 'H')
        ? 'https://e7.pngegg.com/pngimages/348/800/png-clipart-man-wearing-blue-shirt-illustration-computer-icons-avatar-user-login-avatar-blue-child-thumbnail.png'
        : 'https://thumbs.dreamstime.com/b/mujer-de-render-d-png-trabajando-en-tecnolog%C3%ADa-avatar-digital-port%C3%A1til-contra-fondo-transparente-384935566.jpg';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hola, $nombre",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PantallaDatosUsuario(
                  pacienteId: pacienteId, // ID del documento del paciente
                  nombreUsuario:
                      nombre, // 👈 Agregado: Envía el nombre para el encabezado de perfil
                  correoUsuario: correo, // Correo de la sesión actual
                  sexoUsuario: sexo == 'H'
                      ? 'Hombre'
                      : 'Mujer', // 👈 Agregado: Formatea el sexo de forma limpia
                  rolUsuario: rol, usuarioId: '', // Rol del usuario actual
                ),
              ),
            );
          },
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(urlImagen),
          ),
        ),
      ],
    );
  }
}
