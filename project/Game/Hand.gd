extends Container

var deck = Array()
var cards = Array()
var cardScene = load("res://Game/Card.tscn")
var NUM_CARDS = 13
var index

var cardval
var OVAL_CENTRE = Vector2(512, 480)
var H_RAD = 900
var V_RAD = 300
var ANGLE
var ANG_DIST = 0.07
var OVAL_VECT = Vector2()

var z_layer = 0

func _ready():	
	disableZ()	
	setupCards()
	
func setupCards():
	ANGLE = deg2rad(90) - ANG_DIST * (NUM_CARDS - 1) / 2
	for i in len(GameDetails.hand):
		yield(get_tree().create_timer(0.1), "timeout")
		var newCard = cardScene.instance()
		cards.append(newCard)
		cardval = GameDetails.hand[i]
		cardval = int(cardval)
		cards[i].init((cardval/100)+1, cardval % 100, 0)
		cards[i].isCurrentPlayer = 1
		cards[i].changeFace()
		OVAL_VECT = Vector2(H_RAD * cos(ANGLE), -V_RAD * sin(ANGLE))
		cards[i].rect_position = OVAL_CENTRE + OVAL_VECT - cards[i].rect_size / 2
		#cards[i].rect_position.x -= cards[i].rect_size.x
		#print(OVAL_VECT, cards[i].rect_position)
		cards[i].rect_rotation = (90 - rad2deg(ANGLE)) / 4
		ANGLE += ANG_DIST
		add_child(cards[i])
	enableZ()
		
func updateHand(playedArrayRaw): 
	var playedArray = Array()
	for i in playedArrayRaw:
		playedArray.append(i[0]+i[1]*100-100)
	print("removing ", playedArray)
	var pressedArray = Array()
	for card in cards:
		if card.cardval in playedArray:
			pressedArray.append(card)
	print("pressed array is ", pressedArray)
	ANG_DIST += 0.0075 * len(pressedArray)
	for card in pressedArray:			
		var k = cards.find(card)
		cards.remove(k)
		card.queue_free()
		NUM_CARDS -= 1
		print("got 1 card")
	if NUM_CARDS == 0:
		get_parent().winnermessage()
		return
	#for card in pressedArray:	
	#update Angle, change position and rotation
	ANGLE = deg2rad(90) - ANG_DIST * (NUM_CARDS - 1) / 2.0
	for i in range(NUM_CARDS):
		OVAL_VECT = Vector2(H_RAD * cos(ANGLE), -V_RAD * sin(ANGLE))
		cards[i].rect_position = OVAL_CENTRE + OVAL_VECT - cards[i].rect_size / 2
		cards[i].rect_rotation = (90 - rad2deg(ANGLE)) / 4
		ANGLE += ANG_DIST

func playHand():	
	var pressedArray = Array()
	var ranks = Array()
	var suits = Array()
	for card in cards:
		if card._is_pressed:
			pressedArray.append(card)
	var postArray = Array()
	for card in pressedArray:
		postArray.append(card.suit * 100 - 100 + card.rank)
	var url = URLs.game_ping + GameDetails.game_id + "/play_cards/"
	var headers = URLs.defaultHeader()
	get_parent().playCards(url,headers,postArray)
		
func changeZ(top):
	if (!z_layer):
		return
	index = cards.find(top)
	cards[index].get_node('Container').z_index = NUM_CARDS
	for i in range(index-1, -1, -1):
		cards[i].get_node('Container').z_index = NUM_CARDS - (index-i)
	for i in range(index+1, NUM_CARDS):
		cards[i].get_node('Container').z_index = NUM_CARDS - i - 1

func enableZ():
	z_layer = 1
	
func disableZ():
	z_layer = 0
