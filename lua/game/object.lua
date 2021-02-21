require "lua.game.physicsentity"
require "lua.game.physicsrect"

Objects = require "lua.game.objects.*"

function create_object( id, x, y )
    assert( Objects[id], ( "Object %q doesn't exists!" ):format( id ) )
    
    local obj = Objects[id]
    local ent = PhysicsRect( love._scene.world, x, y, obj.w, obj.h )
    ent:set_image( obj.image or TILESET, obj.quads or TILESET_QUADS, obj.quad_id or 1, true )
    if obj.restitution then 
        ent:restitution( obj.restitution )  --  bouncing behaviour; default: 0
    end
    if obj.density then 
        ent:density( obj.density )  --  mass; default: 1
    end
    if obj.friction then
        ent:friction( obj.friction ) --  sliding behaviour; default: 0.2
    end

    ent.object_id = id
    return ent
end