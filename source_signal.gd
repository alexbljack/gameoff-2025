class_name SourceSignal extends Control

signal clicked(source)

@onready var graph: SignalGraph = $Graph
@onready var shaker: Shaker = $Shaker

var selected: bool = false
var assigned_to: SignalSlot = null

var alpha: float
var initial_position: Vector2


func _ready() -> void:
	await get_tree().process_frame
	initial_position = global_position


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit(self)


func _on_mouse_entered() -> void:
	alpha = graph.border_color.a
	graph.border_color.a = 1
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.2)



func _on_mouse_exited() -> void:
	graph.border_color.a = alpha
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2)
