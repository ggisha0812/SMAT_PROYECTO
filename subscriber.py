import json
import paho.mqtt.client as mqtt
from pydantic import BaseModel, Field, ValidationError

# Esquema de datos esperado usando Pydantic
class LecturaSensor(BaseModel):
    sensor_id: int
    timestamp: float
    valor: float = Field(..., ge=-50.0, le=100.0)
    unidad: str


BROKER = "broker.hivemq.com"
PUERTO = 1883
TOPICO = "unmsm/fisi/cc/sensor/temperatura"


# Callback de conexión
def on_connect(client, userdata, flags, rc, properties):
    if rc == 0:
        print("Conectado exitosamente al broker.")

        client.subscribe(TOPICO)
        print(f"Suscrito a: {TOPICO}")
    else:
        print(f"Error de conexión. Código: {rc}")


# Callback cuando llega un mensaje
def on_message(client, userdata, msg):
    raw_payload = msg.payload.decode()

    print(f"\n[SUBSCRIBER] Mensaje recibido en {msg.topic}")

    try:
        datos_json = json.loads(raw_payload)

        lectura = LecturaSensor(**datos_json)

        print(f"-> Datos validados correctamente")
        print(f"-> Sensor ID: {lectura.sensor_id}")
        print(f"-> Temperatura: {lectura.valor} {lectura.unidad}")

    except json.JSONDecodeError:
        print("[ALERTA] JSON inválido.")

    except ValidationError as e:
        print("[ALERTA DE SEGURIDAD]")
        print(e)


def main():
    cliente = mqtt.Client(
        callback_api_version=mqtt.CallbackAPIVersion.VERSION2
    )

    cliente.on_connect = on_connect
    cliente.on_message = on_message

    cliente.connect(BROKER, PUERTO, 60)

    print("Esperando mensajes...")

    cliente.loop_forever()


if __name__ == "__main__":
    main()