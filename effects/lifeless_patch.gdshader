shader_type canvas_item;

uniform float desauturation_strength : hint_range(0.0, 3.0, 0.1) = 2.0;
uniform float darkness : hint_range(0.0, 1.0, 0.1);
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec4 screen_color = texture(screen_texture, SCREEN_UV);
	vec4 prev_color = texture(TEXTURE, UV);
	vec4 new_color = prev_color;
	if (prev_color.a != 0.0){
		float grayscale = (screen_color.r + screen_color.g + screen_color.b)/3.0;
		grayscale -= darkness;
		new_color.r = (screen_color.r+grayscale*desauturation_strength)/(desauturation_strength+1.0);
		new_color.g = (screen_color.g+grayscale*desauturation_strength)/(desauturation_strength+1.0);
		new_color.b = (screen_color.b+grayscale*desauturation_strength)/(desauturation_strength+1.0);
	}
	COLOR = new_color;
}
