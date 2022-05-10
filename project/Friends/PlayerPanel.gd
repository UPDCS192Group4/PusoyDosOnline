extends Control

onready var request_buttons = get_node("HBoxContainer/FriendRequest")
var profile_scene = preload("res://Profile/UserProfile.tscn")
var is_friend = false
var is_request = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func setUsername(username):
	$HBoxContainer/NameBox/Name.text = username

func setName(username):
	setUsername(username)

func setRating(rating):
	$HBoxContainer/RatingBox/Rating.text = rating

func removeButtons():
	request_buttons.visible = false


func _on_TextureButton_pressed():
	print("Yes")
	pass # Replace with function body.

func _on_Accept_pressed():
	print("Accept")
	pass # Replace with function body.

func _on_Reject_pressed():
	print("Reject")
	pass # Replace with function body.

func _on_ProfileButton_pressed():
	if not AccountInfo.logged_in:
		return
	var root = get_tree().get_root()
	var profile_panel = profile_scene.instance()
	root.add_child(profile_panel)
	profile_panel.is_friend = is_friend
	profile_panel.is_request = is_request
	profile_panel.get_profile($HBoxContainer/NameBox/Name.text)
	profile_panel.is_child = true
