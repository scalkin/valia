extends Line2D
class_name Trail

@export var length = 30
@export var frequency = 5
@export var random_offset = Vector2.ZERO

func _ready():
	top_level = true
	add_point(get_parent().global_position)

func _process(_delta):
	global_position = Vector2.ZERO
	
	if get_parent().global_position.distance_to(points[points.size() - 1]) > frequency:
		add_point(get_parent().global_position+ Vector2(randf_range(-random_offset.x, random_offset.x), randf_range(-random_offset.y, random_offset.y)))
		
		if points.size() > length:
			remove_point(0)
