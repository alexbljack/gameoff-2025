class_name WinPanel extends Control

@onready var success_title: Label = $SuccessLabel
@onready var attempts_score: Control = $AttemptsScore
@onready var hints_score: Control = $HintsScore
@onready var hints_mult: Control = $HintsMult
@onready var total_score: Control = $TotalScore
@onready var next_level_button: Button = $NextLevelButton

@onready var attempts_count: Label = $AttemptsScore/AttemptsCount
@onready var attempts_total: Label = $AttemptsScore/AttemptsTotalScore
@onready var hint_state: Label = $HintsScore/HintState
@onready var hint_total: Label = $HintsScore/HintTotalScore
@onready var hint_mult_total: Label = $HintsMult/HintsMultTotal
@onready var hint_mult_increment: Label = $HintsMult/HintsMultIncrement
@onready var total_score_label: Label = $TotalScore/TotalScoreLabel


func _ready() -> void:
	success_title.scale = Vector2.ZERO
	attempts_score.hide()
	hints_score.hide()
	hints_mult.hide()
	total_score.hide()
	next_level_button.hide()


func show_stats(completed: bool):
	show()
	var tween = create_tween()
	tween.tween_property(success_title, "scale", Vector2.ONE, 0.5)
	await tween.finished
	var rows = [attempts_score, hints_score, hints_mult, total_score]
	for row: Control in rows:
		AudioManager.sfx_results.play()
		row.show()
		var shaker: Shaker = row.get_node("Shaker")
		shaker.shake()
		await shaker.finished
	if not completed:
		next_level_button.show()


func calculate(attempts: int, hint_used: bool, hint_mult: float):
	var score_for_attempts = attempts * Game.SCORE_PER_ATTEMPT
	var total_earned: int = 0

	attempts_count.text = "x %s" % attempts
	attempts_total.text = "+%s" % score_for_attempts
	total_earned += score_for_attempts
	hint_mult_total.text = "x%s" % hint_mult
	if hint_used:
		hint_state.text = "Hint used"
		hint_total.text = "+0"
		hint_mult_increment.text = "(+0.0)"
	else:
		hint_state.text = "Hint saved"
		hint_total.text = "+%s" % Game.SCORE_FOR_HINT
		hint_mult_increment.text = "(+%s)" % Game.NO_HINT_MULT_INCREMENT
		total_earned += Game.SCORE_FOR_HINT

	total_earned = snapped(int(total_earned * hint_mult), 10)
	total_score_label.text = "+%s" % total_earned
	return total_earned
