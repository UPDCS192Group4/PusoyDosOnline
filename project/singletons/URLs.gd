extends Node

var base_url = "localhost:8000" # modify upon deployment

var url = "http://" + base_url
var register = url + "/api/register/"
var login = url + "/api/token/"
var leaderboards = url + "/api/users/leaderboard"
var lobby_init = url + "/api/lobby/casual/"

var access
var refresh

# WS URL
# ws://{BASE_URL}/ws/lobby/{LOBBY_ID}/
var ws_url = "ws://" + base_url + "/ws/lobby/"

func _ready():
	pass
