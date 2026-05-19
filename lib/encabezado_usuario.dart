import 'package:flutter/material.dart';
import 'pantalla_datos_usuario.dart';

class EncabezadoUsuario extends StatelessWidget {
  final String nombre;
  final String sexo;
  final String correo;
  final String rol;

  const EncabezadoUsuario({
    super.key,
    required this.nombre,
    required this.sexo,
    required this.correo,
    required this.rol,
  });

  @override
  Widget build(BuildContext context) {
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
                  nombre: nombre,
                  correo: correo,
                  sexo: sexo,
                  rol: rol,
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
