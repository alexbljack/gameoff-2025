extends Node2D

@export var max_oscillators: int = 2
@export var source_signals_count: int = 2

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
@onready var awesome_panel: AwesomePanel = $Menu/AwesomePanel
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
	hint_button.pressed.connect(_on_hint_button_pressed)

	_init_progress()
	_init_level()
	_init_signals()
	_dump_signals()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_show_exit_dialog()


func _show_exit_dialog() -> void:
	menu.show()
	exit_dialog.popup_centered()


func _on_exit_confirmed() -> void:
	menu.hide()
	_handle_game_over()


func _on_exit_canceled() -> void:
	menu.hide()


func _init_progress() -> void:
	level_label.text = "Level %s / %s" % [Game.player_data.current_level, Game.MAX_LEVEL]
	score_label.text = "Score %s" % Game.player_data.current_score


func _init_level() -> void:
	var level_data = Game.LEVELS_DATA[Game.player_data.current_level]
	source_signals_count = level_data[0]
	max_oscillators = level_data[1]
	attempts_container.init(
		Game.player_data.attempts_left, 
		Game.MAX_ATTEMPTS
	)


func _init_signals() -> void:
	if not Game.player_data.current_sources: 
		_generate_signals()
	else:
		_load_signals()
	convertor.init(max_oscillators, result_signals.size())


func _generate_signals() -> void:
	var signals = []
	for j in range(Game.MAX_SOURCES):
		var oscs: Array[Oscillator] = []
		while oscs.size() < source_signals_count:
			var _osc := Oscillator.rand_osc()
			if not signals.any(func (s): return Oscillator.equal(_osc, s)):
				signals.append(_osc)
				oscs.append(_osc)
		var graph: SourceSignal = source_signals.get_child(j)
		_init_source_graph(graph, oscs)
	var result_sources = Utils.get_random_items(sources, max_oscillators)
	for source in result_sources:
		result_signals.append_array(source.oscillators)
	result_graph.init(result_signals)


func _load_signals() -> void:
	for i in range(Game.MAX_SOURCES):
		var graph: SourceSignal = source_signals.get_child(i)
		if i < Game.player_data.current_sources.size():
			var osc: Array[Oscillator]
			osc.assign(Game.player_data.current_sources[i])
			_init_source_graph(graph, osc)
		else:
			graph.queue_free()
		result_signals = Game.player_data.current_result_signals
		result_graph.init(result_signals)		
		convertor.unmatched_combos = Game.player_data.unmatched_signals


func _init_source_graph(graph: SourceSignal, oscs: Array[Oscillator]) -> void:
	graph.init(oscs)
	graph.clicked.connect(_on_source_clicked)
	graph.hovered.connect(_on_source_hovered)
	graph.left.connect(_on_source_left)
	sources.append(graph)


func _dump_signals() -> void:
	Game.player_data.current_sources = sources.map(func (s): return s.oscillators)
	Game.player_data.current_result_signals = result_signals


func _on_source_clicked(source: SourceSignal) -> void:
	if source.assigned_to:
		AudioManager.sfx_plot_click.play()
		source.assigned_to.source_signal = null
		source.assigned_to = null
		_update_sync_button()
		_update_history_graph()
		var tween = create_tween()
		tween.tween_property(source, "global_position", source.initial_position, 0.3)
		await tween.finished
		source.reparent(source_signals)
		source.input_enabled = true
		return

	if convertor.has_free_slot:
		AudioManager.sfx_plot_click.play()
		var slot = convertor.get_free_slot()
		var tween = create_tween()
		tween.tween_property(source, "global_position", slot.global_position, 0.3)
		source.reparent(slot)
		source.assigned_to = slot
		slot.source_signal = source
		await tween.finished
		_update_sync_button()
		_update_history_graph()
	else:
		AudioManager.sfx_plot_denied.play()
		await source.shaker.shake()


func _on_confirm_button_pressed() -> void:
	var signals = convertor.get_oscillators()
	var result = signals.all(
		func (o): return o in result_signals
	)
	
	if result:
		result_graph.show_success_graph(signals)
		_complete_level()
	else:
		_handle_wrong_sync()
		if Game.player_data.attempts_left == 0:
			_handle_game_over()
			return


func _complete_level() -> void:
	AudioManager.sfx_valid_sync.play()
	await _hide_ui_on_complete()
	Game.update_best_level()
	if not Game.player_data.hint_used:
		Game.player_data.current_mult += Game.NO_HINT_MULT_INCREMENT
	var earned = win_panel.calculate(Game.player_data.attempts_left, Game.player_data.hint_used, Game.player_data.current_mult)
	Game.player_data.current_score += earned
	var is_game_completed = Game.player_data.current_level == Game.MAX_LEVEL
	if not is_game_completed:
		Game.player_data.move_to_next_level()
		await win_panel.show_stats(false)
	else:
		Game.player_data.run_in_progress = false
		await win_panel.show_stats(true)
		set_process(false)
		menu.show()
		awesome_panel.show_credits(Game.player_data.current_score)


func _handle_wrong_sync() -> void:
	AudioManager.sfx_wrong_sync.play()
	_show_error_graph()
	Game.player_data.attempts_left -= 1
	attempts_container.spend_attempt()
	result_graph.shaker.shake()
	convertor.save_unmatched()
	Game.player_data.unmatched_signals = convertor.unmatched_combos
	_update_sync_button()


func _hide_ui_on_complete() -> void:
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


func _handle_game_over() -> void:
	var is_best_result = Game.update_best_score()
	Game.update_best_level()
	Game.player_data.run_in_progress = false
	await _hide_ui_on_complete()
	AudioManager.sfx_game_over.play()
	await lose_panel.show_stats(
		Game.player_data.current_level, 
		Game.player_data.current_score,
		is_best_result
	)


func _show_error_graph() -> void:
	result_graph.show_error_graph(convertor.get_oscillators())


func _update_sync_button() -> void:
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
	AudioManager.sfx_plot_hover.play()
	result_graph.show_demo_graph(source.oscillators)


func _on_source_left(_source: SourceSignal):
	result_graph.hide_demo_graph()


func _on_hint_button_pressed() -> void:
	AudioManager.sfx_hint_use.play()
	Game.player_data.hint_used = true
	hint_button.set_state(true)
	for source in _get_sources_to_remove_on_hint():
		var tween = create_tween()
		source.input_enabled = false
		sources.erase(source)
		tween.tween_property(source, 'scale', Vector2(1.1, 1.1), 0.2)
		tween.tween_property(source, 'scale', Vector2.ZERO, 0.1)
		await tween.finished
		source.queue_free()
	_dump_signals()


func _get_sources_to_remove_on_hint() -> Array:
	var candidates = []
	for source in sources:
		var is_valid = source.oscillators.all(
			func (o): return o in result_signals
		) 
		if is_valid or not source:
			continue
		candidates.append(source)
	candidates.shuffle()
	return candidates.slice(0, Game.REMOVED_ON_HINT)
