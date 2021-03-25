# -------------------------------------------------------------------------------------- #
# Written based on this tutorial: https://kidscancode.org/godot_recipes/2d/screen_shake/ #
# Last accessed on: 12/05/2020                                                           #
# -------------------------------------------------------------------------------------- #

extends Camera2D

# -- Shake Camera Variables -- #
export var decay = 0.8						# The rate at which the screen shake intensity decreases
export var max_offset = Vector2(100, 75)	# The maximum horizontal and vertical distance the camera will shake
export var max_roll = 0.1					# The maximum rotation the camera will turn when shaking
export (NodePath) var target				# The node which the camera should follow
var trauma = 0.0							# The initial intensity of the screen shake
var trauma_power = 2						# The strength of the screen shake

# Initialises the random function with a new seed
func _ready():
	randomize()

# Increases the intensity of the screen shake
func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)

# Runs the shake camera logic
func _process(delta):
	# If a target is specified then follow it
	if target:
		global_position = get_node(target).global_position
	# If there's currently trauma, apply decay and shake the screen
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()

# Shakes the screen based on the current trauma value and the set trauma power
func shake():
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * rand_range(-1, 1)
	offset.x = max_offset.x * amount * rand_range(-1, 1)
	offset.y = max_offset.y * amount * rand_range(-1, 1)

# Increases the screen shake intensity whenever the player shoots
func _on_PlayerController_shoot(_bullet, _position, _direction):
	add_trauma(0)
