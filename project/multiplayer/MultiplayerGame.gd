extends Control
var deck = Array()
var hand = Array()
var cardScene = preload("res://Card.tscn")
var newCard

var ws = Websocket.getSocket()

func _ready():
	ws = Websocket.getSocket()
	# ws.connect("connection_closed", self, "_connection_failed")
	# ws.connect("connection_error", self, "_connection_failed")
	# ws.connect("connection_established", self, "_connection_success")
	ws.connect("data_received", self, "_on_data_received")

func _process(delta):
	ws.poll()

func loadGame():
	pass
	# we gonna have to refactor the deck generating stuff here
	## since it should be a server-side thing
	print("loading game!")
	var scene1 = load("res://multiplayer/MultiplayerHand.tscn")
	var child1 = scene1.instance()
	add_child(child1)
	var scene2 = load("res://Pile.tscn")
	var child2 = scene2.instance()
	add_child(child2)
	var scene3 = load("res://Opponents.tscn")
	var child3 = scene3.instance()
	add_child(child3)
	shuffleDeck()
	print("nice")
	emit_signal("ready") # scuffed(?) way to bypass the yield sa other scenes
		# so I don't have to touch them too much
		# we probably should refactor those tho
	$Label.visible = false
		

func shuffleDeck():
	for i in range(1,5):
		for j in range(1,14):
			newCard = cardScene.instance()
			newCard.init(i,j)
			deck.append(newCard)
	randomize()
	deck.shuffle()

func _on_data_received():
	print("receiving data...")
	var data = ws.get_peer(1).get_packet().get_string_from_utf8()
	var msg = data.split(" ")
	print(msg)
	match(msg[0]):
		"hand":
			var hand_string = msg[1].split(",")
			print("received hand from server: ", hand_string)
			for card in hand_string:
				var card_split = card.split("-")
				var suit = int(card_split[0])
				var value = int(card_split[1])
				newCard = cardScene.instance()
				newCard.init(suit, value)
				hand.append(newCard)
			self.loadGame()
		"play":
			var newPile=msg[2].split(",")
			var suits = Array()
			var ranks = Array()
			var tempString
			for i in newPile:
				tempString = i.split("-")
				suits.append(int(tempString[0]))
				ranks.append(int(tempString[1]))
			print(ranks,suits)
			print(msg[2])
			get_node("Pile").updatePile(ranks,suits)
	
func _on_PlayButton_pressed():
	get_node('MultiplayerHand').updateHand()
