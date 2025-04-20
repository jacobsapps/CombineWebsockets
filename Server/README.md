# WebSocket Demo Server

This server provides three different WebSocket endpoints demonstrating various real-time data streaming scenarios.

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Run the server:
```bash
python main.py
```

The server will start on `http://localhost:8000`

## Available WebSocket Endpoints

### 1. Auction Endpoint (`ws://localhost:8000/ws/auction`)
Simulates a live auction with multiple bidders. Bids increase gradually over time, with random delays between updates.

Example message:
```json
{
    "type": "bid",
    "bidder": "Alice",
    "amount": 1000.00,
    "timestamp": "2024-03-28T15:30:00.123456"
}
```

### 2. Device Endpoint (`ws://localhost:8000/ws/device`)
Simulates a physical device (thermostat) rotation angle. The angle changes smoothly over time with realistic movement patterns.

Example message:
```json
{
    "type": "angle_update",
    "angle": 45.72,
    "timestamp": "2024-03-28T15:30:00.123456"
}
```

### 3. Game Endpoint (`ws://localhost:8000/ws/game`)
Simulates a multiplayer game with 4 characters moving around in a 2D space. Characters move realistically between random target positions.

Example message:
```json
{
    "type": "position_update",
    "characters": [
        {
            "name": "Warrior",
            "x": 123.45,
            "y": 678.90
        },
        // ... other characters
    ],
    "timestamp": "2024-03-28T15:30:00.123456"
}
```

## Notes

- Each endpoint runs for approximately 2 minutes before closing the connection
- All endpoints send initial connection and end messages
- Updates are sent in real-time with appropriate delays for realistic simulation
- All data is timestamped for tracking purposes 