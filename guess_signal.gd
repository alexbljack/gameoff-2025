extends Control

signal clicked

@onready var graph: SignalGraph = $Graph
@onready var check_box: CheckBox = $CheckBox

var selected: bool = false


func _ready() -> void:
	check_box.button_pressed = selected


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			selected = not selected
			check_box.button_pressed = selected
			clicked.emit()
