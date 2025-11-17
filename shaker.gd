class_name Shaker extends Node

signal finished

@export var target: CanvasItem
@export var amount := 5.0
@export var duration := 1.0


func shake() -> void:
	var shake = amount
	var start_position = target.global_position
	while shake > 0:
		target.global_position = start_position
		shake -= amount * get_process_delta_time()  / duration
		shake = clampf(shake, 0, amount)
		var shake_x = randf_range(-shake, shake)
		var shake_y = randf_range(-shake, shake)
		target.global_position += Vector2(shake_x, shake_y)
		await get_tree().process_frame
	target.global_position = start_position
	finished.emit()
