from channels.generic.websocket import JsonWebsocketConsumer
from django.contrib.auth.models import AnonymousUser
from asgiref.sync import async_to_sync
import json

class LobbyConsumer(JsonWebsocketConsumer):
    """
    Consumer responsible for lobby websockets.
    This consumer should handle people joining and leaving a lobby.
    This consumer should also support both types of lobbies.
    """
    def _is_authenticated(self):
        """
        Helper function to check if the user who initiated this socket
        is logged in or not
        
        Function taken from https://stackoverflow.com/questions/50901411/django-jwt-middleware-for-channels-websocket-authentication
        """
        if hasattr(self.scope, 'auth_error'):
            return False
        if not self.scope['user'] or self.scope['user'].is_anonymous:
            return False
        return True
    
    def connect(self):
        self.lobby_id = self.scope["url_route"]["kwargs"]["lobby_id"]
        print(f"Connection attempted to lobby {self.lobby_id}")
        
        self.accept()
        
        # Check if the user is allowed to be in this lobby
        # If the user's lobby_id in the backend is not set to this lobby
        # then we must deny access to it.
        if not self._is_authenticated():
            print("User is not authenticated!")
            self.close()
            return
        
        print("User is authenticated!")
        self.lobby_group_name = f"lobby_{self.lobby_id}"
        self.user_id = self.scope["user"].id
        
        # Join this websocket up with the lobby group
        async_to_sync(self.channel_layer.group_add)(
            self.lobby_group_name,
            self.channel_name
        )
        
        async_to_sync(self.channel_layer.group_send)(
            self.lobby_group_name,
            {
                "type": "user_join",
                "username": self.scope["user"].username
            }
        )
    
    def disconnect(self, code):
        if self._is_authenticated():
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
        types = ["chat_received", "user_join", "user_leave", "self_leave"]
    
    def chat_received(self, event):
        self.send(text_data=json.dumps({
            'type': "chat",
            'message': event["message"],
        }))
    
    def user_join(self, event):
        self.send(text_data=json.dumps({
            'type': "join",
            'message': f"User {event['username']} has joined the lobby!",
        }))
    
    def user_leave(self, event):
        self.send(text_data=json.dumps({
            'type': "leave",
            'message': f"User {event['username']} has left the lobby!",
        }))
        
    
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
