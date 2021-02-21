require "lua.game.physicsentity"
require "lua.game.physicsrect"

local GRASS, DIRT = 5, 9
Ground = class( PhysicsRect )
Ground.z = 3
Ground.quad_id = GRASS

function Ground:init( world, x, y, w, h )
    PhysicsRect.init( self, world, x, y, w, h, "static" )
    self:set_image( TILESET, TILESET_QUADS, self.quad_id, false )
end

function Ground:draw()
    love.graphics.setColor( WHITE )
        
    local scale = pixel_to_meter( 1 )
    local step_x, step_y = math.ceil( self.w / self.scale_x ), math.ceil( self.h / self.scale_y )
    local left_x, left_y = self.body:getWorldPoints( self.shape:getPoints() )
    for x = 0, self.w - PX, PX do
        for y = 0, self.h - PX, PX do
            love.graphics.draw( self.image, self.quads[y == 0 and GRASS or DIRT], left_x + x, left_y + y, self.body:getAngle(), scale, scale )
        end
    end
end