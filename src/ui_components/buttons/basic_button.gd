class_name BasicButton extends Button


func _ready() -> void:
	mouse_entered.connect(_on_mouse_hovered)


func _on_mouse_hovered():
	if not disabled:
		AudioManager.sfx_button_hover.play()
