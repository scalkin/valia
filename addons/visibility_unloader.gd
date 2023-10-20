extends Area2D
class_name VisibilityUnloader

func _process(delta):
	set_collision_layer_value(1, false)
	set_collision_mask_value(8, true)
	set_collision_mask_value(1, false)
	get_parent().visible = get_overlapping_areas().size() > 0
