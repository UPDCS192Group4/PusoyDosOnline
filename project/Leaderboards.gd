extends Control

func _ready():
	pass # Replace with function body.
	$Error_message.hide()
	_get_leaderboards()
	
func _get_leaderboards():
	print('part1')
	var url = URLs.leaderboards
	$LeaderboardsRequest.connect("request_completed", self, "_get_request_completed")
	print('part2')
	var error = $LeaderboardsRequest.request(url)
	if error != OK:
		push_error("An error occurred when querying the leaderboards!")
		$Error_message.show()
	print('part3')

func _on_Button_pressed():	
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://Home.tscn")

func _get_request_completed(result,response_code,header,body):
	print('part4')
	var response = parse_json(body.get_string_from_utf8())
	var counter = 0
	for i in response:
		$boards.get_child(counter).get_node("name").text = i
		$boards.get_child(counter).get_node("score").text = str(response[i])
		counter+=1
