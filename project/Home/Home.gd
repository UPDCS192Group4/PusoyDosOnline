extends Control

func _ready():
	pass

func _on_PlayButton_pressed():
	yield(get_tree().create_timer(0.5), "timeout")
	openLobbyHandler()
	pass # Replace with function body.
		
func _on_LeaderboardsButton_pressed():
	yield(get_tree().create_timer(0.5), "timeout")
	showLeaderboards()
	
func openLobbyHandler():
	get_tree().change_scene("res://Lobby/Lobby.tscn")
	
func startNewGame():
	get_tree().change_scene("res://Game/Game.tscn")

func showLeaderboards():
	get_tree().change_scene("res://Leaderboards/Leaderboards.tscn")
