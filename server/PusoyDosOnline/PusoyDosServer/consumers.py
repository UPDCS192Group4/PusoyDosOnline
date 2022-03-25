from channels.generic.websocket import JsonWebsocketConsumer
from asgiref.sync import async_to_sync

class LobbyConsumer(JsonWebsocketConsumer):
    """
    Consumer responsible for lobby websockets.
    This consumer should handle people joining and leaving a lobby.
    This consumer should also support both types of lobbies.
    """
    def connect(self):
        self.lobby_id = self.scope["url_route"]["kwargs"]["lobby_id"]
        self.lobby_group_name = f"lobby_{self.lobby_id}"
        
        # Check if the user is allowed to be in this lobby
        # If the user's lobby_id in the backend is not set to this lobby
        # then we must deny access to it.
        if self.scope["user"].current_lobby != self.lobby_id:
            self.close()
            return
        
        # Join this websocket up with the lobby group
        async_to_sync(self.channel_layer.group_add)(
            self.lobby_group_name,
            self.channel_name
        )
        
        # Accept connection
        self.accept()
    
    def disconnect(self, code):
        # Leave the room group
        async_to_sync(self.channel_layer.group_discard)(
            self.lobby_group_name,
            self.channel_name
        )
    
    def receive_json(self, content):
        """
        Function for receiving data from the clients
        Args:
            content (dict): JSON data decoded into dictionary
        """
        pass
    
    def chat_received(self, event):
        pass
    
    def user_join(self, event):
        pass
    
    def user_leave(self, event):
        pass
    
class GameConsumer(JsonWebsocketConsumer):
    """
    Consumer responsible for game websockets
    This consumer should handle game logic and passing info to everyone else in the game
    """
    def connect(self, event):
        pass
    
    def disconnect(self, code):
        return super().disconnect(code)
    
    def receive_json(self, content, **kwargs):
        return super().receive_json(content, **kwargs)
