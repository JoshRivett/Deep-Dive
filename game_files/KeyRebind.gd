# ---------------------------------------------------------------------------------- #
# Written based on this tutorial: https://www.gotut.net/godot-key-bindings-tutorial/ #
# Last accessed on: 18/05/2020                                                       #
# ---------------------------------------------------------------------------------- #

extends Control

var can_change_key = false
var action_string
enum ACTIONS {WALK_LEFT, WALK_RIGHT, JUMP, ROLL, RESTART, FULLSCREEN, MAIN_MENU}

func _ready():
	set_keys()

func _process(_delta):
	$UICommandHandler.menuCommandHandler()

func _input(event):
	if event is InputEventKey: 
		if can_change_key:
			change_key(event)
			can_change_key = false

func set_keys():
	for i in ACTIONS:
		get_node("CenterContainer/VBoxContainer/" + str(i) + "/Button").set_pressed(false)
		if !InputMap.get_action_list(i).empty():
			get_node("CenterContainer/VBoxContainer/" + str(i) + "/Button").set_text(InputMap.get_action_list(i)[0].as_text())
		else:
			get_node("CenterContainer/VBoxContainer/" + str(i) + "/Button").set_text("No Button!")

func mark_button(string):
	can_change_key = true
	action_string = string
	
	for i in ACTIONS:
		if i != string:
			get_node("CenterContainer/VBoxContainer/" + str(i) + "/Button").set_pressed(false)

func change_key(new_key):
	#Delete key of pressed button
	if !InputMap.get_action_list(action_string).empty():
		InputMap.action_erase_event(action_string, InputMap.get_action_list(action_string)[0])
	
	#Check if new key was assigned somewhere
	for i in ACTIONS:
		if InputMap.action_has_event(i, new_key):
			InputMap.action_erase_event(i, new_key)
			
	#Add new Key
	InputMap.action_add_event(action_string, new_key)
	
	set_keys()

# -- UI Input Handling -- #
func _change_key_WALK_LEFT():
	mark_button("WALK_LEFT")

func _change_key_WALK_RIGHT():
	mark_button("WALK_RIGHT")

func _change_key_JUMP():
	mark_button("JUMP")

func _change_key_ROLL():
	mark_button("ROLL")

func _change_key_RESTART():
	mark_button("RESTART")

func _change_key_FULLSCREEN():
	mark_button("FULLSCREEN")

func _change_key_MAIN_MENU():
	mark_button("MAIN_MENU")

# -- Other -- #
# Returns back to the options menu
func _on_Back_Button_pressed():
	print(get_tree().change_scene("res://UI/OptionsMenu.tscn"))
