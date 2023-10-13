shader_type canvas_item;

uniform float open_amount :hint_range(0.4, 0.6, 0.01) = 0.0;

void fragment() {
	vec4 new_color = vec4(0.0, 0.0, 0.0, 0.0);
	vec2 shifted_uv = UV - vec2(0.5, 0.5);
	float distance_from_center = sqrt(abs(shifted_uv.x*shifted_uv.x) + abs(shifted_uv.y*shifted_uv.y));
	if (distance_from_center < open_amount){
		new_color.a = 0.0;
	}
	else{
		new_color.a = 1.0-open_amount/distance_from_center;
	}
	COLOR = new_color;
}
