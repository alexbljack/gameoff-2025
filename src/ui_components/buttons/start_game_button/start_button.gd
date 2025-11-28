extends BasicButton

@onready var run_info: Label = $RunInfo


func _ready() -> void:
	super()
	run_info.hide()


func init(loaded: bool) -> void:
	if loaded and Game.player_data.run_in_progress:
		text = "Continue"
		pressed.connect(_on_continue)
		run_info.show()
		run_info.text = "Level %s / %s\nScore %s" % [
			Game.player_data.current_level,
			Game.MAX_LEVEL, 
			Game.player_data.current_score
		]
	else:
		text = "New game"
		pressed.connect(_on_new_game)


func _on_new_game() -> void:
	Game.player_data.save_to_file = true
	Game.player_data.start_new_game()
	Game.player_data.reset_level()
	_handle_click()


func _on_continue() -> void:
	_handle_click()


func _handle_click() -> void:
	AudioManager.sfx_confirm.play()
	SceneManager.load_level()
