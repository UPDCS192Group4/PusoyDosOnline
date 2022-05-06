extends Control

func _ready():
	pass # Replace with function body.

func _on_YesButton_pressed():
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://Home/Home.tscn")	
	pass # Replace with function body.

func _on_NoButton_pressed():
	queue_free()
	pass # Replace with function body.

func changeText(newText):
	get_node('CenterContainer').get_node('Panel').get_node('VBoxContainer').get_node('HBoxContainer').get_node('Label').text = newText
