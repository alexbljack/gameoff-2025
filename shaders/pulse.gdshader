shader_type canvas_item;

uniform float speed : hint_range(0.0, 10.0) = 2.0;
uniform float amplitude : hint_range(0.0, 1.0) = 0.2;

void vertex() {
    float scale = 1.0 + sin(TIME * speed) * amplitude;
    VERTEX = VERTEX * scale;
}