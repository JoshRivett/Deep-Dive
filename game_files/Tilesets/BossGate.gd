extends AnimatedSprite

# Opens the boss gate after defeating the boss, allowing progression
func _on_Boss1_on_death():
	play("open")
	$StaticBody2D/CollisionShape2D.queue_free()
