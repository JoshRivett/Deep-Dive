extends Node

# -- Main game loop -- #
# Processes all the of game's logic
func _physics_process(_delta):
	$UICommandHandler.menuCommandHandler()
	$PlayerCommandHandler.playerCommandHandler()

# Creates and initialises a bullet within the scene
func _on_shoot(bullet, position, direction):
	var b = bullet.instance()		# Instances the bullet type
	call_deferred("add_child", b)	# Queues up adding the bullet to the scene
	b.start(position, direction)	# Initialises the bullet

# Switches to the next level scene
func _on_EndLevelFlag_body_entered(_body):
	print(get_tree().change_scene("res://UI/EndScene.tscn"))
