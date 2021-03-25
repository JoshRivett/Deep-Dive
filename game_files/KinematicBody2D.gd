extends "res://LivingEntities/LivingEntity.gd"

const GRAVITY = 200				# Rate of acceleration downwards

func _physics_process(delta):
	motion.y += GRAVITY						# Applies gravity to the player
	motion = move_and_slide(motion, UP)		# Applies motion to the player
