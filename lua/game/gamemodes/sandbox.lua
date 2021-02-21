local gm = class()
gm.only_grab_owned_objects = false

function gm:construct()
end

function gm:loadout( player )
    for id, v in pairs( Objects ) do
        player:add_object( id, 99 )
    end

    return {
        border = false,
    }
end

function gm:update( dt )
end

function gm:draw()
end

return gm