local obj = {}

--  properties
obj.default_count = 3 --  default number of this object in Race gamemode

--  visual
obj.quad_id = 1
obj.w = pixel_to_meter( 16 )
obj.h = pixel_to_meter( 16 )
obj.keep_ratio = true

--  physics
obj.density = 1
obj.restitution = .1
obj.friction = .5

return obj