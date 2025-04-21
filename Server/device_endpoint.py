from fastapi import APIRouter, WebSocket
import asyncio
from datetime import datetime
import random
import math

device_router = APIRouter()

@device_router.websocket("/thermostat")
async def thermostat_websocket(websocket: WebSocket):
    await websocket.accept()
    print("Thermostat WebSocket connected!")
    
    try:
        while True:
            current_time = datetime.now()
            # Generate temperature between 10-40°C with smooth transitions
            temperature = 25 + (math.sin(2 * current_time.timestamp() / 10) * 15)
            angle = (temperature - 10) * (180/30)  # Map 10-40°C to 0-180 degrees
            
            thermostat_message = {
                "angle": round(angle, 2),
                "device_name": "Fahrenheit 451Mbps",
                "timestamp": current_time.isoformat(),
                "temperature": round(temperature, 1)
            }
            
            await websocket.send_json(thermostat_message)
            await asyncio.sleep(0.01)
            
    except Exception as e:
        print(f"Error in thermostat websocket: {e}")
    finally:
        await websocket.close() 