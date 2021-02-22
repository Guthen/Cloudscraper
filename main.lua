--  pixel-art filter
love.graphics.setDefaultFilter( "nearest" )

--  global variables
DEBUG = false
SIZE_FACTOR = 3
SCR_W, SCR_H = 1280, 720
PX = 64
TEXTURE_SIZE = 16

Fonts = {
    NORMAL = love.graphics.newFont( "assets/fonts/vkx_pixel.ttf", 50 ),
    BIG = love.graphics.newFont( "assets/fonts/vkx_pixel.ttf", 100 ),
    ENORMOUS = love.graphics.newFont( "assets/fonts/vkx_pixel.ttf", 140 ),
}

VERSION = "v1.1.0"

function pixel_to_meter( px )
    return px * PX / TEXTURE_SIZE
end

--  dependencies
require "lua.libs.require"
require "lua.libs.*"

TILESET = image( "tileset.png" )
TILESET_QUADS = tileset( TILESET, TEXTURE_SIZE )

require "lua.gui.*"
require "lua.game.*"
require "lua.scenes.*"
require "lua.*"

--  framework
function love.load()
    love.graphics.setFont( Fonts.NORMAL )
    love.window.setMode( SCR_W, SCR_H )
    love.window.setTitle( "Cloudscraper" )
    love.graphics.setBackgroundColor( rgb( 36, 159, 222 ) )

    math.randomseed( os.time() )
    love.setScene( Menu )
end

function love.setScene( scene, ... )
    if love._scene then GameObjects.reset() end

    local args = { ... }
    timer( 0, function() 
        love._scene = scene( unpack( args ) )
    end )
end

function love.update( dt )
    GameObjects.call( "update", dt )
    
    --  Timers
    for k, v in pairs( Timers ) do
        v.time = v.time + dt
        if v.time >= v.max_time then
            v.callback()
            Timers[k] = nil
        end
    end
end

function love.keypressed( key )
    if key == "," then
        DEBUG = not DEBUG
    end

    GameObjects.call( "keypress", key )
end

function love.mousepressed( x, y, button )
    GameObjects.call( "mousepress", button, x, y )
end

function love.mousereleased( x, y, button )
    GameObjects.call( "mouserelease", button, x, y )
end

function love.gamepadpressed( joystick, button )
    GameObjects.call( "gamepadpress", joystick, button )
end

function love.gamepadreleased( joystick, button )
    GameObjects.call( "gamepadrelease", joystick, button )
end

--[[ function love.joystickadded( joystick )
    Player( joystick )
    print( "New player:", joystick )
end ]]

function love.joystickremoved( joystick )
    local player = Player.by_joystick( joystick )
    if player then
        player:destroy()
    end
end

function love.wheelmoved( x, y )
    GameObjects.call( "wheelmove", x, y )
end

function love.draw()
    love.graphics.setColor( WHITE )
    Camera:push()
    GameObjects.callSorted( "draw" )
    Camera:pop()
    
    love.graphics.setColor( WHITE )
    love.graphics.setFont( Fonts.NORMAL )
    love.graphics.origin()
    draw_outlined_text( love.timer.getFPS() .. " FPS", Fonts.NORMAL, 16, Fonts.NORMAL:getHeight(), SCR_W * .2, "left", WHITE, 1 )
    --if DEBUG then
        --love.graphics.print( "#Entities: " .. table_count( PhysicsEntities ), 5, 25 )
    --end
end
