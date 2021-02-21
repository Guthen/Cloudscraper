Camera = {}
Camera.x, Camera.y = 0, 0
Camera.shake_force = 0
Camera.bounds = {
    min_x = 0, 
    max_x = 200,
    min_y = 0, 
    max_y = 200,
    active = true,
}
Camera.pushed = false
Camera.translate_x, Camera.translate_y = 0, 0

local w, h = love.graphics.getDimensions()
function Camera:center( x, y )
    self:set_pos( x - w / 2, y - h / 2 )
end

function Camera:set_pos( x, y )
    self.x = self.bounds.active and clamp( x, self.bounds.min_x, self.bounds.max_x ) or x
    self.y = self.bounds.active and clamp( y, self.bounds.min_y, self.bounds.max_y ) or y
end

function Camera:move( x, y )
    self:set_pos( self.x + x, self.y + y )
end

function Camera:get_mouse_pos()
    return self:get_world_pos( love.mouse.getPosition() )
end

function Camera:get_world_pos( x, y )
    return self.x + x, self.y + y
end

function Camera:shake( force )
    self.shake_force = self.shake_force + force
end

function Camera:update( dt )
    --  shake
    if self.shake_force > .5 then
        self.shake_force = lerp( dt * 3, self.shake_force, 0 )
    else
        self.shake_force = approach( dt * 3, self.shake_force, 0 )
    end

    local x, y = -self.x, -self.y
    if self.shake_force > 0 then
        x = x + math.random() * self.shake_force
        y = y + math.random() * self.shake_force
    end
    self.translate_x, self.translate_y = x, y
end

function Camera:push()
    love.graphics.push()
    love.graphics.translate( self.translate_x, self.translate_y )

    self.pushed = true
end

function Camera:pop()
    love.graphics.pop()

    self.pushed = false
end

function Camera:reset()
    self.x, self.y = 0, 0
    self.shake_force = 0
    self.translate_x, self.translate_y = 0, 0
    self.pushed = false
end