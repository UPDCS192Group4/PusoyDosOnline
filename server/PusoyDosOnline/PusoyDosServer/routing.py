from django.urls import re_path
from .consumers import *

websocket_urlpatterns = [
    re_path(r'ws/lobby/(?P<lobby_id>\w+)/', LobbyConsumer.as_asgi()),
    re_path(r'ws/game/(?P<game_id>\w+)/', GameConsumer.as_asgi()),
]
