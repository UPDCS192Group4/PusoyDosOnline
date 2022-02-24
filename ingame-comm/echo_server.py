# Simple echo server
### Created just for testing purposes, I kinda hate Python for this
### Afaik JS can setup event listeners for when clients connect to the server
### so creating the server with Node.js sounds kinda hot

# REFERENCES
### WebSockets Docs Tutorial (link TBA)

import asyncio
import websockets

port = 8765

async def echo(websocket):
    async for message in websocket:
        print(f"Received message: {message}")
        await websocket.send(message)

async def main():
    async with websockets.serve(echo, "localhost", port):
        print("Server running")
        await asyncio.Future()

asyncio.run(main())