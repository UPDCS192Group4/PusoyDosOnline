extends Node

# Singleton for storing shit, in this case the websocket
### Probably should be moved out of this folder
### I'm placing everything here lang muna para klaro which ones I worked on

var _ws = WebSocketClient.new()

func _ready():
	pass # Replace with function body.

func getSocket():
	return _ws
