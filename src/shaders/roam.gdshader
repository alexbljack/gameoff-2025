shader_type canvas_item;

uniform float amplitude: hint_range(0.0, 200.0) = 10.0;
uniform float speed: hint_range(0.0, 5.0)   = 1.0;
uniform float phase = 0.0;

void vertex() {
    float t = TIME * speed + phase;
    float offset_x = sin(t) * amplitude;
    float offset_y = cos(t * 1.3) * amplitude;
    VERTEX += vec2(offset_x, offset_y);
}