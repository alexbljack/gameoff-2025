extends Node

@export var fader: PackedScene
@export var level_scene: PackedScene
@export var title_scene: PackedScene


func change_scene(new_scene: Node, fade_time: float = 1, change_pause: float = 0) -> void:
	var root = get_tree().root
	var current_scene = get_tree().current_scene
	var fader_in: Fader = fader.instantiate()
	root.add_child(fader_in)
	fader_in.fade_in(fade_time / 2)
	await fader_in.finished
	current_scene.queue_free()
	await current_scene.tree_exited
	var fader_out: Fader = fader.instantiate()
	root.add_child(fader_out)
	root.add_child(new_scene)
	if change_pause > 0:
		await get_tree().create_timer(change_pause).timeout
	fader_in.queue_free()
	get_tree().current_scene = new_scene
	fader_out.fade_out(fade_time / 2)
	await fader_out.finished
	fader_out.queue_free()


func load_level() -> void:
	var scene = level_scene.instantiate()
	change_scene(scene, 2)


func load_title() -> void:
	var scene = title_scene.instantiate()
	change_scene(scene, 2)
