class_name AwesomePanel extends Control

@onready var praise_label: Label = $PraiseLabel
@onready var score_label: Label = $ScoreLabel
@onready var thanks_label: Label = $ThanksLabel
@onready var return_button: Button = $ReturnButton


func _ready() -> void:
	praise_label.hide()
	score_label.hide()
	thanks_label.hide()
	return_button.hide()


func show_credits(score: int):
	score_label.text = "Total score %s" % score
	var rows = [praise_label, score_label, thanks_label, return_button]
	for row: Control in rows:
		row.show()
		var shaker: Shaker = row.get_node("Shaker")
		shaker.shake()
		await shaker.finished
	return_button.show()


func _on_return_button_pressed() -> void:
	SceneManager.load_title()
