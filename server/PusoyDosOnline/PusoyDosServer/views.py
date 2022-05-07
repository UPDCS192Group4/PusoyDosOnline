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
        from_user = self.request.user
        to_user = get_object_or_404(User, username=pk)
        try:
            count, frs = FriendRequest.objects.filter(from_user=from_user, to_user=to_user).delete()
            from_user.friends.add(to_user)
            to_user.friends.add(from_user)
            from_user.save()
            to_user.save()
            return Response({"detail": f"Accepted"})
        except FriendRequest.DoesNotExist:
            return Response({"error": "Cannot find friend request"})
    
    @action(detail=True, methods=["POST"])
    def reject(self, request, pk=None):
        from_user = self.request.user
        to_user = get_object_or_404(User, username=pk)
        try:
            count, frs = FriendRequest.objects.filter(from_user=from_user, to_user=to_user).delete()
            return Response({"detail": f"Rejected"})
        except FriendRequest.DoesNotExist:
            return Response({"error": "Cannot find friend request"})
    
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
        permissions.IsAuthenticated: ["create", "retrieve", "leave"],
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
        if len(get_user_model().objects.filter(current_lobby=lobby)) > 4: # don't allow a join if there's too many people registered to join the lobby
            return Http404()
        if self.request.user.current_lobby != None and self.request.user.current_lobby != lobby: # don't allow a join if a user is still in a lobby
            return Response({"error": "You are already in a lobby"}, status=status.HTTP_403_FORBIDDEN)
        if self.request.user.current_lobby == None:
            lobby.players_inside.add(self.request.user) # add the user to the list when joining via shorthand
            self.request.user.current_lobby = lobby # set the user's lobby to be this one
            self.request.user.save()
        serializer = CasualLobbySerializer(lobby)
        return Response(serializer.data)
    
    @action(detail=True, methods=["GET", "POST"])
    def leave(self, request, pk=None): # for leaving the lobby via HTTP request (pk = actual lobby id)
        lobby = get_object_or_404(Lobby, id=pk)
        if lobby == request.user.current_lobby:
            request.user.current_lobby.players_inside.remove(request.user)
            request.user.current_lobby.save()
            request.user.current_lobby = None
            request.user.save()
            return Response({"detail": "Successfully left the lobby"})
        else:
            return Response({"error": "Invalid lobby"})
