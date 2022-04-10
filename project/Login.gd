extends Control

var home_scene = preload("res://Home.tscn")

var login_panel
var userfield
var usererr
var passfield
var passerr

var reg_panel
var reg_userfield
var reg_usererr
var reg_emailfield
var reg_emailerr
var reg_passfield
var reg_passerr
var reg_conffield
var reg_conferr



# Called when the node enters the scene tree for the first time.
func _ready():
	login_panel = get_node("A/B/Login")
	userfield = get_node("A/B/Login/UserBox/Username/LineEdit")
	usererr = get_node("A/B/Login/UserBox/UserError/RichTextLabel")
	passfield = get_node("A/B/Login/PassBox/Password/LineEdit")
	passerr = get_node("A/B/Login/PassBox/PassError/RichTextLabel")
	
	reg_panel = get_node("A/B/Register")
	reg_userfield = get_node("A/B/Register/UserBox/Username/LineEdit")
	reg_usererr = get_node("A/B/Register/UserBox/UserError/RichTextLabel")
	reg_passfield = get_node("A/B/Register/PassBox/Password/LineEdit")
	reg_passerr = get_node("A/B/Register/PassBox/PassError/RichTextLabel")
	reg_emailfield = get_node("A/B/Register/EmailBox/Email/LineEdit")
	reg_emailerr = get_node("A/B/Register/EmailBox/EmailError/RichTextLabel")
	reg_conffield = get_node("A/B/Register/ConfBox/Confirm/LineEdit")
	reg_conferr = get_node("A/B/Register/ConfBox/ConfError/RichTextLabel")

	usererr.text = ""
	passerr.text = ""
	reg_usererr.text = ""
	reg_passerr.text = ""
	reg_emailerr.text = ""
	reg_conferr.text = ""
	login_panel.show()
	reg_panel.hide()

func userValid(username):
	return true

func passValid(password):
	return true

func _on_Login_pressed():
	usererr.text = ""
	passerr.text = ""
	var username = userfield.text
	var password = passfield.text
	if (userValid(username) and userValid(password)):
		_login(username, password)

func _login(username, password):
	var url = URLs.login
	var headers = ['Content-Type: application/json']
	var body = {"username": username, "password": password}
	print("Attempting Login with url ", url, " with credentials: ", body)
	var err = $LoginRequest.request(url, headers, false, HTTPClient.METHOD_POST, to_json(body))
	print("Err code", err)

func _on_LoginRequest_request_completed(result, response_code, headers, body):
	print("RESPONSE:")
	print("r", result, " c", response_code, " h", headers)
	var json = JSON.parse(body.get_string_from_utf8())
	print("b", json.result)
	print()
	if(response_code == 200):
		AccountInfo.setToken(json.result["access"])
		get_tree().change_scene_to(home_scene)
	if(response_code == 401):
		usererr.text = json.result["detail"]

func _on_ToReg_pressed():
	# Test
	reg_userfield.text = userfield.text
	reg_emailfield.text = ""
	reg_passfield.text = ""
	reg_conffield.text = ""
	login_panel.hide()
	reg_panel.show()

func _on_ToLogin_pressed():
	userfield.text = reg_userfield.text
	passfield.text = ""
	reg_panel.hide()
	login_panel.show()

func _on_Register_pressed():
	var username = reg_userfield.text
	var email = reg_emailfield.text
	var password = reg_passfield.text
	var confirm = reg_conffield.text
	if(userValid(username) and passValid(password)):
		_register(username, email, password, confirm)
	

func _register(username, email, password, confirm):
	pass

func _on_RegisterRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)

# REFERENCES
### HTTPRequest and HTTPClient Documentation
### Some godot forum explaining how to do POST request
