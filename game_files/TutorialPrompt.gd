extends Area2D

# -- Tutorial Prompt Signals -- #
signal tutorial_prompt
signal remove_prompt

# -- Tutorial Prompt Properties -- #
export (String) var prompt

# Sends the prompt to the HUD when the player walks over the collision
func _on_body_entered(body):
	if body.name == "PlayerController":
		emit_signal("tutorial_prompt", prompt)

# Let's the HUD know to remove the prompt as the player has walked away
func _on_TutorialPrompt_body_exited(body):
	if body.name == "PlayerController":
		emit_signal("remove_prompt")
