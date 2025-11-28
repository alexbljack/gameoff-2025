extends Control

@onready var best_score: Label = $BestScore
@onready var best_level: Label = $BestLevel


func _ready() -> void:
	best_score.hide()
	best_level.hide()

	if Game.player_data.best_score > 0:
		best_score.text = "Best score %s" % Game.player_data.best_score
		best_level.text = "Max level %s" % Game.player_data.best_level
		best_score.show()
		best_level.show()
