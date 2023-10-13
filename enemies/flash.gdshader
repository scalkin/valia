shader_type canvas_item;

uniform bool flash = false;

void fragment() {
	vec4 prev_color = texture(TEXTURE, UV);
	vec4 new_color = prev_color;
	if (flash){
		new_color.rgb = vec3(1.0, 1.0, 1.0);
	}
	COLOR = new_color;
}
