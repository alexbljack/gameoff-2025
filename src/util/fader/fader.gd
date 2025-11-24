class_name Fader extends CanvasLayer

signal finished

@onready var fade_rect: ColorRect = $FadeRect

var _color: Color
var _size: Vector2i


func _ready() -> void:
	_color = fade_rect.color
	_size = get_viewport().size
	fade_rect.pivot_offset = _size / 4


func fade_in(time: float):
	fade_rect.color = Color(_color, 0)
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(_color, 1), time)
	await tween.finished
	finished.emit()


func fade_out(time: float):
	fade_rect.color = Color(_color, 1)
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(_color, 0), time)
	await tween.finished
	finished.emit()


func scale_in(time: float):
	var tween = create_tween()
	fade_rect.scale = Vector2.ZERO
	tween.tween_property(fade_rect, "scale", Vector2.ONE, time)
	await tween.finished
	finished.emit()


func scale_out(time: float):
	var tween = create_tween()
	fade_rect.scale = Vector2.ONE
	tween.tween_property(fade_rect, "scale", Vector2.ZERO, time)
	await tween.finished
	finished.emit()
