import 'package:flutter/material.dart';
import 'gestion_nombres.dart';
import 'pantalla_principal.dart'; // Para poder volver al inicio si quieres
import 'configuracion_slots.dart'; // Para el botón de "Hora"

class MenuInferior extends StatelessWidget {
  const MenuInferior({super.key});

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
          // NOTA: Ahora pasamos 'context' como primer argumento
          _buildNavItem(context, Icons.home_rounded, "Inicio", false),
          _buildNavItem(context, Icons.access_time_rounded, "Hora", false),
          _buildNavItem(context, Icons.medical_services_outlined, "Nombres", false),
          _buildNavItem(context, Icons.settings_outlined, "Ajustes", false),
        ],
      ),
    );
  }

  // Widget auxiliar corregido
  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isSelected) {
    return InkWell(
      onTap: () {
        if (label == "Nombres") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PantallaGestionNombres()),
          );
        } else if (label == "Inicio") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
          );
        } else if (label == "Hora") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PantallaConfiguracionSlots()),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
            size: 28,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF4CAF50) : Colors.grey, 
              fontSize: 12
            ),
          ),
        ],
      ),
    );
  }
}