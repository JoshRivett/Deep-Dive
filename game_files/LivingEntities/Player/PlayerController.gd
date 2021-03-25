extends "res://LivingEntities/LivingEntity.gd"

# -- Player Signals -- #
signal shoot	# Emitted whenever the player shoots

# -- Player Properties -- #
const SPEED = 800				# Horizontal movement speed
const ROLL_SPEED = 1200			# Horizontal roll speed
const JUMP_HEIGHT = -3000		# Vertical distance travelled per jump
const GUN_COOLDOWN = 0.4		# The minimum time between the player's shots
export (PackedScene) var Bullet	# The type of bullet the player will shoot

# -- Player Variables -- #
var direction = 1		# Direction the player is facing (left = -1, right = 1)
var armDirection		# Direction of the player's arm in degrees
var shooting = false	# Whether the player is currently shooting or not
var rolling = false		# Whether the player is currently rolling or not
var knockback = false	# Whether the player is currently experience knockback or not

# -- Sound Effects -- #
var jumpSound = load("res://Assets/Audio/Jump.wav")
var landSound = load("res://Assets/Audio/Land.wav")
var shootSound = load("res://Assets/Audio/Laser_Shoot.wav")

# Initialises the player at the start of the scene
func _ready():
	# Initialises the players health and updates the HUD
	health = maxHealth
	emit_signal('health_changed', health * 100 / maxHealth)
	
	# Hides the player for the intro sequence
	$PlayerAnimation.visible = false
	$PlayerArm.visible = false
	
	# Sets the gun's rate of fire
	$GunCooldown.wait_time = GUN_COOLDOWN

# Main controller for the player's logic
func playerController():
	_playerPhysics()
	_aimArm()
	if not is_on_floor() and not rolling and not knockback and not dead:
		$PlayerAnimation.play("jump")
	if knockback and is_on_floor():
		motion.x = 0
		knockback = false
		invulnerable = false
		$PlayerArm.visible = true

# -- Player Intro Sequence Functions -- #
# Places and displays the player at the end of the intro sequence
func _on_PlayerProp_landed(position):
	global_position = position
	$ShakeCamera.current = true
	$PlayerAnimation.visible = true
	$PlayerArm.visible = true

# -- Player Movement and Physics Functions -- #
# Makes the player run to the left
func moveLeft():
	if not(rolling) and not(knockback) and not dead:
		motion.x = -SPEED
		direction = -1
		$PlayerAnimation.flip_h = true
		if is_on_floor():
			$PlayerAnimation.play("run")

# Makes the player run to the right
func moveRight():
	if not(rolling) and not(knockback) and not dead:
		motion.x = SPEED
		direction = 1
		$PlayerAnimation.flip_h = false
		if is_on_floor():
			$PlayerAnimation.play("run")

# Stops the player's motion
func stopMovement():
	if not(rolling) and not(knockback) and not dead:
		motion.x = 0
		if is_on_floor():
			$PlayerAnimation.play("idle")

# Makes the player jump
func jump():
	if is_on_floor() and not rolling and not knockback and not dead:
		motion.y = JUMP_HEIGHT
		$AudioStreamPlayer.stream = jumpSound
		$AudioStreamPlayer.play()

# Makes the player roll
func roll():
	if is_on_floor() and not knockback and not dead:
		rolling = true
		invulnerable = true
		motion.x = direction * ROLL_SPEED
		$PlayerCollision.disabled = true
		$RollCollision.disabled = false
		$PlayerArm.hide()
		$PlayerAnimation.play("roll")

# Resets the player to normal after rolling
func _on_roll_finished():
	if rolling:
		_stopRoll()

# Stops the player's roll state
func _stopRoll():
	rolling = false
	invulnerable = false
	$PlayerCollision.disabled = false
	$RollCollision.disabled = true
	$PlayerArm.show()
	$PlayerAnimation.play("idle")

# Handles player physics, such as gravity and motion
func _playerPhysics():
	motion.y += GRAVITY						# Applies gravity to the player
	motion = move_and_slide(motion, UP)		# Applies motion to the player

# -- Player Shooting Functions -- #
# Gets the direction the player's arm is pointing at
func _getArmDirection():
	armDirection = $PlayerArm.rotation_degrees
	
	# Changes rotation_degrees to be the actual direction instead of total rotation
	# There might be a better, built-in way of doing this
	if armDirection < 0:
		armDirection += 360
	elif armDirection > 360:
		armDirection -= 360
	$PlayerArm.rotation_degrees = armDirection

# Aims the player's arm at the mouse pointer
func _aimArm():
	$PlayerArm.look_at(get_global_mouse_position())
	_getArmDirection()
	
	if direction == 1:
		$PlayerArm.flip_v = false
		$PlayerArm/ArmBackground.flip_v = false
	else:
		$PlayerArm.flip_v = true
		$PlayerArm/ArmBackground.flip_v = true
	
	#if armDirection >= 270 or armDirection < 90:
	#	$PlayerArm.flip_v = false
	#elif armDirection >= 90 and armDirection < 270:
	#	$PlayerArm.flip_v = true
	#print(armDirection)

# Makes the player shoot
func shoot():
	if not shooting and not rolling and not dead:
		shooting = true
		$GunCooldown.start()
		$PlayerArm.play("shoot")
		$PlayerArm/ArmBackground.play("shoot")
		$AudioStreamPlayer.stream = shootSound
		$AudioStreamPlayer.play()
		var dir = Vector2(1, 0).rotated($PlayerArm.global_rotation)					# Gets the direction to shoot the bullet
		emit_signal("shoot", Bullet, $PlayerArm/Position2D.global_position, dir)	# Tells the command handler to create a bullet instance

# Stops the player's shoot state
func _stopShoot():
	$PlayerArm.play("idle")
	$PlayerArm/ArmBackground.play("idle")

# Disables the player's shooting state after the gun cooldown times out
func _on_GunCooldown_timeout():
	shooting = false

# Resets the player's arm to normal after shooting
func _on_shoot_finished():
	if shooting:
		_stopShoot()

# -- Player Damage and Death Functions -- #
# Applies knockback to the player in the given direction and force
func applyKnockback(dir, force):
	if knockback == false and not rolling and not dead:
		knockback = true
		invulnerable = true
		motion.x = force * dir
		motion.y = -force * 2
		$PlayerAnimation.play("knockback")
		$PlayerArm.visible = false

# Resets the level when the player dies (TODO: Add checkpoints)
func killSelf():
	dead = true
	motion.x = 0
	$DeathTimer.start()
	$PlayerAnimation.play("death")
	$PlayerArm.visible = false

func _on_DeathTimer_timeout():
	print(get_tree().reload_current_scene())

# -- Player Camera Functions -- #
# Resets the camera back to the player after defeating the first boss
#func _on_Boss1_on_death():
#	$ShakeCamera.current = true

# Resets the camera back to the player after leaving the boss arena
func _on_CameraFlag_Boss1(_body):
	dead = true
	$PlayerAnimation.visible = false
	$PlayerArm.visible = false
