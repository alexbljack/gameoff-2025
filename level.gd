extends Node2D

const MAX_SIGNALS = 9

@export var max_oscillators: int = 2
@export var on_hint_removed: int = 3
@export var starting_attempts := 4

var sources: Array = []
var attempts: int
var hint_used: bool = false
var result_signals: Array

@onready var result_graph: ResultSignal = $CanvasLayer/ResultSignal
@onready var source_signals: Control = $CanvasLayer/SourceSignals
@onready var confirm_button: Button = $CanvasLayer/ConfirmButton
@onready var hint_button: Button = $CanvasLayer/HintButton

@onready var convertor: Convertor = $CanvasLayer/Convertor
@onready var attempts_container: Control = $CanvasLayer/Attempts
@onready var win_panel: WinPanel = $CanvasLayer/WinPanel
@onready var lose_panel: LosePanel = $CanvasLayer/LosePanel
@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var level_label: Label = $CanvasLayer/LevelLabel


func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm_button_pressed)

	attempts = starting_attempts
	attempts_container.init(attempts)
	convertor.init(max_oscillators)

	_load_data()
	_generate_signals()


func _generate_signals():
	# ensure all random graphs
	for j in range(MAX_SIGNALS):
		var graph: SourceSignal = source_signals.get_child(j)
		var osc = Oscillator.rand_osc()
		graph.init(osc)
		graph.clicked.connect(_on_source_clicked)
		graph.hovered.connect(_on_source_hovered)
		graph.left.connect(_on_source_left)
		sources.append(graph)

	result_signals = Utils.get_random_items(source_signals.get_children().map(func (s): return s.oscillator), max_oscillators)
	result_graph.init(result_signals)


func _load_data():
	level_label.text = "Level %s" % Game.player_data.current_level
	score_label.text = "Score %s" % Game.player_data.current_score


func _on_source_clicked(source: SourceSignal):
	if source.assigned_to:
		source.assigned_to.source_signal = null
		source.assigned_to = null
		_update_match_button()
		_update_history_graph()
		var tween = create_tween()
		tween.tween_property(source, "global_position", source.initial_position, 0.3)
		await tween.finished
		source.reparent(source_signals)
		source.input_enabled = true
		return

	if convertor.has_free_slot:
		var slot = convertor.get_free_slot()
		var tween = create_tween()
		tween.tween_property(source, "global_position", slot.global_position, 0.3)
		source.reparent(slot)
		source.assigned_to = slot
		slot.source_signal = source
		await tween.finished
		_update_match_button()
		_update_history_graph()
	else:
		await source.shaker.shake()


func _on_confirm_button_pressed() -> void:
	var signals = convertor.get_oscillators()
	var result = signals.all(
		func (o): return o in result_signals
	)
	
	if result:
		result_graph.show_success_graph(signals)
		await _complete_level()
		if not hint_used:
			Game.player_data.current_mult += Const.NO_HINT_MULT_INCREMENT
		else:
			Game.player_data.current_mult = 1.0
		var earned = win_panel.calculate(attempts, hint_used, Game.player_data.current_mult)
		Game.player_data.current_score += earned
		Game.player_data.current_level += 1
		await win_panel.show_stats()
	else:
		_show_error_graph()
		attempts -= 1
		attempts_container.spend_attempt()
		result_graph.shaker.shake()
		convertor.save_unmatched()
		_update_match_button()
		if attempts == 0:
			var is_best_result = Game.player_data.update_best_score()
			Game.player_data.run_in_progress = false
			await _complete_level()
			await lose_panel.show_stats(
				Game.player_data.current_level, 
				Game.player_data.current_score,
				is_best_result
			)
			return
		await get_tree().create_timer(1).timeout


func _complete_level() -> void:
	level_label.hide()
	score_label.hide()
	confirm_button.hide()
	hint_button.hide()
	var tween = create_tween()
	for s in sources:
		s.input_enabled = false
	for source in source_signals.get_children():
		tween.parallel().tween_property(source, 'scale', Vector2.ZERO, 0.2)
	await tween.finished


func _show_error_graph() -> void:
	result_graph.show_error_graph(convertor.get_oscillators())


func _update_match_button() -> void:
	if convertor.has_free_slot or convertor.is_already_unmatched():
		confirm_button.deactivate()
	else:
		confirm_button.activate()


func _update_history_graph():
	if convertor.is_already_unmatched():
		_show_error_graph()
	else:
		result_graph.hide_error_graph()


func _on_source_hovered(source: SourceSignal):
	result_graph.show_demo_graph(source.oscillator)


func _on_source_left(_source: SourceSignal):
	result_graph.hide_demo_graph()


func _on_hint_button_button_down() -> void:
	hint_button.disabled = true
	hint_used = true
	var candidates = []
	for source in sources:
		if source.oscillator in result_signals or not source:
			continue
		candidates.append(source)

	candidates.shuffle()
	
	var tween = create_tween()
	var to_delete = []
	for source in candidates.slice(0, on_hint_removed):
		source.input_enabled = false
		sources.erase(source)
		tween.tween_property(source, 'scale', Vector2(1.1, 1.1), 0.2)
		tween.tween_property(source, 'scale', Vector2.ZERO, 0.1)
		to_delete.append(source)	
	await tween.finished
	
	for s in to_delete:
		s.queue_free()

	hint_button.text = "Hint used"
