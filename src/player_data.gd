class_name PlayerData extends Resource

const SAVES_DIR = "user://saves/"
const SAVE_FILE = "syncsave.res"
const SAVE_FILE_PATH = SAVES_DIR + SAVE_FILE

@export var best_score: int = 0:
	set(new_value):
		best_score = new_value
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
