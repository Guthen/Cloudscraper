
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    vec4 texture_color = Texel( tex, texture_coords );

    if ( texture_color.a == 0 ) {
        return texture_color;
    }

    return color;
}