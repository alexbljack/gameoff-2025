extends Node2D

enum SawDir { UP, DOWN }

@export var spawn_interval: float = 0.35
@export var amplitude: float = 100.0          # амплитуда по Y
@export var period_px: float = 220.0          # длина периода волны в пикселях
@export var ball_scene: PackedScene

# волна «едет» фазой — это и даёт движение
@export var saw_direction: SawDir = SawDir.UP
@export var phase_speed_cycles_per_sec: float = 0.3
@export_range(0.0, 1.0, 0.001) var phase: float = 0.0

# визуализация волны
@export var draw_wave: bool = true
@export var wave_samples: int = 1000
@export var wave_line_width: float = 2.0
var wave_color := Color(0.45, 0.85, 1.0, 0.9)

var _timer := 0.0
var _balls: Array = []    # элементы: {node: Node2D, u: float} , где u = x/period % 1

func _process(delta: float) -> void:
	# едем фазой (волна сдвигается)
	phase = fposmod(phase + phase_speed_cycles_per_sec * delta, 1.0)

	# спавним новые шарики
	_timer += delta
	if _timer >= spawn_interval:
		_timer = 0.0
		_spawn_ball()

	# обновляем y каждого шарика: x фиксирован, y из текущей фазы волны
	var vh := get_viewport_rect().size.y
	var y0 := vh * 0.5

	for item in _balls:
		var u: float = item.u                     # «локальная» фаза от x позиции
		var y := _saw_y(fposmod(u + phase, 1.0))  # двигаем только фазой
		item.node.position.y = y0 + y

	queue_redraw()

func _draw() -> void:
	if not draw_wave:
		return

	# рисуем саму пилу как движущееся «полотно» для наглядности
	var rect := get_viewport_rect()
	var w := rect.size.x
	var h := rect.size.y
	var y0 := h * 0.5

	var n = max(2, wave_samples)
	var p= max(1.0, period_px)

	var pts: PackedVector2Array = []
	pts.resize(n)

	for i in range(n):
		var x = lerp(0.0, w, float(i) / float(n - 1))
		var u := fposmod(x / p + phase, 1.0)  # какая часть периода «под этим x» сейчас
		var y := y0 + _saw_y(u)
		pts[i] = Vector2(x, y)

	draw_polyline(pts, wave_color, wave_line_width)

# ===== пилообразная форма, нормированная в [-A, +A] =====
func _saw_y(u: float) -> float:
	# u в [0,1). UP: -A -> +A, DOWN: +A -> -A
	var s := 2.0 * u - 1.0
	if saw_direction == SawDir.DOWN:
		s = -s
	return s * amplitude

func _spawn_ball() -> void:
	if ball_scene == null:
		push_warning("⚠ ball_scene не назначен.")
		return

	var vw := get_viewport_rect().size.x
	var vh := get_viewport_rect().size.y
	var y0 := vh * 0.5
	var p = max(1.0, period_px)

	# ставим шарик в случайную X-позицию (или выберите сетку/левый край)
	var x := randf_range(0.0, vw)
	var ball := ball_scene.instantiate()
	add_child(ball)
	ball.position = Vector2(x, y0)

	# запоминаем «горизонтальную фазу» u, чтобы шарик всегда был на той же «точке волны»
	var u := fposmod(x / p, 1.0)
	_balls.append({ "node": ball, "u": u })
