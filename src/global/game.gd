extends Node

const MAX_SOURCES = 9
const MAX_ATTEMPTS = 3
const MAX_LEVEL := 20
const SCORE_PER_ATTEMPT := 100
const SCORE_FOR_HINT := 200
const NO_HINT_MULT_INCREMENT := 0.2

const LEVELS_DATA = {
	1: [1, 2],  # source oscillators, result signals
	2: [1, 2],
	3: [1, 2],
	4: [1, 2],
	5: [1, 2],
	6: [1, 3],
	7: [1, 3],
	8: [1, 3],
	9: [1, 3],
	10: [1, 3],
	11: [2, 2],
	12: [2, 2],
	13: [2, 2],
	14: [2, 2],
	15: [2, 2],
	16: [2, 3],
	17: [2, 3],
	18: [2, 3],
	19: [2, 3],
	20: [2, 3],
}

var player_data = PlayerData.new()


func try_load_savefile() -> bool:
	var result
	if FileAccess.file_exists(PlayerData.SAVE_FILE_PATH):
		result = ResourceLoader.load(PlayerData.SAVE_FILE_PATH)
		if result:
			Game.player_data = result
			Game.player_data.save_to_file = true
	return result != null


func update_best_score() -> bool:
	if player_data.current_score > player_data.best_score:
		player_data.best_score = player_data.current_score
		return true
	return false


func update_best_level() -> bool:
	if player_data.current_level > player_data.best_level:
		player_data.best_level = player_data.current_level
		return true
	return false
