shader_type canvas_item;

uniform float saturation;
void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    COLOR.rgb = mix(vec3(dot(tex_color.rgb, vec3(0.21, 0.44, 2.5))), tex_color.rgb, saturation);
	COLOR.rgb = COLOR.rgg;
	COLOR.a = tex_color.a;
}
