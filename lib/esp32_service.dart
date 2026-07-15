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
  // IP de tu ESP32. También puedes usar "http://pastillero.local" si tu router soporta mDNS
  final String baseUrl = "http://192.168.0.48"; 

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
}