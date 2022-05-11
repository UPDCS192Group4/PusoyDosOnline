extends Node

#var url = "http://localhost:8000" # modify upon deployment
#var url = "http://642f-2001-4451-6b8-9500-38fd-82a4-400a-338b.ngrok.io"
#var url = "http://1cc0-2001-4451-6b8-9500-38fd-82a4-400a-338b.ngrok.io"
var url = "http://07a7-136-158-0-18.ngrok.io"
var register = url + "/api/register/"
var login = url + "/api/token/"
var profile = url + "/api/users/profile/"
var leaderboards = url + "/api/users/leaderboard"
var removefriend = url + "/api/users/remove_friend/"
var lobby_init = url + "/api/lobby/casual/"
var friendrequests = url + "/api/friendrequest/"
var game_ping = url + "/api/games/"

var access
var refresh

func _ready():
	pass 
	
func defaultHeader():
	return ['Content-Type: application/json', 'Authorization: Bearer ' + access]

func getAcceptURL(username):
	return friendrequests + username + "/accept/"
	
func getRejectURL(username):
	return friendrequests + username + "/reject/"
	
func getRemoveFriendURL(username):
	return removefriend + username + "/"

func getAddFriendURL(username = ""):
	return friendrequests
