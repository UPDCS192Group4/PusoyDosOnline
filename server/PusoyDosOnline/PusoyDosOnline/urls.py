"""PusoyDosOnline URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include, re_path
from PusoyDosServer import views
from rest_framework import routers
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView, TokenVerifyView
from . import views as vws

# REST Framework Router
router = routers.DefaultRouter()
router.register(r'users', views.UserViewSet)
router.register(r'register', views.RegisterViewSet)
router.register(r'lobby/casual', views.CasualLobbyViewSet)
router.register(r'friendrequest', views.FriendRequestViewSet)

urlpatterns = [
    path('', vws.index, name='index'),
    #path('index.js', vws.indexjs, name='indexjs'),
    #path('index.apple-touch-icon.png', vws.indexpng, name='indexpng'),
    re_path(r'(?P<index_file>^index.*)', vws.indexfile, name='indexfile'),
    path('index.pck', vws.indexpck, name='indexpck'),
    path('index.wasm', vws.indexwasm, name='indexwasm'),
    path('admin/', admin.site.urls),
    
    # REST API links 
    path('api/', include(router.urls)),
    path('api/', include('rest_framework.urls', namespace='rest_framework')),
    
    # Web Token Views
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/token/verify/', TokenVerifyView.as_view(), name='token_verify'),
]
