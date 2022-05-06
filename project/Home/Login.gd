extends Control

var home_scene = preload("res://Home/Home.tscn")

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
var reg_err_map

var buttons = []

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
	reg_err_map = {
		"username": reg_usererr,
		"email": reg_emailerr,
		"password": reg_passerr,
		"password_check": reg_conferr
	}

	buttons.append(get_node("A/B/Login/Buttons/ToReg"))
	buttons.append(get_node("A/B/Login/Buttons/Login"))
	buttons.append(get_node("A/B/Register/Buttons/ToLogin"))
	buttons.append(get_node("A/B/Register/Buttons/Register"))

	usererr.text = ""
	passerr.text = ""
	reg_usererr.text = ""
	reg_passerr.text = ""
	reg_emailerr.text = ""
	reg_conferr.text = "Confirm Password"
	login_panel.show()
	reg_panel.hide()

func userValid(username):
	return true

func passValid(password):
	return true

func _disable_buttons():
	for button in buttons:
		button.disabled = true
		
func _enable_buttons():
	for button in buttons:
		button.disabled = false

func _clear_login_err():
	usererr.text = ""
	usererr.add_color_override("default_color", Color(1, 0, 0))
	passerr.text = ""
	
func _clear_reg_err():
	reg_usererr.text = ""
	reg_emailerr.text = ""
	reg_passerr.text = ""
	reg_conferr.text = "Confirm Password"
	reg_conferr.add_color_override("default_color", Color(100.0/255, 100.0/255, 100.0/255))

func _on_Login_pressed():
	_disable_buttons()
	_clear_login_err()
	var username = userfield.text
	var password = passfield.text
	if (userValid(username) and userValid(password)):
		_login(username, password)
		
func _on_Register_pressed():
	_disable_buttons()
	_clear_reg_err()
	var username = reg_userfield.text
	var email = reg_emailfield.text
	var password = reg_passfield.text
	var confirm = reg_conffield.text
	if(userValid(username) and passValid(password)):
		_register(username, email, password, confirm)

func _login(username, password):
	var url = URLs.login
	var headers = ['Content-Type: application/json']
	var body = {"username": username, "password": password}
	print("Attempting Login with url ", url, " with credentials: ", body)
	var err = $LoginRequest.request(url, headers, false, HTTPClient.METHOD_POST, to_json(body))
	print("Err code", err)
	
func _register(username, email, password, confirm):
	var url = URLs.register
	var headers = ['Content-Type: application/json']
	var body = {"username": username, "email": email, "password": password, "password_check": confirm}
	print("Attempting Register with url ", url, " with credentials: ", body)
	var err = $RegisterRequest.request(url, headers, false, HTTPClient.METHOD_POST, to_json(body))
	print("Err code", err)

func _on_LoginRequest_request_completed(result, response_code, headers, body):
	print("RESPONSE:")
	print("r", result, " c", response_code, " h", headers)
	var json = JSON.parse(body.get_string_from_utf8())
	print("b", json.result)
	print()
	#might have to move this inside if response_code == 200
	URLs.access = json.result["access"]
	URLs.refresh = json.result["refresh"]
	if(response_code == 200):
		AccountInfo.setToken(json.result["access"])
		get_tree().change_scene_to(home_scene)
	if(response_code == 400):
		if("username" in json.result.keys()):
			usererr.text = json.result["username"][0]
		if("password" in json.result.keys()):
			passerr.text = json.result["password"][0]
	if(response_code == 401):
		usererr.text = json.result["detail"]
	_enable_buttons()
	
func _on_RegisterRequest_request_completed(result, response_code, headers, body):
	print("RESPONSE:")
	print("r", result, " c", response_code, " h", headers)
	var json = JSON.parse(body.get_string_from_utf8())
	print("b", json.result)
	print()
	if(response_code in [200, 201]):
		_clear_reg_err()
		var username = json.result["username"]
		userfield.text = username
		usererr.add_color_override("default_color", Color(0, 255, 0))
		usererr.text = "Registration Successful!"
		reg_panel.hide()
		login_panel.show()
	if(response_code in [400, 401]):
		for key in json.result.keys():
			reg_err_map[key].text = json.result[key][0]
			if (key == "password_check"):
				reg_conferr.add_color_override("default_color", Color(1,0,0))
	_enable_buttons()
	
func _on_ToReg_pressed():
	# Test
	_clear_login_err()
	reg_userfield.text = userfield.text
	reg_emailfield.text = ""
	reg_passfield.text = ""
	reg_conffield.text = ""
	login_panel.hide()
	reg_panel.show()

func _on_ToLogin_pressed():
	_clear_reg_err()
	userfield.text = reg_userfield.text
	passfield.text = ""
	reg_panel.hide()
	login_panel.show()

# REFERENCES
### Godot HTTPRequest and HTTPClient Documentation
### Godot Control Documentation
### Basta Godot Documentation
### Some godot forum explaining how to do POST request
