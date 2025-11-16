class_name OscController extends Control

@export var oscillator: Oscillator

@onready var amp_slider: HSlider = $AmpControl/HSlider
@onready var freq_slider: HSlider = $FreqControl/HSlider
@onready var phase_slider: HSlider = $PhaseControl/HSlider
@onready var wave_selector: ItemList = $ItemList


func _ready() -> void:
	freq_slider.value = oscillator.freq
	amp_slider.value = oscillator.amplitide
	wave_selector.select(oscillator.wave_type)
	
	amp_slider.value_changed.connect(_on_amp_changed)
	freq_slider.value_changed.connect(_on_freq_changed)
	wave_selector.item_selected.connect(_on_type_selected)

func _on_amp_changed(value: float):
	oscillator.amplitide = value


func _on_freq_changed(value: float):
	oscillator.freq = value


func _on_type_selected(index: int):
	oscillator.wave_type = index as Oscillator.WaveType
