import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'encabezado_usuario.dart';
import 'menu_inferior.dart';
import 'preguntas_frecuentes.dart';
import 'terminos_condiciones.dart';
import 'seguridad_permisos.dart';
import 'ayuda_usuario.dart';

class PanelConexiones extends StatefulWidget {
  final String nombreUsuario;
  final String sexoUsuario;
  final String correoUsuario;
  final String rolUsuario;

  const PanelConexiones({
    super.key,
    required this.nombreUsuario,
    required this.sexoUsuario,
    required this.correoUsuario,
    required this.rolUsuario,
  });

  @override
  State<PanelConexiones> createState() => _PanelConexionesState();
}

class _PanelConexionesState extends State<PanelConexiones> {
  // IP fija de tu ESP32 (puedes usar también "http://pastillero.local")
  final String baseUrl = "http://10.126.234.37";

  // Variables de estado dinámicas
  bool _conectado = false;
  String _wifiSsid = "No conectado";
  bool _rtcOk = false;
  bool _servosOk = false;
  bool _buzzerOk = false;
  bool _cargando = false;
  String _ultimoReporte = "Sin reportes";

  @override
  void initState() {
    super.initState();
    _obtenerEstadoESP32(); // Consulta el estado automáticamente al abrir la pantalla
  }

  // Función que realiza la petición HTTP al endpoint del ESP32
  Future<void> _obtenerEstadoESP32() async {
    setState(() {
      _cargando = true;
    });

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/status'))
          .timeout(const Duration(seconds: 4)); // Timeout de 4 segundos

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        DateTime now = DateTime.now();
        String horaFormateada =
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

        setState(() {
          _conectado = data['conexion'] ?? false;
          _wifiSsid = data['wifi_ssid'] ?? "Desconocido";
          _rtcOk = data['rtc_sincronizado'] ?? false;
          _servosOk = data['servos_calibrados'] ?? false;
          _buzzerOk = data['buzzer_operativo'] ?? false;
          _ultimoReporte = "Hoy a las $horaFormateada";
          _cargando = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Sincronización exitosa! Todo está OK.'),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
        }
      } else {
        _setDesconectado();
      }
    } catch (e) {
      _setDesconectado();
    }
  }

  // Restablece el estado visual si la placa no responde
  void _setDesconectado() {
    setState(() {
      _conectado = false;
      _wifiSsid = "No conectado";
      _rtcOk = false;
      _servosOk = false;
      _buzzerOk = false;
      _cargando = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Error: No se pudo establecer conexión con el dispensador.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
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
              EncabezadoUsuario(
                nombre: widget.nombreUsuario,
                sexo: widget.sexoUsuario,
                correo: widget.correoUsuario,
                rol: widget.rolUsuario,
                pacienteId: '',
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tu cuenta está protegida",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "MiniDoc protege tu información personal y la mantiene privada y segura.",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Fila 1: Preguntas Frecuentes & Términos y Condiciones
                    Row(
                      children: [
                        Expanded(
                          child: _buildGridCard(
                            icon: Icons.help_outline,
                            title: "Preguntas\nFrecuentes",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PreguntasFrecuentes(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGridCard(
                            icon: Icons.description_outlined,
                            title: "Términos y\nCondiciones",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TerminosCondicionesPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildGridCard(
                            icon: Icons.security,
                            title: "Seguridad y\nPermisos",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SeguridadPermisos(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGridCard(
                            icon: Icons.chat_bubble_outline,
                            title: "Ayuda por\n WhatsApp",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AyudaUsuario(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ), // Cierra Row de la segunda fila
                  ],
                ), // Cierra Column del contenedor
              ), // Cierra Container principal
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
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
                    Row(
                      children: [
                        const Icon(Icons.settings_input_antenna,
                            color: Colors.grey, size: 20),
                        const SizedBox(width: 10),
                        const Text(
                          "Estado del Hardware",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54),
                        ),
                        if (_cargando) ...[
                          const Spacer(),
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF2962FF)),
                            ),
                          )
                        ]
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Usamos las variables reactivas que cambian según la respuesta JSON del ESP32
                    _buildStatusItem(
                        Icons.developer_board,
                        "Dispositivo Principal",
                        _conectado ? "Conectado" : "No disponible",
                        _conectado),
                    _buildStatusItem(
                        Icons.wifi, "Modulo WiFi (ESP)", _wifiSsid, _conectado),
                    _buildStatusItem(
                        Icons.settings_applications,
                        "Servomotores",
                        _servosOk ? "Calibrados" : "No detectados",
                        _servosOk),
                    _buildStatusItem(Icons.schedule, "Reloj RTC DS3231",
                        _rtcOk ? "Sincronizado" : "Sin sincronizar", _rtcOk),
                    _buildStatusItem(Icons.volume_up, "Buzzer de Alarma",
                        _buzzerOk ? "Operativo" : "No operativo", _buzzerOk),
                    const Divider(height: 30, color: Colors.black12),
                    _buildStatusItem(
                        Icons.history, "Ultimo reporte", _ultimoReporte, false),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _cargando ? null : _obtenerEstadoESP32,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2962FF),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          elevation: 2,
                        ),
                        child: Text(
                          _cargando ? "Sincronizando..." : "Verificar Conexion",
                          style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PantallaLogin()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text("Cerrar Sesion",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Modo de visualizacion: Hardware Local",
                  style: TextStyle(color: Colors.black38, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MenuInferior(
        nombreUsuario: widget.nombreUsuario,
        sexoUsuario: widget.sexoUsuario,
        correoUsuario: widget.correoUsuario,
        rolUsuario: widget.rolUsuario,
      ),
    );
  }

  Widget _buildStatusItem(
      IconData icon, String title, String subtitle, bool isHardwareActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2E7D32), size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black54)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // El color del CircleAvatar cambia de verde (activo) a rojo (inactivo)
          if (title != "Ultimo reporte")
            CircleAvatar(
                radius: 6,
                backgroundColor:
                    isHardwareActive ? const Color(0xFF4CAF50) : Colors.red)
          else
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        ],
      ),
    );
  }
}

Widget _buildOptionCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
      side: BorderSide(color: Colors.grey.shade200, width: 1),
    ),
    color: const Color(0xFFF9F9F9),
    child: ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF2E7D32), size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 13, color: Colors.black54),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.black38,
      ),
    ),
  );
}

Widget _buildSmallCard({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
      side: BorderSide(color: Colors.grey.shade200, width: 1),
    ),
    color: const Color(0xFFF9F9F9),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF2E7D32), size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildGridCard({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return Card(
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.grey.shade200, width: 1),
    ),
    color: const Color(0xFFFAFAFA),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1B5E20), size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B5E20),
                  height: 1.2,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFF1B5E20),
            ),
          ],
        ),
      ),
    ),
  );
}
