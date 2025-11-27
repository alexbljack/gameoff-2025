extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_mouse_pressed)


func _on_mouse_entered():
	scale = Vector2(1.2, 1.2)


func _on_mouse_exited():
	scale = Vector2.ONE


func _on_mouse_pressed():
	AudioManager.sfx_button_click.play()
