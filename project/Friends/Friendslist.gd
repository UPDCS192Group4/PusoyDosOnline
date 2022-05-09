extends Control

var err
var panel_scene = preload("res://Friends/PlayerPanel.tscn")
var friendslist = []
var requestslist = []

func _ready():
	$ErrorMessage/Label.hide()
	$ProfileRequest.connect("request_completed", self, "_get_profile_request_completed")
	# $RequestsRequest.connect("request_complete", self, "_get_requests_request_completed")
	_get_list()	
	
func _get_list():
	if not AccountInfo.logged_in:
		return 0
	var profile_url = URLs.profile
	var requests_url = URLs.friendrequests
	var headers = ['Content-Type: application/json', 'Authorization: Bearer ' + URLs.access]
	var err1 = $ProfileRequestRequest.request(profile_url,headers,false,HTTPClient.METHOD_GET)
	var err2 = $RequestsRequest.request(requests_url, headers, false, HTTPClient.METHOD_GET)

func _on_Button_pressed():	
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://Home/Home.tscn")
	
func _get_profile_request_completed(result,response_code,header,body):
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
