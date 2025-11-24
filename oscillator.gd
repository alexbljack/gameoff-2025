class_name Oscillator extends Resource

static var SPEED := 0.15

enum WaveType { SINE, SAW, SQUARE, TRIANGLE }

@export var wave_type: WaveType = WaveType.SINE
@export_range(0, 1.0, 0.2) var amplitide: float = 1
@export_range(1, 5.0, 1) var freq: float = 1
@export_range(0, 1.0, 0.25) var phase_offset: float = 0


func sample(x: float) -> float:
	var t = Time.get_ticks_msec() / 1000.0
	var base_phase = freq * (x - SPEED * t)
	var phase = TAU * (base_phase + phase_offset)
	return amplitide * _wave_sample(phase)


func _wave_sample(phase: float) -> float:
	match wave_type:
		WaveType.SINE:
			return sin(phase)
		WaveType.SQUARE:
			return 1.0 if sin(phase) >= 0.0 else -1.0
		WaveType.SAW:
			return 2.0 * _get_frac(phase) - 1.0
		WaveType.TRIANGLE:
			return 1.0 - abs(2.0 * _get_frac(phase) - 1.0) * 2.0
	return 0.0


func _get_frac(phase: float) -> float:
	return fposmod(phase, TAU) / TAU


static func rand_osc() -> Oscillator:
	var osc = Oscillator.new()
	osc.amplitide = snapped(randf_range(0.2, 1.0), 0.2)
	osc.freq = snapped(randf_range(1, 5), 1.0) # randomize
	osc.wave_type = randi_range(0, 3) as Oscillator.WaveType
	return osc
