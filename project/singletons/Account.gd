extends Node

var logged_in = false
var _token = ""

func _ready():
	pass

func getToken():
	return _token

func setToken(token):
	_token = token

func logout():
	logged_in = false
	# _token = "" idk if I should touch this or nah
