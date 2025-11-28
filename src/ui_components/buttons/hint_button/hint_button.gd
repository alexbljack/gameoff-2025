extends Button

@onready var animator: AnimationPlayer = $AnimationPlayer

func set_state(hint_used: bool):
	text = "Hint used" if hint_used else "Get hint"
	disabled = hint_used
	if not hint_used:
		animator.play("pulse")
	else:
		animator.stop()
