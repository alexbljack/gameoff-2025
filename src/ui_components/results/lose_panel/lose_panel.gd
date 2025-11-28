class_name LosePanel extends Control

@onready var game_over_label: Label = $GameOverLabel
@onready var level_row: Control = $Level
@onready var score_row: Control = $Score
@onready var best_result_label: Label = $BestResultLabel
@onready var return_button: Button = $ReturnButton
@onready var level_reached: Label = $Level/LevelReached
@onready var score_earned: Label = $Score/ScoreEarned


func _ready() -> void:
	game_over_label.scale = Vector2.ZERO
	level_row.hide()
	score_row.hide()
	best_result_label.hide()
	return_button.hide()


func show_stats(level: int, score: int, is_best_result: bool):
	level_reached.text = "%s / %s" % [level, Const.MAX_LEVEL]
	score_earned.text = "%s" % score
	show()
	var tween = create_tween()
	tween.tween_property(game_over_label, "scale", Vector2.ONE, 0.5)
	await tween.finished
	var rows = [level_row, score_row]
	if is_best_result:
		rows.append(best_result_label)
	for row: Control in rows:
		if row == best_result_label:
			AudioManager.sfx_best_result.play()
		else:
			AudioManager.sfx_results.play()
		row.show()
		var shaker: Shaker = row.get_node("Shaker")
		shaker.shake()
		await shaker.finished
	return_button.show()


func _on_return_button_pressed() -> void:
	AudioManager.sfx_confirm.play()
	SceneManager.load_title()


func _on_return_button_mouse_entered() -> void:
	AudioManager.sfx_button_hover.play()
