extends Control

var err
var friendslist = []
var requestslist = []
var is_child = false
var is_friend = false
var is_request = false

func _ready():
	$ErrorMessage/Label.text = "Loading..."
	$Profile.hide()
	$ProfileRequest.connect("request_completed", self, "_get_profile_request_completed")
	#$RequestsRequest.connect("request_complete", self, "_get_requests_request_completed")
	# _get_list()	
	
func _get_list():
	if not AccountInfo.logged_in:
		return 0
	var profile_url = URLs.profile
	var requests_url = URLs.friendrequests
	var headers = ['Content-Type: application/json', 'Authorization: Bearer ' + URLs.access]
	var err1 = $ProfileRequest.request(profile_url,headers,false,HTTPClient.METHOD_GET)
	var err2 = $RequestsRequest.request(requests_url, headers, false, HTTPClient.METHOD_GET)

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
	var response = parse_json(body.get_string_from_utf8())
	if (response_code != 200 and response_code != 201): 
		$ErrorMessage/Label.text = "Error during query..."
		$ErrorMessage/Label.show()
		yield(get_tree().create_timer(2), "timeout")
		$ErrorMessage/Label.text = "Redirecting..."
		yield(get_tree().create_timer(1), "timeout")
		get_tree().change_scene("res://Home/Home.tscn")	
		return
	AccountInfo.updateInfo(response.result)
	pass
	
func populateProfile(profile_json):
	var json = profile_json
	$Profile/Username/Value.text = json.username
	$Profile/Rating/Value.text = str(json.rating)
	$Profile/Games/Value.text = str(json.played_games)
	$Profile/Wins/Value.text = str(json.won_games)
	$Profile/Loses/Value.text = str(json.lost_games)
	$Profile/Winstreak/Value.text = str(json.winstreak)
	$Profile.show()
	$Profile/Friend.visible = not is_request
	$Profile/FriendRequest.visible = is_request
	$Profile/Friend/Add.visible = not is_friend
	$Profile/Friend/Remove.visible = is_friend
	$ErrorMessage/Label.hide()
