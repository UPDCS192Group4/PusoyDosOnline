extends MarginContainer
class_name Card
var _is_pressed = 0
var rank
var suit
var face
var isCurrentPlayer = 0
var isPile = 0
var cardBack = preload("res://assets/cards/card_back_1.png")
var cardPressed = preload("res://assets/cards/card_on_pressed.png")
var cardHovered = preload("res://assets/cards/card_on_hover.png")

func _ready():
	pass

func init(inputSuit, inputRank):
	rank = inputRank
	suit = inputSuit
	$Container/CardTexture.texture = cardBack
	$Container/CardButton.texture_hover = null
	$Container/CardButton.texture_pressed = null
	
func changeFace():
	if isCurrentPlayer or isPile:
		face = load("res://assets/cards/card-" + str(suit) + "-" + str(rank) + ".png")
		$Container/CardTexture.texture = face
	if isCurrentPlayer:
		$Container/CardButton.texture_hover = cardHovered
		$Container/CardButton.texture_pressed = cardPressed
		
func _on_CardButton_mouse_entered():
	if isCurrentPlayer == 0:
		return
	get_parent().changeZ(self)
	pass # Replace with function body.
