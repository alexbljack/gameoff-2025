class_name PlayerData extends Resource

const SAVES_DIR = "user://saves/"
const SAVE_FILE = "syncsave.res"
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

@export var attempts_left: int = Const.MAX_ATTEMPTS:
	set(new_value):
		attempts_left = new_value
		try_save()

var save_file: String = ""


func save_to_file(file_path: String) -> void:
	ResourceSaver.save(self, file_path)


func try_save() -> void:
	if save_file:
		save_to_file(save_file)


func update_best_score() -> bool:
	if current_score > best_score:
		best_score = current_score
		return true
	return false


func update_best_level() -> bool:
	if current_level > best_level:
		best_level = current_level
		return true
	return false


func start_new_game() -> void:
	run_in_progress = true
	current_level = 1
	current_score = 0
	current_mult = 1.0


func start_new_level() -> void:
	current_sources = []
	current_result_signals = []
	unmatched_signals = []
	attempts_left = Const.MAX_ATTEMPTS
	hint_used = false
