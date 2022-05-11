from django.shortcuts import get_object_or_404, redirect, render
from django.http import (Http404, HttpResponseForbidden, HttpResponseRedirect, JsonResponse, HttpRequest, HttpResponseBadRequest)
from django.utils import timezone
from django.contrib.auth import authenticate, login, logout, get_user_model
from django.contrib.auth.decorators import login_required
from django.core.exceptions import ObjectDoesNotExist
from rest_framework import viewsets, permissions, status, mixins, serializers
from rest_framework.decorators import action, api_view
from rest_framework.response import Response
from django_countries import countries

from .models import *
from .serializers import *
from .playchecker import *

import random
import datetime

# Permissions class for UserViewSet
class UserPermissions(permissions.AllowAny):
    def has_permission(self, request, view):
        for perm, actions in getattr(view, "perms", {}).items():
            if view.action in actions:
                return perm().has_permission(request, view)
        return False

# REST Framework views
class UserViewSet(mixins.RetrieveModelMixin,
                  mixins.ListModelMixin,
                  viewsets.GenericViewSet):
    """
    API endpoint for viewing a specific user
    """
    UserModel = get_user_model()
    queryset = UserModel.objects.all().order_by("-date_joined") # latest accounts first
    serializer_class = UserSerializer
    permission_classes = [UserPermissions]
    perms = {
        permissions.IsAuthenticated: ["profile", "self_profile", "leaderboard", "set_new_password", "set_country", "remove_friend"],
        permissions.IsAdminUser: ["list", "retrieve"],
    }
    
    @action(detail=False, url_path="profile/(?P<username>[\w.@+-]+)")
    def profile(self, request, username=""):
        """
        Get someone else's profile
        """
        try:
            user = self.UserModel.objects.get(username=username) # find a user by their username
        except self.UserModel.DoesNotExist:
            return Response({"detail": "user not found"}, status=status.HTTP_404_NOT_FOUND)
        serializer = self.get_serializer(user, many=False)
        return Response(serializer.data)
    
    @action(detail=False, url_path="profile")
    def self_profile(self, request):
        """
        Get your own profile (stats, etc)
        """
        user = request.user
        serializer = self.get_serializer(user, many=False)
        return Response(serializer.data)
    
    @action(detail=False)
    def leaderboard(self, request):
        """
        Leaderboard listings based on current rating
        """
        highest_rated = self.UserModel.objects.all().order_by("-rating") # highest rating first
        page = self.paginate_queryset(highest_rated)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        serializer = self.get_serializer(highest_rated, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=["POST"])
    def set_new_password(self, request):
        # TODO: Move this to separate serializer?
        if not "old_pass" in request.data or not "new_pass" in request.data or not "new_pass_check" in request.data:
            raise serializers.ValidationError({"detail": "No password or password check data passed"})
        
        # Check if new_pass == new_pass_check
        new_pass = request.data["new_pass"]
        if new_pass != request.data["new_pass_check"]:
            raise serializers.ValidationError({"detail": "Invalid password"})
        
        # Check if the old password is correct
        if not self.request.user.check_password(request.data["old_pass"]):
            raise serializers.ValidationError({"detail": "Incorrect password"})
        
        # Validate new password
        try:
            validate_password(new_pass, User)
        except:
            raise serializers.ValidationError({"detail": "Invalid password"})
        self.request.user.set_password(new_pass)
        self.request.user.save()
        return Response({"detail": "Password successfully changed"})
    
    @action(detail=False, methods=["GET", "POST"])
    def set_country(self, request):
        """
        Set your country given an ISO country code
        """
        if not "country_code" in request.data:
            return Response({"detail": "No country code data passed"})
        country_code = request.data["country_code"]
        if not country_code in dict(countries):
            raise serializers.ValidationError({"detail": "Incorrect country code"})
        self.request.user.country_code = country_code
        self.request.user.save()
        return Response({"detail": f"Changed your country to {country_code}"})
    
    @action(detail=False, methods=["GET", "POST"], url_path="remove_friend/(?P<username>[\w.@+-]+)")
    def remove_friend(self, request, username=""):
        """
        Remove existing friend in current user's friend list
        """
        find_friend = self.request.user.friends.all().filter(username=username)
        if not find_friend.exists():
            raise serializers.ValidationError({"detail": "Friend not found"})
        friend_to_remove = find_friend.first()
        self.request.user.friends.remove(friend_to_remove)
        friend_to_remove.friends.remove(self.request.user)
        self.request.user.save()
        friend_to_remove.save()
        return Response({"detail": "Friend successfully removed"})

class RegisterViewSet(mixins.CreateModelMixin,
                      viewsets.GenericViewSet):
    """
    API endpoint for registering a new account
    """
    UserModel = get_user_model()
    queryset = UserModel.objects.all()
    permission_classes = [permissions.AllowAny]
    serializer_class = RegisterSerializer
    throttle_scope = "register"
    
class FriendRequestViewSet(mixins.CreateModelMixin,
                           mixins.ListModelMixin,
                           viewsets.GenericViewSet):
    queryset = FriendRequest.objects.all()
    serializer_class = FriendRequestSerializer
    permission_classes = [UserPermissions]
    perms = {
        permissions.IsAuthenticated: ["create", "accept", "reject", "list"],
    }
    
    def perform_create(self, serializer):
        from_user_name = self.request.user.username
        if serializer.is_valid():
            # Validate if to_user exists
            to_user = User.objects.get(username=serializer.validated_data["to_user"]["username"])
            
            if self.queryset.filter(from_user=self.request.user, to_user=to_user).exists():
                # Validate if friend request already sent
                raise serializers.ValidationError({"detail": "Friend request already sent"})
            
            serializer.save(from_user_name=from_user_name)
    
    def list(self, request):
        queryset = self.filter_queryset(self.get_queryset().filter(to_user=self.request.user))

        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)
        
    @action(detail=True, methods=["GET", "POST"])
    def accept(self, request, pk=None):
        from_user = get_object_or_404(User, username=pk)
        to_user = self.request.user
        try:
            count, frs = FriendRequest.objects.filter(from_user=from_user, to_user=to_user).delete()
            if count > 0:
                from_user.friends.add(to_user)
                to_user.friends.add(from_user)
                from_user.save()
                to_user.save()
                return Response({"detail": f"Accepted"})
            else:
                return Response({"error": "Cannot find friend request"}, status=status.HTTP_404_NOT_FOUND)
        except FriendRequest.DoesNotExist:
            return Response({"error": "Cannot find friend request"}, status=status.HTTP_404_NOT_FOUND)
    
    @action(detail=True, methods=["POST"])
    def reject(self, request, pk=None):
        from_user = get_object_or_404(User, username=pk)
        to_user = self.request.user
        try:
            count, frs = FriendRequest.objects.filter(from_user=from_user, to_user=to_user).delete()
            if count > 0:
                return Response({"detail": f"Rejected"})
            else:
                return Response({"error": "Cannot find friend request"}, status=status.HTTP_404_NOT_FOUND)
        except FriendRequest.DoesNotExist:
            return Response({"error": "Cannot find friend request"}, status=status.HTTP_404_NOT_FOUND)
    
class CasualLobbyViewSet(mixins.CreateModelMixin,
                         mixins.RetrieveModelMixin,
                         mixins.ListModelMixin,
                         viewsets.GenericViewSet):
    """
    API endpoint for generating and getting casual lobbies
    """
    queryset = Lobby.objects.all()
    serializer_class = CasualLobbySerializer
    permission_classes = [UserPermissions]
    perms = {
        permissions.IsAuthenticated: ["create", "retrieve", "leave", "ready"],
        permissions.IsAdminUser: ["list"],
    }
    
    def perform_create(self, serializer):
        if self.request.user.current_lobby != None:
            raise serializers.ValidationError("User in a lobby not allowed to create a new one")
        new_lobby = serializer.save(owner=self.request.user.id)
        lobby = self.queryset.get(shorthand=new_lobby.shorthand)
        lobby.players_inside.add(self.request.user)
        self.request.user.current_lobby = lobby
        lobby.save()
        self.request.user.save()
    
    def retrieve(self, request, pk=None):
        """
        Retrieve a lobby via its shorthand
        Will be used by clients to get their lobbies
        """
        lobby = get_object_or_404(self.queryset, shorthand=pk)
        if len(get_user_model().objects.filter(current_lobby=lobby)) > 4 and lobby.game == None: # don't allow a join if there's too many people registered to join the lobby, and there is no game running already
            return Http404()
        if self.request.user.current_lobby != None and self.request.user.current_lobby != lobby: # don't allow a join if a user is still in a lobby
            return Response({"error": "You are already in a lobby"}, status=status.HTTP_403_FORBIDDEN)
        if self.request.user.current_lobby == None:
            lobby.players_inside.add(self.request.user) # add the user to the list when joining via shorthand
            lobby.save()
            self.request.user.current_lobby = lobby # set the user's lobby to be this one
            self.request.user.save()
        serializer = CasualLobbySerializer(lobby)
        return Response(serializer.data)
    
    @action(detail=True, methods=["GET", "POST"])
    def leave(self, request, pk=None): # for leaving the lobby via HTTP request (pk = actual lobby id)
        lobby = get_object_or_404(self.queryset, id=pk)
        if lobby == request.user.current_lobby:
            request.user.current_lobby.players_inside.remove(request.user)
            request.user.current_lobby.save()
            request.user.current_lobby = None
            request.user.save()
            return Response({"detail": "Successfully left the lobby"})
        else:
            return Response({"error": "Invalid lobby"})
        
    @action(detail=True, methods=["GET", "POST"])
    def ready(self, request, pk=None): # pk = lobby ID!
        # Endpoint for starting a game for this lobby
        lobby = get_object_or_404(self.queryset, id=pk)
        # TODO: Check if lobby has enough players before starting!
        if lobby.owner != request.user.id:
            return Response({"error": "You are not allowed to start this lobby."}, status=status.HTTP_403_FORBIDDEN)
        if lobby.game != None:
            return Response({"error": "This lobby already has an associated game!"}, status=status.HTTP_403_FORBIDDEN)
        
        # Generate deck
        full_deck = []
        for j in range(4):
            full_deck += [(100 * j) + i for i in range(1, 14)]
        
        # Generate randomness
        seed = random.randint(1, 2**31-1)
        rng = random.Random()
        rng.seed(seed)
        
        # Shuffle deck
        rng.shuffle(full_deck)
            
        # Make game with the shuffled deck and seed used
        game = Game.objects.create(seed=seed)
        print(f"Attempting to generate game {game.id} with seed {seed}")
        i = 0
        order = 1
        for player in lobby.players_inside.all():
            hand_to_give = list(sorted(full_deck[i*13:(i*13)+13]))
            player_order = 0
            if hand_to_give[0] != 1:
                player_order = order
                order += 1
            hand = Hand.objects.create(user=player, hand=hand_to_give, move_order=player_order)
            game.players.add(player)
            game.hands.add(hand)
            i += 1
        game.save()
        
        # Set the game's lobby to the game just generated
        lobby.game = game
        lobby.save()
        return Response({"detail": "Game successfully created", "game": game.id})
        
class GameViewSet(mixins.RetrieveModelMixin,
                  mixins.ListModelMixin,
                  viewsets.GenericViewSet):
    """
    API endpoint for manipulating games currently running
    """
    queryset = Game.objects.all()
    serializer_class = GameSerializer
    permission_classes = [UserPermissions]
    perms = {
        permissions.IsAuthenticated: ["retrieve", "play_cards"],
        permissions.IsAdminUser: ["list"],
    }
    
    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        # Check for time skips
        if timezone.now() > instance.last_activity + datetime.timedelta(seconds=60) and instance.current_round > 0:
            instance.current_round += 1
            instance.save()
        serializer = self.get_serializer(instance)
        return Response(serializer.data)
    
    @action(detail=True, methods=["POST"])
    def play_cards(self, request, pk=None):
        # pk = game ID
        game = get_object_or_404(self.queryset, id=pk)
        
        # Check if the game is over or not
        if game.winners == 3:
            return Response({"error": "Game is already over"}, status=status.HTTP_410_GONE)
        
        # Validate if request.data *can* be valid
        
        # request.data should ideally only consist of {"play": [<list_of_card_ints>]}
        # Any other fields in there must be ignored.
        if request.data.get("play") == None:
            return Response({"error": "No play field in data received"}, status=status.HTTP_403_FORBIDDEN)
        
        # The length of a play can only be a maximum 5 cards, and there are no moves with only 4 cards.
        # A play of length 0 is a pass.
        plays = request.data.get("play")
        if len(plays) > 5 or len(plays) == 4:
            return Response({"error": "No play field length exceeded expected value"}, status=status.HTTP_403_FORBIDDEN)
        
        # Check if cards are unique
        if len(plays) != len(set(plays)):
            return Response({"error": "Invalid play field data"}, status=status.HTTP_403_FORBIDDEN)
        
        # Check if each card in the plays is an actual card int
        for card in plays:
            if card < 0 or card // 100 > 3 or card % 100 > 13 or (card > 0 and card % 100 == 0):
                return Response({"error": "Invalid play field data"}, status=status.HTTP_403_FORBIDDEN)
        
        # Perform validations with database calls
        # Get player hand
        player_hand = None
        for hand in game.hands.all():
            if hand.user.username == request.user.username:
                player_hand = hand
                break
        if player_hand == None:
            return Response({"error": "Cannot find player's hand!"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        # Query if user can actually make a move right now
        if game.current_round % 4 != player_hand.move_order:
            return Response({"error": "Not allowed to make a move for this round"}, status=status.HTTP_403_FORBIDDEN)
        
        # Check if it's a skip (game should not skip if it's the first round)
        if len(plays) == 0 and game.current_round > 0 and game.control < 4:
            game.current_round += 1
            game.control += 1
            game.save()
            return Response({"detail": "Skipped successfully"})
        
        # Check if the user has all of the cards
        for card in plays:
            if not card in player_hand.hand:
                return Response({"error": "Card played not found in hand"}, status=status.HTTP_403_FORBIDDEN)
        
        # Check if it's an invalid play
        play_info = process(plays)
        pile_info = process(game.last_play)
        if play_info[0] == 0:
            return Response({"error": "Invalid play: Invalid card ordering"}, status=status.HTTP_403_FORBIDDEN)
        
        # Check if the move is a valid move given the cards and previously played cards
        if game.control >= 4:
            # Control:
            # No need to check the previous play. Just set it.
            if game.current_round == 0 and not 1 in plays:
                # First move *must* always contain the 3 of clubs (001)
                return Response({"error": "Invalid play: First move must contain the 3 of clubs"}, status=status.HTTP_403_FORBIDDEN)
        else:
            # Not control, check the previous play
            if not compare(play_info, pile_info):
                # If comparison fails, deny play
                return Response({"error": "Invalid play: Play lower than current pile"}, status=status.HTTP_403_FORBIDDEN)
        
        # Since it passed all the checks, actually remove the card from hand and set it as the previous.
        win = False
        if player_hand.card_count - len(plays) == 0:
            # Win condition: User has no more cards to play
            player_hand.card_count = 0
            player_hand.placement = game.winners + 1
            game.skips[game.winners] = player_hand.move_order
            game.winners += 1
            win = True
        for card in plays:
            player_hand.hand.remove(card)
        player_hand.card_count -= len(plays)
        player_hand.save() # Save player hand
        game.last_play = plays # Set the current play to the pile
        while game.current_round % 4 in game.skips:
            game.current_round += 1 # Add 1 to the round counter if the next round should be skipped
        game.control = 0 # Reset control since we just played a card
        game.save() # Save game state
        return Response({"detail": "Success", "hand": player_hand.hand, "win": win})
    