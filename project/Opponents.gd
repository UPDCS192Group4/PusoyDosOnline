extends Container

var playerA = Array()
var playerB = Array()
var playerC = Array()
var deck = Array()

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

func _ready():	
	yield(get_parent(), "ready")
	deck = get_parent().deck

	A_ANGLE =  - A_ANG_DIST * (A_NUM_CARDS - 1) / 2
	B_ANGLE = deg2rad(270) - B_ANG_DIST * (B_NUM_CARDS - 1) / 2
	C_ANGLE =  deg2rad(180) - C_ANG_DIST * (C_NUM_CARDS - 1) / 2
	print(A_ANGLE)
	for i in range(13):
		playerA.append(deck[13+i])
		add_child(playerA[i])
		A_OVAL_VECT = Vector2(H_RAD * cos(A_ANGLE), -V_RAD * sin(A_ANGLE))
		playerA[i].rect_position = A_CENTRE + A_OVAL_VECT - playerA[i].rect_size / 2
		playerA[i].rect_rotation = 90 + ( - rad2deg(A_ANGLE)) / 4
		print(playerA[i].rank, ' ', playerA[i].suit, ' ', rad2deg(A_ANGLE), ' ', playerA[i].rect_rotation)
		A_ANGLE += A_ANG_DIST
	print('------------------')
	for i in range(13):
		playerB.append(deck[26+i])
		add_child(playerB[i])
		B_OVAL_VECT = Vector2(V_RAD * cos(B_ANGLE), -H_RAD * sin(B_ANGLE))
		playerB[i].rect_position = B_CENTRE + B_OVAL_VECT - playerB[i].rect_size / 2
		playerB[i].rect_rotation = 180 + (270 - rad2deg(B_ANGLE)) / 4
		print(playerB[i].rank, ' ', playerB[i].suit, ' ', rad2deg(B_ANGLE), ' ', playerB[i].rect_rotation)
		B_ANGLE += B_ANG_DIST
	print('------------------')
	for i in range(13):
		playerC.append(deck[39+i])
		add_child(playerC[i])
		C_OVAL_VECT = Vector2(H_RAD * cos(C_ANGLE), -V_RAD * sin(C_ANGLE))
		playerC[i].rect_position = C_CENTRE + C_OVAL_VECT - playerC[i].rect_size / 2
		playerC[i].rect_rotation = 90 - (rad2deg(C_ANGLE)-180) / 4
#		print(playerC[i].rank, ' ', playerC[i].suit, ' ', rad2deg(C_ANGLE), ' ', playerC[i].rect_rotation)
		C_ANGLE += C_ANG_DIST
