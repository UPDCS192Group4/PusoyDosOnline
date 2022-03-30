extends Control
var deck = Array()
var cardScene = preload("res://Card.tscn")
var newCard
var pressedArray = Array()

var ws = Websocket.getSocket()

func _ready():
	ws = Websocket.getSocket()
	# ws.connect("connection_closed", self, "_connection_failed")
	# ws.connect("connection_error", self, "_connection_failed")
	# ws.connect("connection_established", self, "_connection_success")
	ws.connect("data_received", self, "_on_data_received")

func _process(delta):
	ws.poll()
	
func loadGame():
	var scene1 = load("res://Hand.tscn")
	var child1 = scene1.instance()
	add_child(child1)
	var scene2 = load("res://Pile.tscn")
	var child2 = scene2.instance()
	add_child(child2)
	var scene3 = load("res://Opponents.tscn")
	var child3 = scene3.instance()
	child3.set_name("Opponents")
	add_child(child3)
	shuffleDeck()
	emit_signal("ready")
	#what is this
	#Label.visible = false

func shuffleDeck():
#	for i in range(1,5):
#		for j in range(1,14):
#			newCard = cardScene.instance()
#			newCard.init(i,j,0)
#			deck.append(newCard)
	
	# Uncomment to show that straight works:
	for i in range(1,14):
		for j in range(1,5):
			newCard = cardScene.instance()
			newCard.init(i,j,0)
			deck.append(newCard)
	randomize()
	
	# Uncomment to show that flush works:
	#deck.shuffle()
	
func _on_PlayButton_pressed():
	get_node('Hand').updateHand()
	pressedArray.clear()

func _on_HomeButton_pressed():
	var scene1 = load("res://PopUp.tscn")
	var child1 = scene1.instance()
	get_parent().add_child(child1)
	pass

func addPressedCard(newRank, newSuit):
	var temp = Array()
	temp.append(newRank)
	temp.append(newSuit)
	pressedArray.append(temp)
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
	var topOfPile = get_node('Pile').getTopOfPile()
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

func _on_data_received():
	print("receiving data...")
	var data = ws.get_peer(1).get_packet().get_string_from_utf8()
	var msg = data.split(" ")
	print(msg)
	match(msg[0]):
		"hand":
			var hand_string = msg[1].split(",")
			print("received hand from server: ", hand_string)
			for card in hand_string:
				var card_split = card.split("-")
				var suit = int(card_split[0])
				var value = int(card_split[1])
				newCard = cardScene.instance()
				newCard.init(suit, value)
				hand.append(newCard)
			self.loadGame()
		"play":
			var newPile=msg[2].split(",")
			var suits = Array()
			var ranks = Array()
			var tempString
			for i in newPile:
				tempString = i.split("-")
				suits.append(int(tempString[0]))
				ranks.append(int(tempString[1]))
			print(ranks,suits)
			print(msg[2])
			get_node("Pile").updatePile(ranks,suits)
	
