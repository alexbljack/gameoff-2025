extends Node2D

@export var level_scene: PackedScene

@onready var best_score: Label = $CanvasLayer/BestResultLabel
@onready var best_level: Label = $CanvasLayer/BestLevelLabel
@onready var start_button: Button = $CanvasLayer/StartButton
@onready var run_info: Label = $CanvasLayer/RunInfo


func _ready() -> void:
	start_button.mouse_entered.connect(_on_start_button_mouse_hovered)
	best_score.hide()
	best_level.hide()
	run_info.hide()

	_init_save()

	if Game.player_data.best_score > 0:
		best_score.text = "Best score %s" % Game.player_data.best_score
		best_level.text = "Max level %s" % Game.player_data.best_level
		best_score.show()
		best_level.show()

	if Game.player_data.run_in_progress:
		run_info.show()
		run_info.text = "Level %s / %s\nScore %s" % [
			Game.player_data.current_level,
			Const.MAX_LEVEL, 
			Game.player_data.current_score
		]
		start_button.text = "Continue"
		start_button.pressed.connect(_on_continue)
	else:
		start_button.text = "New game"
		start_button.pressed.connect(_on_new_game)


func _init_save() -> void:
	if not DirAccess.dir_exists_absolute(PlayerData.SAVES_DIR):
		DirAccess.make_dir_recursive_absolute(PlayerData.SAVES_DIR)

	if FileAccess.file_exists(PlayerData.SAVE_FILE_PATH):
		Game.player_data = ResourceLoader.load(PlayerData.SAVE_FILE_PATH)
		Game.player_data.save_file = PlayerData.SAVE_FILE_PATH


func _on_new_game() -> void:
	Game.player_data.save_file = PlayerData.SAVE_FILE_PATH
	Game.player_data.start_new_game()
	Game.player_data.start_new_level()
	AudioManager.sfx_confirm.play()
	SceneManager.load_level()


func _on_continue() -> void:
	AudioManager.sfx_confirm.play()
	SceneManager.load_level()


func _on_start_button_mouse_hovered():
	AudioManager.sfx_button_hover.play()
