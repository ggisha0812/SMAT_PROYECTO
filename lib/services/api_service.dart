import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'estacion_model.dart'; // Importamos el modelo que acabamos de crear

class ApiService {
  final String baseUrl = 'http://localhost:3000/api'; 

  // LAB 7.1: Traer estaciones con manejo robusto de errores y timeout
  Future<List<Estacion>> fetchEstaciones() async {
    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/estaciones/'),
      ).timeout(const Duration(seconds: 5)); // Evita esperas infinitas [cite: 355]

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body); [cite: 357]
        // Convertimos la lista dinámica en objetos de tipo Estacion 
        return jsonResponse.map((data) => Estacion.fromJson(data)).toList(); [cite: 358]
      } else {
        throw Exception('Error del servidor: ${response.statusCode}'); [cite: 361]
      }
    } catch (e) {
      // Esto evita que la App se cierre inesperadamente si el servidor está apagado [cite: 363]
      throw Exception('No se pudo conectar con SMAT. ¿Está el servidor activo?'); [cite: 364]
    }
  }

  // LAB 6.2: Eliminar una estación interactuando con el Backend [cite: 228]
  Future<bool> eliminarEstacion(int id) async {
    try {
      final token = await AuthService().getToken(); [cite: 231]
      final response = await http.delete( [cite: 232]
        Uri.parse('$baseUrl/estaciones/$id'), [cite: 234]
        headers: {'Authorization': 'Bearer $token'}, [cite: 235]
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200; [cite: 236]
    } catch (e) {
      return false;
    }
  }

  // LAB 6.2: Actualizar una estación existente [cite: 237]
  Future<bool> editarEstacion(int id, String nombre, String ubicacion) async {
    try {
      final token = await AuthService().getToken(); [cite: 238]
      final response = await http.put( [cite: 248]
        Uri.parse('$baseUrl/estaciones/$id'), [cite: 248]
        headers: {
          'Content-Type': 'application/json', [cite: 251]
          'Authorization': 'Bearer $token', [cite: 252]
        },
        body: jsonEncode({'nombre': nombre, 'ubicacion': ubicacion}), [cite: 253]
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200; [cite: 254]
    } catch (e) {
      return false;
    }
  }
}
