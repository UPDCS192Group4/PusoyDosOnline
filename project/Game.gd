extends Control
var deck = Array()
var cardScene = preload("res://Card.tscn")
var newCard
func _ready():
	var scene1 = load("res://Hand.tscn")
	var child1 = scene1.instance()
	add_child(child1)
	var scene2 = load("res://Pile.tscn")
	var child2 = scene2.instance()
	add_child(child2)
	var scene3 = load("res://Opponents.tscn")
	var child3 = scene3.instance()
	add_child(child3)
	shuffleDeck()

func shuffleDeck():
	for i in range(1,5):
		for j in range(1,14):
			newCard = cardScene.instance()
			newCard.init(i,j,0)
			deck.append(newCard)
	randomize()
	deck.shuffle()
	
func _on_PlayButton_pressed():
	get_node('Hand').updateHand()

func _on_HomeButton_pressed():
	var scene1 = load("res://PopUp.tscn")
	var child1 = scene1.instance()
	get_parent().add_child(child1)
	pass # Replace with function body.
