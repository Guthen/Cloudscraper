PhysicsEntities, PhysicsEntity = {}, class( GameObject )
PhysicsEntity.z = 1
PhysicsEntity.object_id = nil
PhysicsEntity.visible = true
PhysicsEntity.color = WHITE
PhysicsEntity.draw_shapes = {
    polygon = function( self )
        love.graphics.polygon( "fill", self.body:getWorldPoints( self.shape:getPoints() ) )
    end,
    circle = function( self )
        love.graphics.circle( "fill", self.body:getX(), self.body:getY(), self.shape:getRadius() )
    end,
}

PhysicsEntity.body = nil
PhysicsEntity.shape = nil
PhysicsEntity.fixture = nil
PhysicsEntity.world = nil

function PhysicsEntity:init( world, x, y, type )
    self.world = world
    self.body = love.physics.newBody( world.world, x, y, type )

    PhysicsEntities[#PhysicsEntities + 1] = self
end

function PhysicsEntity:rectangle( w, h )
    self.shape = love.physics.newRectangleShape( w, h )
    self.fixture = love.physics.newFixture( self.body, self.shape )
    return self
end

function PhysicsEntity:circle( radius )
    self.shape = love.physics.newCircleShape( radius )
    self.fixture = love.physics.newFixture( self.body, self.shape )
    return self
end

function PhysicsEntity:edge( start_x, start_y, end_x, end_y )
    self.shape = love.physics.newEdgeShape( start_x, start_y, end_x, end_y )
    self.fixture = love.physics.newFixture( self.body, self.shape )
    self.visible = false
    return self
end

function PhysicsEntity:start_mouse_joint( target, x, y )
    if self.mouse_joint then
        self:stop_mouse_joint()
    end

    self.mouse_joint = love.physics.newMouseJoint( self.body, x, y )
    self.mouse_joint_target = target
end

function PhysicsEntity:stop_mouse_joint()
    if self.mouse_joint and not self.mouse_joint:isDestroyed() then
        self.mouse_joint:destroy()
        self.mouse_joint = nil
    end
end

function PhysicsEntity:density( n )
    self.fixture:setDensity( n )
    return self
end

function PhysicsEntity:restitution( n )
    self.fixture:setRestitution( n )
    return self
end

function PhysicsEntity:friction( n )
    self.fixture:setFriction( n )
    return self
end

function PhysicsEntity:apply_linear_impulse( ix, iy )
    self.body:applyLinearImpulse( ix, iy )
    return self
end

function PhysicsEntity:apply_force( fx, fy )
    self.body:applyForce( fx, fy )
    return self
end

function PhysicsEntity:update( dt )
    if self.mouse_joint then
        --if self.mouse_joint.joystick then
            self.mouse_joint:setTarget( Camera:get_world_pos( self.mouse_joint_target.x, self.mouse_joint_target.y ) )
        --else
            --self.mouse_joint:setTarget( self.mouse_joint_target.x, self.mouse_joint_target.y )
        --end
    end
end

function PhysicsEntity:draw()
    if not self.visible then return end

    love.graphics.setColor( self.color )
    self.draw_shapes[self.shape:getType()]( self )
end

function PhysicsEntity:destroy()
    GameObject.destroy( self )

    --  free physics objects
    if not self.fixture:isDestroyed() then
        self.fixture:destroy()
    end
    if not self.body:isDestroyed() then
        self.body:destroy()
    end
    self.shape:release()
    self:stop_mouse_joint()

    --  free owner objects list
    if self.owner and self.owner.objects[self] then
        self.owner.objects[self] = nil
    end

    --  destroy reference in list
    for i, v in ipairs( PhysicsEntities ) do
        if v == self then
            table.remove( PhysicsEntities, i )
            break
        end
    end
end
