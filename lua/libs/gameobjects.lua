--  GameObjects
GameObjects = {}
local objects, sorted_objects, id = {}, {}, 0

--  @function GameObjects.call
--      | description: Call every GameObject on specified function
--      | params:
--          string key: Function's key/name to call
--          varargs ...: All parameters to pass in the function's call
function GameObjects.call( key, ... )
    for k, v in pairs( objects ) do
        v[key]( v, ... )
    end
end

--  @function GameObjects.callSorted
--      | description: Call every sorted GameObject on specified function
--      | params:
--          string key: Function's key/name to call
--          varargs ...: All parameters to pass in the function's call
function GameObjects.callSorted( key, ... )
    for i, v in ipairs( sorted_objects ) do
        v[key]( v, ... )
    end
end

--  @function GameObjects.sort
--      | description: Sort every GameObject, usefull for GameObjects.callSorted
--      | params:
--          function callback: sort callback, used by table.sort
function GameObjects.sort( callback )
    table.sort( sorted_objects, callback )
end

--  @function GameObjects.reset
--      | description: Destroy every GameObject and reset all internal variables
function GameObjects.reset()
    GameObjects.call( "destroy", true )
    objects, sorted_objects, id = {}, {}, 0
end

function GameObjects.add( object )
    id = id + 1
    object.id = id
    objects[object.id] = object
    sorted_objects[#sorted_objects + 1] = object
end

--  @class GameObject
--      | description: 
--          Represent a game object in the game world. A game object has an update and a draw phase, 
--          both called each frame.
--      | member:
--          GameObject:construct
--          GameObject:init
--          GameObject:update
--          GameObject:keypress
--          GameObject:mousepress
--          GameObject:wheelmove
--          GameObject:draw
--          GameObject:destroy
GameObject = class()
GameObject._valid = true

--  @function GameObject:construct
--      | description: Construct GameObject : called when a new instance is created
function GameObject:construct( ... )
    GameObjects.add( self )

    self:init( ... )
end

--  @function GameObject:init
--      | description: Initialize GameObject
--      | params:
--          varargs args: Arguments passed by constructor
function GameObject:init( ... )
end

--  @function GameObject:update
--      | description: Update GameObject
--      | params:
--          number dt: Delta-Time between last frame and current frame
function GameObject:update( dt )
end

--  @function GameObject:keypress
--      | description: Called when a key has been pressed on keyboard
--      | params:
--          string key: Key name which has been pressed
function GameObject:keypress( key )
end

--  @function GameObject:mousepress
--      | description: Called when a mouse button has been pressed
--      | params:
--          number button: Mouse button which has been pressed
--          number x: Mouse x-position
--          number y: Mouse y-position
function GameObject:mousepress( button, x, y )
end

function GameObject:mouserelease( button, x, y )
end

function GameObject:gamepadpress( joystick, button )
end

function GameObject:gamepadrelease( joystick, button )
end

--  @function GameObject:wheelmove
--      | description: Called when the mouse wheel has been moved
--      | params:
--          number x: Mouse x-position
--          number y: Mouse y-position
function GameObject:wheelmove( x, y )
end

--  @function GameObject:draw
--      | description: Draw GameObject
function GameObject:draw()
end

--  @function GameObject:destroy
--      | description: Destroy GameObject
function GameObject:destroy()
    self._valid = false
    objects[self.id] = nil

    --  Remove from sorted
    for i, v in ipairs( sorted_objects ) do
        if not objects[v.id] then
            table.remove( sorted_objects, i )
            break
        end
    end
end