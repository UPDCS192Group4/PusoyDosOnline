"""
ASGI config for PusoyDosOnline project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/4.0/howto/deployment/asgi/
"""

import os

from channels.routing import ProtocolTypeRouter
from channels.auth import AuthMiddlewareStack # This would be used if we were dealing with session cookies
from .middleware import UserAuthMiddleware # This would be used instead since we're dealing with custom JWT Tokens
from channels.routing import ProtocolTypeRouter, URLRouter, ChannelNameRouter
from django.core.asgi import get_asgi_application

import PusoyDosServer.routing # websocket routing
from .backend_consumers import * # lobby/game jobs handling

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'PusoyDosOnline.settings')

application = ProtocolTypeRouter({
    "http": get_asgi_application(),
    "websocket": UserAuthMiddleware(
        URLRouter(
            PusoyDosServer.routing.websocket_urlpatterns
        )
    ),
    
    # Jobs for handling lobby joins
    # NOTE: These are workers! They need to be specified to be opened
    #       using the runworker command in manage.py!
    "channels": ChannelNameRouter({
        "lobby-clean": LobbyCleaner.as_asgi(),
    })
})
