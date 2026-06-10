from fastapi import FastAPI

app = FastAPI()

# "Base de datos" en memoria (simulación)
lecturas_db = []


@app.get("/")
def home():
    return {"message": "API SMAT funcionando"}


# 🔥 ENDPOINT QUE NECESITA TU BRIDGE
@app.post("/lecturas/")
def crear_lectura(data: dict):
    """
    Recibe datos desde el MQTT Bridge:
    {
        "valor": 34.5,
        "estacion_id": 1
    }
    """

    lecturas_db.append(data)

    print("📥 Dato recibido desde Bridge:", data)

    return {
        "mensaje": "Lectura guardada correctamente",
        "data": data
    }


# (OPCIONAL) Ver datos guardados
@app.get("/lecturas/")
def obtener_lecturas():
    return lecturas_db