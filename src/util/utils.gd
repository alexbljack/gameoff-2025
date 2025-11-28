class_name Utils


static func delete_nodes(nodes: Array) -> void:
	for node: Node in nodes:
		node.queue_free()
		await node.tree_exited


static func delete_all_children(node: Node) -> void:
	await delete_nodes(node.get_children())


static func get_random_items(arr: Array, count: int) -> Array:
	var result = []
	while result.size() < count:
		var item = arr.pick_random()
		if item not in result:
			result.append(item)
	return result