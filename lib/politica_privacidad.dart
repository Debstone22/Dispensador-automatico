import 'package:flutter/material.dart';

class PoliticaPrivacidadPage extends StatelessWidget {
  const PoliticaPrivacidadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Política de Privacidad',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.privacy_tip,
                size: 70,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Política de Privacidad MiniDoc',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              '''
En MiniDoc nos comprometemos a proteger la privacidad y seguridad de la información proporcionada por los usuarios.

1. Información recopilada

La aplicación puede recopilar información básica del usuario como nombres, correo electrónico, datos de autenticación e información relacionada con medicamentos registrados.

2. Uso de la información

Los datos recopilados son utilizados exclusivamente para permitir el funcionamiento de la aplicación, gestionar usuarios, almacenar horarios de medicamentos y generar recordatorios.

3. Almacenamiento de datos

La información puede almacenarse mediante servicios seguros en la nube como Firebase Authentication y Firebase Firestore, aplicando mecanismos de protección para evitar accesos no autorizados.

4. Seguridad de la información

MiniDoc implementa mecanismos de autenticación y control de acceso para proteger la información del usuario.

5. Compartición de datos

Los datos personales no serán vendidos ni compartidos con terceros, salvo cuando sea requerido por obligaciones legales.

6. Derechos del usuario

El usuario puede solicitar la revisión, actualización o eliminación de su información personal registrada en el sistema.

7. Aceptación

Al utilizar MiniDoc, el usuario acepta las condiciones descritas en esta política de privacidad.
''',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Aceptar política',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
