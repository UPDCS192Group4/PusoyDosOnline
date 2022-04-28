from random import shuffle
from channels.consumer import SyncConsumer
from PusoyDosServer.models import * # import the database models from our project

class LobbyCleaner(SyncConsumer):
    # TODO: This is irrelevant once Celery is implemented on this project.
    pass

class GameManager(SyncConsumer):
    """
    Consumer responsible for setting up the game when called upon by the owner of a lobby.
    
    DO NOT FORGET TO RUN THIS AS A WORKER
    """
    
    def game_create(self, lobby_id):
        """
        Game creation event
        Called using the event type "game.create"
        Expects a lobby_id value (string, uuid4 format) to link the created game to
        """
        full_deck = [f"C{i:02}" for i in range(1, 14)] + [f"D{i:02}" for i in range(1, 14)] + [f"H{i:02}" for i in range(1, 14)] + [f"S{i:02}" for i in range(1, 14)]
        shuffle(full_deck)
        # A card is essentially [Suit][Number Value]. Aces are 01s, Jacks are 11, Queens are 12, Kings are 13. Numbers are prepended with 0 if less than 10
        # Suits are represented using the first letter of each suit: C = Clubs, D = Diamonds, H = Hearts, S = Spades
        lobby = Lobby.objects.get(id=lobby_id)
        game = Game.objects.create()
        
        # Set the game parameters
        for player in User.objects.filter(current_lobby=lobby): # find all players in the current lobby
            game.players.add(player) # add the players to the database, to ensure that everyone knows the order
        for i in range(4):
            game.decks[i] = full_deck[i*13:(i*13)+13] # set each player's deck
        game.save()
        
        
        # Set lobby parameters to be in line with the game
        lobby.game = game # set the lobby's game to the game just created
        lobby.save() # save the lobby
