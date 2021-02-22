Players = {}
PlayerColors = {
    rgb( 223, 62, 35 ), --  red
    rgb( 40, 92, 196 ), --  blue
    rgb( 20, 160, 46 ), --  green
    rgb( 188, 74, 155 ), --  pink
}

Player = class( GameObject )
Player.z = 20
Player.x, Player.y = 0, 0
Player.score = 0
Player.player_id = 1
Player.color = WHITE
Player.image = image( "cursor.png" )
Player.cursor_scale = 2

Player.inventory, Player.objects = {}, {}
Player.grabbed_object = nil

Player.joystick = nil --  use mouse/keyboard if nil (else gamepad)
Player.joystick_sensibility = 10 --  px/frame

Player.rotate_speed = 5

function Player:init( joystick )
    self.joystick = joystick

    --  increase id for next player
    self.player_id = Player.player_id
    Player.player_id = Player.player_id + 1
    
    self.z = Player.z + self.player_id
    self.inventory, self.objects = {}, {}
    self.color = PlayerColors[self.player_id] or WHITE

    Players[self.player_id] = self
end

function Player:add_object( id, count )
    if not self.inventory[id] then
        self.inventory[id] = {
            current = count,
            max = count,
        }
    else
        self.inventory[id].current = self.inventory[id].current + ( count or 1 )
    end

    self:refresh_inventory()
end

function Player:spawn_object( id, x, y )
    if not self.inventory[id] or self.inventory[id].current <= 0 then return end
    self.inventory[id].current = self.inventory[id].current - 1

    --  spawn
    local ent = create_object( id, x, y, self )
    ent.owner = self
    self.objects[ent] = true
    return ent
end

function Player:refresh_inventory()
    if not self.panel then return end

    --  avoid multiple calls
    timer( 0, function()
        self:popup_inventory()
    end, ( "player_%d_inventory" ):format( self.player_id ) )
end

function Player:popup_inventory()
    if self.panel then self.panel:destroy() end

    local player = self

    local panel = Panel()
    panel:set_pos( self.center_x, 64 )
    panel:set_size( 146 )
    panel.color = { .2, .2, .2, .5 }
    if player.joystick then
        function panel:think( dt )
            if player.joystick_nav_mode then
                local obj = player.joystick_nav_mode
                player.x, player.y = obj.abs_x + obj.w / 2, obj.abs_y + obj.h / 2
            end
        end
    end

    local i = 1
    local x, y = 0, 0
    local padding = 4
    local button_size = ( panel.w - padding * 3 ) / 2
    for id, count in pairs( self.inventory ) do
        --  button
        local obj = Objects[id]
        local button = Button( panel )
        button:set_pos( padding * ( x + 1 ) + button_size * x, padding * ( y + 1 ) + button_size * y )
        button:set_size( button_size, button_size )
        button.filter = player
        function button:paint( w, h )
            --  background
            love.graphics.setColor( panel.color )
            love.graphics.rectangle( "fill", 0, 0, w, h )

            --  image
            love.graphics.setColor( count.current <= 0 and { 1, 1, 1, .5 } or self.is_hovered and { 1, 1, 1, .85 } or WHITE )

            local quad = ( obj.quads or TILESET_QUADS )[obj.quad_id]
            local viewport_w, viewport_h = select( 3, quad:getViewport() )
            local scale = math.min( w / viewport_w, h / viewport_h )
            love.graphics.draw( TILESET, quad, w / 2, h / 2, 0, scale, scale, viewport_w / 2, viewport_h / 2 )

            --  count
            draw_outlined_text( count.current .. "/" .. count.max, Fonts.NORMAL, w / 2 + 4, h, w * 2, "center", WHITE, 1 )
        end
        function button:click( button )
            if player.grabbed_object then return end
            if not ( button == 1 ) then return end

            --  check for no collision
            local x, y = Camera:get_world_pos( player.x, player.y )
            for i, v in ipairs( PhysicsEntities ) do
                if v.fixture:testPoint( x, y ) then
                    return false
                end
            end

            --  check availability
            local obj = player:spawn_object( id, x, y )
            if not obj then return end

            player.grabbed_object = obj
            timer( 0.05, function() --  let world compute some physics (else too static)
                if player.grabbed_object then
                    player.grabbed_object:start_mouse_joint( player, x, y )
                end
            end )
            player.joystick_nav_mode = false
        end

        --  nav
        if player.joystick then
            if panel.children[i - 1] then
                panel.children[i - 1].nav_next = button
                button.nav_previous = panel.children[i - 1]
            end
        end

        --  position
        x = x + 1
        if x >= 3 then
            x = 0
            y = y + 1
        end
        i = i + 1
    end

    --  nav
    if player.joystick then
        if panel.children[1] then
            panel.children[1].nav_previous = panel.children[#panel.children]
            panel.children[#panel.children].nav_next = panel.children[1]
        end
    end
    
    --  size
    panel:size_to_children( true, true )
    panel.w = panel.w + padding
    panel.h = panel.h + padding

    --  center
    panel:set_pos( panel.x - panel.w / 2, panel.y )

    self.panel = panel
end

Player.highest_object = nil
function Player:get_score()
    local score = SCR_H

    --  don't allow player to win by holding an object
    --[[ if self.grabbed_object and self.highest_object then 
        local y = self.grabbed_object.body:getY()
        return self.score < y and y or self.score
    end ]]

    for v in pairs( self.objects ) do
        local x, y = v.body:getLinearVelocity()
        x, y = round( x / 10, 0 ), round( y / 10, 0 )
        if not ( self.grabbed_object == v ) and x <= 1 and x >= -1 and y <= 1 and y >= -1 and #v.body:getContacts() > 0 then
            local max_y = v.body:getY()
            local points = { v.body:getWorldPoints( v.shape:getPoints() ) }
            for i = 2, #points, 2 do
                max_y = math.min( max_y, points[i] )
            end
            
            score = math.min( score, max_y )
        end
    end

    self.score = score
    return score
end

function Player.by_joystick( joystick )
    for i, v in ipairs( Players ) do
        if v.joystick == joystick then
            return v
        end
    end
end

function Player.reset()
    for i, v in ipairs( Players ) do
        v:destroy()
    end
    Player.player_id = 1
end

function Player:pickup_object_at( x, y )
    for i, v in ipairs( PhysicsEntities ) do
        if v.body:getType() == "dynamic" and ( not v.owner or love._scene.gm.only_grab_owned_objects == false or v.owner == self ) then
            if v.fixture:testPoint( x, y ) then
                v:start_mouse_joint( self, x, y )
                self.grabbed_object = v
            end
        end
    end
end

function Player:drop_object()
    if self.grabbed_object then
        self.grabbed_object:stop_mouse_joint()
        self.grabbed_object = nil
        self.grabbed_object_rotated = nil
    end
end

function Player:set_nav_mode( obj_focus )
    if not self.joystick then return end

    if obj_focus then
        self.joystick_nav_mode = obj_focus
        self.last_x, self.last_y = self.x, self.y
    else
        self.joystick_nav_mode = false
        self.x, self.y = self.last_x, self.last_y
    end
end

function Player:mousepress( button, x, y )
    if self.joystick then return end
    self:pickup_object_at( Camera:get_world_pos( x, y ) )
end

function Player:mouserelease( x, y, button )
    if self.joystick then return end
    self:drop_object()
end

function Player:gamepadpress( joystick, button )
    if not ( joystick == self.joystick ) then return end

    if button == "a" then
        self:pickup_object_at( Camera:get_world_pos( self.x, self.y ) )
    elseif button == "y" then
        if class.instanceOf( love._scene, Game ) then
            self:set_nav_mode( not self.joystick_nav_mode and self.panel and self.panel.children[1] )
        end
    elseif button == "start" and class.instanceOf( love._scene, Game ) then
        love.setScene( Menu )
    end
end

function Player:gamepadrelease( joystick, button )
    if not ( joystick == self.joystick ) then return end

    if button == "a" then
        self:drop_object()
    end
end

function Player:update( dt )
    --  mouse/keyboard
    if not self.joystick then
        --  cursor movement
        self.x, self.y = love.mouse.getPosition()

        --  camera movement
        if class.instanceOf( love._scene, Game ) then
            local y = 0
            if love.keyboard.isDown( "z" ) then
                y = y - 1
            end
            if love.keyboard.isDown( "s" ) then
                y = y + 1
            end

            local speed = dt * Game.camera_speed
            Camera:move( 0, y * speed )
        end
    --  gamepad
    else
        --  cursor movement
        local x, y = self.joystick:getGamepadAxis( "leftx" ), round( self.joystick:getGamepadAxis( "lefty" ), 1 )
        if x > -0.1 and x < 0.1 then
            x = 0
        end
        self.x = clamp( self.x + x * self.joystick_sensibility, 0, SCR_W )
        self.y = clamp( self.y + y * self.joystick_sensibility, 0, SCR_H )

        --  camera movement
        if class.instanceOf( love._scene, Game ) then
            local y = self.joystick:getGamepadAxis( "righty" )
            if y > -0.1 and y < 0.1 then
                y = 0
            end

            if not ( y == 0 ) then
                Camera:move( 0, y * Game.camera_speed * dt )
            end

            --  object rotation
            if self.grabbed_object and not self.grabbed_object.body:isDestroyed() then
                local rot = 0
                if self.joystick:isGamepadDown( "rightshoulder" ) then
                    rot = rot + dt * self.rotate_speed
                end
                if self.joystick:isGamepadDown( "leftshoulder" ) then
                    rot = rot - dt * self.rotate_speed
                end

                if not ( rot == 0 ) then
                    self.grabbed_object_rotated = true
                    self.grabbed_object.body:setAngle( self.grabbed_object.body:getAngle() + rot )
                end

                if self.grabbed_object_rotated then
                    self.grabbed_object.body:setAngularVelocity( 0 )
                end
            end
        end
    end

    --  cursor
    for i, v in ipairs( PhysicsEntities ) do
        if v.body:getType() == "dynamic" then
            if v.fixture:testPoint( Camera:get_world_pos( self.x, self.y ) ) then
                self.cursor_scale = Player.cursor_scale * 1.1
                return
            end
        end
    end

    self.cursor_scale = Player.cursor_scale
end

function Player:draw()
    Camera:pop()

    love.graphics.setColor( self.color )
    love.graphics.draw( self.image, self.x, self.y, 0, self.cursor_scale )

    Camera:push()

    --  score line
    if class.instanceOf( love._scene, Game ) then
        self.anim_score = lerp( love.timer.getDelta() * 5, self.anim_score or 0, self:get_score() )
        local line_height, line_width, line_space = pixel_to_meter( 1 ), pixel_to_meter( 3 ), pixel_to_meter( 1.5 )
        for x = 0, SCR_W, line_width + line_space do
            love.graphics.rectangle( "fill", x + ( love.timer.getTime() * 25 ) % ( line_width + line_space ) - line_width, math.min( self.anim_score, SCR_H - PX * 2 ) - line_height / 2, line_width, line_height )
        end
    end
end

function Player:destroy( is_reset )
    if is_reset then return end

    GameObject.destroy( self )

    --  remove players from table
    table.remove( Players, self.player_id )

    --  reattribute id
    local id = 1
    for k, v in pairs( Players ) do
        v.color = PlayerColors[id]
        v.player_id = id
        id = id + 1
    end
    Player.player_id = id
end