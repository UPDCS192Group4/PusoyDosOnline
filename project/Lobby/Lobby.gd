extends Control

var t = 0
var t_rate = 120

var url
var headers
var err
var json

func _ready():
	LobbyDetails.clear_data()
	GameDetails.clear_data()
	$ErrorMessage/Label.hide()
	$CreateRequest.connect("request_completed", self, "_on_CreateRequest_request_completed")
	$JoinRequest.connect("request_completed", self, "_on_JoinRequest_request_completed")
	$PingRequest.connect("request_completed", self, "_on_PingRequest_request_completed")
	$LeaveRequest.connect("request_completed", self, "_on_LeaveRequest_request_completed")
	$ReadyRequest.connect("request_completed", self, "_on_ReadyRequest_request_completed")

func _process(_delta):
	if LobbyDetails.in_waiting != 1:
		return
	t += 1
	if (t >= t_rate):
		t = t - t_rate
		_ping_server()
	
func _on_HomeButton_pressed():
	var scene1 = load("res://Game/PopUp.tscn")
	var new_child = scene1.instance()
	new_child.changeText("Go home?")
	if LobbyDetails.in_waiting:
		new_child.disable_auto_Home()
		new_child.get_node("A").get_node("B").get_node("C").get_node("D").get_node("YesButton").connect("pressed", self, "_go_home")
	get_node("HomeBtnLayer").add_child(new_child)

func _go_home():
	url = URLs.lobby_init + LobbyDetails.id + "/leave/"
	headers = URLs.defaultHeader()
	err = $LeaveRequest.request(url, headers, false, HTTPClient.METHOD_GET)
	
func _on_LeaveRequest_request_completed(result, response_code, headers, body):
	if (response_code != 200 and response_code != 201): 
		$ErrorMessage/Label.text = "Leave failed, LOL!..."
		$ErrorMessage/Label.show()
		yield(get_tree().create_timer(2), "timeout")
		$ErrorMessage/Label.text = "Redirecting..."
		yield(get_tree().create_timer(1), "timeout")
		get_tree().change_scene("res://Home/Home.tscn")	
		return
	get_tree().change_scene("res://Home/Home.tscn")	
	
# The following contain functions for when a user creates a lobby
func _on_CreateLobby_pressed():
	url = URLs.lobby_init
	headers = URLs.defaultHeader()
	print(url,headers)
	err = $CreateRequest.request(url, headers, false, HTTPClient.METHOD_POST)

func _on_CreateRequest_request_completed(result, response_code, headers, body):
	print(response_code)
	if (response_code != 200 and response_code != 201): 
		$ErrorMessage/Label.text = "Error creating lobby..."
		$ErrorMessage/Label.show()
		yield(get_tree().create_timer(2), "timeout")
		$ErrorMessage/Label.text = "Redirecting..."
		yield(get_tree().create_timer(1), "timeout")
		get_tree().change_scene("res://Home/Home.tscn")	
		return
	json = JSON.parse(body.get_string_from_utf8())
	LobbyDetails.id = json.result["id"]
	LobbyDetails.shorthand = json.result["shorthand"]
	for player in json.result["players_inside"]:
		LobbyDetails.player_names.append(player["username"])
	LobbyDetails.is_owner = 1
	get_node("LobbyChoices").queue_free()
	_start_waiting_room()

# The following are functions for when a user joins a lobby
func _on_JoinLobby_pressed():
	get_node("LobbyChoices").queue_free()
	var join = load("res://Lobby/JoinLobby.tscn")
	var joinScene = join.instance()
	joinScene.set_name("JoinInput")
	joinScene.get_node("Container").get_node("EnterButton").connect("pressed", self, "_code_entered")
	add_child(joinScene)
	
func _code_entered():
	var code = get_node("JoinInput").get_node("Container").get_node("Code").text
	url = URLs.lobby_init + code + "/"
	headers = URLs.defaultHeader()
	err = $JoinRequest.request(url, headers, false, HTTPClient.METHOD_GET)

func _on_JoinRequest_request_completed(result, response_code, headers, body):
	if (response_code != 200 and response_code != 201): 
		$ErrorMessage/Label.text = "Error joining lobby..."
		$ErrorMessage/Label.show()
		yield(get_tree().create_timer(2), "timeout")
		$ErrorMessage/Label.text = "Redirecting..."
		yield(get_tree().create_timer(1), "timeout")
		get_tree().change_scene("res://Home/Home.tscn")	
		return
	json = JSON.parse(body.get_string_from_utf8())
	LobbyDetails.id = json.result["id"]
	LobbyDetails.shorthand = json.result["shorthand"]
	for player in json.result["players_inside"]:
		LobbyDetails.player_names.append(player["username"])
	LobbyDetails.is_owner = 0
	get_node("JoinInput").queue_free()
	_start_waiting_room()

func _start_waiting_room():
	LobbyDetails.in_waiting = 1
	var newRoom = LobbyDetails.roomScene.instance()
	newRoom.set_name("WaitingRoom")
	newRoom.get_node("Container").get_node("Shorthand").text = "Lobby Code: " + LobbyDetails.shorthand
	for i in range(len(LobbyDetails.player_names)):
		newRoom.get_node("Container").get_child(i+1).text = LobbyDetails.player_names[i]
	add_child(newRoom)
	
# The following contains updates to the lobby by sending pings to the server
func _ping_server():
	url = URLs.lobby_init + LobbyDetails.shorthand + "/"
	headers = URLs.defaultHeader()
	err = $PingRequest.request(url, headers, false, HTTPClient.METHOD_GET)

func _on_PingRequest_request_completed(result, response_code, headers, body):
	if (response_code != 200 and response_code != 201): 
		$ErrorMessage/Label.text = "Unexpected error in lobby..."
		$ErrorMessage/Label.show()
		yield(get_tree().create_timer(2), "timeout")
		$ErrorMessage/Label.text = "Redirecting..."
		yield(get_tree().create_timer(1), "timeout")
		get_tree().change_scene("res://Home/Home.tscn")	
		return
	json = JSON.parse(body.get_string_from_utf8())
	#for i in json.result:
	#	print(i, " : ", json.result[i])
	#LobbyDetails.is_owner = json.result["Owner"] == AccountInfo.id
	#print("is owner? : ", json.result["Owner"],AccountInfo.id)
	var returned_list = Array()
	for player in json.result["players_inside"]:
		returned_list.append(player["username"])
	if (LobbyDetails.player_names == returned_list) and (len(LobbyDetails.player_names) < 4):
		return
	if (LobbyDetails.player_names != returned_list):
		LobbyDetails.player_names = returned_list
		for i in range(4):
			get_node("WaitingRoom").get_node("Container").get_child(i+1).text = ""
		for i in range(len(LobbyDetails.player_names)):
			get_node("WaitingRoom").get_node("Container").get_child(i+1).text = LobbyDetails.player_names[i]
	print('waiting room updated')
	if len(LobbyDetails.player_names) != 4:
		return
	print('reached here')
	if LobbyDetails.is_owner:
		print('starting')
		#start game
		url = URLs.lobby_init + LobbyDetails.id + "/ready/"
		headers = URLs.defaultHeader()
		$ReadyRequest.request(url, headers, false, HTTPClient.METHOD_POST)
		return
	print('no game id')
	if json.result["game_id"]:
		LobbyDetails.in_waiting = 0
		GameDetails.game_id = json.result["game_id"]
		_start_game()
		
func _start_game():
	$ErrorMessage/Label.text = "Game starting..."
	$ErrorMessage/Label.show()
	yield(get_tree().create_timer(2), "timeout")
	get_tree().change_scene("res://Game/Game.tscn")

func _on_ReadyRequest_request_completed(result, response_code, headers, body):
	print(response_code)
	if (response_code != 200 and response_code != 201): 
		print("Ready failed..")
		return
	LobbyDetails.in_waiting = 0
	json = JSON.parse(body.get_string_from_utf8())
	GameDetails.game_id = json.result["game"]
	_start_game()
