#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float curvature;
    float scanlineStrength;
    float opacityVal;
};

layout(binding = 1) uniform sampler2D source;

void main() {
    vec2 uv = qt_TexCoord0;

    // --- 1. BARREL DISTORTION ---
    vec2 dc = abs(0.5 - uv);
    vec2 dc2 = dc * dc;
    uv.x -= 0.5; uv.x *= 1.0 + (dc2.y * (curvature * 0.5)); uv.x += 0.5;
    uv.y -= 0.5; uv.y *= 1.0 + (dc2.x * (curvature * 0.5)); uv.y += 0.5;

    // --- 2. BLACK BORDER ---
    if(uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    }

    // --- 3. COLOR & SCANLINES ---
    vec4 color = texture(source, uv);
    float scanline = sin(uv.y * 800.0) * 0.5 + 0.5;
    color.rgb -= scanline * scanlineStrength;

    fragColor = color * qt_Opacity * opacityVal;
}
