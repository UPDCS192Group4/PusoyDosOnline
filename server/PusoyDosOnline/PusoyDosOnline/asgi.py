"""
ASGI config for PusoyDosOnline project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/4.0/howto/deployment/asgi/
"""

import os

from channels.routing import ProtocolTypeRouter
from channels.auth import AuthMiddlewareStack
from channels.routing import ProtocolTypeRouter, URLRouter
from django.core.asgi import get_asgi_application
import PusoyDosServer.routing

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'PusoyDosOnline.settings')

application = ProtocolTypeRouter({
    "http": get_asgi_application(),
    "websocket": AuthMiddlewareStack(
        URLRouter(
            PusoyDosServer.routing.websocket_urlpatterns
        )
    ),
})
