extends TextureRect

@export var active_texture: Texture2D
@export var spent_texture: Texture2D

@onready var shaker: Shaker = $Shaker

var spent = false


func _ready() -> void:
	texture = active_texture


func spend():
	spent = true
	shaker.shake()
	texture = spent_texture
