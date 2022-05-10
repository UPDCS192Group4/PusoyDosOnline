extends Control

var sidepanel = null
var leaderboards_scene = preload("res://Leaderboards/Leaderboards.tscn")
var friends_scene = preload("res://Friends/Friendslist.tscn")

func _ready():
	$ClearRequest.connect("request_completed", self, "_on_ClearRequest_request_completed")
	$LeaveRequest.connect("request_completed", self, "_on_LeaveRequest_request_completed")
	$PingRequest.connect("request_completed", self, "_on_PingRequest_request_completed")
	$ErrorMessage/Label.hide()
	print("Player Info:")
	print(AccountInfo._profile_json)

func _on_PlayButton_pressed():
	LobbyDetails.player_names.clear()
	yield(get_tree().create_timer(0.5), "timeout")
	clearLobby()
		
func _on_LeaderboardsButton_pressed():
	yield(get_tree().create_timer(0.5), "timeout")
	showLeaderboards()
	
func clearLobby():
	var url = URLs.profile
	var headers = ['Content-Type: application/json', 'Authorization: Bearer ' + URLs.access]
	var err = $ClearRequest.request(url, headers, false, HTTPClient.METHOD_GET)
	
func _on_ClearRequest_request_completed(result, response_code, headers, body):
	if (response_code != 200 and response_code != 201): 
		$ErrorMessage/Label.text = "Uh oh!..."
		$ErrorMessage/Label.show()
		yield(get_tree().create_timer(2), "timeout")
		$ErrorMessage/Label.text = "Please contact Big T.."
		yield(get_tree().create_timer(2), "timeout")
		get_tree().change_scene("res://Home/Home.tscn")	
		return
	
	var json = JSON.parse(body.get_string_from_utf8())
	if json.result["lobby"] == null:
		openLobbyHandler()
		return
	LobbyDetails.shorthand = json.result["lobby"]
	_query_lobby_id()
	
func _query_lobby_id():
	var url = URLs.lobby_init + LobbyDetails.shorthand + "/"
	var headers = ['Content-Type: application/json', 'Authorization: Bearer ' + URLs.access]
	print("Pinging ", url)
	var err = $PingRequest.request(url, headers, false, HTTPClient.METHOD_GET)

func _on_PingRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	if (response_code != 200 and response_code != 201): 
		$ErrorMessage/Label.text = "Oh no..."
		$ErrorMessage/Label.show()
		yield(get_tree().create_timer(2), "timeout")
		$ErrorMessage/Label.text = "Contact BIG T..."
		yield(get_tree().create_timer(2), "timeout")
		get_tree().change_scene("res://Home/Home.tscn")	
		return
	print("Ping request results")
	for i in json.result:
		print(i, " : ", json.result[i])
	LobbyDetails.id = json.result["id"]
	_go_home()
		
func _go_home():
	var url = URLs.lobby_init + LobbyDetails.id + "/leave/"
	var new_headers = ['Content-Type: application/json', 'Authorization: Bearer ' + URLs.access]
	var err = $LeaveRequest.request(url, new_headers, false, HTTPClient.METHOD_GET)
	
func _on_LeaveRequest_request_completed(result, response_code, headers, body):
	if (response_code != 200 and response_code != 201): 
		$ErrorMessage/Label.text = "Leave failed, LOL!..."
		$ErrorMessage/Label.show()
		yield(get_tree().create_timer(2), "timeout")
		$ErrorMessage/Label.text = "Redirecting..."
		yield(get_tree().create_timer(1), "timeout")
		get_tree().change_scene("res://Home/Home.tscn")	
		return
	openLobbyHandler()
	
func openLobbyHandler():
	get_tree().change_scene("res://Lobby/Lobby.tscn")
	
func startNewGame():
	get_tree().change_scene("res://Game/Game.tscn")

func showLeaderboards():
	#get_tree().change_scene("res://Leaderboards/Leaderboards.tscn")
	change_sidepanel(leaderboards_scene)

func close_sidepanel():
	if sidepanel == null:
		print("Sidepanel is already closed")
		return
	sidepanel.queue_free()
	sidepanel = null

func change_sidepanel(sidepanel_scene):
	close_sidepanel()
	sidepanel = sidepanel_scene.instance()
	sidepanel.in_home = true
	$ContainerBox/ContainerBox/Sidepanel.add_child(sidepanel)
	sidepanel.get_node("Button").connect("pressed", self, "close_sidepanel")

func _on_LogoutButton_pressed():
	AccountInfo.logout()
	get_tree().change_scene("res://Home/Login.tscn")
	
func _on_FriendsButton_pressed():
	change_sidepanel(friends_scene)

func _on_Donate_pressed():
	AccountInfo.fetchProfile()
