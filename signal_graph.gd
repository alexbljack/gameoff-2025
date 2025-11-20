class_name SignalGraph extends ColorRect

@export var oscillators: Array[Oscillator]
@export var second_plot: Array[Oscillator]
@export var max_amplitude: float = 3

@export var points_number: int = 128
@export var line_color: Color = Color(0.35, 0.75, 1.0)
@export var glow_color: Color = Color(0.35, 0.75, 1.0)
@export var secondary_color: Color = Color(0.905, 0.083, 0.268, 1.0)
@export var line_width: float = 3

@export var border_width: float = 2
@export var border_color: Color = Color(0.35, 0.75, 1.0)

var w
var h
var cy
var cx
var period_px
var amp_px
var col_major = Color(0.5, 0.5, 0.5, 0.3)


func _ready() -> void:
	w = size.x
	h = size.y
	cy = h * 0.5
	cx = w * 0.5
	period_px = w / 5
	amp_px = h * 0.5 / max_amplitude


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	_draw_grid()
	_draw_border()

	draw_line(Vector2(0, cy), Vector2(w, cy), col_major, 2.0, true)
	_draw_wave(oscillators, glow_color, line_width * 4)
	_draw_wave(oscillators, line_color, line_width)
	if second_plot:
		_draw_wave(second_plot, secondary_color, 6)


func _draw_wave(_oscillators: Array, _color: Color, _width: float) -> void:
	var pts: PackedVector2Array = []
	for i: int in range(points_number):
		var t = float(i) / float(points_number - 1)
		var x = t * w
		var y_norm = 0.0
		for osc: Oscillator in _oscillators:
			y_norm += osc.sample(t)
		var y = cy - y_norm * amp_px
		pts.append(Vector2(x, y))

	draw_polyline(pts, _color, _width, true)


func _draw_grid() -> void:
	var col_minor := Color(0.35, 0.35, 0.38, 0.35)

	for x in range(0, int(w) + 1, period_px):
		draw_line(Vector2(x, 0), Vector2(x, h), col_minor, 1.0, true)

	for y in range(0, int(h) + 1, amp_px):
		draw_line(Vector2(0, y), Vector2(w, y), col_major, 1.0, true)


func _draw_border():
	draw_line(Vector2(0, 0), Vector2(w, 0), border_color, border_width, true)
	draw_line(Vector2(0, 0), Vector2(0, h), border_color, border_width, true)
	draw_line(Vector2(w, 0), Vector2(w, h), border_color, border_width, true)
	draw_line(Vector2(0, h), Vector2(h, w), border_color, border_width, true)
