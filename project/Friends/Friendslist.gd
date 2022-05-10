extends Control

var err
var panel_scene = preload("res://Friends/PlayerPanel.tscn")
var in_home = false

func _ready():
	if not AccountInfo.logged_in:
		for i in range(25):
			$ScrollContainer/VBoxContainer.add_child(panel_scene.instance())
		return
	AccountInfo.connect("refreshedInfo", self, "refreshAll")
	#AccountInfo.connect("profileRequestDone", self, "profileUpdate")
	#AccountInfo.connect("requestsRequestDone", self, "requestUpdate")
	$ErrorMessage/Label.text = "Loading..."
	$ProfileRequest.connect("request_completed", self, "_get_profile_request_completed")
	populateFriends()
	populateRequests()
	
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

func _on_Button_pressed():	
	if in_home:
		return
	get_tree().change_scene("res://Home/Home.tscn")
	
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
	AccountInfo.updateInfo(json.result)
	populateFriends()

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
	print("???", response)
	pass
	
func populateFriends():
	$ErrorMessage/Label.hide()
	var friends = AccountInfo.friends
	for friend in friends:
		if friend.username == AccountInfo.username:
			continue
		var panel = panel_scene.instance()
		panel.setName(friend.username)
		panel.setRating(str(friend.rating))
		panel.is_friend = true
		$ScrollContainer/VBoxContainer.add_child(panel)
		panel.removeButtons()

func populateRequests():
	var requests = AccountInfo.requests
	for request in requests:
		var username = request.from_user_name
		if username in AccountInfo.friend_names or username == AccountInfo.username:
			continue
		var panel = panel_scene.instance()
		panel.setName(username)
		panel.is_friend = false
		panel.is_request = true
		$ScrollContainer/VBoxContainer.add_child(panel)
		panel.removeRating()

func clearEntries(friends=true, requests=true):
	for child in $ScrollContainer/VBoxContainer.get_children():
		child.queue_free()
		
func refreshAll():
	clearEntries()
	populateFriends()
	populateRequests()
