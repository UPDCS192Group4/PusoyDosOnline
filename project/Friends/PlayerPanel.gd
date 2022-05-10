extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TextureButton_pressed():
	# print("Yes")
	pass # Replace with function body.

func setUsername(username):
	$HBoxContainer/NameBox/Name.text = username

func setName(username):
	setUsername(username)

func setRating(rating):
	$HBoxContainer/RatingBox/Rating.text = rating

func _on_TextureButton_pressed2():
	print("username")


func _on_Accept_pressed():
	print("Accept")
	pass # Replace with function body.


func _on_Reject_pressed():
	print("Reject")
	pass # Replace with function body.
