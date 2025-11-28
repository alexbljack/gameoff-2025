class_name Convertor extends ColorRect

@export var slot_scene: PackedScene

var slots: Array = []
var result_osc_count: int
var unmatched_combos: Array = []

var has_free_slot: bool:
	get:
		return get_free_slot() != null

@onready var slots_container: VBoxContainer = $Slots


func _ready() -> void:
	Utils.delete_all_children(slots_container)


func init(slots_count: int, results_count: int) -> void:
	result_osc_count = results_count
	for i in slots_count:
		var slot = slot_scene.instantiate()
		slots_container.add_child(slot)
		slots.append(slot)


func get_free_slot() -> Slot:
	for slot in slots:
		if not slot.source_signal:
			return slot
	return null


func get_signals_in_slots() -> Array:
	return slots.map(func(s): return s.source_signal)


func get_oscillators() -> Array:
	var result := []
	for source in get_signals_in_slots():
		if source != null:
			result.append_array(source.oscillators)
	return result


func save_unmatched():
	unmatched_combos.append(get_oscillators())


func is_already_unmatched() -> bool:
	var oscs = get_oscillators()
	if oscs.size() < result_osc_count:
		return false

	for combo in unmatched_combos:
		var result = oscs.all(func (o): return o in combo)
		if result:
			return true
	return false
