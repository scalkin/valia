@tool
extends StaticBody2D

@export var texture_id = 0:
	set(value):
		if get_node_or_null("multitexturesprite") != null:
			get_node("multitexturesprite").texture_id = value
			texture_id = get_node("multitexturesprite").texture_id
		else:
			texture_id = 0
