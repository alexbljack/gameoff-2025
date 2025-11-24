class_name GraphConfig extends Resource

@export var oscillators: Array[Oscillator]
@export var line: LineConfig


func get_sample_points(width: int, cy: float, amp_px: int):
	var points: PackedVector2Array = []
	for i: int in range(line.points_number):
		var t = float(i) / float(line.points_number - 1)
		var x = t * width
		var y_norm = 0.0
		for osc: Oscillator in oscillators:
			y_norm += osc.sample(t)
		var y = cy - y_norm * amp_px
		points.append(Vector2(x, y))
	return points
