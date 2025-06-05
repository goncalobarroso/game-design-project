shader_type canvas_item;
uniform sampler2D SCREE_TEXTURE: hint_screen_texture, filter_linear_mipmap;

uniform float lod: hint_range(0.0, 5) = 0.0;

void fragment(){
	vec4 color = texture(SCREE_TEXTURE, SCREEN_UV, lod);
	COLOR = color;
}
