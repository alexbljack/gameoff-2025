extends HBoxContainer

@export var marker_scene: PackedScene


func _ready() -> void:
	pass # Replace with function body.


func init(attempts: int) -> void:
	for child in get_children():
		child.call_deferred("queue_free")

	for i in range(attempts):
		var m = marker_scene.instantiate()
		add_child(m)


func spend_attempt():
	for child in get_children():
		if not child.spent:
			child.spend()
			return
