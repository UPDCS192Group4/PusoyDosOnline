extends Control


func _ready():
	pass

func _on_HomeButton_pressed():
	var scene1 = load("res://Game/PopUp.tscn")
	var child1 = scene1.instance()
	child1.changeText("Go home?")
	get_node('CanvasLayer').add_child(child1)
	pass


func _on_CreateLobby_pressed():
	var url = URLs.lobby_init
	var headers = ['Content-Type: application/json', 'Authorization: Bearer ' + URLs.access]
	var response = $HTTPRequest.request(url, headers, false, HTTPClient.METHOD_POST)
	print("LOBBY RESPONSE", response)
	pass # Replace with function body.


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print("BODY OF RESPONSE: ", json.result)
	get_node("LobbyChoices").queue_free()
	pass # Replace with function body.
