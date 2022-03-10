extends Control

var ws = null

func _ready():
	ws = Websocket.getSocket()
	ws.connect("connection_closed", self, "_connection_failed")
	ws.connect("connection_error", self, "_connection_failed")
	ws.connect("connection_established", self, "_connection_success")

func _process(_delta):
	ws.poll()

func _connection_success(_proto = ""):
	$ConnectingLabel.visible = false
	$Label.text = "Connection success!"
	$Label.visible = true
	get_tree().change_scene("res://multiplayer/MultiplayerGame.tscn")

func _connection_failed(_was_clean = false):
	$ConnectingLabel.visible = false
	$Label.text = "Connection failed!"
	$Label.visible = true
	$Timer.start()

func _on_Button_pressed():
	$ConnectingLabel.visible = true
	var url = $LineEdit.text
	var err = ws.connect_to_url(url)
	ws.poll()
	if err != OK:
		print(err)

func _on_Timer_timeout():
	$Label.visible = false
