import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'estacion_model.dart';

class ApiService {
  final String baseUrl = 'http://localhost:3000/api';

  // LAB 7.1: Traer estaciones con manejo de errores y timeout
  Future<List<Estacion>> fetchEstaciones() async {
    try {
      final token = await AuthService().getToken();
      final response = await http
          .get(
            Uri.parse('$baseUrl/estaciones/'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Estacion.fromJson(data)).toList();
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(
        'No se pudo conectar con SMAT. ¿Está el servidor activo?',
      );
    }
  }

  // LAB 6.2: Eliminar una estación
  Future<bool> eliminarEstacion(int id) async {
    try {
      final token = await AuthService().getToken();
      final response = await http
          .delete(
            Uri.parse('$baseUrl/estaciones/$id'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // LAB 6.2: Actualizar una estación
  Future<bool> editarEstacion(int id, String nombre, String ubicacion) async {
    try {
      final token = await AuthService().getToken();
      final response = await http
          .put(
            Uri.parse('$baseUrl/estaciones/$id'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'nombre': nombre, 'ubicacion': ubicacion}),
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
