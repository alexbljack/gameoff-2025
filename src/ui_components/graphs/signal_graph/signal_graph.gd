class_name SignalGraph extends ColorRect

@export var max_amplitude: float = 3
@export var graphs: Array[GraphConfig]
@export var draw_grid: bool = true

var w
var h
var cy
var cx
var period_px
var amp_px
var col_major = Color(0.5, 0.5, 0.5, 0.3)
var initial_position: Vector2


func _ready() -> void:
	w = size.x
	h = size.y
	cy = h * 0.5
	cx = w * 0.5
	period_px = w / 5
	amp_px = h * 0.5 / max_amplitude
	await get_tree().process_frame
	initial_position = global_position


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if draw_grid:
		_draw_grid()
	for graph in graphs:
		_draw_wave(graph)


func _draw_wave(config: GraphConfig) -> void:
	if not config.oscillators:
		return
	var points = config.get_sample_points(w, cy, amp_px)
	draw_polyline(points, config.line.glow_color, config.line.glow_width, true)
	draw_polyline(points, config.line.color, config.line.width, true)


func _draw_grid() -> void:
	draw_line(Vector2(0, cy), Vector2(w, cy), col_major, 2.0, true)
	var col_minor := Color(0.35, 0.35, 0.38, 0.35)
	for x in range(0, int(w) + 1, period_px):
		draw_line(Vector2(x, 0), Vector2(x, h), col_minor, 1.0, true)
	for y in range(0, int(h) + 1, amp_px):
		draw_line(Vector2(0, y), Vector2(w, y), col_major, 1.0, true)
