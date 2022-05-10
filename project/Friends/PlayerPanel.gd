extends Control

var profile_scene = preload("res://Profile/UserProfile.tscn")
var is_friend = false
var is_request = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func getUsername():
	return $HBoxContainer/NameBox/Name.text

func getName():
	return getUsername()


func setUsername(username):
	$HBoxContainer/NameBox/Name.text = username

func setName(username):
	setUsername(username)

func setRating(rating):
	$HBoxContainer/RatingBox/Rating.text = rating

func removeButtons():
	$HBoxContainer/FriendRequest.visible = false

func removeRating():
	$HBoxContainer/RatingBox.visible = false

func _on_TextureButton_pressed():
	print("Yes")
	pass # Replace with function body.

func _on_Accept_pressed():
	print("Accept")
	if not AccountInfo.logged_in:
		return
	var username = getUsername()
	var url = URLs.getAcceptURL(username)
	var headers = URLs.defaultHeader()
	$HTTPRequest.request(url, headers, false, HTTPClient.METHOD_GET)

func _on_Reject_pressed():
	print("Reject")
	if not AccountInfo.logged_in:
		return
	var username = getUsername()
	var url = URLs.getRejectURL(username)
	var headers = URLs.defaultHeader()
	$HTTPRequest.request(url, headers, false, HTTPClient.METHOD_GET)

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


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code in [200]:
		AccountInfo.fetchInfo()
	pass # Replace with function body.
