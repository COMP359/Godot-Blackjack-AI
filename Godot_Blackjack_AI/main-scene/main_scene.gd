extends Control

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://gameplay-scene/game.tscn")

func _on_options_pressed():
	pass # Replace with function body.

func _on_close_game_pressed():
	get_tree().quit()
