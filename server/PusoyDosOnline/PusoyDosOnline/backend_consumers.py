from channels.consumer import SyncConsumer

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
        Expects a lobby_id value to link the created game to
        """
        pass
