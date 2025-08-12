# server.py
import asyncio
import websockets
import subprocess
import re

#comment

connected_clients = set()
usernames = {}  # Store usernames for each websocket

async def handle_client(websocket):
    connected_clients.add(websocket)
    print(f"[+] Client connected. Total clients: {len(connected_clients)}")

    try:
        # First message from the client = username
        username = await websocket.recv()
        usernames[websocket] = username
        print(f"[Server] {username} joined the chat.")

        # Listen for all future messages
        async for message in websocket:
            full_msg = f"{username}: {message}"
            print(f"[Server] {full_msg}")

            # Broadcast to everyone (including the sender)
            # If a send fails because the client disconnected, remove it.
            to_remove = []
            for client in list(connected_clients):
                try:
                    await client.send(full_msg)
                except websockets.exceptions.ConnectionClosed:
                    to_remove.append(client)
                except Exception as e:
                    # unexpected errors shouldn't crash the server
                    print(f"[Warn] Failed sending to {client.remote_address}: {e}")
                    to_remove.append(client)

            for c in to_remove:
                connected_clients.discard(c)
                usernames.pop(c, None)

    except websockets.exceptions.ConnectionClosed:
        print(f"[-] {usernames.get(websocket, 'Unknown')} disconnected.")
    finally:
        connected_clients.discard(websocket)
        usernames.pop(websocket, None)


def get_lan_ip():
    # Run ipconfig and capture output
    result = subprocess.run(["ipconfig"], capture_output=True, text=True)
    output = result.stdout

    # Find first IPv4 address that isn't 127.0.0.1
    match = re.search(r"IPv4 Address[.\s]*:\s*(\d+\.\d+\.\d+\.\d+)", output)
    if match:
        return match.group(1)
    return "127.0.0.1"  # fallback

async def main():
    lan_ip = get_lan_ip()
    async with websockets.serve(handle_client, "0.0.0.0", 8765):
        print(f"[Server] Running on ws://{lan_ip}:8765")
        await asyncio.Future()

if __name__ == "__main__":
    asyncio.run(main())
