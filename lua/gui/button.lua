require "lua.gui.panel"

Button = class( Panel )

function Button:mousepress( button, x, y )
    local player = Player.by_joystick()
    if self.is_hovered == player and collide( self.abs_x, self.abs_y, self.w, self.h, x, y, 1, 1 ) then
        self:click( button, x - self.x, y - self.y )
    end
end

function Button:gamepadpress( joystick, button )
    Panel.gamepadpress( self, joystick, button )
    if not ( button == "a" ) then return end

    local player = Player.by_joystick( joystick )
    if player and self.is_hovered == player then
        self:click( 1, player.x - self.x, player.y - self.y )
    end
end

function Button:click( button, x, y )
    --  > override
end