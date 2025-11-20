extends Node2D

const max_signals = 9

@export var max_oscillators: int = 2
@export var on_hint_removed: int = 3
@export var starting_attempts := 4

var attempts: int

var free_slot: SignalSlot:
	get:
		for child: SignalSlot in slots.get_children():
			if not child.source_signal:
				return child
		return null

var signals_in_slots: Array:
	get:
		return slots.get_children().map(func(s): return s.source_signal)

var result_osc: Array[Oscillator]
var osc_positions: Dictionary

@onready var result_signal: Control = $CanvasLayer/ResultSignal
@onready var source_signals: Control = $CanvasLayer/SourceSignals
@onready var confirm_button: Button = $CanvasLayer/ConfirmButton
@onready var hint_button: Button = $CanvasLayer/HintButton
@onready var slots: VBoxContainer = $CanvasLayer/Convertor/Slots
@onready var convertor_border: Line2D = $CanvasLayer/Convertor/Border
@onready var attempts: HBoxContainer = $CanvasLayer/Attempts


func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm_button_pressed)

	attempts = starting_attempts
	for attempt in attempts:
		attempts

	for i in range(max_oscillators):
		var osc = _create_random_osc()
		add_child(osc)
		result_osc.append(osc)
		result_signal.graph.oscillators = result_osc
		while true:
			var pos = randi_range(0, 8)
			if pos in osc_positions.keys():
				continue
			else:
				osc_positions[pos] = osc
				break

	
	for j in range(9):
		# ensure all random graphs
		var plot: SourceSignal = source_signals.get_child(j)
		if j in osc_positions.keys():
			plot.graph.oscillators.append(osc_positions[j])
		else:
			plot.graph.oscillators.append(_create_random_osc())
		plot.clicked.connect(_on_plot_clicked)
		plot.hovered.connect(_on_source_hovered)
		plot.left.connect(_on_source_left)



func _create_random_osc() -> Oscillator:
	var osc = Oscillator.new()
	osc.amplitide = snapped(randf_range(0.2, 1.0), 0.2)
	osc.freq = snapped(randf_range(1, 5), 1.0) # randomize
	osc.wave_type = randi_range(0, 3) as Oscillator.WaveType
	return osc


func _on_plot_clicked(source: SourceSignal):
	if source.assigned_to:
		source.assigned_to.source_signal = null
		source.assigned_to = null
		var tween = create_tween()
		tween.tween_property(source, "global_position", source.initial_position, 0.3)
		await tween.finished
		source.reparent(source_signals)
		_update_match_button()
		return

	if free_slot:
		var tween = create_tween()
		tween.tween_property(source, "global_position", free_slot.global_position, 0.3)
		source.reparent(free_slot)
		source.assigned_to = free_slot
		free_slot.source_signal = source
		await tween.finished
		_update_match_button()
	else:
		source.shaker.shake()
		return


func _on_confirm_button_pressed() -> void:
	var result = []

	var tween = create_tween()
	for sig in signals_in_slots:
		tween.parallel().tween_property(sig, 'scale', Vector2(1.1, 1.1), 0.5)
	await tween.finished
	
	tween = create_tween()
	for sig in signals_in_slots:
		tween.parallel().tween_property(sig, 'scale', Vector2(1.0, 1.0), 0.1)
	await tween.finished
	
	for sig in signals_in_slots:
		var osc = sig.graph.oscillators[0]
		result_signal.graph.second_plot.append(sig.graph.oscillators[0])
		result.append(osc in result_osc)
	
	if result.all(func (r): return r):
		print("WIN")
	else:
		attempts -= 1


	await get_tree().create_timer(1).timeout
	result_signal.graph.second_plot.clear()


func _update_match_button():
	if free_slot != null:
		confirm_button.deactivate()
	else:
		confirm_button.activate()


func _on_source_hovered(source: SourceSignal):
	result_signal.graph.second_plot.append(source.graph.oscillators[0])


func _on_source_left(_source: SourceSignal):
	result_signal.graph.second_plot.clear()


func _on_hint_button_button_down() -> void:
	hint_button.disabled = true
	var ids = []
	for i in range(9):
		if i in osc_positions.keys():
			continue
		ids.append(i)
	ids.shuffle()
	
	var tween = create_tween()
	var to_delete = []
	for to_remove_id in ids.slice(0, on_hint_removed):
		var source = source_signals.get_child(to_remove_id)
		tween.tween_property(source, 'scale', Vector2(1.1, 1.1), 0.2)
		tween.tween_property(source, 'scale', Vector2.ZERO, 0.2)
		to_delete.append(source)	
	await tween.finished
	
	for s in to_delete:
		s.queue_free()
	
	tween = create_tween()
	tween.tween_property(hint_button, 'scale', Vector2.ZERO, 0.2)
	await tween.finished
	hint_button.queue_free()
	
