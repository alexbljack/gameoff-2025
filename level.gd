extends Node2D

@export var max_oscillators: int = 2
@export var on_hint_removed: int = 3

var attempts: int:
	set(new_value):
		attempts = new_value
		Game.player_data.attempts_left = attempts

var hint_used: bool = false:
	set(new_value):
		hint_used = new_value
		Game.player_data.hint_used = hint_used

var sources: Array = []
var result_signals: Array

@onready var result_graph: ResultSignal = $Main/ResultSignal
@onready var source_signals: Control = $Main/SourceSignals
@onready var confirm_button: Button = $Main/ConfirmButton
@onready var hint_button: Button = $Main/HintButton

@onready var convertor: Convertor = $Main/Convertor
@onready var attempts_container: Control = $Main/Attempts
@onready var win_panel: WinPanel = $Main/WinPanel
@onready var lose_panel: LosePanel = $Main/LosePanel
@onready var score_label: Label = $Main/ScoreLabel
@onready var level_label: Label = $Main/LevelLabel

@onready var menu: CanvasLayer = $Menu
@onready var exit_dialog: ConfirmationDialog = $Menu/ExitDialog
@onready var exit_button: TextureButton = $Main/ExitButton


func _ready() -> void:
	exit_dialog.confirmed.connect(_on_exit_confirmed)
	exit_dialog.canceled.connect(_on_exit_canceled)
	exit_button.pressed.connect(_show_exit_dialog)
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	
	hint_used = Game.player_data.hint_used
	hint_button.set_state(hint_used) 

	attempts = Game.player_data.attempts_left
	attempts_container.init(attempts, Const.MAX_ATTEMPTS)

	_load_data()

	if not Game.player_data.current_sources:
		max_oscillators = 2 if Game.player_data.current_level < Const.DIFFICULTY_INCREASE_LEVEL else 3 
		convertor.init(max_oscillators)
		_generate_signals()
	else:
		for i in range(Const.MAX_SOURCES):
			var graph: SourceSignal = source_signals.get_child(i)
			if i < Game.player_data.current_sources.size():
				var osc = Game.player_data.current_sources[i]
				_init_source_graph(graph, osc)
			else:
				graph.queue_free()
		result_signals = Game.player_data.current_result_signals
		result_graph.init(result_signals)
		convertor.init(result_signals.size())
		convertor.unmatched_combos = Game.player_data.unmatched_signals
	_dump_signals()


func _process(_delta: float):
	if Input.is_action_just_pressed("ui_cancel"):
		_show_exit_dialog()


func _generate_signals():
	var signals = []
	var phase_shift = Game.player_data.current_level > Const.START_PHASE_SHIFT_FROM_LEVEL
	for j in range(Const.MAX_SOURCES):
		var osc: Oscillator
		while true:
			osc = Oscillator.rand_osc(phase_shift)
			if not signals.any(func (s): return Oscillator.equal(osc, s)):
				signals.append(osc)
				break
		var graph: SourceSignal = source_signals.get_child(j)
		_init_source_graph(graph, osc)

	result_signals = Utils.get_random_items(sources.map(func (s): return s.oscillator), max_oscillators)
	result_graph.init(result_signals)


func _load_data():
	level_label.text = "Level %s" % Game.player_data.current_level
	score_label.text = "Score %s" % Game.player_data.current_score


func _init_source_graph(graph: SourceSignal, osc: Oscillator):
	graph.init(osc)
	graph.clicked.connect(_on_source_clicked)
	graph.hovered.connect(_on_source_hovered)
	graph.left.connect(_on_source_left)
	sources.append(graph)


func _dump_signals():
	Game.player_data.current_sources = sources.map(func (s): return s.oscillator)
	Game.player_data.current_result_signals = result_signals


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
		var earned = win_panel.calculate(attempts, hint_used, Game.player_data.current_mult)
		Game.player_data.current_score += earned
		Game.player_data.current_level += 1
		Game.player_data.start_new_level()
		await win_panel.show_stats()
	else:
		_show_error_graph()
		attempts -= 1
		attempts_container.spend_attempt()
		result_graph.shaker.shake()
		convertor.save_unmatched()
		Game.player_data.unmatched_signals = convertor.unmatched_combos
		_update_match_button()
		if attempts == 0:
			_game_over()
			return
		await get_tree().create_timer(1).timeout


func _complete_level() -> void:
	level_label.hide()
	score_label.hide()
	confirm_button.hide()
	hint_button.hide()
	exit_button.hide()
	var tween = create_tween()
	for s in sources:
		s.input_enabled = false
	for source in source_signals.get_children():
		tween.parallel().tween_property(source, 'scale', Vector2.ZERO, 0.2)
	await tween.finished


func _game_over():
	var is_best_result = Game.player_data.update_best_score()
	Game.player_data.run_in_progress = false
	await _complete_level()
	await lose_panel.show_stats(
		Game.player_data.current_level, 
		Game.player_data.current_score,
		is_best_result
	)


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
	hint_button.set_state(true)
	hint_used = true
	var candidates = []
	for source in sources:
		if source.oscillator in result_signals or not source:
			continue
		candidates.append(source)

	candidates.shuffle()

	for source in candidates.slice(0, on_hint_removed):
		var tween = create_tween()
		source.input_enabled = false
		sources.erase(source)
		tween.tween_property(source, 'scale', Vector2(1.1, 1.1), 0.2)
		tween.tween_property(source, 'scale', Vector2.ZERO, 0.1)
		await tween.finished
		source.queue_free()
	
	_dump_signals()


func _show_exit_dialog():
	menu.show()
	exit_dialog.popup_centered()


func _on_exit_confirmed():
	menu.hide()
	_game_over()


func _on_exit_canceled():
	menu.hide()
