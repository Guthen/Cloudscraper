--[[ Entities, Entity = {}, class( GameObject )

--  position
Entity.x, Entity.y = 0, 0
Entity.ang = 0

--  image
Entity.image = image( "player.png" )
Entity.quad_id, Entity.quads = 1, quads( Entity.image )
Entity.anim_fps, Entity.anim_time = 5, 0
Entity.color = WHITE

--  methods
function Entity:init( x, y, ... )
    self.x, self.y = x or self.x, y or self.y

    Entities[self.id] = self
end

function Entity:update_anim( dt )
    self.anim_time = self.anim_time + dt
    if self.anim_time >= 1 / self.anim_fps then
        self.quad_id = self.quad_id + 1 > #self.quads and 1 or self.quad_id + 1
        self.anim_time = 0
    end
end

function Entity:update( dt )
    self:update_anim( dt )
end

function Entity:draw()
    love.graphics.setColor( self.color )
    love.graphics.draw( self.image, self.quads[self.quad_id], self.x, self.y, self.ang, SIZE_FACTOR, SIZE_FACTOR )
end

function Entity:destroy()
    Entities[self.id] = nil
    GameObject.destroy( self )
end ]]