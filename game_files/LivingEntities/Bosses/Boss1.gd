extends "res://LivingEntities/Bosses/Boss.gd"

# -- Boss 1 Signals -- #
signal boss_view	# Emitted once the player has entered the boss arena
signal shoot		# Emitted whenever the boss shoots
signal slam			# Emitted whenver the boss slams into the floor or ceiling

# -- Player/Boss positions -- #
enum { LEFT, MIDDLE, RIGHT }

# -- Boss attack states -- #
enum { IDLE, DOWNWARDS_SHOOT, SIDEWAYS_SHOOT, SLAM }

# -- Boss 1 Properties -- #
export (PackedScene) var Bullet	# The type of bullet the boss shoots
const MOVEMENT_SPEED = 1000		# The horizontal movement speed of the boss
const SLAM_DAMAGE = 20			# The damage dealt by the boss's slam attack
const RATE_OF_FIRE = 0.1		# The rate of fire of the boss's gun
const SIDEWAYS_SHOTS = 5		# The number of shots fired by the boss's sideways shooting attack
const DOWNWARD_SHOTS = 20		# The number of shots fired by the boss's downwards shooting attack

# -- Boss 1 Variables -- #
var magnetBoots = false					# Whether or not the boss's magnet boots are active (inverts gravity)
var fightStarted = false				# Whether or not the fight has started
var shotsFired = 0						# The number of shots fired during a given attack
var target								# The location the boss is attempting to attack
var gunAngle = 0						# The angle at which to fire bullets in
var playerLocation						# The current location of the player within the arena
var bossLocation = MIDDLE				# The current location of the boss within the arena
var bossState = IDLE					# The current attack state of the boss
var grounded = true						# Whether or not the boss is currently on the ground
var rng = RandomNumberGenerator.new()	# Instance of a random number generator

# Initalises the random number generator and the rate of fire of the boss's gun
func _ready():
	rng.randomize()
	$GunTimer.wait_time = RATE_OF_FIRE

# Runs the boss's physics based logic
func _physics_process(_delta):
	# Applies gravity/inverts gravity depending on whether or not the magnet boots are active
	if magnetBoots == true:
		# Applies motion and inverted gravity to the boss
		motion = move_and_slide(motion, DOWN)
		motion.y -= GRAVITY
		$Animation.flip_v = true
	else:
		# Applies motion and gravity to the boss
		motion = move_and_slide(motion, UP)
		motion.y += GRAVITY
		$Animation.flip_v = false
	
	# Checks if the boss has slammed into the ground or is airborne
	if is_on_floor():
		$SlamArea/SlamCollision.disabled = true
		if grounded == false:
			grounded = true
			emit_signal("slam")
			$SlamArea/SlamCollision.disabled = false
		
		if motion.x != 0:
			if bossState == DOWNWARDS_SHOOT:
				$Animation.play("walkCycleShoot")
			else:
				$Animation.play("walkCycle")
		else:
			$Animation.play("idle")
		
	else:
		grounded = false
		$SlamArea/SlamCollision.disabled = true

# -- Boss Attacks/Algorithms -- #
# Decides which attack to use based on boss and player location
func chooseAttack():
	print(bossLocation)
	match playerLocation:
		LEFT:
			if bossLocation == RIGHT:
				downwardShootAttack()
			else:
				target = LEFT
				$Animation.flip_h = true
				slamAttack()
		MIDDLE:
			sidewaysShootAttack()
		RIGHT:
			if bossLocation == LEFT:
				downwardShootAttack()
			else:
				target = RIGHT
				$Animation.flip_h = false
				slamAttack()

# Starts the boss's downward shooting attack
func downwardShootAttack():
	print("Downward shoot")
	magnetBoots = true
	bossState = DOWNWARDS_SHOOT
	gunAngle = 90
	$AttackTimer.stop()
	$GunTimer.start()
	
	if bossLocation == LEFT:
		motion.x = MOVEMENT_SPEED
	if bossLocation == RIGHT:
		motion.x = -MOVEMENT_SPEED

# Starts the boss's sideways shooting attack
func sidewaysShootAttack():
	print("Sideways shoot")
	if bossLocation == MIDDLE:
		motion.x = -MOVEMENT_SPEED
	else:
		magnetBoots = false
	bossState = SIDEWAYS_SHOOT
	if bossLocation == LEFT:
		gunAngle = 0
	elif bossLocation == RIGHT:
		gunAngle = 180
	$AttackTimer.stop()
	$GunTimer.start()

# Starts the boss's slam attack
func slamAttack():
	print("slam")
	magnetBoots = true
	bossState = SLAM
	
	if target == LEFT:
		if bossLocation != LEFT:
			if is_on_floor():
				motion.x = -MOVEMENT_SPEED
		else:
			if grounded == false:
				magnetBoots = false
	
	if target == RIGHT:
		if bossLocation != RIGHT:
			if is_on_floor():
				motion.x = MOVEMENT_SPEED
		else:
			if grounded == false:
				magnetBoots = false

# Shoots the boss's gun with a random spread
func shoot(direction):
	var spread = rng.randi_range(-5, 5)
	var dir = Vector2(1, 0).rotated(deg2rad(direction + spread))	# Gets the direction to shoot the bullet
	emit_signal("shoot", Bullet, $Animation/Position2D.global_position, dir)	# Tells the command handler to create a bullet instance

# If the player is hit by a slam attack, deal damage to them
func _on_SlamArea_body_entered(body):
	if body.has_method("take_damage") and $SlamArea/SlamCollision.disabled == false:
		body.take_damage(SLAM_DAMAGE)
		if body.global_position.x > global_position.x:
			body.applyKnockback(1, 1000)
		else:
			body.applyKnockback(-1, 1000)
	call_deferred("$SlamArea/SlamCollision.disabled", "true")

# Chooses a new attack after waiting idle for a set period
func _on_AttackTimer_timeout():
	if bossState == IDLE:
		chooseAttack()
	else:
		bossState = IDLE
		print("idle")
		#magnetBoots = true
		$AttackTimer.start()

# Shoots bullets until the specified number have been fired
func _on_GunTimer_timeout():
	shoot(gunAngle)
	shotsFired += 1
	print(shotsFired)
	if (shotsFired < SIDEWAYS_SHOTS and bossState == SIDEWAYS_SHOOT) or (shotsFired < DOWNWARD_SHOTS and bossState == DOWNWARDS_SHOOT):
		$GunTimer.start()
	else:
		shotsFired = 0
		$GunTimer.stop()
		$AttackTimer.start()

# -- Boss Location Detection -- #
# Updates the boss's location to LEFT and runs attack logic
func _on_TopLeftArea_body_entered(_body):
	bossLocation = LEFT
	$Animation.flip_h = false
	
	if (bossState == SLAM and target == LEFT) or bossState == DOWNWARDS_SHOOT or bossState == SIDEWAYS_SHOOT:
		motion.x = 0
		magnetBoots = false
		$AttackTimer.start()

# Updates the boss's location to RIGHT and runs attack logic
func _on_TopRightArea_body_entered(_body):
	bossLocation = RIGHT
	$Animation.flip_h = true
	
	if (bossState == SLAM and target == RIGHT) or bossState == DOWNWARDS_SHOOT or bossState == SIDEWAYS_SHOOT:
		motion.x = 0
		magnetBoots = false
		$AttackTimer.start()

# -- Player Location Detection -- #
# If the fight hasn't started, start it. Otherwise update player location to LEFT
func _on_LeftArea_body_entered(body):
	if body.name == "PlayerController":
		if fightStarted == false:
			fightStarted = true
			magnetBoots = true
			$AttackTimer.start()
			$AttackTimer.wait_time = 2
			emit_signal("boss_view")
		playerLocation = LEFT

# Updates the player location to MIDDLE
func _on_MiddleArea_body_entered(body):
	if body.name == "PlayerController":
		playerLocation = MIDDLE

# Updates the player location to RIGHT
func _on_RightArea_body_entered(body):
	if body.name == "PlayerController":
		playerLocation = RIGHT
