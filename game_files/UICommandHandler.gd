extends Node

# Command handler for UI and menu functions
func menuCommandHandler():
	# Checks for menu related input
	if Input.is_action_just_pressed("FULLSCREEN"):
		OS.window_fullscreen = !OS.window_fullscreen
	elif Input.is_action_just_pressed("RESTART"):
		print(get_tree().reload_current_scene())
	elif Input.is_action_just_pressed("MAIN_MENU"):
		print(get_tree().change_scene("res://UI/MainMenu.tscn"))
