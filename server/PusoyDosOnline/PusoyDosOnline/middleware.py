from rest_framework_simplejwt.authentication import JWTAuthentication
from django.contrib.auth.models import AnonymousUser
from django.contrib.auth import get_user_model
from asgiref.sync import sync_to_async

class UserAuthMiddleware:
    def __init__(self, app):
        self.app = app
        self.JWTAuth = JWTAuthentication()
        
    def filter_headers(self, headers):
        for name, value in headers:
            if name == b'authorization':
                return value
        return None
        
    async def __call__(self, scope, receive, send):
        token = None
        headers = scope["headers"]
        header = self.filter_headers(headers)
        if header:
            raw_token = self.JWTAuth.get_raw_token(header)
        
        if raw_token:
            try:
                token = self.JWTAuth.get_validated_token(raw_token)
            except: # token did not get validated, either token is no longer valid or was never valid
                token = None
                
        if token:
            scope["user"] = await sync_to_async(self.JWTAuth.get_user)(token)
        else:
            scope["user"] = None
            
        return await self.app(scope, receive, send)