extends Container

var pileCards = Array()
var cardScene = load("res://Card.tscn")
var index

var OVAL_CENTRE = Vector2(512, 800)
var H_RAD = 700
var V_RAD = 400
var ANGLE
var ANG_DIST = 0.15
var OVAL_VECT = Vector2()
var NUM_CARDS = 0

func _ready():
	pass

func updatePile(ranks, suits):
	NUM_CARDS = ranks.size()
	ANGLE = deg2rad(90) - ANG_DIST * (NUM_CARDS - 1)/2
	while(pileCards.size() > 0):
		pileCards[0].queue_free()
		pileCards.remove(0)
	var newCard
	for i in range(ranks.size()):
		newCard = cardScene.instance()
		newCard.init(suits[i], ranks[i], 1)
		newCard.isPile = 1
		newCard.changeFace()
		pileCards.append(newCard)
		add_child(pileCards[i])
		
		OVAL_VECT = Vector2(H_RAD * cos(ANGLE), -V_RAD * sin(ANGLE))
		pileCards[i].rect_position = OVAL_CENTRE + OVAL_VECT - pileCards[i].rect_size / 2
		pileCards[i].rect_rotation = (90 - rad2deg(ANGLE))/4
		ANGLE += ANG_DIST
	
	#this part is used to demonstrate removing cards from each of the other piles
	get_parent().get_node('Opponents').A_updateHand(ranks.size())
	get_parent().get_node('Opponents').B_updateHand(ranks.size())
	get_parent().get_node('Opponents').C_updateHand(ranks.size())
	
func changeZ(top):
	#print('changing pile z')
	index = pileCards.find(top)
	pileCards[index].get_node('Container').z_index = NUM_CARDS
	for i in range(index-1, -1, -1):
		pileCards[i].get_node('Container').z_index = NUM_CARDS - (index-i)
	for i in range(index+1, NUM_CARDS):
		pileCards[i].get_node('Container').z_index = NUM_CARDS - i - 1
		#cards[i].Container.z_index
	#for i in range(NUM_CARDS):
	#	print(pileCards[i].get_node('Container').z_index)

func getTopOfPile():
	var ranks = Array()
	var suits = Array()
	var ret = Array()
	if !NUM_CARDS == 0:
		for card in pileCards:
			ret.append([card.rank,card.suit])
	print(ret)
	#ret.append(ranks)
	#ret.append(suits)
		
	return ret
