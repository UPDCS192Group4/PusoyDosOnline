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

var last_pile = [0,0,0,0,0]
