from fastapi import APIRouter, WebSocket
import asyncio
from datetime import datetime
import random
import math

game_router = APIRouter()

# Game world boundaries
WORLD_WIDTH = 1000
WORLD_HEIGHT = 1000

class Character:
    def __init__(self, name, x, y):
        self.name = name
        self.x = x
        self.y = y
        self.target_x = x
        self.target_y = y
        self.speed = random.uniform(2, 5)
        
    def set_new_target(self):
        self.target_x = random.uniform(0, WORLD_WIDTH)
        self.target_y = random.uniform(0, WORLD_HEIGHT)
        
    def move(self):
        # Calculate direction vector
        dx = self.target_x - self.x
        dy = self.target_y - self.y
        distance = math.sqrt(dx*dx + dy*dy)
        
        if distance < self.speed:
            # Reached target, set new one
            self.x = self.target_x
            self.y = self.target_y
            self.set_new_target()
        else:
            # Move towards target
            self.x += (dx/distance) * self.speed
            self.y += (dy/distance) * self.speed
            
    def get_position(self):
        return {
            "name": self.name,
            "x": round(self.x, 2),
            "y": round(self.y, 2)
        }

# Initialize characters
characters = [
    Character("Warrior", random.uniform(0, WORLD_WIDTH), random.uniform(0, WORLD_HEIGHT)),
    Character("Mage", random.uniform(0, WORLD_WIDTH), random.uniform(0, WORLD_HEIGHT)),
    Character("Rogue", random.uniform(0, WORLD_WIDTH), random.uniform(0, WORLD_HEIGHT)),
    Character("Archer", random.uniform(0, WORLD_WIDTH), random.uniform(0, WORLD_HEIGHT))
]

@game_router.websocket("/game")
async def game_websocket(websocket: WebSocket):
    await websocket.accept()
    
    try:
        # Send initial connection message
        await websocket.send_json({
            "type": "connection",
            "message": "Connected to game WebSocket",
            "timestamp": datetime.now().isoformat()
        })
        
        # Simulate character movements for 2 minutes
        start_time = datetime.now()
        
        while (datetime.now() - start_time).total_seconds() < 120:  # 2 minutes
            # Update all character positions
            for char in characters:
                char.move()
            
            # Send position update
            position_update = {
                "type": "position_update",
                "characters": [char.get_position() for char in characters],
                "timestamp": datetime.now().isoformat()
            }
            
            await websocket.send_json(position_update)
            await asyncio.sleep(0.1)  # Update 10 times per second
            
        # Send end message
        await websocket.send_json({
            "type": "end",
            "message": "Game simulation completed",
            "timestamp": datetime.now().isoformat()
        })
        
    except Exception as e:
        print(f"Error: {e}")
    finally:
        await websocket.close() 