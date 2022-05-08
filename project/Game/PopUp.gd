extends Control

var autoHome = 1

func _ready():
	pass # Replace with function body.

func _on_YesButton_pressed():
	yield(get_tree().create_timer(0.5), "timeout")
	if autoHome:
		get_tree().change_scene("res://Home/Home.tscn")	
	pass # Replace with function body.

func _on_NoButton_pressed():
	queue_free()
	pass # Replace with function body.

func changeText(newText):
	get_node('A').get_node('B').get_node('C').get_node('HBoxContainer').get_node('Label').text = newText

func disable_auto_Home():
	autoHome = 0
