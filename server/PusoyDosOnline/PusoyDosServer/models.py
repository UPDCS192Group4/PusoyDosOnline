import uuid

from django.db import models
from django.contrib.postgres.fields import ArrayField
from django.utils import timezone
from django.contrib.auth.models import AbstractUser
from django_countries.fields import CountryField
from random import choices, randint

def generate_shorthand():
    return "".join(choices("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", k=5))

def get_default_last_play():
    return [0] * 5

def get_default_skips():
    return [-1] * 3

# Create your models here.
class Lobby(models.Model):
    """
    Lobby information
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    shorthand = models.CharField(max_length=5, default=generate_shorthand, unique=True)
    # websocket = models.CharField(max_length=128, default="", blank=True) # websocket will only be populated if a game is running from this lobby
    game = models.ForeignKey("Game", blank=True, on_delete=models.SET_NULL, null=True) # this will only be populated if there is a game running from this lobby, this replaces the role of the field.
    owner = models.UUIDField(null=True)
    creation_date = models.DateTimeField(default=timezone.now)
    last_activity = models.DateTimeField(default=timezone.now)
    status = models.IntegerField(default=0) # status = amount of players ready
    players_inside = models.ManyToManyField("User", blank=True) # players currently inside the lobby
    class Meta:
        verbose_name_plural = "lobbies"
        
    def save(self, *args,**kwargs):
        self.last_activity = timezone.now() # keep the last activity updated
        return super().save(*args, **kwargs)
        
class Game(models.Model):
    """
    Game information
    Should contain information on players, hands, and current game state
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    last_activity = models.DateTimeField(default=timezone.now)
    seed = models.IntegerField(default=0)
    current_round = models.IntegerField(default=0) # 1 round = 1 successful play made (either cards are played or its a skip)
    hands = models.ManyToManyField("Hand", blank=True)
    players = models.ManyToManyField("User", blank=True)
    # A card is essentially [Suit][Number Value]. 3s are 1, Kings are 11, Aces are 12, 2s are 13. Numbers are prepended with 0 if less than 10
    # Suits are represented using the first digit of each suit: 0 = Clubs, 1 = Spades, 2 = Hearts, 3 = Diamonds
    # So a 3 of Clubs would be internally represented as 001, a 2 of Diamonds would be 313, etc etc
    last_play = ArrayField(base_field=models.IntegerField(name="LastCard", default=0), size=5, default=get_default_last_play) # contains the last play
    control = models.IntegerField(default=4) # if control == 4, then the current player has control
    winners = models.IntegerField(default=0) # winner count: keep track of how many winners are assigned already
    skips = ArrayField(base_field=models.IntegerField(name="SkipThis", default=-1), size=3, default=get_default_skips) # skip these please!
    
    def save(self, *args,**kwargs):
        self.last_activity = timezone.now() # keep the last activity updated
        return super().save(*args, **kwargs)
    
class Hand(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    move_order = models.IntegerField(default=0) # a move is allowed if game.current_round % 4 == move_order
    card_count = models.IntegerField(default=13) # how many cards does this hand still have?
    user = models.ForeignKey("User", on_delete=models.SET_NULL, null=True)
    hand = ArrayField(base_field=models.IntegerField(name="Card", default=0), size=13)
    placement = models.IntegerField(default=0) # did this user win yet? (if 0, user still playing) 

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
    
    def save(self, *args,**kwargs):
        self.last_activity = timezone.now() # keep the last activity updated
        return super().save(*args, **kwargs)
    
class FriendRequest(models.Model):
    from_user = models.ForeignKey(User, related_name="from_user", on_delete=models.CASCADE)
    to_user = models.ForeignKey(User, related_name="to_user", on_delete=models.CASCADE)
    sent_at = models.DateTimeField(default=timezone.now)
    
    def __str__(self):
        return f"{self.from_user.username} -> {self.to_user.username}"
    