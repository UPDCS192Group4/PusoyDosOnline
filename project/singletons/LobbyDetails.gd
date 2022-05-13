extends Node

var id = null
var shorthand = null
var players = null
var player_names = Array()
var join_code = null
var in_waiting = 0
var is_owner = 0

var roomScene = preload("res://Lobby/WaitingRoom.tscn")

func _ready():
	pass

func clear_data():
	id = null
	shorthand = null
	players = null
	player_names.clear()
	join_code = null
	in_waiting = 0
	is_owner = 0
