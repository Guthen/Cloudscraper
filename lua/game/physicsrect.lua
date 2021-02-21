PhysicsRect = class( PhysicsEntity )
PhysicsRect.image = nil
PhysicsRect.quads = nil
PhysicsRect.quad_id = 1
PhysicsRect.w = 16
PhysicsRect.h = 16

function PhysicsRect:init( world, x, y, w, h, type )
    PhysicsEntity.init( self, world, x, y, type or "dynamic" )
    self:rectangle( w or self.w, h or self.h )

    self.w = w
    self.h = h
end

function PhysicsRect:set_image( image, quads, quad_id, keep_ratio )
    self.image = image
    self.quads = quads
    self.quad_id = quad_id or self.quad_id

    --  compute viewport
    local w, h = image:getDimensions()
    if quads and quad_id then
        w, h = select( 3, quads[quad_id]:getViewport() )
    end
    self.viewport_w, self.viewport_h = w, h

    --  compute scale
    if keep_ratio then
        local scale = math.max( self.w / self.viewport_w, self.h / self.viewport_h ) + .1
        self.scale_x, self.scale_y = scale, scale
    else
        self.scale_x, self.scale_y = self.w / self.viewport_w, self.h / self.viewport_h
    end

    return self
end

function PhysicsRect:draw()
    love.graphics.setColor( self.color )

    --[[ if self.owner then
        love.graphics.setShader( Shaders.COLOR )
    end ]]
    
    if self.image then
        if self.quads then
            local quad = self.quads[self.quad_id]
            love.graphics.draw( self.image, quad, self.body:getX(), self.body:getY(), self.body:getAngle(), self.scale_x, self.scale_y, self.viewport_w / 2, self.viewport_h / 2 )
        else
            love.graphics.draw( self.image, self.body:getX(), self.body:getY(), self.body:getAngle(), self.scale_x, self.scale_y, self.viewport_w / 2, self.viewport_h / 2 )
        end
    else
        PhysicsEntity.draw( self )
    end

    --[[ if self.owner then
        love.graphics.setShader()
    end ]]
end