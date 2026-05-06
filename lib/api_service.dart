import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart'; // Importante para obtener el token

class ApiService {
  final String baseUrl = "http://10.0.2.2:8000";

  Future<bool> crearEstacion(String nombre, String ubicacion) async {
    try {
      // 1. Recuperamos el token guardado en el teléfono
      final token = await AuthService().getToken();

      // 2. Realizamos la petición POST
      final response = await http.post(
        Uri.parse('$baseUrl/estaciones/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Aquí enviamos la "llave"
        },
        body: jsonEncode({
          'nombre': nombre,
          'ubicacion': ubicacion,
        }),
      );

      // 3. Verificamos si el servidor aceptó la creación
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error al crear estación: $e");
      return false;
    }
  }
}