import paho.mqtt.client as mqtt
import requests
import json
import sys
import time

# CONFIGURACIÓN
MQTT_BROKER = "broker.hivemq.com"
MQTT_PORT = 1883
MQTT_TOPIC = "fisi/smat/estaciones/+/lecturas"

API_URL = "http://localhost:8000/lecturas/"

JWT_TOKEN = "TU_TOKEN_JWT_AQUI"

# 🧠 CACHE LOCAL (EDGE)
last_values = {}   # {id: valor}
last_sent_time = {}  # {id: timestamp}


# 🔵 CONEXIÓN
def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("🟢 Conectado al Broker MQTT")
        client.subscribe(MQTT_TOPIC)
        print(f"📡 Escuchando: {MQTT_TOPIC}")
    else:
        print(f"🔴 Error conexión: {rc}")
        sys.exit(1)


# 📩 MENSAJES MQTT
def on_message(client, userdata, msg):
    try:
        payload = json.loads(msg.payload.decode("utf-8"))

        topic_parts = msg.topic.split("/")
        estacion_id = int(topic_parts[3])

        nuevo_valor = float(payload["valor"])
        ahora = time.time()

        print(f"\n📩 Estación {estacion_id} -> {nuevo_valor}")

        # 🔥 VALORES PREVIOS
        valor_anterior = last_values.get(estacion_id)
        ultimo_envio = last_sent_time.get(estacion_id, 0)

        # 🔥 CONDICIÓN 1: primer dato siempre pasa
        if valor_anterior is None:
            enviar = True

        else:
            # 🔥 CONDICIÓN 2: cambio > 5%
            cambio = abs(nuevo_valor - valor_anterior) / valor_anterior * 100

            # 🔥 CONDICIÓN 3: más de 60 segundos sin enviar
            tiempo_ok = (ahora - ultimo_envio) > 60

            enviar = (cambio > 5) or tiempo_ok

        # 🔴 BLOQUEO DE DATOS (FILTRO EDGE)
        if not enviar:
            print(f"🟡 FILTRADO (ruido eliminado) - cambio {round(cambio,2)}%")
            return

        # 🔥 ACTUALIZAR CACHE
        last_values[estacion_id] = nuevo_valor
        last_sent_time[estacion_id] = ahora

        # 📤 ENVIAR AL BACKEND
        data = {
            "valor": nuevo_valor,
            "estacion_id": estacion_id
        }

        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {JWT_TOKEN}"
        }

        response = requests.post(API_URL, json=data, headers=headers)

        if response.status_code in [200, 201]:
            print(f"💾 ENVIADO -> DB (estación {estacion_id})")
        else:
            print(f"⚠️ Error API: {response.status_code}")

    except Exception as e:
        print(f"❌ Error: {e}")


# 🚀 MAIN
def main():
    client = mqtt.Client()

    client.on_connect = on_connect
    client.on_message = on_message

    print("🚀 Bridge con FILTRO DE RUIDO activo...")

    client.connect(MQTT_BROKER, MQTT_PORT, 60)

    client.loop_forever()


if __name__ == "__main__":
    main()