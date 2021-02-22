Menu = class( GameObject )
Menu.z = 20
Menu.buttons = {
    {
        text = "Sandbox",
        color = WHITE,
        action = function()
            love.setScene( Game, "sandbox" )
        end,
    },
    {
        text = "Race",
        color = WHITE,
        action = function()
            love.setScene( Game, "race" )
        end,
    },
    {
        text = "Quit",
        color = WHITE,
        action = function()
            love.event.quit( 1 )
        end,
    },
}

local button_wide, button_tall, button_height = SCR_W * .4, SCR_H * .08, SCR_H * .2
function Menu:init()
    local panel = Panel()
    panel:set_pos( 0, 0 )
    panel.paint = function() end
    function panel:think( dt )
        for i, v in ipairs( Players ) do
            if v.joystick_nav_mode then
                local obj = v.joystick_nav_mode
                v.x, v.y = obj.abs_x + obj.w / 2, obj.abs_y + obj.h / 2
            end
        end
    end
    self.panel = panel

    --  buttons
    local i = 0
    local buttons = {}
    for i, v in ipairs( self.buttons ) do
        local button = Button( panel )
        button:set_pos( 0, button_height + i * button_tall * 2 )
        button:set_size( button_wide, button_tall )
        button.click = v.action
        button.lerp_w = .9
        button.z = 6
        function button:paint( w, h )
            self.lerp_w = lerp( love.timer.getDelta() * 6, self.lerp_w, self.is_hovered and 1.1 or .9 )

            if self.is_hovered then
                self.color = self.is_hovered.color
            else
                self.color = WHITE
            end

            love.graphics.setColor( { self.color[1], self.color[2], self.color[3], self.is_hovered and .75 or .5 } )
            love.graphics.polygon( "fill", 0, 0, w * self.lerp_w, 0, w * ( self.lerp_w - .1 ), h, 0, h )
            
            local offset = 6
            love.graphics.setColor( { 0, 0, 0, self.is_hovered and .25 or .1 } )
            love.graphics.polygon( "fill", 0, offset, w * self.lerp_w + offset, offset, w * ( self.lerp_w - .1 ) + offset, h + offset, 0, h + offset )

            local limit = 400
            draw_outlined_text( v.text, Fonts.BIG, w / 10 * self.lerp_w, h + 2, limit, "left", self.color, 1 )
        end
        buttons[i] = button

        --  nav
        if buttons[i - 1] then
            button.nav_previous = buttons[i - 1]
            buttons[i - 1].nav_next = button
        end

        i = i + 1
    end

    --  button nav
    buttons[1].nav_previous = buttons[#buttons]
    buttons[#buttons].nav_next = buttons[1]

    --  clouds
    Cloud.height = SCR_H * .69
    local max_clouds = 50
    for i = 1, max_clouds do
        Cloud( math.random( max_clouds ) * SCR_W / max_clouds, -i * TEXTURE_SIZE / 8 )
    end

    --  players
    --Player.reset()
    if #Players == 0 then
        for i, v in ipairs( love.joystick.getJoysticks() ) do
            Player( v ):set_nav_mode( buttons[1] )
            v:setVibration( .3, .3, .2 )
        end
        if #Players == 0 then
            Player()
        end
    else
        --  re-add players
        for i, v in ipairs( Players ) do
            GameObjects.add( v )
            v.joystick_nav_mode = nil
        end
    end
    love.mouse.setVisible( false )

    --  world scene
    self.world = World( PX )
    self.world.world:setCallbacks( 
        function( ... )
            Game:physics_begin_contact( ... )
        end, 
        function( ... )
            Game:physics_end_contact( ... )
        end,
        function( ... )
            Game:physics_pre_solve( ... )
        end,
        function( ... )
            Game:physics_post_solve( ... )
        end
    )

    local ground_x, ground_y, offset = SCR_W * .75, SCR_H - PX / 2, PX
    Ground( self.world, SCR_W / 2, ground_y, SCR_W + offset, PX )
    timer( 0, function()
        for i = 0, 2 do
            create_object( "beam", ground_x + PX * i, ground_y - PX * 1.5 )
            create_object( "crate", ground_x + PX * i, ground_y - PX * 1.5 * 2 )
        end

        create_object( "beam", ground_x + PX, ground_y - PX * 1.5 * 3 )
        create_object( "barrel", ground_x + PX, ground_y - PX * 2 * 7.5 )
    end )
end

function Menu:update( dt )
    --  sort gameobjects (z-order)
    GameObjects.sort( function( a, b )
        return ( a.z or 0 ) < ( b.z or 0 )
    end )

    Camera:update( dt )
end

function Menu:keypress( key )
    if key == "escape" then
        love.event.quit( 1 )
    elseif key == "space" then
        if not Player.by_joystick() then
            Player()
        end
    end
end

function Menu:gamepadpress( joystick, button )
    if button == "start" and not Player.by_joystick( joystick ) then
        Player( joystick ):set_nav_mode( self.panel.children[1] )
        joystick:setVibration( .3, .3, .2 )
    end
end

function Menu:draw()
    local limit = SCR_W * .5
    draw_outlined_text( "Cloudscraper", Fonts.ENORMOUS, button_wide / 15, button_height * .5 + button_tall * 1.5, limit, "left", WHITE, 1 )
    
    
    draw_outlined_text( VERSION, Fonts.NORMAL, 16, SCR_H, limit, "left", WHITE, 1 )
    draw_outlined_text( "Guthen @2021", Fonts.NORMAL, SCR_W - button_wide * .01, SCR_H, limit, "right", WHITE, 1 )
end

function Menu:destroy()
    GameObject.destroy( self )

    --Player.reset()
    Camera:reset()
end