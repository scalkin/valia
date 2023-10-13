extends Sprite2D

func _process(_delta):
	#position.x = -3*(abs(cos(abs(get_parent().rotation+2)))+2)
	#position.x = 2*(abs(get_parent().rotation))-10
	if get_parent().get_parent().tertiary_active:
		position.x = -4
		return
	position.x = (abs(cos(get_parent().rotation)*2)*-4)-5
