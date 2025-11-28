extends HBoxContainer

@export var marker_scene: PackedScene


func init(attempts: int, max_attempts: int) -> void:
	for child in get_children():
		child.call_deferred("queue_free")

	var spent_ids = max_attempts - attempts

	for i in range(max_attempts):
		var m = marker_scene.instantiate()
		add_child(m)
		var is_spent = i < spent_ids 
		m.init(is_spent)



func spend_attempt() -> void:
	for child in get_children():
		if not child.spent:
			child.spend()
			return
