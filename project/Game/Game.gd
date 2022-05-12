extends Control

var deck = Array()
var cardScene = preload("res://Game/Card.tscn")
var scene1 = preload("res://Game/Hand.tscn")
var scene2 = preload("res://Game/Pile.tscn")
var scene3 = preload("res://Game/Opponents.tscn")
var popup = preload("res://Game/PopUp.tscn")

var url
var headers
var err
var json

var t = 0
var t_rate = 240

var temprank
var tempsuit
var newCard
var pressedArray = Array()
var playedArray = Array()
var temp = Array()

var is_ready = 0

func _ready():
	is_ready = 0
	$HandRequest.connect("request_completed", self, "_on_HandRequest_request_completed")
	$PingRequest.connect("request_completed", self, "_on_PingRequest_request_completed")
	$PlayRequest.connect("request_completed", self, "_on_PlayRequest_request_completed")
	$PassRequest.connect("request_completed", self, "_on_PlayRequest_request_completed")
	$LeaveRequest.connect("request_completed", self, "_on_LeaveRequest_request_completed")
	request_hand()
	var child2 = scene2.instance()
	add_child(child2)
	#var child3 = scene3.instance()
	#child3.set_name("Opponents")
	#add_child(child3)
	disablePlayButton()
	is_ready = 1

func printdict(dict):
	for i in dict:
		print(i, " : ", dict[i])
		
func _process(_delta):
	t += 1
	if t >= t_rate:
		t = t - t_rate
		_ping_server()	

func request_hand():
	url = URLs.game_ping + GameDetails.game_id
	headers = URLs.defaultHeader()
	err = $HandRequest.request(url, headers, false, HTTPClient.METHOD_GET)

func _on_HandRequest_request_completed(result, response_code, headers, body):
	if (response_code != 200 and response_code != 201):
		print("Error encountered, retrying Hand request.")
		request_hand()
		return
	json = JSON.parse(body.get_string_from_utf8())
	var user
	for i in range(len(json.result["hands"])):
		user = json.result["hands"][i]
		GameDetails.gamers[int(user["move_order"])] = user["user"]
		if user["user"] == AccountInfo.username:
			GameDetails.my_move_order = int(user["move_order"])
			for j in user["hand"]:
				j = int(j)
				if j == 1:
					GameDetails.needs_3_of_clubs = 1
				GameDetails.hand.append(j)
	var handscene = scene1.instance()
	add_child(handscene)
	
func _ping_server():
	if not is_ready:
		return
	print("Pinging")
	url = URLs.game_ping + GameDetails.game_id
	headers = URLs.defaultHeader()
	err = $PingRequest.request(url, headers, false, HTTPClient.METHOD_GET)
	
func _on_PingRequest_request_completed(result, response_code, headers, body):
	if (response_code != 200 and response_code != 201):
		print("Ping errored")
		return
	json = JSON.parse(body.get_string_from_utf8())	
	GameDetails.current_player = int(json.result["current_round"])
	$Pile.updatePile(json.result["last_play"])
	if GameDetails.my_move_order == GameDetails.current_player % 4:
		if GameDetails.is_current_player:
			return
		GameDetails.is_current_player = 1
		if int(json.result["control"]) >= 4:
			GameDetails.is_control = 1
		else:
			GameDetails.is_control = 0
		return
	disablePlayButton()
	GameDetails.is_current_player = 0
	GameDetails.is_control = 0
	
func ready_to_move():
	pass
	
func _on_PlayButton_pressed():
	playedArray.clear()
	playedArray = pressedArray
	get_node('Hand').playHand()
	
func playCards(url,headers,postArray):
	$PlayRequest.request(url,headers,false, HTTPClient.METHOD_POST, to_json({"play":postArray}))
	
func _on_PlayRequest_request_completed(result, response_code, headers, body):
	print('---------------------, r: ', response_code)
	if response_code == 200 or response_code == 201:
		$Hand.updateHand(playedArray)
		if GameDetails.needs_3_of_clubs:
			GameDetails.needs_3_of_clubs = 0
		pressedArray.clear()
		playedArray.clear()

func _on_HomeButton_pressed():
	var message = popup.instance()
	message.changeText("Leave Game?")
	#message.changeYesText("Leave")
	#message.changeNoText("Play")
	message.disable_auto_Home()
	message.get_node("A").get_node("B").get_node("C").get_node("D").get_node("YesButton").connect("pressed", self, "_go_home")
	add_child(message)

func addPressedCard(newRank, newSuit):
	temp.clear()
	temp.append(newRank)
	temp.append(newSuit)
	pressedArray.append(temp)
	if GameDetails.is_current_player:
		checkArray(pressedArray)
	
func removePressedCard(newRank, newSuit):
	temp.clear()
	temp.append(newRank)
	temp.append(newSuit)
	var k = pressedArray.find(temp)
	pressedArray.remove(k)
	if GameDetails.is_current_player:
		checkArray(pressedArray)

func enablePlayButton():
	get_node("PlayButton").text = 'PLAY'
	get_node("PlayButton").disabled = false
	
func disablePlayButton():
	get_node("PlayButton").text = "NOPE"
	get_node("PlayButton").disabled = true

func checkArray(inputArray):
	if GameDetails.needs_3_of_clubs:
		if !([1,1] in inputArray):
			disablePlayButton()
			return
		if classifyArray(inputArray):
			enablePlayButton()
			return
		disablePlayButton()
		return
	if GameDetails.is_control == 1:
		if classifyArray(inputArray):
			enablePlayButton()
			return
		disablePlayButton()
		return
	
	# Else no control, need to check against top of pile
	inputArray = classifyArray(inputArray)	
	if !inputArray:
		return
		
	var topOfPileRaw = GameDetails.last_pile
	var topOfPile = Array()
	for i in topOfPileRaw:
		temprank = i % 100
		tempsuit = i / 100 + 1
		topOfPile.append([temprank,tempsuit])
		
	topOfPile = classifyArray(topOfPile)
			
	# Compare arrays topOfPile and inputArray using customSort()
	if customSort(inputArray, topOfPile):
		print('enabling')
		enablePlayButton()
		return
	else:
		disablePlayButton()
		return

func classifyArray(array):
	print("CHECKING ", array)
	# If an array of selected cards is invalid, this function returns [0].
	# Otherwise, this function returns [n,a1,a2,...] where n is the number of cards
	# in the selection and a1,a2,.. are other quantifiers for the array.
	# Two arrays with the same n can be compared by comparing their quantifiers.
	# Two arrays with different n cannot be compared and one cannot be played after the other.
	var returnArray = Array()
	
	if array.size() == 0:
		return returnArray
		
	if array.size() == 1:
		# For array of length 1, quantifiers are rank, suit, in that order.
		returnArray.append(1)
		returnArray.append(array[0][0])
		returnArray.append(array[0][1])
		return returnArray
		
	if array.size() == 2:
		if array[0][0] != array[1][0]:
			return returnArray
		else:
			# For array of length 2, quantifiers are rank, suit, in that order.
			returnArray.append(2)
			returnArray.append(array[0][0])
			returnArray.append(max(array[0][1],array[1][1]))
			return returnArray
			
	if array.size() == 3:
		if max(array[0][0],max(array[1][0],array[2][0])) != \
			min(array[0][0],min(array[1][0],array[2][0])):
			return returnArray
		else:
			returnArray.append(3)
			returnArray.append(array[0][0])
			return returnArray
			
	if array.size() == 4:
		return returnArray
		
	if array.size() == 5:
		var rankArray = Array()
		for i in range(5):
			rankArray.append(array[i][0])
		rankArray.sort()
		#flush
		if array[0][1] == array[1][1] and array[1][1] == array[2][1] \
			and array[2][1] == array[3][1] and array[3][1] == array[4][1]:
				if rankArray[0]+1 == rankArray[1] and rankArray[1]+1 == rankArray[2] \
				and rankArray[2]+1 == rankArray[3] and rankArray[3]+1 == rankArray[4]:
					print('straight flush/royal flush')
					returnArray.append(5)
					returnArray.append(5)
					returnArray.append(rankArray[4])
					returnArray.append(array[0][1])
					return returnArray
				else:
					print('flush')
					returnArray.append(5)
					returnArray.append(2)
					returnArray.append(rankArray[4])
					returnArray.append(array[0][1])
					return returnArray
		#straight
		if rankArray[0]+1 == rankArray[1] and rankArray[1]+1 == rankArray[2] \
			and rankArray[2]+1 == rankArray[3] and rankArray[3]+1 == rankArray[4]:
				print('straight')
				returnArray.append(5)
				returnArray.append(1)
				returnArray.append(rankArray[4])
				for i in range(5):
					if array[i][0] == rankArray[4]:
						returnArray.append(array[i][1])
						break
				return returnArray
		#four of a kind
		if (rankArray[0] == rankArray[1] and rankArray[1] == rankArray[2] \
			and rankArray[2] == rankArray[3]) or (rankArray[1] == rankArray[2] \
			and rankArray[2] == rankArray[3] and rankArray[3] == rankArray[4]):
				print('four of a kind')
				returnArray.append(5)
				returnArray.append(4)
				returnArray.append(rankArray[2])
				returnArray.append(0) #padding
				return returnArray
		#full house
		if (rankArray[0] == rankArray[1] and rankArray[2] == rankArray[3] \
			and rankArray[3] == rankArray[4]) or (rankArray[0] == rankArray[1] \
			and rankArray[1] == rankArray[2] 	and rankArray[3] == rankArray[4]):
				print('full house')
				returnArray.append(5)
				returnArray.append(3)
				returnArray.append(rankArray[2])
				returnArray.append(0) #padding
				return returnArray
		return returnArray
			
	return returnArray

func customSort(a,b):
	# Catch faulty inputs by first comparing size:
	if a.size() != b.size():
		print('Arrays are not of the same size.')
		return false
	
	if a[0] == 0:
		return false
		
	if a[0] != b[0]:
		return false
		
	#Checks if the values of a are at least the values in b.
	for i in range(a.size()):
		if a[i] < b[i]:
			return false
		elif a[i] == b[i]:
			pass
		elif a[i] > b[i]:
			return  true

func _on_PassButton_pressed():
	if !GameDetails.is_current_player:
		return
	url = URLs.game_ping + GameDetails.game_id + "/play_cards/"
	headers = URLs.defaultHeader()
	$PassRequest.request(url,headers,false, HTTPClient.METHOD_POST, to_json({"play":[]}))

func _on_PassRequest_request_completed(result, response_code, headers, body):
	if response_code != 200 or response_code != 201:
		_on_PassButton_pressed()

func winnermessage():
	var message = popup.instance()
	message.changeText("Congrats on winning! Keep watching or leave?")
	message.changeYesText("Leave")
	message.changeNoText("Spectate")
	message.disable_auto_Home()
	message.get_node("A").get_node("B").get_node("C").get_node("D").get_node("YesButton").connect("pressed", self, "_go_home")
	add_child(message)

func _go_home():
	url = URLs.lobby_init + LobbyDetails.id + "/leave/"
	headers = URLs.defaultHeader()
	err = $LeaveRequest.request(url, headers, false, HTTPClient.METHOD_GET)
	
func _on_LeaveRequest_request_completed(result, response_code, headers, body):
	if (response_code != 200 and response_code != 201): 
		print("error leaving")
		get_tree().change_scene("res://Home/Home.tscn")	
		return
	get_tree().change_scene("res://Home/Home.tscn")	
