extends Area2D
class_name PlayerVisibilityNode

func _process(delta):
	set_collision_layer_value(1, false)
	set_collision_mask_value(2, true)
	set_collision_mask_value(1, false)
	if get_overlapping_bodies().size() > 0:
		get_parent().modulate.a = 0.6
	else:
		get_parent().modulate.a = 1
