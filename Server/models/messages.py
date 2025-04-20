from dataclasses import dataclass
from datetime import datetime
from typing import List
from enum import Enum

class MessageType(str, Enum):
    AUCTION = "auction"
    DIAL = "dial"
    GAME = "game"

@dataclass
class Position:
    x: float
    y: float

@dataclass
class GameCharacter:
    emoji: str
    position: Position
    velocity: Position
    id: str

@dataclass
class AuctionMessage:
    bid: float
    item_id: str
    bidder: str
    timestamp: datetime
    type: str = MessageType.AUCTION

@dataclass
class DialMessage:
    angle: float
    speed: float
    device_id: str
    timestamp: datetime
    type: str = MessageType.DIAL

@dataclass
class GameMessage:
    characters: List[GameCharacter]
    timestamp: datetime
    type: str = MessageType.GAME 