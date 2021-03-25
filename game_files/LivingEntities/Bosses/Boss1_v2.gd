extends "res://LivingEntities/Bosses/Boss.gd"

# -- Boss 1 Signals -- #
signal shoot	# Emitted whenever the boss shoots
signal slam		# Emitted whenver the boss slams into the floor or ceiling

# -- Boss 1 Properties -- #
export (PackedScene) var Bullet	# The type of bullet the boss shoots
const MOVEMENT_SPEED = 800		# The horizontal movement speed of the boss
const SLAM_DAMAGE = 25			# The damage dealt by the bosses slam attacks
const ATTACK_DELAY = 2.0		# The time between the boss's attacks
const RATE_OF_FIRE = 0.1		# The rate of fire of the boss's gun

# -- Player/Boss positions -- #
enum { LEFT, MIDDLE, RIGHT }

# -- Boss attack states -- #
enum { IDLE, CHOOSING_ATTACK, DOWNWARDS_SHOOT, SIDEWAYS_SHOOT, SHOOTING, DOWN_SHOOTING, SLAM, PANIC, DEAD }

# -- Boss 1 Variables -- #
var fightStarted = false				# Whether the fight has started or not
var player = null						# Reference to the player
var magnetBoots = false					# Whether or not the boss's magnet boots are active
var up = UP								# Which direction is up, variable as this changes with inverted gravity
var grounded = false					# Whether or not the boss has hit the ground
var bossLocation = MIDDLE				# The current location of the boss in the arena
var playerLocation = LEFT				# The current location of the player in the arena
var targetLocation = LEFT				# The location the boss is attempting to attack
var bossState = IDLE					# The current attack state of the boss
var shotsFired = 0						# The number of shots fired during a given attack
var rng = RandomNumberGenerator.new()	# Instance of a random number generator

# -- Sound Effects -- #
var slamSound = load("res://Assets/Audio/Slam.wav")
var shootSound = load("res://Assets/Audio/Laser_Shoot.wav")

func _ready():
	$AttackTimer.wait_time = ATTACK_DELAY
	$GunTimer.wait_time = RATE_OF_FIRE

func _physics_process(_delta):
	magnetBootPhysics()
	slamCheck()
	animationHandler()
	chooseAttack()
	
	# Moves the boss
	motion = move_and_slide(motion, up)

# Plays the appropriate animation
func animationHandler():
	if fightStarted:
		if bossState == SLAM:
			if motion.x == 0:
				$Animation.play("idle")
			else:
				$Animation.play("walkCycle")
				$Animation.flip_h = (motion.x < 0)
		elif bossState == SHOOTING:
			if not magnetBoots:
				$Animation.play("shootForwards")
		elif bossState == DOWN_SHOOTING:
			$Animation.play("walkCycleShoot")
		elif bossState == PANIC:
			$Animation.play("walkCycleShoot")
			$Animation.speed_scale = 1.5
			$Animation.flip_h = (motion.x < 0)
		elif bossState == DEAD:
			if not is_on_floor():
				$Animation.play("falling")
			else:
				$Animation.play("dead")
		else:
			$Animation.play("idle")
			$Animation.flip_h = (player.global_position.x < global_position.x)

# Starts the boss fight after the player triggers it
func _on_boss1_fight_started(body):
	fightStarted = true
	magnetBoots = true
	player = body
	$AttackTimer.start()

func _on_AttackTimer_timeout():
	print("attack timer finished")
	$AttackTimer.stop()
	if health*100/maxHealth > 70:
		phase = 1
		phaseOne()
	elif health*100/maxHealth > 20:
		phase = 2
		if health*100/maxHealth > 50:
			$AttackTimer.wait_time = ATTACK_DELAY/2
		else:
			$AttackTimer.wait_time = ATTACK_DELAY/4
		phaseTwo()
	else:
		phase = 3
		phaseThree()
	print(phase)

# Logic for phase one of the boss fight
func phaseOne():
	targetLocation = playerLocation
	
	match targetLocation:
		LEFT:
			if bossLocation == LEFT or bossLocation == MIDDLE:
				slamAttack()
			else:
				sidewaysShootAttack()
		MIDDLE:
			slamAttack()
		RIGHT:
			if bossLocation == LEFT:
				sidewaysShootAttack()
			else:
				slamAttack()

# Logic for phase two of the boss fight
func phaseTwo():
	targetLocation = playerLocation
	
	match targetLocation:
		LEFT:
			match bossLocation:
				LEFT:
					slamAttack()
				MIDDLE:
					slamAttack()
				RIGHT:
					sidewaysShootAttack()
		MIDDLE:
			match bossLocation:
				LEFT:
					downwardsShootAttack()
				MIDDLE:
					slamAttack()
				RIGHT:
					downwardsShootAttack()
		RIGHT:
			match bossLocation:
				LEFT:
					sidewaysShootAttack()
				MIDDLE:
					slamAttack()
				RIGHT:
					slamAttack()

# Logic for phase three of the boss fight
func phaseThree():
	$AttackTimer.stop()
	$GunTimer.start()
	magnetBoots = true
	bossState = PANIC
	motion.x = MOVEMENT_SPEED * 1.5

# If boss is idle, get ready to attack again
func chooseAttack():
	if bossState == IDLE and fightStarted:
		print("attack timer start")
		bossState = CHOOSING_ATTACK
		$AttackTimer.start()
	elif phase == 3:
		panicAttack()

# Starts the boss's slam attack state
func slamAttack():
	print("slam attack")
	$AttackTimer.stop()
	bossState = SLAM
	
	if targetLocation == bossLocation:
		if grounded == true and magnetBoots == true:
			magnetBoots = false
			bossState = IDLE
		else:
			magnetBoots = true
	else:
		magnetBoots = true
		if playerLocation > bossLocation:
			motion.x = MOVEMENT_SPEED
		else:
			motion.x = -MOVEMENT_SPEED

# Starts the boss's sideways shoot attack
func sidewaysShootAttack():
	print("sideways shoot attack")
	$AttackTimer.stop()
	bossState = SIDEWAYS_SHOOT
	magnetBoots = false

# Starts the boss's downwards shoot attack
func downwardsShootAttack():
	print("downwards shoot attack")
	$AttackTimer.stop()
	bossState = DOWNWARDS_SHOOT
	magnetBoots = true

# Logic for the boss's panic attack
func panicAttack():
	if phase == 3:
		if bossLocation == LEFT:
			motion.x = MOVEMENT_SPEED * 1.5
		elif bossLocation == RIGHT:
			motion.x = MOVEMENT_SPEED * -1.5

# Flips the boss and its gravity if magnet boots are active
func magnetBootPhysics():
	if magnetBoots:
		up = DOWN
		motion.y -= GRAVITY
		$Animation.flip_v = true
	else:
		up = UP
		motion.y += GRAVITY
		$Animation.flip_v = false

# Checks if the boss is slamming into the ground or ceiling
func slamCheck():
	# If the boss has just hit the floor, emit a slam signal
	if is_on_floor():
		if grounded == false:
			grounded = true
			if fightStarted:
				$AudioStreamPlayer.stream = slamSound
				$AudioStreamPlayer.play()
			emit_signal("slam")
			if bossState == SLAM and not magnetBoots:
				bossState = IDLE
		if bossState == SIDEWAYS_SHOOT:
			if magnetBoots == false:
				bossState = SHOOTING
				$GunTimer.start()
		elif bossState == DOWNWARDS_SHOOT:
			if magnetBoots == true:
				bossState = DOWN_SHOOTING
				if targetLocation > bossLocation:
					motion.x = MOVEMENT_SPEED
				else:
					motion.x = -MOVEMENT_SPEED
				$GunTimer.start()
	# If the boss is in the air, reset the grounded flag
	else:
		grounded = false

# Deals damage to the player if slammed by the boss
func _on_SlamArea_body_entered(body):
	if grounded == false and motion.y > 0:
		if body == player: 
			player.take_damage(SLAM_DAMAGE)
			if player.global_position.x > global_position.x:
				player.applyKnockback(1, 1000)
			else:
				player.applyKnockback(-1, 1000)

# Shoots the boss's gun with a random spread
func shoot():
	var barrel
	var direction
	
	# Determines which way the boss's gun is facing
	if not $Animation.flip_h and not $Animation.flip_v:
		barrel = $Animation/RightBarrel
		direction = 0
	elif $Animation.flip_h and not $Animation.flip_v:
		barrel = $Animation/LeftBarrel
		direction = 180
	elif not $Animation.flip_h and $Animation.flip_v:
		barrel = $Animation/DownRightBarrel
		direction = 90
	else:
		barrel = $Animation/DownLeftBarrel
		direction = 90
	
	# Determines the direction with spread and emits the signal to spawn the bullet
	$AudioStreamPlayer.stream = shootSound
	$AudioStreamPlayer.play()
	var spread = rng.randi_range(-3, 3)
	var dir = Vector2(1, 0).rotated(deg2rad(direction + spread))	# Gets the direction to shoot the bullet
	emit_signal("shoot", Bullet, barrel.global_position, dir)		# Tells the command handler to create a bullet instance

# Handles shooting the boss's gun
func _on_GunTimer_timeout():
	if is_on_floor():
		if bossState == SHOOTING:
			if shotsFired < 20:
				shoot()
				shotsFired += 1
			else:
				shotsFired = 0
				bossState = IDLE
				$GunTimer.stop()
		elif bossState == DOWN_SHOOTING:
			shoot()
		elif phase == 3:
			shoot()

func killSelf():
	emit_signal("on_death")
	bossState = DEAD
	dead = true
	$GunTimer.stop()
	magnetBoots = false
	motion.x = 0
	phase = 0

# -- Player Location Detection -- #
func _on_LeftArea_body_entered(body):
	if body == player:
		playerLocation = LEFT
		print("player left")

func _on_MiddleArea_body_entered(body):
	if body == player:
		playerLocation = MIDDLE
		print("player middle")

func _on_RightArea_body_entered(body):
	if body == player:
		playerLocation = RIGHT
		print("player right")


# -- Boss Location Detection
func _on_TopLeftArea_body_entered(_body):
	bossLocation = LEFT
	if bossState == SLAM and bossLocation == targetLocation:
		motion.x = 0
		magnetBoots = false
	if bossState == DOWN_SHOOTING:
		motion.x = 0
		bossState = IDLE
	print("boss left")

func _on_TopMiddleArea_body_entered(_body):
	bossLocation = MIDDLE
	if bossState == SLAM and bossLocation == targetLocation:
		motion.x = 0
		magnetBoots = false
	print("boss middle")

func _on_TopRightArea_body_entered(_body):
	bossLocation = RIGHT
	if bossState == SLAM and bossLocation == targetLocation:
		motion.x = 0
		magnetBoots = false
	if bossState == DOWN_SHOOTING:
		motion.x = 0
		bossState = IDLE
	print("boss right")
