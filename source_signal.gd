class_name SourceSignal extends SignalGraph

signal clicked(source)
signal hovered(source)
signal left(source)

@onready var line: LineConfig = preload("res://src/source_graph.tres")
@onready var shaker: Shaker = $Shaker
@onready var border: Line2D = $Border

var oscillator: Oscillator
var selected: bool = false
var assigned_to: Slot = null
var alpha: float
var input_enabled := true


func init(_oscillator: Oscillator):
	oscillator = _oscillator
	var graph = GraphConfig.new()
	graph.line = line
	graph.oscillators.assign([_oscillator])
	graphs.assign([graph])


func _on_gui_input(event: InputEvent) -> void:
	if not input_enabled:
		return
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit(self)


func _on_mouse_entered() -> void:
	if not input_enabled:
		return
	hovered.emit(self)
	alpha = border.default_color.a
	border.default_color.a = 1
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.2)


func _on_mouse_exited() -> void:
	left.emit(self)
	border.default_color.a = alpha
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2)
