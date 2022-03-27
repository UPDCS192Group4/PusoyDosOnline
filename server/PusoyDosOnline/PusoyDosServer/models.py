import uuid

from django.db import models
from django.utils import timezone
from django.contrib.auth.models import AbstractUser
from django_countries.fields import CountryField

# Create your models here.
class Lobby(models.Model):
    """
    Lobby information
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    shorthand = models.CharField(max_length=5, default="", blank=True)
    websocket = models.CharField(max_length=128, default="", blank=True)
    owner = models.UUIDField(null=True)
    creation_date = models.DateTimeField(default=timezone.now)
    last_activity = models.DateTimeField(default=timezone.now)
    status = models.IntegerField(default=True) # status is if it's waiting or about to start a game
    class Meta:
        verbose_name_plural = "lobbies"

class User(AbstractUser):
    """
    User information
    """
    first_name = None # We don't need these so we'll just set these to NULL
    last_name = None # We don't need these so we'll just set these to NULL
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    rating = models.IntegerField("Elo Rating", default=1000)
    current_lobby = models.ForeignKey(Lobby, on_delete=models.SET_NULL, null=True, blank=True)
    country_code = CountryField()
    highest_rating = models.IntegerField("Max Rating", default=1000)
    played_games = models.IntegerField(default=0)
    won_games = models.IntegerField(default=0)
    lost_games = models.IntegerField(default=0)
    winstreak = models.IntegerField(default=0)
    
    def __str__(self):
        return self.username
    
    def get_short_name(self):
        # Override the AbstractUser function for this just in case it's used elsewhere
        return self.username
    