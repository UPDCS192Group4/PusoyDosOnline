extends Control

var err
var friendslist = []
var requestslist = []
var is_child = false
var is_self = false
var is_friend = false
var is_request = false

onready var addButton = $Profile/Friend/Add/AddButton
onready var removeButton = $Profile/Friend/Remove/RemoveButton
onready var acceptButton = $Profile/FriendRequest/Accept/AcceptButton
onready var rejectButton = $Profile/FriendRequest/Reject/RejectButton

signal added
signal removed

func _ready():
	AccountInfo.connect("refreshedInfo", self, "updateFriendButtons")
	$ErrorMessage/Label.text = "Loading..."
	$Profile.hide()
	$ProfileRequest.connect("request_completed", self, "_get_profile_request_completed")
	$RequestsRequest.connect("request_completed", self, "_get_requests_request_completed")
	$AddRequest.connect("request_completed", self, "_get_add_request_completed")
	# _get_list()	

# DEFUNCT
"""
func _get_list():
	if not AccountInfo.logged_in:
		return 0
	var profile_url = URLs.profile
	var requests_url = URLs.friendrequests
	var headers = ['Content-Type: application/json', 'Authorization: Bearer ' + URLs.access]
	var err1 = $ProfileRequest.request(profile_url,headers,false,HTTPClient.METHOD_GET)
	var err2 = $RequestsRequest.request(requests_url, headers, false, HTTPClient.METHOD_GET)
"""

func getUsername():
	return $Profile/Username/Value.text
	
func getName():
	return getUsername()

func get_profile(username):
	if not AccountInfo.logged_in:
		return 0
	var headers = ['Content-Type: application/json', 'Authorization: Bearer ' + URLs.access]
	var err1 = $ProfileRequest.request(URLs.profile + str(username) + "/",headers,false,HTTPClient.METHOD_GET)

func _on_Button_pressed():	
	if not is_child:
		print("This is the main scene!")
		return
	queue_free()

func _get_profile_request_completed(result,response_code,header,body):
	var json = JSON.parse(body.get_string_from_utf8())
	if (response_code != 200 and response_code != 201): 
		$ErrorMessage/Label.text = "Error during query..."
		$ErrorMessage/Label.show()
		yield(get_tree().create_timer(2), "timeout")
		$ErrorMessage/Label.text = "Redirecting..."
		yield(get_tree().create_timer(1), "timeout")
		get_tree().change_scene("res://Home/Home.tscn")	
		return
	print("Player info: ", json.result)
	populateProfile(json.result)
	
func _get_requests_request_completed(result,response_code,header,body):
	print("Requests RC: ", response_code)
	if response_code != 200:
		print("Requests Request failed with response code ", response_code)
		return
	AccountInfo.fetchInfo()
	
func _get_add_request_completed(result,response_code,header,body):
	print("Add RC: ", response_code)
	if not response_code in [200, 201]:
		print("Requests Request failed with response code ", response_code)
		if response_code == 400:
			$Profile/Friend/Add.text = parse_json(body.get_string_from_utf8()).detail
			$Profile/Friend/Add/AddButton.disabled = true
		return
	$Profile/Friend/Add.text = "Friend request sent!"
	$Profile/Friend/Add/AddButton.disabled = true

func populateProfile(profile_json):
	var json = profile_json
	$Profile/Username/Value.text = json.username
	$Profile/Rating/Value.text = str(json.rating)
	$Profile/Games/Value.text = str(json.played_games)
	$Profile/Wins/Value.text = str(json.won_games)
	$Profile/Loses/Value.text = str(json.lost_games)
	$Profile/Winstreak/Value.text = str(json.winstreak)
	$Profile.show()
	updateFriendButtons()
	$ErrorMessage/Label.hide()

func updateFriendButtons():
	var username = $Profile/Username/Value.text
	is_self = username == AccountInfo.username
	is_friend = username in AccountInfo.friend_names
	is_request = username in AccountInfo.request_names
	$Profile/Friend.visible = (is_friend or not is_request) and not is_self
	$Profile/FriendRequest.visible = not is_friend and is_request and not is_self
	$Profile/Friend/Add.visible = not is_friend
	$Profile/Friend/Remove.visible = is_friend


func _on_AddButton_pressed():
	print("Add")
	if not AccountInfo.logged_in:
		return
	var username = getUsername()
	var url = URLs.getAddFriendURL()
	var headers = URLs.defaultHeader()
	var body = {"to_user_name": username}
	var err = $AddRequest.request(url, headers, false, HTTPClient.METHOD_POST, to_json(body))
	if err != OK:
		print("Add Friend request to ", url, " not okay: ", err)
	pass # Replace with function body.
	

func _on_RemoveButton_pressed():
	print("Remove")
	if not AccountInfo.logged_in:
		return
	var username = getUsername()
	var url = URLs.getRemoveFriendURL(username)
	var headers = URLs.defaultHeader()
	var err = $RequestsRequest.request(url, headers, false, HTTPClient.METHOD_GET)
	if err != OK:
		print("Remove Friend request to ", url, " not okay: ", err)
	pass # Replace with function body.

func _on_AcceptButton_pressed():
	print("Accept")
	if not AccountInfo.logged_in:
		return
	var username = getUsername()
	var url = URLs.getAcceptURL(username)
	var headers = URLs.defaultHeader()
	$RequestsRequest.request(url, headers, false, HTTPClient.METHOD_GET)

func _on_RejectButton_pressed():
	print("Reject")
	if not AccountInfo.logged_in:
		return
	var username = getUsername()
	var url = URLs.getRejectURL(username)
	var headers = URLs.defaultHeader()
	$RequestsRequest.request(url, headers, false, HTTPClient.METHOD_GET)
