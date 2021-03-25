extends CanvasLayer

# Updates the player's health whenever it is changed
func _on_health_changed(currentHealth):
	$MarginContainer/HBoxContainer/HealthBar.value = currentHealth

# Displays the boss health bar upon entering the boss 1 arena
func _on_boss1_fight_started(_body):
	$BossHealth.visible = true

# Updates the boss health bar whenever Boss1 changes health
func _on_Boss1_health_changed(currentHealth):
	$BossHealth.value = currentHealth
	if $BossHealth.value == 0:
		$BossHealth.visible = false

func _on_tutorial_prompt(prompt):
	$TutorialPromptArea/CenterContainer/Prompt.text = prompt

func _on_remove_prompt():
	$TutorialPromptArea/CenterContainer/Prompt.text = ""
