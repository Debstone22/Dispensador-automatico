import 'package:flutter/material.dart';
import 'firebase_service.dart';

class PanelConexiones extends StatefulWidget {
  const PanelConexiones({super.key});

  @override
  State<PanelConexiones> createState() => _PanelConexionesState();
}

class _PanelConexionesState extends State<PanelConexiones> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Fondo verde claro
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1B5E20)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SALUDO ---
              const Text(
                "Hola, María",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20), // Verde oscuro
                ),
              ),
              const SizedBox(height: 30),

              // --- TARJETA DE CONTROL ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      spreadRadius: 5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título de la tarjeta
                    Row(
                      children: const [
                        Icon(Icons.settings_input_antenna, color: Colors.grey, size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Panel de control de conexiones",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // --- LISTA DE COMPONENTES DE HARDWARE ---
                    _buildStatusItem(Icons.developer_board, "Estado del Arduino Uno", "Conectado", true),
                    _buildStatusItem(Icons.wifi, "Conexión WiFi", "MiRedCasa", true),
                    _buildStatusItem(Icons.settings_applications, "Servomotores", "Calibrados", true),
                    _buildStatusItem(Icons.schedule, "Módulo Reloj RTC", "Sincronizado", true),
                    _buildStatusItem(Icons.volume_up, "Buzzer (Alarma)", "Operativo", true),
                    
                    const Divider(height: 30, color: Colors.black12), // Separador sutil
                    
                    _buildStatusItem(Icons.history, "Última sincronización", "Hace 2 minutos", false),

                    const SizedBox(height: 25),

                    // --- BOTÓN RECONECTAR ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          // Aquí irá la lógica futura para hacer un "Ping" a Supabase/Arduino
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Verificando conexión con el hardware...')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2962FF), // Azul brillante como en el mockup
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          "Reconectar",
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final firebaseService = FirebaseService();
                        // Ejecutamos la creación en cascada
                        await firebaseService.crearUsuarioInicial();
                        await firebaseService.crearDispositivoConSlots();
                        await firebaseService.simularTomaDePastilla();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('¡Base de datos Minidoc creada en Firebase!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                      child: const Text("Sembrar Base de Datos (Seed)"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET REUTILIZABLE PARA CADA FILA ---
  // Esto demuestra buenas prácticas de código al no repetir estructuras
  Widget _buildStatusItem(IconData icon, String title, String subtitle, bool isHardware) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          // Icono con fondo verde pastel
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9), 
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2E7D32), size: 26),
          ),
          const SizedBox(width: 16),
          
          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
          
          // Indicador (Punto verde o Flechita)
          if (isHardware)
            Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50), // Punto verde de "Todo OK"
                shape: BoxShape.circle,
              ),
            )
          else
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        ],
      ),
    );
  }
}