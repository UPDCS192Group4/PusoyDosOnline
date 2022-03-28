from django.shortcuts import get_object_or_404, redirect, render
from django.http import (Http404, HttpResponseRedirect, JsonResponse, HttpRequest, HttpResponseBadRequest)
from django.utils import timezone
from django.contrib.auth import authenticate, login, logout, get_user_model
from django.contrib.auth.decorators import login_required
from django.core.exceptions import ObjectDoesNotExist
from rest_framework import viewsets, permissions, status, mixins, serializers
from rest_framework.decorators import action, api_view
from rest_framework.response import Response

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
        permissions.IsAuthenticated: ["profile", "self_profile", "leaderboard"],
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
    
    @action(detail=True)
    def set_new_password(self, request):
        pass
    
    @action(detail=True)
    def set_country(self, request):
        pass

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
        permissions.IsAuthenticated: ["create", "retrieve"],
        permissions.IsAdminUser: ["list"],
    }
    
    def perform_create(self, serializer):
        if self.request.user.current_lobby != None:
            raise serializers.ValidationError("User in a lobby not allowed to create a new one")
        new_lobby = serializer.save(owner=self.request.user.id)
        self.request.user.current_lobby = Lobby.objects.all().get(shorthand=new_lobby.shorthand)
        self.request.user.save()
    
    def retrieve(self, request, pk=None):
        """
        Retrieve a lobby via its shorthand
        Will be used by clients to get their lobbies
        """
        lobby = get_object_or_404(self.queryset, shorthand=pk)
        serializer = CasualLobbySerializer(lobby)
        return Response(serializer.data)
