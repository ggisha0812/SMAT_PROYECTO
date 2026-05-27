import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/estacion_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();
  
  // Guardamos el Future en una variable para el RefreshIndicator (Lab 7.1)
  late Future<List<Estacion>> futureEstaciones;

  @override
  void initState() {
    super.initState();
    _obtenerDatos();
  }

  void _obtenerDatos() {
    setState(() {
      futureEstaciones = apiService.fetchEstaciones(); // Dispara la consulta robusta [cite: 385]
    });
  }

  // LAB 6.2 - PASO 3: Crear el Diálogo de Edición interactivo (showDialog) [cite: 289, 290]
  void _mostrarDialogoEdicion(Estacion estacion) { [cite: 292]
    final nombreCtrl = TextEditingController(text: estacion.nombre); [cite: 293]
    final ubicacionCtrl = TextEditingController(text: estacion.ubicacion); [cite: 294]

    showDialog(
      context: context, [cite: 295]
      builder: (context) => AlertDialog( [cite: 297]
        title: const Text("Editar Estación"), [cite: 298]
        content: Column( [cite: 299]
          mainAxisSize: MainAxisSize.min, [cite: 300]
          children: [ [cite: 301]
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: "Nombre")), [cite: 302]
            TextField(controller: ubicacionCtrl, decoration: const InputDecoration(labelText: "Ubicación")), [cite: 302]
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), [cite: 307]
            child: const Text("Cancelar"), [cite: 307]
          ),
          ElevatedButton( [cite: 316]
            onPressed: () async { [cite: 317]
              bool ok = await apiService.editarEstacion(estacion.id, nombreCtrl.text, ubicacionCtrl.text); [cite: 319]
              if (ok) { [cite: 319]
                Navigator.pop(context); [cite: 320]
                _obtenerDatos(); // Actualiza la lista en pantalla [cite: 324]
              }
            },
            child: const Text("Guardar"), [cite: 327]
          ),
        ],
      ),
    );
  }

  // LAB 6.2 - RETO 1: Lógica de Colores "Indicadores de Alerta Temprana" [cite: 332, 333]
  Color _obtenerColorAlerta(int valorLectura) {
    // Verde si es normal (< 50). Rojo si supera el umbral crítico (> 50) [cite: 333, 334]
    return valorLectura > 50 ? Colors.red : Colors.green; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio - SMAT'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _obtenerDatos,
          )
        ],
      ),
      body: FutureBuilder<List<Estacion>>(
        future: futureEstaciones,
        builder: (context, snapshot) {
          // Mientras carga el servicio de red (Feedback Visual)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // LAB 7.1 - RESILIENCIA: Mostrar el mensaje personalizado capturado en el try-catch
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  '${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: Center,
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay estaciones registradas."));
          }

          final estaciones = snapshot.data!;

          // LAB 7.1 - PASO 2: Implementar Sincronización con RefreshIndicator [cite: 335, 380]
          return RefreshIndicator( [cite: 380]
            onRefresh: () async { [cite: 381]
              _obtenerDatos(); // Dispara la recarga al deslizar hacia abajo [cite: 383, 385]
            },
            child: ListView.builder( [cite: 387]
              itemCount: estaciones.length, [cite: 388]
              itemBuilder: (context, index) {
                final estacion = estaciones[index];

                // LAB 6.2 - PASO 2: Gestión de Interfaz mediante Swipe-to-Dismiss [cite: 255, 256, 258]
                return Dismissible( [cite: 258]
                  key: Key(estacion.id.toString()), [cite: 259]
                  direction: DismissDirection.endToStart, [cite: 260]
                  background: Container( [cite: 261]
                    color: Colors.red, [cite: 263]
                    alignment: Alignment.centerRight, [cite: 264]
                    padding: const EdgeInsets.only(right: 20), [cite: 265]
                    child: const Icon(Icons.delete, color: Colors.white), [cite: 266]
                  ),
                  onDismissed: (direction) async { [cite: 267]
                    bool ok = await apiService.eliminarEstacion(estacion.id); [cite: 268]
                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar( [cite: 269]
                        SnackBar(content: Text("${estacion.nombre} eliminada")), [cite: 269]
                      );
                    } else {
                      _obtenerDatos(); // Si falla el backend, reaparece el elemento en la interfaz
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Error al eliminar la estación")),
                      );
                    }
                  },
                  child: ListTile( [cite: 282]
                    leading: Icon(
                      Icons.radio_button_checked,
                      color: _obtenerColorAlerta(estacion.ultimaLectura), // Aplicación del Reto de Colores [cite: 333]
                    ),
                    title: Text(estacion.nombre), [cite: 283]
                    subtitle: Text(estacion.ubicacion), [cite: 284]
                    onTap: () => _mostrarDialogoEdicion(estacion), // Paso 3: Diálogo rápido [cite: 285]
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}