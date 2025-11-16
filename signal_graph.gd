class_name SignalGraph extends ColorRect

enum WaveType { SINE, SAW, SQUARE, TRIANGLE }

@export var oscillators: Array[Oscillator]
@export var second_plot: Array[Oscillator]

@export var points_number: int = 128
@export var line_color: Color = Color(0.35, 0.75, 1.0)
@export var secondary_color: Color = Color(0.905, 0.083, 0.268, 1.0)
@export var line_width: float = 2.0

@export var draw_grid: bool = true
@export var grid_step_px: int = 50

var w
var h
var cy
var period_px
var amp_px


func _ready() -> void:
	w = size.x
	h = size.y
	cy = h * 0.5
	period_px = w / 5
	amp_px = h * 0.5 * 0.5


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if draw_grid:
		_draw_grid()

	draw_line(Vector2(0, cy), Vector2(w, cy), Color(0.5, 0.5, 0.5, 0.6), 1.0)
	_draw_wave(oscillators, line_color)
	if second_plot:
		_draw_wave(second_plot, secondary_color)


func _draw_wave(_oscillators: Array, _color: Color) -> void:
	var pts: PackedVector2Array = []
	for i: int in range(points_number):
		var t = float(i) / float(points_number - 1)
		var x = t * w
		var y_norm = 0.0
		for osc: Oscillator in _oscillators:
			y_norm += osc.sample(t)
		var y = cy - y_norm * amp_px
		pts.append(Vector2(x, y))

	draw_polyline(pts, _color, line_width)


func _draw_grid() -> void:
	var step = max(10, grid_step_px)
	var col_minor := Color(0.35, 0.35, 0.38, 0.35)
	var col_major := Color(0.45, 0.45, 0.5, 0.6)

	for x in range(0, int(w) + 1, step):
		var c := col_major if (x % (step * 2) == 0) else col_minor
		draw_line(Vector2(x, 0), Vector2(x, h), c, 1.0)
	for y in range(0, int(h) + 1, step):
		var c := col_major if (y % (step * 2) == 0) else col_minor
		draw_line(Vector2(0, y), Vector2(w, y), c, 1.0)
