extends Container

var deck = Array()
var cards = Array()
var cardScene = load("res://Card.tscn")
var NUM_CARDS = 13
var index

var OVAL_CENTRE = Vector2(512, 480)
var H_RAD = 900
var V_RAD = 300
var ANGLE
var ANG_DIST = 0.07
var OVAL_VECT = Vector2()

func _ready():	
	yield(get_parent(), "ready")
	deck = get_parent().hand
	
	ANGLE = deg2rad(90) - ANG_DIST * (NUM_CARDS - 1) / 2
	for i in range(13):
		cards.append(deck[i])
		cards[i].isCurrentPlayer = 1
		cards[i].changeFace()
		add_child(cards[i])
		OVAL_VECT = Vector2(H_RAD * cos(ANGLE), -V_RAD * sin(ANGLE))
		cards[i].rect_position = OVAL_CENTRE + OVAL_VECT - cards[i].rect_size / 2
		cards[i].rect_rotation = (90 - rad2deg(ANGLE)) / 4
		ANGLE += ANG_DIST

func updateHand(): 
	var pressedArray = Array()
	var ranks = Array()
	var suits = Array()
	var cards_string = PoolStringArray() # combined ranks and suits but in string
	for card in cards:
		if card._is_pressed:
			pressedArray.append(card)
			ranks.append(card.rank)
			suits.append(card.suit)
			cards_string.append(str(card.suit) + "-" + str(card.rank))
	ANG_DIST += 0.0075 * pressedArray.size()
	for card in pressedArray:			
		var k = cards.find(card)
		cards.remove(k)
		card.queue_free()
		NUM_CARDS -= 1
	for card in pressedArray:	
		ANGLE = deg2rad(90) - ANG_DIST * (NUM_CARDS - 1) / 2.0
		for i in range(NUM_CARDS):
			OVAL_VECT = Vector2(H_RAD * cos(ANGLE), -V_RAD * sin(ANGLE))
			cards[i].rect_position = OVAL_CENTRE + OVAL_VECT - cards[i].rect_size / 2
			cards[i].rect_rotation = (90 - rad2deg(ANGLE)) / 4
			ANGLE += ANG_DIST
	var play_message = "play " + cards_string.join(",")
	print("played ", play_message)
	get_parent().ws.get_peer(1).put_packet(play_message.to_utf8())
	get_parent().get_node('Pile').updatePile(ranks,suits) # this should be moved
#		var k = card.get_index()
#		cards.remove(k)
#		card.queue_free()
#		NUM_CARDS -= 1
#		angle = deg2rad(90) - 0.1 * (NUM_CARDS-1) / 2.0
#		print('gurl', NUM_CARDS)
#		for i in range(NUM_CARDS):
#			OvalAngleVector = Vector2(H_rad*cos(angle), -V_rad*sin(angle))
#			cards[i].rect_position = OvalCentre + OvalAngleVector - cards[i].rect_size/2
#			cards[i].rect_rotation = (90-rad2deg(angle))/4
#			angle += 0.1
#			print(cards[i].rect_position)
		#cards[i].rect_position.x=(1024-NUM_CARDS*40)/2+i*40-70+20

func changeZ(top):
	index = cards.find(top)
	cards[index].get_node('Container').z_index = NUM_CARDS
	for i in range(index-1, -1, -1):
		cards[i].get_node('Container').z_index = NUM_CARDS - (index-i)
	for i in range(index+1, NUM_CARDS):
		cards[i].get_node('Container').z_index = NUM_CARDS - i - 1
		#cards[i].Container.z_index
