Game = class( GameObject )
Game.z = 19
Game.camera_speed = 1000

Game.scoring_players = {} --  list of players waiting to be checked (some seconds before confirm wins)
Game.scoring_time = 4 --  3s before wins
Game.winner = nil

Game.text_scale = 0

Gamemodes = require "lua.game.gamemodes.*"

function Game:init( gm_id )
    --  load gamemode
    self.gm = Gamemodes[gm_id]()
    self.gm.game = self

    --  init
    self.scoring_players = {}
    self.winner = nil
    self.text_scale = 0

    --  world
    self.world = World( PX )
    self.world.world:setCallbacks( 
        function( ... )
            self:physics_begin_contact( ... )
        end, 
        function( ... )
            self:physics_end_contact( ... )
        end,
        function( ... )
            self:physics_pre_solve( ... )
        end,
        function( ... )
            self:physics_post_solve( ... )
        end
    )

    local diff = pixel_to_meter( PX )
    self.max_height = pixel_to_meter( 250 )
    Cloud.height = self.max_height - diff

    --  create clouds
    local max_clouds = 50
    for i = 1, max_clouds do
        Cloud( math.random( max_clouds ) * SCR_W / max_clouds, -i * TEXTURE_SIZE / 8 )
    end

    print( "Max Height: " .. self.max_height, "Clouds Height: " .. Cloud.height, "N-Clouds: " .. max_clouds )

    --  init players
    --[[ Player.reset()
    for i, v in ipairs( love.joystick.getJoysticks() ) do
        Player( v )
    end
    if #Players == 0 then
        Player()
    end
    Player() ]]
    --[[ Player()
    Player() ]]

    --  re-add players
    for i, v in ipairs( Players ) do
        GameObjects.add( v )
        v.inventory, v.objects = {}, {}
        v.joystick_nav_mode = nil
    end

    love.mouse.setVisible( false )

    local border_width = SCR_W / #Players
    for i, v in ipairs( Players ) do
        v.center_x = ( i - 1 ) * border_width + border_width / 2

        v:popup_inventory()

        local result = self.gm:loadout( v )
        if not result or ( result and not ( result.border == false ) ) or i == #Players then
            Edge( self.world, i * border_width, -self.max_height + SCR_H - diff, self.max_height + diff ) --  right
        end
    end
    --self.winner = Players[1]

    --  create map bounds
    local ground_offset = PX
    local ground = Ground( self.world, SCR_W / 2 - ground_offset, SCR_H - PX, SCR_W + ground_offset * 2, PX * 2 ) --  ground (bottom)
    Edge( self.world, 0, -self.max_height + SCR_H - diff, self.max_height + diff ) --  left
    --PhysicsEntity( self.world, SCR_W, -self.max_height + SCR_H - diff ):edge( 0, 0, 0, self.max_height + diff ) --  right
    PhysicsEntity( self.world, 0, -self.max_height + SCR_H - diff ):edge( 0, 0, SCR_W, 0 ) --  top

    --  bind camera map bounds
    Camera.bounds.min_x = 0 
    Camera.bounds.min_y = -self.max_height + SCR_H
    Camera.bounds.max_x = SCR_W
    Camera.bounds.max_y = 0
end

--  physics
function Game:physics_begin_contact( a, b, contact )
    Camera:shake( math.max( a:getBody():getAngularVelocity(), b:getBody():getAngularVelocity() ) )
end

function Game:physics_end_contact( a, b, contact )
end

function Game.physics_pre_solve( ... )
end

function Game:physics_post_solve( a, b, contact )
    --  destroy objects colliding with edges
    if a:getUserData() == "edge" then
        for i, v in ipairs( PhysicsEntities ) do
            if b == v.fixture then
                if v.owner and v.object_id then
                    v.owner:add_object( v.object_id )
                end
                --timer( 0, function() 
                    v:destroy()
                --end )
                break
            end
        end
    elseif b:getUserData() == "edge" then
        for i, v in ipairs( PhysicsEntities ) do
            if a == v.fixture then
                if v.owner and v.object_id then
                    v.owner:add_object( v.object_id )
                end
                --timer( 0, function() 
                    v:destroy()
                --end )
                break
            end
        end
    end
end

--  love
function Game:keypress( key )
    if key == "escape" then
        love.setScene( Menu )
    end
end

function Game:update( dt )
    --  score
    if not self.winner then
        for i, v in ipairs( Players ) do
            if Cloud.height - v:get_score() > Cloud.height then
                --print( v:get_score(), Cloud.height, self.scoring_players[v] )
                self.scoring_players[v] = self.scoring_players[v] or self.scoring_time
                if self.scoring_players[v] > 0 then
                    self.scoring_players[v] = self.scoring_players[v] - dt
                else
                    self.winner = v
                    self.text_scale = 0
                end
            else
                self.scoring_players[v] = nil
            end
        end
    end

    --  camera
    Camera:update( dt )

    --  sort gameobjects (z-order)
    GameObjects.sort( function( a, b )
        return ( a.z or 0 ) < ( b.z or 0 )
    end )

    --  gamemode
    self.gm:update( dt )
end

local line_height, line_width, line_space = pixel_to_meter( 2 ), pixel_to_meter( 5 ), pixel_to_meter( 2 )
function Game:draw()
    --  height
    love.graphics.setColor( WHITE )
    for x = 0, SCR_W, line_width + line_space do
        love.graphics.rectangle( "fill", x + ( love.timer.getTime() * 25 ) % ( line_width + line_space ), -Cloud.height + SCR_H - line_height / 2, line_width, line_height )
    end

    --  players
    Camera:pop()
    if self.winner then
        local limit = 500

        self.text_scale = lerp( love.timer.getDelta() * 6, self.text_scale, 1 )

        draw_outlined_text( ( "Player %d wins!" ):format( self.winner.player_id ), Fonts.BIG, SCR_W / 2, SCR_H / 2, limit, "center", self.winner.color, self.text_scale )
        if round( love.timer.getTime() * 1.5, 0 ) % 2 == 0 then
            draw_outlined_text( ( "Press START to quit the party." ), Fonts.BIG, SCR_W / 2, SCR_H / 2 + Fonts.BIG:getHeight() / 2, limit * 2, "center", WHITE, self.text_scale / 2 )
        end
    else
        local limit = 300
        for ply, time in pairs( self.scoring_players ) do
            if round( time, 1 ) == round( time, 0 ) then
                self.text_scale = .5
            end
            self.text_scale = lerp( love.timer.getDelta() * 6, self.text_scale, 1.5 )
            draw_outlined_text( round( time, 0 ), Fonts.ENORMOUS, SCR_W / 2, SCR_H / 2, limit, "center", ply.color, self.text_scale )
        end
    end

    if DEBUG then
        local limit = 500
        for i, v in ipairs( Players ) do
            love.graphics.setColor( v.color )
            love.graphics.printf( ( "%d - %s" ):format( v.id, v.joystick and v.joystick:getName() or "Mouse/Keyboard" ), SCR_W - 16 - limit, love.graphics.getFont():getHeight() * ( i - 1 ) + 8, limit, "right" )
        end
    end
    Camera:push()

    --  gamemode
    self.gm:draw()
end

function Game:destroy()
    GameObject.destroy( self )

    --Player.reset()
    Camera:reset()
end