extends Control

func _process(_delta):
	$UICommandHandler.menuCommandHandler()
	$CenterContainer/VBoxContainer/Fullscreen/Button.pressed = OS.window_fullscreen

# Toggles whether the game is in fullscreen mode or not
func _on_Fullscreen_pressed():
	OS.window_fullscreen = !OS.window_fullscreen

# Opens the controls menu for key rebinding
func _on_Controls_pressed():
	print(get_tree().change_scene("res://UI/KeyRebindMenu.tscn"))

# Returns back to the main menu screen
func _on_Back_pressed():
	print(get_tree().change_scene("res://UI/MainMenu.tscn"))
