local obj = {}

--  properties
obj.default_count = 3 --  default number of this object in Race gamemode

--  visual
obj.quads = { love.graphics.newQuad( TEXTURE_SIZE * 3, 0, TEXTURE_SIZE, TEXTURE_SIZE * 2, TILESET:getDimensions() ) }
obj.quad_id = 1
obj.w = pixel_to_meter( 6 )
obj.h = pixel_to_meter( 32 )
obj.keep_ratio = true

--  physics
obj.density = 4
obj.restitution = .05
obj.friction = 1

return obj