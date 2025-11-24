shader_type canvas_item;

uniform vec4 pulse_color : source_color = vec4(1.0, 0.25, 0.25, 1.0);
uniform float pulse_strength : hint_range(0.0, 1.0) = 0.8;
uniform float speed : hint_range(0.0, 10.0) = 2.0;
uniform float sharpness : hint_range(0.0, 1.0) = 0.0;

uniform bool use_keymask = false;
uniform vec3 key_color = vec3(1.0, 1.0, 1.0);
uniform float mask_tolerance : hint_range(0.0, 1.0) = 0.2;

void fragment() {
    vec4 base = texture(TEXTURE, UV);

    float t = 0.5 + 0.5 * sin(TIME * speed * 6.2831853);
    float shape = mix(t, pow(clamp(t, 0.0001, 1.0), 0.2), sharpness);
    float mask = 1.0;
    if (use_keymask) {
        float d = distance(base.rgb, key_color);
        mask = 1.0 - smoothstep(0.0, mask_tolerance, d);
    }

    vec3 target = mix(base.rgb, pulse_color.rgb, pulse_strength);
    vec3 out_rgb = mix(base.rgb, target, shape * mask);

    COLOR = vec4(out_rgb, base.a);
}