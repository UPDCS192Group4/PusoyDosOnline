extends Node

var url = "http://localhost:8000" # modify upon deployment
#var url = "http://642f-2001-4451-6b8-9500-38fd-82a4-400a-338b.ngrok.io"
#var url = "http://1cc0-2001-4451-6b8-9500-38fd-82a4-400a-338b.ngrok.io"
var register = url + "/api/register/"
var login = url + "/api/token/"
var profile = url + "/api/users/profile/"
var leaderboards = url + "/api/users/leaderboard"
var lobby_init = url + "/api/lobby/casual/"
var friends = url + "/api/friends/"

var access
var refresh

func _ready():
	pass 
