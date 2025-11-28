extends BasicButton

@onready var animator: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	super()
	set_state(Game.player_data.hint_used)


func set_state(hint_used: bool):
	text = "Hint used" if hint_used else "Get hint"
	disabled = hint_used
	if not hint_used:
		animator.play("pulse")
	else:
		animator.stop()
