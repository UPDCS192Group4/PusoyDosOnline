import uuid

from django.db import models
from django.contrib.auth.models import AbstractUser

# Create your models here.
class Lobby(models.Model):
    """
    Lobby information
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    websocket = models.CharField(max_length=128, default="", blank=True)
    owner = models.UUIDField()
    creation_date = models.DateTimeField()
    last_activity = models.DateTimeField()
    status = models.IntegerField() # status is if it's waiting or about to start a game

class User(AbstractUser):
    """
    User information
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    rating = models.IntegerField("Elo Rating")
    current_lobby = models.ForeignKey(Lobby)
    country_code = models.CharField(max_length=3, defualt="")
    highest_rating = models.IntegerField()
    
    
    def __str__(self):
        return self.username
    