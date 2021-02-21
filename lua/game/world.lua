World = class( GameObject )
World.z = 10
World.px = 0

function World:init( px, x_gravity, y_gravity )
    love.physics.setMeter( px )
    self.world = love.physics.newWorld( x_gravity or 0, y_gravity or 9.81 * px, true )
    self.px = px
end

function World:update( dt )
    self.world:update( dt )
end

function World:destroy()
    GameObject.destroy( self )

    self.world:destroy()
end