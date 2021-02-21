local gm = class()

function gm:construct()
    self.timer = 0
end

function gm:loadout( player )
    for id, v in pairs( Objects ) do
        if v.default_count then
            player:add_object( id, v.default_count )
        end
    end
end

function gm:update( dt )
    if not self.game.winner then
        self.timer = self.timer + dt
    end
end

function gm:draw()
    Camera:pop()
    draw_outlined_text( os.date( "%M:%S", self.timer ), Fonts.BIG, SCR_W / 2, SCR_H * .1, SCR_W / 2, "center", WHITE, 1 )
    Camera:push()
end

return gm