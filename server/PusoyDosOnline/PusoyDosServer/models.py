import uuid

from django.db import models
from django.utils import timezone
from django.contrib.auth.models import AbstractUser
from django_countries.fields import CountryField
from random import choices

def generate_shorthand():
    return "".join(choices("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", k=5))

# Create your models here.
class Lobby(models.Model):
    """
    Lobby information
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    shorthand = models.CharField(max_length=5, default=generate_shorthand, unique=True)
    websocket = models.CharField(max_length=128, default="", blank=True) # websocket will only be populated if a game is running from this lobby
    owner = models.UUIDField(null=True)
    creation_date = models.DateTimeField(default=timezone.now)
    last_activity = models.DateTimeField(default=timezone.now)
    status = models.IntegerField(default=True) # status is if it's waiting or about to start a game
    players_inside = models.ManyToManyField("User", blank=True) # players currently inside the lobby
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
    country_code = CountryField(default="AQ")
    highest_rating = models.IntegerField("Max Rating", default=1000)
    played_games = models.IntegerField(default=0)
    won_games = models.IntegerField(default=0)
    lost_games = models.IntegerField(default=0)
    winstreak = models.IntegerField(default=0)
    
    friends = models.ManyToManyField("User", blank=True)
    
    def __str__(self):
        return self.username
    
    def get_short_name(self):
        # Override the AbstractUser function for this just in case it's used elsewhere
        return self.username
    
class FriendRequest(models.Model):
    from_user = models.ForeignKey(User, related_name="from_user", on_delete=models.CASCADE)
    to_user = models.ForeignKey(User, related_name="to_user", on_delete=models.CASCADE)
    sent_at = models.DateTimeField(default=timezone.now)
    
    def __str__(self):
        return f"{self.from_user.username} -> {self.to_user.username}"
    