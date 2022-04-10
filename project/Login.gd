extends Control


var userfield
var usererr
var passfield
var passerr

# Called when the node enters the scene tree for the first time.
func _ready():
	userfield = get_node("A/B/Login/UserBox/Username/LineEdit")
	usererr = get_node("A/B/Login/UserBox/UserError/RichTextLabel")
	passfield = get_node("A/B/Login/PassBox/Password/LineEdit")
	passerr = get_node("A/B/Login/PassBox/PassError/RichTextLabel")

	usererr.text = ""
	passerr.text = ""

func userValid(username):
	return true

func passValid(password):
	return true

func _on_Login_pressed():
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

func _on_ToReg_pressed():
	# Test
	$RegisterRequest.request("http://www.mocky.io/v2/5185415ba171ea3a00704eed")
	
func _on_RegisterRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)
