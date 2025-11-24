class_name Utils


static func delete_nodes(nodes: Array) -> void:
	for node: Node in nodes:
		node.queue_free()
		await node.tree_exited


static func delete_all_children(node: Node) -> void:
	await delete_nodes(node.get_children())


static func get_random_items(arr: Array, count: int):
	var n = 0
	var result = []
	while n < count:
		var item = arr.pick_random()
		if item not in result:
			result.append(item)
			n += 1
	return result