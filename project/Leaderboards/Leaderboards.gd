extends Control

func _ready():
	pass # Replace with function body.

func _on_Button_pressed():	
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://Home/Home.tscn")
