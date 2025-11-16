extends Node

var phase := 0.0
var wave_speed := 0.2

func _process(delta: float) -> void:
	phase += TAU * wave_speed * delta
