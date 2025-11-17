extends TextureRect

@onready var tw = get_tree().create_tween()

func _ready():
    breathe()

func breathe():
    tw = get_tree().create_tween().set_loops()
    tw.tween_property(self, "scale", Vector2(1.03, 1.03), 4.0)
    tw.tween_property(self, "scale", Vector2(1.0, 1.0), 4.0)