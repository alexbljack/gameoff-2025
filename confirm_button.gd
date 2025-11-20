extends Button

@onready var animator: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	pass


func activate():
	disabled = false
	animator.play("pulse")


func deactivate():
	disabled = true
	animator.stop()