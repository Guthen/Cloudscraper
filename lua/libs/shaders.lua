require "lua.libs.util"

--  colors
BLACK = rgb( 0, 0, 0 )
WHITE = rgb( 255, 255, 255 )

--  shaders
Shaders = {}

local path = "assets/shaders"
for i, v in ipairs( love.filesystem.getDirectoryItems( path ) ) do
    Shaders[v:gsub( "%.%w+$", "" ):upper()] = love.graphics.newShader( path .. "/" .. v )
end