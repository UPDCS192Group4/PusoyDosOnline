extends Control

var ws = null

func _ready():
	ws = Websocket.getSocket()
	ws.connect("connection_closed", self, "_connection_failed")
	ws.connect("connection_error", self, "_connection_failed")
	ws.connect("connection_established", self, "_connection_success")
	ws.connect("data_received", self, "_on_data_received")
	pass

func _process(_delta):
	ws.poll()
	
func _connection_failed(_was_clean = false):
	print("Connection failed")

func _connection_success(_proto = ""):
	print("Connection Established")

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
	print(json.result)
	var ws_url = URLs.ws_url + json.result["id"] + "/"
	var ws_headers = ["Bearer "+URLs.access]
	print(ws_url, ws_headers)
	var err = ws.connect_to_url(ws_url, ws_headers)
	ws.poll()
	if err != OK:
		print("ERROR: ", err)
		_connection_failed()
		
func _on_data_received():
	print("receiving data...")
	var data = ws.get_peer(1).get_packet().get_string_from_utf8()
	var msg = data.split(" ")
	print(msg)
