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
	var err = $CreateRequest.request(url, headers, false, HTTPClient.METHOD_POST)

func _on_CreateRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print("Response code: ", response_code)
	if (response_code != 200 and response_code != 201): 
		$ErrorMessage/Label.text = "Error creating lobby..."
		$ErrorMessage/Label.show()
		yield(get_tree().create_timer(2), "timeout")
		$ErrorMessage/Label.text = "Redirecting..."
		yield(get_tree().create_timer(1), "timeout")
		get_tree().change_scene("res://Home/Home.tscn")	
		return
	LobbyDetails.id = json.result["id"]
	LobbyDetails.shorthand = json.result["shorthand"]
	#for i in json.result:
	#	print(i, " : ", json.result[i])
	for player in json.result["players_inside"]:
		LobbyDetails.player_names.append(player["username"])
	get_node("LobbyChoices").queue_free()
	_start_waiting_room()
	
func _start_waiting_room():
	var newRoom = LobbyDetails.roomScene.instance()
	newRoom.set_name("WaitingRoom")
	newRoom.get_node("Container").get_node("Shorthand").text = "Lobby Code: " + LobbyDetails.shorthand
	for i in range(len(LobbyDetails.player_names)):
		newRoom.get_node("Container").get_child(i+1).text = LobbyDetails.player_names[i]
	add_child(newRoom)
