extends Node

var logged_in = false
var _token = ""

func _ready():
	pass

func getToken():
	return _token

func setToken(token):
	_token = token
