extends Control

func _ready():
	$ErrorMessage/Label.hide()
	$CreateRequest.connect("request_completed", self, "_on_CreateRequest_request_completed")
	pass

func _on_HomeButton_pressed():
	var scene1 = load("res://Game/PopUp.tscn")
	var child1 = scene1.instance()
	child1.changeText("Go home?")
	get_node('CanvasLayer').add_child(child1)

func _on_CreateLobby_pressed():
	var url = URLs.lobby_init
	var headers = ['Content-Type: application/json', 'Authorization: Bearer ' + URLs.access]
	var response = $CreateRequest.request(url, headers, false, HTTPClient.METHOD_POST)
	print("LOBBY RESPONSE", response)

func _on_CreateRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	if (response_code != 200): 
		$ErrorMessage/Label.text = "Error creating lobby..."
		$ErrorMessage/Label.show()
		yield(get_tree().create_timer(2), "timeout")
		$ErrorMessage/Label.text = "Redirecting..."
		yield(get_tree().create_timer(1), "timeout")
		get_tree().change_scene("res://Home/Home.tscn")	
		return
	print("BODY OF RESPONSE: ", json.result)
	get_node("LobbyChoices").queue_free()
