extends Control

# Runs the UI command handler for UI based keyboard shortcuts (fullscreen, etc.)
func _process(_delta):
	$UICommandHandler.menuCommandHandler()

# Starts the main game scene when the start button is pressed
func _on_StartButton_pressed():
	print(get_tree().change_scene("res://GameLoop.tscn"))

# Opens the options menu when the options button is pressed
func _on_OptionsButton_pressed():
	print(get_tree().change_scene("res://UI/OptionsMenu.tscn"))

# Quits the games when the quit button is pressed
func _on_QuitButton_pressed():
	get_tree().quit()
