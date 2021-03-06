extends MarginContainer
class_name Card
var _is_pressed = 0
var rank
var suit
var cardval
var face
var isCurrentPlayer = 0
var isPile = 0
var cardBack = preload("res://assets/cards/card_back_1.png")
var cardPressed = preload("res://assets/cards/card_on_pressed.png")
var cardHovered = preload("res://assets/cards/card_on_hover.png")

func _ready():
	pass

func init(inputSuit, inputRank, pileCard):
	rank = inputRank
	suit = inputSuit
	cardval = (suit-1) * 100 + rank
	$Container/CardTexture.texture = cardBack
	$Container/CardButton.texture_hover = null
	$Container/CardButton.texture_pressed = null
	isPile = pileCard
	
func changeFace():
	if isCurrentPlayer or isPile:
		#print("suit, rank is ", suit, rank)
		face = load("res://assets/cards/card-" + str(suit) + "-" + str(rank) + ".png")
		$Container/CardTexture.texture = face
	if isCurrentPlayer:
		$Container/CardButton.texture_hover = cardHovered
		$Container/CardButton.texture_pressed = cardPressed
		
func _on_CardButton_mouse_entered():
	#print('entered ', isCurrentPlayer, ' ', isPile, ' ', get_parent())
	if isCurrentPlayer == 0 and isPile == 0:
		return
	get_parent().changeZ(self)
	pass # Replace with function body.
