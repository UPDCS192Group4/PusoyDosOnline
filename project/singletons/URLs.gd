extends Node

var url = "http://localhost:8000" # modify upon deployment
var register = url + "/api/register/"
var login = url + "/api/token/"
var leaderboards = url + "/api/users/leaderboard"
var lobby_init = url + "/api/lobby/casual/"

var access
var refresh

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
