extends Node

# Command handler for player functions
func playerCommandHandler():
	# Runs the player controller logic
	$PlayerController.playerController()
	
	# Checks for shoot input
	if Input.is_action_pressed("SHOOT"):
		$PlayerController.shoot()
	
	# Checks for roll or jump input
	if Input.is_action_just_pressed("ROLL"):
		$PlayerController.roll()
	elif Input.is_action_just_pressed("JUMP"):
		$PlayerController.jump()
	
	# Checks for movement input
	if Input.is_action_pressed("WALK_LEFT") and not Input.is_action_pressed("WALK_RIGHT"):
		$PlayerController.moveLeft()
	elif Input.is_action_pressed("WALK_RIGHT") and not Input.is_action_pressed("WALK_LEFT"):
		$PlayerController.moveRight()
	else:
		$PlayerController.stopMovement();
