# Excerpt from DroneDash — a generic node object pool.
# Recycles hazards, pickups and particle effects instead of
# instantiating/freeing them on every spawn, which keeps frame
# times smooth and avoids GC hitches on mobile.
#
# Usage:  var n = pool.get_object(scene); add_child(n)
#         pool.return_object(n, scene.resource_path)

class_name ObjectPool
extends Node

var pool: Dictionary = {}  # scene_path -> Array[Node]

## Get an object from the pool, or instantiate a new one if pool is empty.
## Caller must call add_child() on the returned node.
func get_object(scene: PackedScene) -> Node:
	var path = scene.resource_path

	if not pool.has(path):
		pool[path] = []

	# Try to get a valid recycled object
	while pool[path].size() > 0:
		var obj = pool[path].pop_back()
		if is_instance_valid(obj):
			obj.visible = true
			obj.set_process(true)
			obj.set_physics_process(true)
			return obj

	# Pool empty or all refs stale — instantiate fresh
	return scene.instantiate()

## Return an object to the pool for reuse.
## Removes from tree, disables processing, calls reset_for_pool() if available.
func return_object(obj: Node, scene_path: String) -> void:
	if not is_instance_valid(obj):
		return

	# Remove from scene tree so add_child() works on next get
	if obj.get_parent():
		obj.get_parent().remove_child(obj)

	# Disable
	obj.visible = false
	obj.set_process(false)
	obj.set_physics_process(false)

	# Let the object reset its own state
	if obj.has_method("reset_for_pool"):
		obj.reset_for_pool()

	if not pool.has(scene_path):
		pool[scene_path] = []
	pool[scene_path].append(obj)

## Clear all pooled objects (call on scene change / game over cleanup)
func clear_all() -> void:
	for path in pool:
		for obj in pool[path]:
			if is_instance_valid(obj):
				obj.queue_free()
	pool.clear()
