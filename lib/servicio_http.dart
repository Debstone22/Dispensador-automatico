import 'package:http/http.dart' as http;

class ServicioDispositivo {
  static const String baseUrl = "http://192.168.0.36";

  static Future<bool> dispensar(int slot) async {
    try {
      // Usamos un timeout muy corto, ya que la respuesta será inmediata
      final response = await http.get(Uri.parse('$baseUrl/dispensar$slot'))
          .timeout(const Duration(seconds: 2)); 
      
      // Si recibimos 200, significa que el ESP32 recibió la orden
      return response.statusCode == 200;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}