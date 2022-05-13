extends Node

var logged_in = false
var _profile_json = {}
var id = -1
var username = ""
var rating = -1
var country_code = "XX"
var played_games = -1
var won_games = -1
var lost_games = -1
var winstreak = -1
var friends = []
var requests = []
var friend_names = []
var request_names = []
var _token = ""

var profileRequest = HTTPRequest.new()
var requestsRequest = HTTPRequest.new()
var refreshTimer = Timer.new()

var refreshTime = 60

signal profileRequestDone(err_or_response_code)
signal requestsRequestDone(err_or_response_code)
signal refreshedInfo()

func _ready():
	add_child(profileRequest)
	add_child(requestsRequest)
	add_child(refreshTimer)
	profileRequest.connect("request_completed", self, "_get_profile_request_completed")
	requestsRequest.connect("request_completed", self, "_get_requests_request_completed")
	# refreshTimer.connect("timeout", self, "fetchInfo")
	pass

func getToken():
	return _token

func setToken(token):
	_token = token
	
func login(token):
	setToken(token)
	logged_in = true
	fetchInfo()
	refreshTimer.start(refreshTime)

func logout():
	logged_in = false
	refreshTimer.stop()
	
func updateInfo(profile_json):
	# should be the json result already
	_profile_json = profile_json
	id = profile_json.id
	username = profile_json.username
	rating = profile_json.rating
	country_code = profile_json.country_code
	played_games = profile_json.played_games
	won_games = profile_json.won_games
	lost_games = profile_json.lost_games
	winstreak = profile_json.winstreak
	friends = profile_json.friends
	friend_names = []
	for object in friends:
		friend_names.append(object.username)
	# _token = "" idk if I should touch this or nah

func updateFriendRequests(requests_json):
	var json = requests_json
	requests = json.results
	request_names = []
	for object in requests:
		request_names.append(object.from_user_name)

func fetchProfile():
	if not logged_in:
		return 0
	var url = URLs.profile
	var headers = URLs.defaultHeader()
	var err = profileRequest.request(url,headers,false,HTTPClient.METHOD_GET)
	if err != OK:
		print("GET Request to ", url, " not OK: ", err)
		emit_signal("profileRequestDone", err)
		
func fetchRequests():
	if not logged_in:
		return 0
	var url = URLs.friendrequests
	var headers = URLs.defaultHeader()
	var err = requestsRequest.request(url,headers,false,HTTPClient.METHOD_GET)
	if err != OK:
		print("GET Request to ", url, " not OK: ", err)
		emit_signal("requestsRequestDone", err)
		
func fetchInfo():
	fetchProfile()
	fetchRequests()

func _get_profile_request_completed(result,response_code,header,body):
	var response = parse_json(body.get_string_from_utf8())
	if (response_code != 200 and response_code != 201): 
		print("Rip ", response_code)
		emit_signal("profileRequestDone", response_code)
		return
	# print(response)
	# print("AutoLoad HTTPRequest success: ", response)
	updateInfo(response)
	emit_signal("profileRequestDone", OK)
	emit_signal("refreshedInfo")

func _get_requests_request_completed(result,response_code,header,body):
	var response = parse_json(body.get_string_from_utf8())
	if (response_code != 200 and response_code != 201): 
		print("Rip ", response_code)
		emit_signal("profileRequestDone", response_code)
		return
	# print(response)
	print("Friendrequests: ", response)
	updateFriendRequests(response)
	emit_signal("requestsRequestDone", OK)
	emit_signal("refreshedInfo")

