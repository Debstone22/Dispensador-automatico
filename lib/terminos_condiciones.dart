import 'package:flutter/material.dart';

class TerminosCondicionesPage extends StatelessWidget {
  const TerminosCondicionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Términos y Condiciones',
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
                Icons.medical_services,
                size: 70,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Términos y Condiciones de MiniDoc',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              '''
Al utilizar la aplicación MiniDoc, el usuario acepta los presentes términos y condiciones de uso.

1. Aceptación del servicio

MiniDoc es una aplicación diseñada para apoyar la gestión y seguimiento del consumo de medicamentos mediante recordatorios y control de horarios establecidos por el usuario.

2. Uso de la aplicación

El usuario se compromete a utilizar la aplicación de manera responsable, proporcionando información correcta sobre medicamentos, horarios y datos personales necesarios para el funcionamiento del sistema.

3. Responsabilidad del usuario

El usuario es responsable de verificar la información registrada en la aplicación. MiniDoc funciona como una herramienta de apoyo y no reemplaza la evaluación, diagnóstico o indicación realizada por profesionales de la salud.

4. Gestión de medicamentos

La información registrada sobre medicamentos debe corresponder a las indicaciones proporcionadas por el usuario o familiares responsables. El sistema únicamente facilita recordatorios y seguimiento.

5. Seguridad de la cuenta

El usuario debe proteger sus credenciales de acceso y evitar compartir su información personal con terceros no autorizados.

6. Disponibilidad del servicio

MiniDoc busca mantener la disponibilidad del sistema; sin embargo, pueden presentarse interrupciones por mantenimiento, actualizaciones o problemas externos.

7. Actualizaciones

Los términos y condiciones pueden modificarse para mejorar la seguridad y funcionamiento de la aplicación. El usuario será informado sobre cambios importantes.
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
                  'Aceptar términos',
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
