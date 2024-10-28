shader_type canvas_item;

uniform float radius_scale: hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float width = 1;
uniform float height = 1;

void fragment() {
    vec4 image = texture(TEXTURE, UV);
    vec2 pos = vec2(UV.x * width, UV.y * height);
    float radius = min(width, height) * radius_scale / 2.0;
    float dist = length(pos - vec2(width / 2.0, height / 2.0));
    if (dist > radius) {
        image.a = 0.0;
    }
    vec4 color;
    color = mix(image.rgba, COLOR.rgba, image.a);
    COLOR.rgba = color.rgba;
}
