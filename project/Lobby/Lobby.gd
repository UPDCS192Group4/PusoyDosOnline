extends Control

var ws = null

func _ready():
	ws = Websocket.getSocket()
	ws.connect("connection_closed", self, "_connection_closed")
	ws.connect("connection_error", self, "_connection_error")
	ws.connect("connection_established", self, "_connection_success")
	ws.connect("data_received", self, "_on_data_received")
	dir(ws)

func _process(_delta):
	ws.poll()
	if ws.get_connection_status():
		print("HOST: ", ws.get_connected_host())
	
func _connection_closed(_was_clean = false):
	##dir(ws)
	print("Connection closed")
	
func _connection_error(_was_clean = false):
	#dir(ws)
	print("Connection error")

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


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)
	var ws_url = URLs.ws_url + json.result["id"] + "/"
	var ws_headers = ["Bearer "+URLs.access]
	var err = ws.connect_to_url(ws_url)
	dir(ws)
	ws.poll()
	print("ERR: ", err)
		
func _on_data_received():
	print("receiving data...")
	var data = ws.get_peer(1).get_packet().get_string_from_utf8()
	var msg = data.split(" ")
	print(msg)

func dir(class_instance):
	var output = {}
	var methods = []
	for method in class_instance.get_method_list():
		methods.append(method.name)
	
	output["METHODS"] = methods
	
	var properties = []
	for prop in class_instance.get_property_list():
		properties.append([prop.name, class_instance.get(prop.name)])
	output["PROPERTIES"] = properties
	
	#print("METHODS:")
	#for i in output["METHODS"]:
		#print(i)
	print("META: ", class_instance.get_meta("headers"))
	#print("PROPERTIES:")
	#for i in output["PROPERTIES"]:
		#print(i)
	print(get_stack())
	return output
