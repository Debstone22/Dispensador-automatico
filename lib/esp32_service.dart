import 'dart:convert';
import 'package:http/http.dart' as http;



class Esp32Status {
  final bool conectado;
  final String wifiSsid;
  final bool rtcSincronizado;
  final bool servosCalibrados;
  final bool buzzerOperativo;

  Esp32Status({
    required this.conectado,
    required this.wifiSsid,
    required this.rtcSincronizado,
    required this.servosCalibrados,
    required this.buzzerOperativo,
  });

  factory Esp32Status.desconectado() {
    return Esp32Status(
      conectado: false,
      wifiSsid: "Desconectado",
      rtcSincronizado: false,
      servosCalibrados: false,
      buzzerOperativo: false,
    );
  }

  // Mapear el JSON que envía el ESP32
  factory Esp32Status.fromJson(Map<String, dynamic> json) {
    return Esp32Status(
      conectado: json['conexion'] ?? false,
      wifiSsid: json['wifi_ssid'] ?? "Desconocido",
      rtcSincronizado: json['rtc_sincronizado'] ?? false,
      servosCalibrados: json['servos_calibrados'] ?? false,
      buzzerOperativo: json['buzzer_operativo'] ?? false,
    );
  }
}

class Esp32Service {
    final String baseUrl = "http://pastillero.local"; 

  Future<Esp32Status> obtenerEstadoHardware() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/status'),
      ).timeout(const Duration(seconds: 4)); // Si tarda más de 4 seg, asumimos desconectado

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return Esp32Status.fromJson(data);
      } else {
        return Esp32Status.desconectado();
      }
    } catch (e) {
      // Cualquier error de red (IP no encontrada, fuera de rango) caerá aquí
      return Esp32Status.desconectado();
    }
  }
  // Función para enviar la configuración de la alarma al ESP32
  Future<bool> configurarAlarma({
    required int slot,
    required String hora, // Formato "HH:MM"
    required List<bool> diasActivos, // Lista de 7 booleanos [Dom, Lun, Mar, Mie, Jue, Vie, Sab]
  }) async {
    // 1. Armamos la base de la consulta
    String parametros = "?slot=$slot&hora=$hora";

    // 2. Agregamos los días marcados a la URL
    // En tu ESP32: d0 = Domingo, d1 = Lunes... d6 = Sábado
    for (int i = 0; i < 7; i++) {
      if (diasActivos[i]) {
        parametros += "&d$i=1";
      }
    }

    try {
      // 3. Enviamos la petición al ESP32
      final response = await http.get(
        Uri.parse('$baseUrl/set_config$parametros'),
      ).timeout(const Duration(seconds: 5));

      // El paquete http sigue las redirecciones automáticamente (el ESP32 devuelve un 303 que redirige al 200)
      return response.statusCode == 200; 
    } catch (e) {
      return false; // Error de red o ESP32 apagado
    }
  }
}
