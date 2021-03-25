extends AudioStreamPlayer

# -- Soundtrack -- #
var calmBefore = load("res://Assets/Audio/calmBefore.ogg")

# Starts the "calmBefore" song when the prop lands
func _on_PlayerProp_landed(_x):
	stream = calmBefore
	play()

# Stops any songs when entering the boss fight
func _on_boss1_fight_started(_x):
	stop()
