extends Node

var game_id
var hand = Array()
var gamers = {}
var my_move_order
var current_player
var is_current_player = 0
var has_won = 0
var is_control
var needs_3_of_clubs = 0
var num_winners = 0
var last_pile = [0,0,0,0,0]

func clear_data():
	game_id = null
	hand.clear()
	gamers.clear()
	my_move_order = null
	current_player = null
	is_current_player = 0
	has_won = 0
	is_control = null
	needs_3_of_clubs = 0
	num_winners = 0
	last_pile = [0,0,0,0,0]
