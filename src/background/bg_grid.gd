extends TextureRect


func _ready():
    breathe()


func breathe():
    var tween = get_tree().create_tween().set_loops()
    tween.tween_property(self, "scale", Vector2(1.03, 1.03), 4.0)
    tween.tween_property(self, "scale", Vector2(1.0, 1.0), 4.0)