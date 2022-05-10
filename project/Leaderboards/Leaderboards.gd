extends Control

var err
var max_display = 10
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
	$LeaderboardsRequest.connect("request_completed", self, "_get_leaderboards_request_completed")
	_get_list()
	
	#$RequestsRequest.connect("request_complete", self, "_get_requests_request_completed")
	# _get_list()	
	
func _get_list():
	if not AccountInfo.logged_in:
		return 0
	var url = URLs.leaderboards
	var headers = URLs.defaultHeader()
	var err = $LeaderboardsRequest.request(url,headers,false,HTTPClient.METHOD_GET)
	if err != OK:
		print("Leaderboards request to ", url, " failed with err: ", err)

func _on_Button_pressed():	
	if in_home:
		return
	get_tree().change_scene("res://Home/Home.tscn")
	
func _get_leaderboards_request_completed(result,response_code,header,body):
	var json = parse_json(body.get_string_from_utf8())
	if (response_code != 200 and response_code != 201): 
		$ErrorMessage/Label.text = "Error during query..."
		$ErrorMessage/Label.show()
		yield(get_tree().create_timer(2), "timeout")
		$ErrorMessage/Label.text = "Redirecting..."
		yield(get_tree().create_timer(1), "timeout")
		get_tree().change_scene("res://Home/Home.tscn")	
		return
	print("Leaderboards: ", json)
	populateLeaderboards(json)
	
func populateLeaderboards(leaderboards_json):
	var leaderboards = leaderboards_json.results
	$ErrorMessage/Label.hide()
	var counter = 0
	for object in leaderboards:
		if counter >= max_display:
			break
		var panel = panel_scene.instance()
		panel.setName(object.username)
		panel.setRating(str(object.rating))
		$ScrollContainer/VBoxContainer.add_child(panel)
		panel.removeButtons()
		counter += 1
