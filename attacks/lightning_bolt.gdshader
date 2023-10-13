shader_type canvas_item;

uniform float cutoff : hint_range(0.0, 1.0, 0.2) = 0.0;

void fragment() {
	vec4 prev_color = texture(TEXTURE, UV);
	vec4 new_color = prev_color;
	if (prev_color.a >= cutoff){
		new_color.a = 1.0;
	}
	else{
		new_color.a = 0.0;
	}
	COLOR = new_color;
}
