extends "res://ShakeCamera.gd"

# Enables the camera when the player enters the boss arena
func _on_boss1_fight_started(_body):
	current = true

# Disables the camera when the player defeats the boss
func _on_Boss1_on_death():
	current = false

# Adds screenshake whenever the boss shoots
func _on_Boss1_shoot(_bullet, _position, _direction):
	if trauma < 0.3:
		add_trauma(0.3)

# Adds screenshake whenever the boss slams into the floor or ceiling
func _on_Boss1_slam():
	add_trauma(0.8)
