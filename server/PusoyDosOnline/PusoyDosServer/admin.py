from django.contrib import admin
from .models import *

# Register your models here.
admin.site.register(User)
admin.site.register(Lobby)
admin.site.register(FriendRequest)
admin.site.register(Game)
admin.site.register(Hand)