extends KinematicBody2D

# -- Living Entity Signals -- #
signal health_changed	# Emitted whenever the entity's health goes up or down
signal on_death			# Emitted when the entity's health reaches zero

# -- Living Entity Properties -- #
const UP = Vector2(0, -1)		# Definition for what direction is up
const DOWN = Vector2(0, 1)		# Definition for what direction is up
const GRAVITY = 200				# Rate of acceleration downwards
export (int) var maxHealth		# The total health of the entity

# -- Living Entity Variables -- #
var health						# The current health of the entity
var motion = Vector2()			# Motion of the entity
var invulnerable = false		# Whether or not the entity should take damage
var dead = false				# Whether the entity is dead or not

# -- Sound Effects -- #
var hurtSound = load("res://Assets/Audio/Hurt.wav")

# Initalises the entity's health to the specified max health
func _ready():
	health = maxHealth

# Deals damage to the entity by reducing its health
func take_damage(damage):
	# Checks if the entity is currently immune to damage
	if not invulnerable:
		$AudioStreamPlayer.stream = hurtSound
		$AudioStreamPlayer.play()
		health -= damage
		emit_signal('health_changed', health * 100 / maxHealth)
		# Checks if the entity has been defeated
		if health <= 0:
			invulnerable = true
			killSelf()

# Destroys the entity
func killSelf():
	emit_signal('on_death')
	queue_free()
