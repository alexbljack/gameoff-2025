extends TextureRect

@export var active_texture: Texture2D
@export var spent_texture: Texture2D

@onready var shaker: Shaker = $Shaker

var spent = false


func _ready() -> void:
	texture = active_texture


func init(is_spent: bool) -> void:
	spent = is_spent
	texture = spent_texture if is_spent else active_texture


func spend() -> void:
	spent = true
	shaker.shake()
	texture = spent_texture
