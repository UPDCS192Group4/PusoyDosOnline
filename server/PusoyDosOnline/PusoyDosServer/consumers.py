import uuid
from channels.generic.websocket import JsonWebsocketConsumer
from django.contrib.auth.models import AnonymousUser
from asgiref.sync import async_to_sync
import json

from .models import Lobby

class LobbyConsumer(JsonWebsocketConsumer):
    """
    Consumer responsible for lobby websockets.
    This consumer should handle people joining and leaving a lobby.
    This consumer should also support both types of lobbies.
    
    TODO: Turn this to AsyncJsonWebsocketConsumer before release
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
        
        # Check if the user is allowed to be in this lobby
        # If the user's lobby_id in the backend is not set to this lobby
        # then we must deny access to it.
        if not self._is_authenticated():
            print("User is not authenticated!")
            self.close()
            return
        
        if self.scope["user"].current_lobby == None or str(self.scope["user"].current_lobby.id) != self.lobby_id:
            print("User is not allowed to be in this lobby!")
            self.close()
            return
        
        print("User is authenticated!")
        self.lobby_group_name = f"lobby_{self.lobby_id}"
        self.user_id = self.scope["user"].id
        
        # Add user to the player list in the database
        lobby = Lobby.objects.get(id=self.lobby_id) # this lobby should already exist
        lobby.players_inside.add(self.scope["user"])
        lobby.save()
        
        # Get updated player list
        player_list = list(lobby.players_inside.all().values_list("username", flat=True))
        print("Player successfully added to database log!")
        
        # Join this websocket up with the lobby group
        async_to_sync(self.channel_layer.group_add)(
            self.lobby_group_name,
            self.channel_name
        )
        print("Consumer successfully added to group!")
        
        # Send the player_join event to everyone in the group to notify them that someone has joined
        async_to_sync(self.channel_layer.group_send)(
            self.lobby_group_name,
            {
                "type": "user_join",
                "username": self.scope["user"].username,
                "list": player_list,
            }
        )
        
        # Finally accept the connection
        self.accept()
    
    def disconnect(self, code):
        # If this is a case of an unauthenticated user or a user
        # not belonging to this lobby, don't do anything special
        if not self._is_authenticated() or self.scope["user"].current_lobby == None or str(self.scope["user"].current_lobby.id) != self.lobby_id:
            return
        
        # Remove user from the database listing
        lobby = Lobby.objects.get(id=self.lobby_id) # this lobby should already exist
        lobby.players_inside.remove(self.scope["user"])
        lobby.save()
        
        # Get updated player list
        player_list = list(lobby.players_inside.all().values_list("username", flat=True))
        
        # Announce to group that user left
        async_to_sync(self.channel_layer.group_send)(
            self.lobby_group_name,
            {
                "type": "user_leave",
                "username": self.scope["user"].username,
                "list": player_list,
            }
        )
        
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
        
        if not "type" in content:
            self.send(text_data=json.dumps({
                "type": "error",
                "error": "Invalid lobby data sent",
            }))
            return
        
        if content["type"] == "chat" and "message" in content:
            async_to_sync(self.channel_layer.group_send)(
                self.lobby_group_name,
                {
                    "type": "chat_received",
                    "message": content["message"],
                    "from": self.scope["user"].username,
                }
            )
            return
        
        if content["type"] == "start":
            # Count how many users there are in the lobby
            return
        
        if content["type"] == "leave":
            # Remove the lobby from the user
            self.scope["user"].current_lobby = None
            self.scope["user"].save()
            # Close the connection
            self.close()
            return
            
    
    def chat_received(self, event):
        self.send(text_data=json.dumps({
            'type': "chat",
            'message': event["message"],
            'from': event["from"],
        }))
    
    def user_join(self, event):
        self.send(text_data=json.dumps({
            'type': "join",
            'message': f"User {event['username']} has joined the lobby!",
            'list': event['list'],
        }))
    
    def user_leave(self, event):
        self.send(text_data=json.dumps({
            'type': "leave",
            'message': f"User {event['username']} has left the lobby!",
            'list': event['list'],
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
