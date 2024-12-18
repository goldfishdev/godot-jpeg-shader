shader_type canvas_item;

// to use:
// create a ColorRect that covers the area you want
// apply shader as the material for it


uniform sampler2D screen_texture : hint_screen_texture;

uniform float washout_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float blur_amount : hint_range(0.0, 5.0) = 1.0;
uniform float blockiness : hint_range(50.0, 300.0) = 150.0;
uniform float color_steps : hint_range(8, 32) = 16.0;
uniform float grain_amount : hint_range(0.0, 0.1) = 0.02;
void fragment() {
    // compress some
    vec2 block_uv = floor(UV * blockiness) / blockiness;

    // blur-ish
    vec2 texel_size = vec2(1.0) / vec2(textureSize(screen_texture, 0));
    vec4 color = vec4(0.0);
    vec3 avg_color = vec3(0.0);
    int samples = 0;

    for (float x = -1.0; x <= 1.0; x++) {
        for (float y = -1.0; y <= 1.0; y++) {
            if (mod(x + y, 2.0) == 0.0) {
                color += texture(screen_texture, block_uv + vec2(x, y) * texel_size * blur_amount);
                avg_color += texture(screen_texture, block_uv + vec2(x, y) * texel_size).rgb;
                samples++;
            }
        }
    }

    color /= float(samples);
    avg_color /= float(samples);

    // make kind of washed out
    float grayscale = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    color.rgb = mix(color.rgb, vec3(grayscale) + vec3(0.1), washout_intensity);
    color.rgb = floor(color.rgb * (color_steps * 1.5)) / (color_steps * 1.5);

    // grain
    float noise = (fract(sin(dot(block_uv * vec2(12.9898, 78.233), vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * 2.0;
    color.rgb += noise * (grain_amount * 0.5); // Reduced grain amount

    COLOR = clamp(color, 0.0, 1.0);
}
