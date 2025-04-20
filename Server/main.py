from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from auction_endpoint import auction_router
from device_endpoint import device_router
from game_endpoint import game_router

app = FastAPI()

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include all routers
app.include_router(auction_router)
app.include_router(device_router)
app.include_router(game_router)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 