extends "res://LivingEntities/LivingEntity.gd"

# -- Player Prop Signals -- #
signal landed	# Emitted once the prop has stood up after impact

# -- Player Prop Variables -- #
var grounded = false	# Whether or not the prop has hit the ground yet
var passedIntro = false	# Whether or not the prop has passed the intro sequence

# -- Sound Effects -- #
var slamSound = load("res://Assets/Audio/Slam.wav")

# Initialises the prop's horitontal motion
func _ready():
	invulnerable = true
	motion.x = 2000

# Runs the main logic of the prop
func _physics_process(_delta):
	# Applies gravity and motion to the prop
	motion.y += GRAVITY
	motion = move_and_slide(motion, UP)
	
	# Checks if the prop has hit the ground for the first time and applies screenshake if so
	if is_on_floor():
		if grounded == false:
			$AudioStreamPlayer.stream = slamSound
			$AudioStreamPlayer.play()
			$AnimatedSprite.play("landed")
			$ShakeCamera.add_trauma(0.8)
			grounded = true
			
		# Applies friction to the prop and then destroys it once it stops completely
		if motion.x > 0:
			motion.x -= 50
		elif passedIntro == false:
			$AnimatedSprite.play("getUp")
			passedIntro = true
	else:
		grounded = false

# After the prop has finished standing, it switches places with the player controller
func _on_animation_finished():
	if $AnimatedSprite.animation == "getUp":
		emit_signal("landed", global_position)
		$AnimatedSprite.visible = false

# After leaving the boss arena, the player controller and prop are switched back around
func _on_CameraFlag_body_entered(player):
	if player.name == "PlayerController":
		global_position = player.global_position
		$AnimatedSprite.flip_h = player.direction == -1
		$AnimatedSprite.play("falling")
		$AnimatedSprite.visible = true
		$ShakeCamera.current = true
