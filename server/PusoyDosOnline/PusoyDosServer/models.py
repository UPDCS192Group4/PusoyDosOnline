import uuid

from django.db import models
from django.utils import timezone
from django.contrib.auth.models import AbstractUser

# Create your models here.
class Lobby(models.Model):
    """
    Lobby information
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    websocket = models.CharField(max_length=128, default="", blank=True)
    owner = models.UUIDField(null=True)
    creation_date = models.DateTimeField(default=timezone.now)
    last_activity = models.DateTimeField(default=timezone.now)
    status = models.IntegerField(default=True) # status is if it's waiting or about to start a game

class User(AbstractUser):
    """
    User information
    """
    first_name = None # We don't need these so we'll just set these to NULL
    last_name = None # We don't need these so we'll just set these to NULL
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    rating = models.IntegerField("Elo Rating", default=1000)
    current_lobby = models.ForeignKey(Lobby, on_delete=models.SET_NULL, null=True)
    country_code = models.CharField(max_length=3, default="")
    highest_rating = models.IntegerField("Max Rating", default=1000)
    
    def __str__(self):
        return self.username
    
    def get_short_name(self):
        # Override the AbstractUser function for this just in case it's used elsewhere
        return self.username
    