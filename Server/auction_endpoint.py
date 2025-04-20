from fastapi import APIRouter, WebSocket
import asyncio
from datetime import datetime, timedelta
import random

auction_router = APIRouter()

# Generate 50-60 random bids starting at $1000 with varying increments
def generate_bidders():
    names = ["Alice", "Bob", "Charlie", "David", "Eve", "Frank", "Grace", 
             "Henry", "Ivy", "Jack", "Kelly", "Liam", "Maya", "Noah", "Olivia"]
    
    num_bids = random.randint(50, 60)
    bids = []
    current_amount = 1000.00
    
    for _ in range(num_bids):
        # Random increment between $10 and $100, with occasional larger jumps
        if random.random() < 0.1:  # 10% chance of aggressive bid
            increment = random.uniform(100, 250)
        else:
            increment = random.uniform(10, 100)
            
        current_amount += increment
        bids.append({
            "bidder": random.choice(names),
            "amount": round(current_amount, 2)
        })
    
    return bids

@auction_router.websocket("/auction")
async def auction_websocket(websocket: WebSocket):
    await websocket.accept()
    print("WebSocket connected! Starting auction...")
    
    try:
        bids = generate_bidders()
        print(f"Generated {len(bids)} bids")
        
        # Set auction duration to 2 minutes
        total_duration = 120  # 2 minutes in seconds
        end_time = datetime.now() + timedelta(seconds=total_duration)
        
        # Calculate average delay between bids
        avg_delay = total_duration / len(bids)
        
        for bid in bids:
            current_time = datetime.now()
            if current_time >= end_time:
                break
                
            remaining_seconds = (end_time - current_time).total_seconds()
            
            bid_message = {
                "bidder": bid["bidder"],
                "amount": bid["amount"],
                "timestamp": current_time.isoformat(),
                "timeRemaining": round(remaining_seconds)  # Rounded to nearest second
            }
            
            await websocket.send_json(bid_message)
            print(f"Sent bid: {bid['bidder']} - ${bid['amount']:.2f} - {round(remaining_seconds)}s remaining")
            
            # Only delay if there's time remaining
            delay = min(
                random.uniform(avg_delay * 0.7, avg_delay * 1.3),
                remaining_seconds  # Don't delay beyond end time
            )
            await asyncio.sleep(delay)
            
        # Send final message when auction ends
        await websocket.send_json({
            "bidder": bid_message["bidder"],  # Last winning bidder
            "amount": bid_message["amount"],  # Final amount
            "timestamp": datetime.now().isoformat(),
            "timeRemaining": 0,
            "status": "ended"
        })
        print("Auction ended!")
            
    except Exception as e:
        print(f"Error in auction websocket: {e}")
    finally:
        print("WebSocket connection closed")
        await websocket.close() 