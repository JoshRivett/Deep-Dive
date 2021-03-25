extends Area2D

# -- Bullet Properties -- #
export (int) var speed		# The speed at which the bullet will travel
export (int) var damage		# The damage to be dealt by the bullet
export (float) var lifetime	# The maximum time the bullet can exist before being destroyed

# -- Bullet Variables -- #
var velocity = Vector2()

# Initialises the bullet
func start(_position, _direction):
	position = _position
	rotation = _direction.angle()
	$Lifetime.wait_time = lifetime
	velocity = _direction * speed

# Moves the bullet each frame
func _process(delta):
	position += velocity * delta

# Destroys the bullet
func explode():
	queue_free()

# Destroys the bullet and deals damage if a living entity was hit
func _on_Bullet_body_entered(body):
	# Ignores the body if it is dead
	if body.get("dead"):
		if body.dead == true:
			return
	# If the entity can roll and is rolling, the bullet ignores them
	if body.has_method("roll"):
		if body.rolling == true or body.dead == true:
			return
	# Otherwise the bullet explodes and deals damage to the entity
	explode()
	if body.has_method("take_damage"):
		body.take_damage(damage)

# Destroys the bullet if it reaches its lifetime
func _on_Lifetime_timeout():
	explode()
