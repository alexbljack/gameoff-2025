class_name PlayerData extends Resource

const SAVES_DIR = "user://saves/"
const SAVE_FILE = "syncwave_save.res"
const SAVE_FILE_PATH = SAVES_DIR + SAVE_FILE

@export var best_score: int = 0:
	set(new_value):
		best_score = new_value
		try_save()

@export var best_level: int = 0:
	set(new_value):
		best_level = new_value
		try_save()

@export var run_in_progress: bool = false:
	set(new_value):
		run_in_progress = new_value
		try_save()

@export var current_level: int = 1:
	set(new_value):
		current_level = new_value
		try_save()

@export var current_score: int = 0:
	set(new_value):
		current_score = new_value
		try_save()

@export var current_mult: float = 1.0:
	set(new_value):
		current_mult = new_value
		try_save()

@export var current_sources: Array = []:
	set(new_value):
		current_sources = new_value
		try_save()

@export var current_result_signals: Array = []:
	set(new_value):
		current_result_signals = new_value
		try_save()

@export var unmatched_signals: Array = []:
	set(new_value):
		unmatched_signals = new_value
		try_save()

@export var hint_used: bool = false:
	set(new_value):
		hint_used = new_value
		try_save()

@export var attempts_left: int = Game.MAX_ATTEMPTS:
	set(new_value):
		attempts_left = new_value
		try_save()

var save_to_file: bool = false


func try_save() -> void:
	if save_to_file:
		if not DirAccess.dir_exists_absolute(PlayerData.SAVES_DIR):
			DirAccess.make_dir_recursive_absolute(PlayerData.SAVES_DIR)
		ResourceSaver.save(self, SAVE_FILE_PATH)


func start_new_game() -> void:
	run_in_progress = true
	current_level = 1
	current_score = 0
	current_mult = 1.0


func reset_level() -> void:
	current_sources = []
	current_result_signals = []
	unmatched_signals = []
	attempts_left = Game.MAX_ATTEMPTS
	hint_used = false


func move_to_next_level():
	current_level += 1
	reset_level()
