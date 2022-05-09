from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers
from rest_framework.validators import UniqueValidator
from django_countries.serializer_fields import CountryField

from .models import *

class FriendSerializer(serializers.ModelSerializer):
    class Meta:
        model = get_user_model()
        fields = ['username', 'rating', 'country_code']
        
class PlayerListSerializer(serializers.ModelSerializer):
    class Meta:
        model = get_user_model()
        fields = ['username', 'rating', 'country_code', 'played_games', 'won_games', 'lost_games']
        
class PasswordSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    password_check = serializers.CharField(write_only=True, required=True) # make sure that the user knows what password they're inputting
    
    class Meta:
        model = get_user_model()
        fields = ["password", "password_check"]
    
    def validate(self, attrs):
        if attrs["password"] != attrs["password_check"]:
            raise serializers.ValidationError({"password": "password check is not the same as password input"})
        return attrs

class UserSerializer(serializers.ModelSerializer):
    country_code = CountryField()
    friends = FriendSerializer(many=True)
    lobby = serializers.CharField(source="current_lobby.shorthand", allow_null=True)
    class Meta:
        model = get_user_model()
        fields = ['id', 'username', 'rating', 'country_code', 'played_games', 'won_games', 'lost_games', 'winstreak', 'friends', 'lobby']
        read_only_fields = ['id', 'username', 'rating', 'played_games', 'won_games', 'lost_games', 'winstreak', 'friends', 'lobby']
        
    def to_representation(self, instance):
        """
        Override the representation for "public" views like leaderboards
        We do not want to show the IDs of other users as much as possible
        """
        ret = super().to_representation(instance)
        
        # Remove the user ID and lobby ID if we're listing users or looking through the leaderboards
        if self.context["view"].action in ["list", "leaderboard"]:
            ret.pop("id")
            ret.pop("lobby")
        
        return ret
        
class RegisterSerializer(serializers.ModelSerializer):
    email = serializers.EmailField(required=True, validators=[UniqueValidator(queryset=get_user_model().objects.all())])
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    password_check = serializers.CharField(write_only=True, required=True) # make sure that the user knows what password they're inputting
    
    class Meta:
        model = get_user_model()
        fields = ['username', 'password', 'password_check', 'email']
        
    def validate(self, attrs):
        if attrs["password"] != attrs["password_check"]:
            raise serializers.ValidationError({"password": "password check is not the same as password input"})
        return attrs
    
    def create(self, validated_data):
        user = get_user_model().objects.create(
            username = validated_data["username"],
            email    = validated_data["email"],
        )
        
        user.set_password(validated_data["password"])
        user.save()
        
        return user
    
class CasualLobbySerializer(serializers.ModelSerializer):
    shorthand = serializers.CharField(read_only=True)
    id = serializers.UUIDField(read_only=True)
    owner = serializers.UUIDField(read_only=True)
    players_inside = PlayerListSerializer(many=True, read_only=True)
    game_id = serializers.UUIDField(read_only=True, source="game.id", allow_null=True)
    last_activity = serializers.DateTimeField(read_only=True)
    
    class Meta:
        model = Lobby
        fields = ['id', 'shorthand', 'owner', 'players_inside', 'game_id', 'last_activity']
        
    def to_representation(self, instance):
        ret = super().to_representation(instance)
        if "owner" in ret:
            ret.pop("owner") # Don't show the owner IDs other people
        return ret
    
class FriendRequestSerializer(serializers.ModelSerializer):
    from_user_name = serializers.CharField(read_only=True, source="from_user.username")
    to_user_name = serializers.CharField(source="to_user.username")
    sent_at = serializers.DateTimeField(read_only=True)
    
    class Meta:
        model = FriendRequest
        fields = ["from_user_name", "to_user_name", "sent_at"]
        
    def validate(self, attrs):
        if not User.objects.filter(username=attrs["to_user"]["username"]).exists():
            raise serializers.ValidationError({"detail": "Target user does not exist"})
        return attrs
    
    def create(self, validated_data):
        friend_request = FriendRequest.objects.create(
            from_user = User.objects.get(username=validated_data["from_user_name"]),
            to_user = User.objects.get(username=validated_data["to_user"]["username"]),
        )
        
        return friend_request

class HandSerializer(serializers.ModelSerializer):
    user = serializers.CharField(source="user.username")
    class Meta:
        model = Hand
        fields = ['id', 'user', 'hand']
        read_only_fields = ['id', 'user']

class GameSerializer(serializers.ModelSerializer):
    hands = HandSerializer(many=True)
    last_activity = serializers.DateTimeField(read_only=True)
    class Meta:
        model = Game
        fields = ["id", "hands", "last_activity"]
        
    def to_representation(self, instance):
        ret = super().to_representation(instance)
        if self.context["view"].action != "list" and "hands" in ret:
            hands = ret["hands"].copy()
            for hand in hands:
                # Remove hand from returned value if it doesn't match the current user's username
                if hand["user"] != self.context["view"].request.user.username:
                    ret["hands"].remove(hand)
        return ret
