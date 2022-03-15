from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers
from rest_framework.validators import UniqueValidator
from django_countries.serializer_fields import CountryField


class UserSerializer(serializers.ModelSerializer):
    country_code = CountryField()
    class Meta:
        model = get_user_model()
        fields = ['username', 'rating', 'country_code', 'played_games', 'won_games', 'lost_games', 'winstreak']
        
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
