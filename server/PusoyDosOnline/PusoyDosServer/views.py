from xmlrpc.client import ResponseError
from django.shortcuts import redirect, render
from django.http import (Http404, HttpResponseRedirect, JsonResponse, HttpRequest, HttpResponseBadRequest)
from django.utils import timezone
from django.contrib.auth import authenticate, login, logout, get_user_model
from django.contrib.auth.decorators import login_required
from rest_framework import viewsets, permissions, status, mixins
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import *
from .serializers import *

# Create your views here.
def api_login(request):
    if request.method != "POST":
        username = request.POST["username"]
        password = request.POST["password"]
        user = authenticate(username, password)
        if user is not None:
            login(request, user)
            return redirect("/api/profile")
        else:
            pass
    else:
        return JsonResponse({"error": "Incorrect protocol"})
    
def api_logout(request):
    pass

def api_register(request):
    if request.method == "POST":
        email    = request.POST["email"]
        username = request.POST["username"]
        password = request.POST["password"]
        
        # Create the new user
        UserModel = get_user_model()
        newuser = UserModel.objects.create_user(username, email, password)
        newuser.save()
        
        # Authenticate the user automatically
        user = authenticate(username, password)
        
        # Connect the newly-created user to the current session
        login(request, user)
        
        return redirect("/api/profile/")
    else:
        return JsonResponse({"error": "Incorrect protocol"})

@login_required(login_url="/api/login")
def api_profile(request, username=""):
    if username == "":
        # No username was passed via the link, pull up basic info on user
        pass
    else:
        # Username passed via link, pull up info on the username
        pass

def api_leaderboard(request):
    pass

# REST Framework views
class UserViewSet(mixins.RetrieveModelMixin,
                  viewsets.GenericViewSet):
    """
    API endpoint for viewing a specific user
    """
    UserModel = get_user_model()
    queryset = UserModel.objects.all().order_by("-date_joined") # latest accounts first
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAdminUser, permissions.IsAuthenticated]
    
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
        try:
            user = self.UserModel.objects.get(username=request.user.username) # find a user by their username
        except self.UserModel.DoesNotExist:
            return Response({"detail": "user not found"}, status=status.HTTP_404_NOT_FOUND)
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
