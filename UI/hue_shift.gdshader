shader_type canvas_item;

uniform vec3 filter_color : source_color;

void fragment() {
    vec4 base_color = texture(TEXTURE, UV);
    vec3 color = mix(base_color.rgb, filter_color, 1);
    COLOR = vec4(color, base_color.a);
}
