import requests
import time
import random

# CONFIGURACIÓN
# Nota: Verifica si tu FastAPI corre en el puerto 8000 o en el 3000 según tus laboratorios previos
API_URL = "http://localhost:8000/lecturas/"  # Ajustar ruta si tu endpoint varía

def enviar_telemetria():
    print("=== EMULADOR DE HARDWARE IoT SMAT INICIADO ===")
    
    while True:
        # Emular lectura del sensor (Nivel de agua en cm)
        # Genera valores aleatorios entre 20 y 90 para forzar estados normales y de alerta
        lectura_emulada = round(random.uniform(20.0, 90.0), 2)
        
        # Datos en formato JSON esperados por tu Backend
        payload = {
            "estacion_id": 1,  # Asegúrate de tener una estación con ID 1 en tu SQLite
            "valor": lectura_emulada
        }
        
        # --- EL RETO DE LA SEMANA 9: LÓGICA DE ALARMA Y FRECUENCIA DINÁMICA ---
        if lectura_emulada > 70.0:
            print(f"[ALERTA] Umbral de inundación superado: {lectura_emulada} cm")
            intervalo = 2  # Modo de Emergencia (Cada 2 segundos)
        else:
            print(f"[NORMAL] Lectura estable: {lectura_emulada} cm")
            intervalo = 10  # Modo Normal (Cada 10 segundos)
            
        # Envío del paquete de datos mediante HTTP POST
        try:
            response = requests.post(API_URL, json=payload, timeout=5)
            if response.status_code == 201 or response.status_code == 200:
                print(f"-> Telemetría enviada con éxito. Estado: {response.status_code}")
            else:
                print(f"[ERROR] Servidor rechazó el dato. Código: {response.status_code}")
        except requests.exceptions.RequestException as e:
            print(f"[CRÍTICO] No hay conexión con el servidor: {e}")
            
        # Espera dinámica según el estado del reto
        print(f"Esperando {intervalo} segundos para la siguiente lectura...\n")
        time.sleep(intervalo)

if __name__ == "__main__":
    enviar_telemetria()
