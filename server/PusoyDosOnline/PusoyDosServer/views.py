from django.shortcuts import redirect, render
from django.http import (Http404, HttpResponseRedirect, JsonResponse, HttpRequest, HttpResponseBadRequest)
from django.utils import timezone
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required

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
        pass

def api_register(request):
    pass

@login_required(login_url="/api/login")
def api_profile(request):
    pass

def api_leaderboard(request):
    pass