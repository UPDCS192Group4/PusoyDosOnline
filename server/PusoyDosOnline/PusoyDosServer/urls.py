from django.urls import path
from . import views

urlpatterns = [
	path('leaderboards', views.leaderboards, name='leaderboards')
]