extends Area2D

# -- Boss 1 Trigger Signals -- #
signal boss1_fight_started

# -- Boss 1 Trigger Variables -- #
var fightStarted = false

# Starts the boss 1 fight when the player enters the arena
func _on_LeftArea_body_entered(body):
	if not fightStarted:
		fightStarted = true
		emit_signal("boss1_fight_started", body)
