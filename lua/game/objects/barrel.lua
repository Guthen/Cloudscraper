local obj = {}

--  properties
obj.default_count = 5 --  default number of this object in Race gamemode

--  visual
obj.quad_id = 2
obj.w = pixel_to_meter( 12 )
obj.h = pixel_to_meter( 16 )
obj.keep_ratio = true

--  physics
obj.density = 2
obj.restitution = .02
obj.friction = .75

return obj