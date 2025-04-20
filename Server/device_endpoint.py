from fastapi import APIRouter, WebSocket
import asyncio
from datetime import datetime
import random
import math

device_router = APIRouter()

# Simulate thermostat angle changes
async def generate_angle_changes():
    current_angle = 0
    while True:
        # Generate smooth angle changes between 0 and 360 degrees
        change = random.uniform(-10, 10)
        current_angle = (current_angle + change) % 360
        
        # Add some realistic behavior - slower changes near extremes
        if current_angle < 20 or current_angle > 340:
            await asyncio.sleep(random.uniform(0.5, 1.5))
        else:
            await asyncio.sleep(random.uniform(0.1, 0.3))
            
        yield {
            "type": "angle_update",
            "angle": round(current_angle, 2),
            "timestamp": datetime.now().isoformat()
        }

@device_router.websocket("/device")
async def device_websocket(websocket: WebSocket):
    await websocket.accept()
    
    try:
        # Send initial connection message
        await websocket.send_json({
            "type": "connection",
            "message": "Connected to device WebSocket",
            "timestamp": datetime.now().isoformat()
        })
        
        # Generate and send angle updates for 2 minutes
        angle_generator = generate_angle_changes()
        start_time = datetime.now()
        
        while (datetime.now() - start_time).total_seconds() < 120:  # 2 minutes
            angle_update = await anext(angle_generator)
            await websocket.send_json(angle_update)
            
        # Send end message
        await websocket.send_json({
            "type": "end",
            "message": "Device simulation completed",
            "timestamp": datetime.now().isoformat()
        })
        
    except Exception as e:
        print(f"Error: {e}")
    finally:
        await websocket.close() 