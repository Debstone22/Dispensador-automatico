import 'package:flutter/material.dart';
import 'gestion_nombres.dart';
import 'pantalla_principal.dart';
import 'configuracion_slots.dart';
import 'panel_conexiones.dart';

class MenuInferior extends StatelessWidget {
  final String nombreUsuario;
  final String sexoUsuario;
  final String correoUsuario;
  final String rolUsuario;

  const MenuInferior({
    super.key,
    required this.nombreUsuario,
    required this.sexoUsuario,
    required this.correoUsuario,
    required this.rolUsuario,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(context, Icons.home_rounded, "Inicio"),
          _buildNavItem(context, Icons.access_time_rounded, "Hora"),
          _buildNavItem(context, Icons.medical_services_outlined, "Nombres"),
          _buildNavItem(context, Icons.settings_outlined, "Ajustes"),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label) {
    return InkWell(
      onTap: () {
        if (label == "Nombres") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PantallaGestionNombres(
                nombreUsuario: nombreUsuario,
                sexoUsuario: sexoUsuario,
                correoUsuario: correoUsuario,
                rolUsuario: rolUsuario,
              ),
            ),
          );
        } else if (label == "Inicio") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PantallaPrincipal(
                nombreUsuario: nombreUsuario,
                sexoUsuario: sexoUsuario,
                correoUsuario: correoUsuario,
                rolUsuario: rolUsuario,
              ),
            ),
          );
        } else if (label == "Hora") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PantallaConfiguracionSlots(
                nombreUsuario: nombreUsuario,
                sexoUsuario: sexoUsuario,
                correoUsuario: correoUsuario,
                rolUsuario: rolUsuario,
              ),
            ),
          );
        } else if (label == "Ajustes") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PanelConexiones(
                nombreUsuario: nombreUsuario,
                sexoUsuario: sexoUsuario,
                correoUsuario: correoUsuario,
                rolUsuario: rolUsuario,
              ),
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey, size: 28),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}