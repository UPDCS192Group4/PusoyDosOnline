extends Control

var playerA = Array()
var playerB = Array()
var playerC = Array()
var deck = Array()
var cardScene = preload("res://Game/Card.tscn")
var newCard

var A_CENTRE = Vector2(-200,400)
var B_CENTRE = Vector2(512,-200)
var C_CENTRE = Vector2(1224,400)
var H_RAD = 300
var V_RAD = 400
var A_ANGLE
var B_ANGLE
var C_ANGLE
var A_ANG_DIST = 0.07
var B_ANG_DIST = 0.07
var C_ANG_DIST = 0.07
var A_OVAL_VECT = Vector2()
var B_OVAL_VECT = Vector2()
var C_OVAL_VECT = Vector2()

var A_NUM_CARDS = 13
var B_NUM_CARDS = 13
var C_NUM_CARDS = 13

var map_players = {}
var names = {}
var hand_counts = {}

func printdict(dict):
	for i in dict:
		print(i, " : ", dict[i])
		
func _ready():	
	$A/A_Sprite.hide()
	$B/B_Sprite.hide()
	$C/C_Sprite.hide()
	$Self.hide()
	for i in range(1,5):
		for j in range(1,14):
			newCard = cardScene.instance()
			newCard.init(i,j,0)
			deck.append(newCard)

	A_ANGLE =  - A_ANG_DIST * (A_NUM_CARDS - 1) / 2
	B_ANGLE = deg2rad(270) - B_ANG_DIST * (B_NUM_CARDS - 1) / 2
	C_ANGLE =  deg2rad(180) - C_ANG_DIST * (C_NUM_CARDS - 1) / 2
	#print(A_ANGLE)
	for i in range(13):
		playerA.append(deck[13+i])
		add_child(playerA[i])
		A_OVAL_VECT = Vector2(H_RAD * cos(A_ANGLE), -V_RAD * sin(A_ANGLE))
		playerA[i].rect_position = A_CENTRE + A_OVAL_VECT - playerA[i].rect_size / 2
		playerA[i].rect_rotation = 90 + ( - rad2deg(A_ANGLE)) / 4
		#print(playerA[i].rank, ' ', playerA[i].suit, ' ', rad2deg(A_ANGLE), ' ', playerA[i].rect_rotation)
		A_ANGLE += A_ANG_DIST
	#print('------------------')
	for i in range(13):
		playerB.append(deck[26+i])
		add_child(playerB[i])
		B_OVAL_VECT = Vector2(V_RAD * cos(B_ANGLE), -H_RAD * sin(B_ANGLE))
		playerB[i].rect_position = B_CENTRE + B_OVAL_VECT - playerB[i].rect_size / 2
		playerB[i].rect_rotation = 180 + (270 - rad2deg(B_ANGLE)) / 4
		#print(playerB[i].rank, ' ', playerB[i].suit, ' ', rad2deg(B_ANGLE), ' ', playerB[i].rect_rotation)
		B_ANGLE += B_ANG_DIST
	#print('------------------')
	for i in range(13):
		playerC.append(deck[39+i])
		add_child(playerC[i])
		C_OVAL_VECT = Vector2(H_RAD * cos(C_ANGLE), -V_RAD * sin(C_ANGLE))
		playerC[i].rect_position = C_CENTRE + C_OVAL_VECT - playerC[i].rect_size / 2
		playerC[i].rect_rotation = 90 - (rad2deg(C_ANGLE)-180) / 4
#		print(playerC[i].rank, ' ', playerC[i].suit, ' ', rad2deg(C_ANGLE), ' ', playerC[i].rect_rotation)
		C_ANGLE += C_ANG_DIST

	map_players[(GameDetails.my_move_order+1)%4] = 'C'
	names[(GameDetails.my_move_order+1)%4] = GameDetails.gamers[(GameDetails.my_move_order+1)%4]
	hand_counts[(GameDetails.my_move_order+1)%4] = 13
	
	map_players[(GameDetails.my_move_order+2)%4] = 'B'
	names[(GameDetails.my_move_order+2)%4] = GameDetails.gamers[(GameDetails.my_move_order+2)%4]
	hand_counts[(GameDetails.my_move_order+2)%4] = 13
	
	map_players[(GameDetails.my_move_order+3)%4] = 'A'
	names[(GameDetails.my_move_order+3)%4] = GameDetails.gamers[(GameDetails.my_move_order+3)%4]
	hand_counts[(GameDetails.my_move_order+3)%4] = 13
	printdict(map_players)
	printdict(names)
	for key in map_players:
		if map_players[key] == 'A':
			$A/A_Label.text = names[key]
		if map_players[key] == 'B':
			$B/B_Label.text = names[key]
		if map_players[key] == 'C':
			$C/C_Label.text = names[key]
	
func check_updates(inputDict, currentPlayer):
	for key in hand_counts:
		if hand_counts[key] > inputDict[key]:
			update_opponents(key,hand_counts[key]-inputDict[key])
			hand_counts[key] = inputDict[key]
	$Self.hide()
	$A/A_Sprite.hide()
	$B/B_Sprite.hide()
	$C/C_Sprite.hide()
	if currentPlayer == GameDetails.my_move_order:
		$Self.show()
	elif map_players[currentPlayer] == 'A':
		$A/A_Sprite.show()
	elif map_players[currentPlayer] == 'B':
		$B/B_Sprite.show()
	elif map_players[currentPlayer] == 'C':
		$C/C_Sprite.show()
		
	
func update_opponents(move_order, numRemoved):
	if map_players[move_order] == 'A':
		A_updateHand(numRemoved)
		return
	if map_players[move_order] == 'B':
		B_updateHand(numRemoved)
		return
	if map_players[move_order] == 'C':
		C_updateHand(numRemoved)
		return

func A_updateHand(numRemoved):
	for i in range(numRemoved):			
		var k = playerA[0]
		playerA.remove(0)
		k.queue_free()
		A_NUM_CARDS -= 1
		
	A_ANGLE =  - A_ANG_DIST * (A_NUM_CARDS - 1) / 2
	for i in range(A_NUM_CARDS):
		A_OVAL_VECT = Vector2(H_RAD * cos(A_ANGLE), -V_RAD * sin(A_ANGLE))
		playerA[i].rect_position = A_CENTRE + A_OVAL_VECT - playerA[i].rect_size / 2
		playerA[i].rect_rotation = 90 + ( - rad2deg(A_ANGLE)) / 4
		A_ANGLE += A_ANG_DIST

func B_updateHand(numRemoved):
	for i in range(numRemoved):			
		var k = playerB[0]
		playerB.remove(0)
		k.queue_free()
		B_NUM_CARDS -= 1
		
	B_ANGLE = deg2rad(270) - B_ANG_DIST * (B_NUM_CARDS - 1) / 2
	for i in range(B_NUM_CARDS):
		B_OVAL_VECT = Vector2(V_RAD * cos(B_ANGLE), -H_RAD * sin(B_ANGLE))
		playerB[i].rect_position = B_CENTRE + B_OVAL_VECT - playerB[i].rect_size / 2
		playerB[i].rect_rotation = 180 + (270 - rad2deg(B_ANGLE)) / 4
		B_ANGLE += B_ANG_DIST

func C_updateHand(numRemoved):
	for i in range(numRemoved):			
		var k = playerC[0]
		playerC.remove(0)
		k.queue_free()
		C_NUM_CARDS -= 1
		
	C_ANGLE =  deg2rad(180) - C_ANG_DIST * (C_NUM_CARDS - 1) / 2
	for i in range(C_NUM_CARDS):
		C_OVAL_VECT = Vector2(H_RAD * cos(C_ANGLE), -V_RAD * sin(C_ANGLE))
		playerC[i].rect_position = C_CENTRE + C_OVAL_VECT - playerC[i].rect_size / 2
		playerC[i].rect_rotation = 90 - (rad2deg(C_ANGLE)-180) / 4
		C_ANGLE += C_ANG_DIST
