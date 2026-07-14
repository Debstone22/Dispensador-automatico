import 'package:flutter/material.dart';

class PreguntasFrecuentes extends StatelessWidget {
  const PreguntasFrecuentes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Preguntas frecuentes',
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.medical_services,
              size: 70,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            _pregunta(
                '¿Qué es MiniDoc?',
                'MiniDoc es un sistema inteligente diseñado para ayudar '
                    'a los adultos mayores en la gestión y control de sus medicamentos.'),
            _pregunta(
                '¿Cómo agrego un medicamento?',
                'Desde la sección Medicamentos puede registrar el nombre, '
                    'cantidad y horario correspondiente.'),
            _pregunta(
                '¿Cómo funcionan los recordatorios?',
                'El sistema genera alertas según los horarios configurados '
                    'para recordar la toma del medicamento.'),
            _pregunta(
                '¿Qué pasa si no tomo mi medicamento?',
                'El sistema puede registrar la falta de confirmación y '
                    'enviar una notificación al familiar encargado.'),
            _pregunta(
                '¿Puedo modificar los horarios?',
                'Sí, puede actualizar los horarios desde la sección '
                    'de configuración de medicamentos.'),
            _pregunta(
                '¿Mis datos están protegidos?',
                'MiniDoc utiliza mecanismos de autenticación y almacenamiento '
                    'seguro para proteger la información del usuario.'),
          ],
        ),
      ),
    );
  }

  Widget _pregunta(String pregunta, String respuesta) {
    return ExpansionTile(
      leading: const Icon(
        Icons.help_outline,
        color: Colors.green,
      ),
      title: Text(
        pregunta,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Text(
            respuesta,
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}
