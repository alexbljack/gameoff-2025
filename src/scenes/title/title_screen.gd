extends Node2D

@export var start_button: Button


func _ready() -> void:
	var loaded = Game.try_load_savefile()
	start_button.init(loaded)
