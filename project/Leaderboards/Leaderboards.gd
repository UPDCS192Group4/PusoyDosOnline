extends Control

func _ready():
	pass # Replace with function body.
	$ErrorMessage.hide()
	_get_leaderboards()
	
func _get_leaderboards():
	var url = URLs.leaderboards
	var headers = ['Content-Type: application/json', 'Authorization: Bearer ' + URLs.access]
	$LeaderboardsRequest.connect("request_completed", self, "_get_request_completed")
	print("best")
	var err = $LeaderboardsRequest.request(url,headers,false,HTTPClient.METHOD_GET)
	print("eu")
	if err != OK:
		push_error("An  error occured when querying the leaderboards.")
		$ErrorMessage.show()

func _on_Button_pressed():	
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://Home/Home.tscn")

func _get_request_completed(result,response_code,header,body):
	print("part")
	var response = parse_json(body.get_string_from_utf8())
	print(response)
	var counter = 0
	for object in response.results:
		print(object.username,object.rating)
		if counter >= 5:
			break
		$players.get_child(counter).get_node("name").text = object.username
		$players.get_child(counter).get_node("score").text = str(object.rating)
		counter += 1