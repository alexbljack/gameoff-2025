class_name ResultSignal extends SignalGraph

var oscillators: Array[Oscillator]

@onready var shaker: Shaker = $Shaker
@onready var line: LineConfig = preload("res://src/result_graph.tres")
@onready var demo_line: LineConfig = preload("res://src/source_graph.tres")
@onready var error_line: LineConfig = preload("res://src/error_graph.tres")
@onready var success_line: LineConfig = preload("res://src/success_graph.tres")

var main_graph
var demo_graph
var error_graph
var success_graph


func init(_oscillators) -> void:
	oscillators.assign(_oscillators)
	
	main_graph = GraphConfig.new() 
	main_graph.line = line
	main_graph.oscillators.assign(oscillators)
	graphs.assign([main_graph])
	
	demo_graph = GraphConfig.new()
	demo_graph.line = demo_line
	graphs.append(demo_graph)

	error_graph = GraphConfig.new()
	error_graph.line = error_line
	graphs.append(error_graph)

	success_graph = GraphConfig.new()
	success_graph.line = success_line
	graphs.append(success_graph)


func show_demo_graph(_oscillator: Oscillator) -> void:
	demo_graph.oscillators.assign([_oscillator])


func hide_demo_graph() -> void:
	demo_graph.oscillators.clear()


func show_error_graph(_oscillators) -> void:
	error_graph.oscillators.assign(_oscillators)


func hide_error_graph() -> void:
	error_graph.oscillators.clear()


func show_success_graph(_oscillators):
	success_graph.oscillators.assign(_oscillators)
