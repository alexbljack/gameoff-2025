extends Button


func set_state(hint_used: bool):
	text = "Hint used" if hint_used else "Get hint"
	disabled = hint_used
