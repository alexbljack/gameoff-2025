extends Node2D

const max_signals = 9

@export var max_oscillators: int = 2

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

@onready var result_signal: Control = $CanvasLayer/ResultSignal
@onready var source_signals: Control = $CanvasLayer/SourceSignals
@onready var confirm_button: Button = $CanvasLayer/ConfirmButton
@onready var slots: VBoxContainer = $CanvasLayer/Convertor/Slots


func _ready() -> void:
	var osc_positions := {} 
	
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
		var plot = source_signals.get_child(j)
		if j in osc_positions.keys():
			plot.graph.oscillators.append(osc_positions[j])
		else:
			plot.graph.oscillators.append(_create_random_osc())
		plot.clicked.connect(_on_plot_clicked)



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
	for sig in signals_in_slots:
		result_signal.graph.second_plot.append(sig.graph.oscillators[0])
	await get_tree().create_timer(1).timeout
	result_signal.graph.second_plot.clear()


func _update_match_button():
	confirm_button.disabled = free_slot != null
