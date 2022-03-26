extends Control
var deck = Array()
var cardScene = preload("res://Card.tscn")
var newCard
var pressedArray = Array()

func _ready():
	var scene1 = load("res://Hand.tscn")
	var child1 = scene1.instance()
	add_child(child1)
	var scene2 = load("res://Pile.tscn")
	var child2 = scene2.instance()
	add_child(child2)
	var scene3 = load("res://Opponents.tscn")
	var child3 = scene3.instance()
	child3.set_name("Opponents")
	add_child(child3)
	shuffleDeck()
	
	var ranks = Array()
	var suits = Array()

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

func addPressedCard(newRank, newSuit):
	var temp = Array()
	temp.append(newRank)
	temp.append(newSuit)
	pressedArray.append(temp)
	checkArray()
func removePressedCard(newRank, newSuit):
	var temp = Array()
	temp.append(newRank)
	temp.append(newSuit)
	var k = pressedArray.find(temp)
	pressedArray.remove(k)
	checkArray()

func enablePlayButton():
	get_node("PlayButton").text = 'PLAY'
	get_node("PlayButton").disabled = false
func disablePlayButton():
	get_node("PlayButton").text = "NOPE"
	get_node("PlayButton").disabled = true

func checkArray():
	var topOfPile = get_node('Pile').getTopOfPile()
	#compare pressedArray to onTop, in a three part check
	#first check if number of cards is the same as topOfPile
	
	#next check if play is valid (i.e., if pair, should have the same rank)
	
	#next check if play is better than topOfPile
