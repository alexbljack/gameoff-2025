extends BasicButton


func _ready() -> void:
	super()
	pressed.connect(_on_pressed)


func _on_pressed():
	AudioManager.sfx_confirm.play()
	SceneManager.load_title()
