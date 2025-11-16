extends Node2D

const max_signals = 9
const GUESS_SIGNAL = preload("uid://cry4dg0ccj8om")

@export var max_oscillators: int = 2

var result_osc: Array[Oscillator]

@onready var result_signal: Control = $CanvasLayer/ResultSignal
@onready var guess_signals: GridContainer = $CanvasLayer/GuessSignals
@onready var confirm_button: Button = $CanvasLayer/ConfirmButton


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
	
	for child in guess_signals.get_children():
		guess_signals.remove_child(child)
	
	for j in range(max_signals):
		# ensure all random graphs
		var plot = GUESS_SIGNAL.instantiate()
		guess_signals.add_child(plot)
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


func _on_plot_clicked():
	var selected = 0
	for plot in guess_signals.get_children():
		if plot.selected:
			selected += 1
	confirm_button.disabled = selected < max_oscillators


func _on_confirm_button_pressed() -> void:
	for plot in guess_signals.get_children():
		if plot.selected:
			result_signal.graph.second_plot.append(plot.graph.oscillators[0])
	await get_tree().create_timer(1).timeout
	result_signal.graph.second_plot.clear()
