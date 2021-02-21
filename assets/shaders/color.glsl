uniform vec4 replace_color = vec4( 1.0, 1.0, 1.0, 1.0 );

vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    vec4 texture_color = Texel( tex, texture_coords );

    if ( texture_color == replace_color ) {
        return color;
    }

    return texture_color;
}