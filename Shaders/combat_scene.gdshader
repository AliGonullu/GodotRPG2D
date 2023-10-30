shader_type canvas_item;

uniform vec4 color;

void fragment() {
	/*
	vec4 pixelColor = texture(TEXTURE, UV);
	COLOR = pixelColor;
	*/
	COLOR.rgb = COLOR.bgr;
}
