extends TextureButton

var _texture2 = load("res://assets/cards/card_on_pressed.png")
var _texture_toggle = 0

func _ready():
	pass

func _pressed():
	if get_parent().get_parent().isCurrentPlayer == 0:
		return
	
	var game = get_tree().root.get_node('Game')
	if _texture_toggle == 0:
		self.texture_normal = _texture2
		get_parent().get_parent().rect_scale *= 1.1
		game.addPressedCard(get_parent().get_parent().rank, get_parent().get_parent().suit)
	else:
		self.texture_normal = null
		get_parent().get_parent().rect_scale /= 1.1
		game.removePressedCard(get_parent().get_parent().rank, get_parent().get_parent().suit)
	_texture_toggle = 1 - _texture_toggle
	get_parent().get_parent()._is_pressed = 1 - get_parent().get_parent()._is_pressed
	

func _hover():
	if get_parent().get_parent().isCurrentPlayer == 0:
		return
	get_parent().get_parent().rect_scale *= 1.1
