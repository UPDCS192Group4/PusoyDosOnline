extends Control
var deck = Array()
var cardScene = preload("res://Game/Card.tscn")
var scene1 = preload("res://Game/Hand.tscn")
var scene2 = preload("res://Game/Pile.tscn")
var scene3 = preload("res://Game/Opponents.tscn")
var newCard
var pressedArray = Array()

var url
var headers

var t = 0
var t_rate = 1000

var temprank
var tempsuit

func _ready():
	$HandRequest.connect("request_completed", self, "_on_HandRequest_request_completed")
	$PingRequest.connect("request_completed", self, "_on_PingRequest_request_completed")
	$PlayRequest.connect("request_completed", self, "_on_PlayRequest_request_completed")
	request_hand()
	var child2 = scene2.instance()
	add_child(child2)
	#var child3 = scene3.instance()
	#child3.set_name("Opponents")
	#add_child(child3)
	disablePlayButton()

func _process(_delta):
	t += 1
	if t > t_rate:
		_ping_server()	
		t -= t_rate

func request_hand():
	url = URLs.game_ping + GameDetails.game_id
	headers = URLs.defaultHeader()
	$HandRequest.request(url, headers, false, HTTPClient.METHOD_GET)
	pass

func _on_HandRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print("RESULT FROM Game")
	for i in json.result:
		print(i, " : ", json.result[i])
	for i in range(len(json.result["hands"])):
		var user = json.result["hands"][i]
		GameDetails.gamers[user["move_order"]] = user["user"]
		if user["user"] == AccountInfo.username:
			GameDetails.my_move_order = user["move_order"]
			for j in user["hand"]:
				if j == 1:
					GameDetails.needs_3_of_clubs = 1
				GameDetails.hand.append(j)
	var child1 = scene1.instance()
	add_child(child1)
	print("Move details:")
	for key in GameDetails.gamers:
		print(key, " : ", GameDetails.gamers[key])
	pass
	
func _ping_server():
	print("Pinging")
	url = URLs.game_ping + GameDetails.game_id
	headers = URLs.defaultHeader()
	$PingRequest.request(url, headers, false, HTTPClient.METHOD_GET)
	
func _on_PingRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())	
	for i in json.result:
		print(i, " : ", json.result[i])
	GameDetails.current_player = json.result["current_round"]
	#GameDetails.topOfPile = json.result["last_play"]
	$Pile.updatePile(json.result["last_play"])
	if GameDetails.current_player == GameDetails.my_move_order:
		GameDetails.is_current_player = 1
		print('yey')
		if int(json.result["control"]) >= 4:
			GameDetails.is_control = 1
		else:
			GameDetails.is_control = 0
		ready_to_move()
		return
	GameDetails.is_current_player = 0
	pass
	
func ready_to_move():
	pass
	
func _on_PlayButton_pressed():
	get_node('Hand').playHand()
	pressedArray.clear()
	
func playCards(url,headers,postArray):
	print('---------------------')
	$PlayRequest.request(url,headers,false, HTTPClient.METHOD_POST, to_json({"play":postArray}))
	
func _on_PlayRequest_request_completed(result, response_code, headers, body):
	print('---------------------, r: ', response_code)
	if response_code == 200 or response_code == 201:
		$Hand.updateHand()
		if GameDetails.needs_3_of_clubs:
			GameDetails.needs_3_of_clubs = 0
	pass

func _on_HomeButton_pressed():
	var scene1 = load("res://Game/PopUp.tscn")
	var child1 = scene1.instance()
	get_node('CanvasLayer').add_child(child1)
	pass

func addPressedCard(newRank, newSuit):
	var temp = Array()
	temp.append(newRank)
	temp.append(newSuit)
	pressedArray.append(temp)
	print('hmph')
	checkArray(pressedArray)
	
func removePressedCard(newRank, newSuit):
	var temp = Array()
	temp.append(newRank)
	temp.append(newSuit)
	var k = pressedArray.find(temp)
	pressedArray.remove(k)
	checkArray(pressedArray)

func enablePlayButton():
	get_node("PlayButton").text = 'PLAY'
	get_node("PlayButton").disabled = false
	
func disablePlayButton():
	get_node("PlayButton").text = "NOPE"
	get_node("PlayButton").disabled = true

func checkArray(inputArray):
	GameDetails.needs_3_of_clubs = 0
	print('a')
	if GameDetails.needs_3_of_clubs:
		if !([1,1] in inputArray):
			disablePlayButton()
			return
		enablePlayButton()
	print('b')
	if GameDetails.is_control == 1:
		enablePlayButton()
		return
	print('c')
	if !GameDetails.is_current_player:
		disablePlayButton()
		return
	print('d')
			
	var topOfPileRaw = GameDetails.last_pile
	var topOfPile = Array()
	for i in topOfPileRaw:
		temprank = i % 100
		tempsuit = i / 100 + 1
		topOfPile.append([temprank,tempsuit])
	print("TOP IS ", topOfPile)
	topOfPile = classifyArray(topOfPile)
	inputArray = classifyArray(inputArray)
	#print('log ',topOfPile,inputArray)
	if topOfPile[0] == 0 and inputArray[0] !=0:
		enablePlayButton()
		return
	elif topOfPile[0] == 0 and inputArray[0] == 0:
		disablePlayButton()
		return
	if topOfPile[0] != inputArray[0]:
		disablePlayButton()
		return
		
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
		returnArray.append(0)
	if array.size() == 1:
		# For array of length 1, quantifiers are rank, suit, in that order.
		returnArray.append(1)
		returnArray.append(array[0][0])
		returnArray.append(array[0][1])
	elif array.size() == 2:
		if array[0][0] != array[1][0]:
			returnArray.append(0)
		else:
			# For array of length 2, quantifiers are rank, suit, in that order.
			returnArray.append(2)
			returnArray.append(array[0][0])
			returnArray.append(max(array[0][1],array[1][1]))
	elif array.size() == 3:
		if max(array[0][0],max(array[1][0],array[2][0])) != \
			min(array[0][0],min(array[1][0],array[2][0])):
			returnArray.append(0)
		else:
			returnArray.append(3)
			returnArray.append(array[0][0])
	elif array.size() == 4:
		returnArray.append(0)
	elif array.size() == 5:
		var rankArray = Array()
		for i in range(5):
			rankArray.append(array[i][0])
		rankArray.sort()
		print('rank array', rankArray)
		#flush
		if array[0][1] == array[1][1] and array[1][1] == array[2][1] \
			and array[2][1] == array[3][1] and array[3][1] == array[4][1]:
				if rankArray[0]+1 == rankArray[1] and rankArray[1]+1 == rankArray[2] \
				and rankArray[2]+1 == rankArray[3] and rankArray[3]+1 == rankArray[4]:
					print('straight flush/royal flush')
					returnArray.append(5)
					returnArray.append(5)
					returnArray.append(array[0][1])
					returnArray.append(rankArray[4])
				else:
					print('flush')
					returnArray.append(5)
					returnArray.append(2)
					returnArray.append(array[0][1])
					returnArray.append(rankArray[4])
		#straight
		elif rankArray[0]+1 == rankArray[1] and rankArray[1]+1 == rankArray[2] \
			and rankArray[2]+1 == rankArray[3] and rankArray[3]+1 == rankArray[4]:
				print('straight')
				returnArray.append(5)
				returnArray.append(1)
				returnArray.append(rankArray[4])
				for i in range(5):
					if array[i][0] == rankArray[4]:
						returnArray.append(array[i][1])
						break
		#four of a kind
		elif (rankArray[0] == rankArray[1] and rankArray[1] == rankArray[2] \
			and rankArray[2] == rankArray[3]) or (rankArray[1] == rankArray[2] \
			and rankArray[2] == rankArray[3] and rankArray[3] == rankArray[4]):
				print('four of a kind')
				returnArray.append(5)
				returnArray.append(4)
				returnArray.append(rankArray[2])
		#full house
		elif (rankArray[0] == rankArray[1] and rankArray[2] == rankArray[3] \
			and rankArray[3] == rankArray[4]) or (rankArray[0] == rankArray[1] \
			and rankArray[1] == rankArray[2] 	and rankArray[3] == rankArray[4]):
				print('full house')
				returnArray.append(5)
				returnArray.append(3)
				returnArray.append(rankArray[2])
		else:
			returnArray.append(0)
	else:
		returnArray.append(0)
	return returnArray

func customSort(a,b):
	# Catch faulty inputs by first comparing size:
	if a.size() != b.size():
		print('Arrays are not of the same size.')
		return false
		
	#Checks if the values of a are at least the values in b.
	for i in range(a.size()):
		if a[i] < b[i]:
			return false
		elif a[i] == b[i]:
			pass
		elif a[i] > b[i]:
			return  true
