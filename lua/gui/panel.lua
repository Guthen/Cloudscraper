Panel = class( GameObject )
Panel.z = 19.5
Panel.x, Panel.y = 0, 0
Panel._x, Panel._y = 0, 0
Panel.w, Panel.h = 50, 50
Panel.color = WHITE

Panel.abs_x, Panel.abs_y = nil, nil
Panel.children, Panel.parent = {}, nil

function Panel:init( parent )
    --[[ self.x, self.y = x or self.x, y or self.y
    self.w, self.h = w or self.w, h or self.h ]]
    if parent then
        self:set_parent( parent )
    end

    self.children = {}
end

function Panel:get_absolute_pos()
    --  return precomputed pos
    if self.abs_x and self.abs_y then
        return self.abs_x, self.abs_y
    end

    --  compute pos else
    local x, y = self.x, self.y

    local parent = self.parent
    while parent do
        x, y = x + parent.x, y + parent.y
        parent = parent.parent
    end

    self.abs_x, self.abs_y = x, y
    return x, y
end

function Panel:set_pos( x, y )
    self.x = x
    self.y = y
    
    self._x, self._y = self.x, self.y

    --  perform layout
    for i, v in ipairs( { self, unpack( self.children ) } ) do
        v.abs_x, v.abs_y = nil
        v:get_absolute_pos()
    end
end

function Panel:set_size( w, h )
    self.w = w or self.w
    self.h = h or self.h
end

function Panel:size_to_children( size_x, size_y )
    local max_w, max_h = 0, 0

    size_x = size_x == nil and true or size_x
    size_y = size_y == nil and true or size_y

    for i, v in ipairs( self.children ) do
        max_w = math.max( max_w, v.x + v.w )
        max_h = math.max( max_h, v.y + v.h )
    end

    self:set_size( size_x and max_w or self.w, size_y and max_h or self.h )
end

function Panel:set_parent( parent )
    self.parent = parent
    self.parent.children[#self.parent.children + 1] = self
    self.z = self.parent.z - 1

    self:set_pos( self.x, self.y )
end

function Panel:gamepadpress( joystick, button )
    local time = round( love.timer.getTime(), 1 )

    local player = Player.by_joystick( joystick )
    if player and player.joystick_nav_mode == self and not ( player.joystick_nav_time == time ) then
        if button == "dpright" and self.nav_next then
            player.joystick_nav_mode = self.nav_next
            player.joystick_nav_time = time
        elseif button == "dpleft" and self.nav_previous then
            player.joystick_nav_mode = self.nav_previous
            player.joystick_nav_time = time
        end
    end
end

function Panel:update( dt )
    --  hovered
    for i, v in ipairs( Players ) do
        if not self.filter or ( self.filter == v ) then 
            self.is_hovered = collide( self.abs_x, self.abs_y, self.w, self.h, v.x, v.y, 1, 1 ) and v
            if self.is_hovered then
                break
            end
        end
    end

    --  nav mode with left stick
    local player = self.is_hovered and self.is_hovered.joystick and self.is_hovered
    if player then
        --[[ local time = round( love.timer.getTime(), 0 )
        if not ( player.joystick_nav_time == time ) then
            local x = round( player.joystick:getAxis( 2 ), 0 )
            if x > 0 and self.nav_next then
                player.joystick_nav_mode = self.nav_next
                player.joystick_nav_time = time
            elseif x < 0 and self.nav_previous then
                player.joystick_nav_mode = self.nav_previous
                player.joystick_nav_time = time
            end
        end ]]
        if not ( round( player.joystick:getAxis( 1 ), 0 ) == 0 ) then
            player.joystick_nav_mode = false
        end
    end

    self:think( dt )
end

function Panel:think( dt )
end

function Panel:draw( w, h, force, is_first )
    if not ( force == true ) and self.parent then return end --  > draw only if forced when parented

    is_first = is_first == nil or is_first == true
    if is_first then
        Camera:pop()
    end

    love.graphics.push()
    love.graphics.translate( self.x, self.y )

    self:paint( self.w, self.h )
    for i, v in ipairs( self.children ) do
        v:draw( w, h, true, false )
    end

    love.graphics.pop()
    
    if is_first then
        Camera:push()
    end
end

function Panel:paint( w, h )
    love.graphics.setColor( self.color )
    love.graphics.rectangle( "fill", 0, 0, w, h )
end

function Panel:destroy()
    for i, v in ipairs( self.children ) do
        v:destroy()
    end

    GameObject.destroy( self )
end