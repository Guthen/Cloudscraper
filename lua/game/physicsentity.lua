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

PhysicsEntity.cursor_joints = {}
PhysicsEntity.body = nil
PhysicsEntity.shape = nil
PhysicsEntity.fixture = nil
PhysicsEntity.world = nil

function PhysicsEntity:init( world, x, y, type )
    self.world = world
    self.body = love.physics.newBody( world.world, x, y, type )
    self.cursor_joints = {}

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
    if self.cursor_joints[target] then
        self:stop_mouse_joint( target )
    end

    self.cursor_joints[target] = love.physics.newMouseJoint( self.body, x, y )
    --self.mouse_joint_target = target
end

function PhysicsEntity:stop_mouse_joint( target )
    if not target then
        for target, joint in pairs( self.cursor_joints ) do
            self:stop_mouse_joint( target )
        end
    else
        if self.cursor_joints[target] and not self.cursor_joints[target]:isDestroyed() then
            self.cursor_joints[target]:destroy()
            self.cursor_joints[target] = nil
        end
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
    for target, joint in pairs( self.cursor_joints ) do
        joint:setTarget( Camera:get_world_pos( target.x, target.y ) )
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
