extends Node

var logged_in = false
var _profile_json = {}
var id = -1
var username = ""
var rating = -1
var country_code = "XX"
var played_games = -1
var won_games = -1
var lost_games = -1
var winstreak = -1
var friends = []

var _token = ""

func _ready():
	pass

func getToken():
	return _token

func setToken(token):
	_token = token
	
func login(token):
	setToken(token)
	logged_in = true

func logout():
	logged_in = false
	
func updateInfo(profile_json):
	# should be the json result already
	_profile_json = profile_json
	id = profile_json.id
	username = profile_json.username
	rating = profile_json.rating
	country_code = profile_json.country_code
	played_games = profile_json.played_games
	won_games = profile_json.won_games
	lost_games = profile_json.lost_games
	winstreak = profile_json.winstreak
	friends = profile_json.friends
	
	# _token = "" idk if I should touch this or nah
