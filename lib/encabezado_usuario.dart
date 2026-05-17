import 'package:flutter/material.dart';

class EncabezadoUsuario extends StatelessWidget {
  final String nombre;
  final String urlImagen;

  const EncabezadoUsuario({
    super.key,
    this.nombre = "María",
    this.urlImagen =
        'https://thumbs.dreamstime.com/b/mujer-de-render-d-png-trabajando-en-tecnolog%C3%ADa-avatar-digital-port%C3%A1til-contra-fondo-transparente-384935566.jpg',
  });

  @override
  Widget build(BuildContext context) {
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
        CircleAvatar(radius: 25, backgroundImage: NetworkImage(urlImagen)),
      ],
    );
  }
}
