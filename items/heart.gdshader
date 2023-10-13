shader_type canvas_item;

void fragment() {
	vec2 new_uv = vec2(UV.x, UV.y + sin(TIME)/6.0);
	vec4 color = texture(TEXTURE, new_uv);
	COLOR = color;
}
