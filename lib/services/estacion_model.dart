class Estacion {
  final int id;
  final String nombre;
  final String ubicacion;
  final int ultimaLectura; // Para la lógica de colores (Reto Lab 6.2)

  Estacion({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.ultimaLectura,
  });

  // Constructor Factory para transformar el JSON del Backend a Objeto Dart
  factory Estacion.fromJson(Map<String, dynamic> json) {
    return Estacion(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? 'Sin nombre',
      ubicacion: json['ubicacion'] ?? 'Sin ubicación',
      ultimaLectura: json['ultima_lectura'] ?? 0,
    );
  }
}
