require "lua.game.physicsentity"

Edge = class( PhysicsEntity )
Edge.z = 2
Edge.w = 16
Edge.h = 0

Edge.image = image( "border.png" )
Edge.image_size = Edge.image:getHeight()

function Edge:init( world, x, y, h )
    PhysicsEntity.init( self, world, x, y )
    self:edge( 0, 0, 0, h )
    self.fixture:setUserData( "edge" )

    self.x = x
    self.y = y
    self.h = h
end

function Edge:draw()
    love.graphics.setColor( { 1, 1, 1, .8 } )

    local step = pixel_to_meter( self.image_size )
    for y = 0, self.h, step do
        love.graphics.draw( self.image, self.x - self.w / 2, self.y + y + ( love.timer.getTime() * 25 ) % step, 0, self.w / self.image_size, self.w / self.image_size )
    end
end