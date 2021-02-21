Cloud = class( GameObject )
Cloud.z = 3
Cloud.x, Cloud.y = 0, 0
Cloud.height = -500

Cloud.image = image( "clouds.png" )
Cloud.quads = tileset( Cloud.image, TEXTURE_SIZE * 2, TEXTURE_SIZE )
Cloud.quad_id = 1

Cloud.speed = 150

function Cloud:init( x, y )
    self.x, self.y = x, y
    self.z = math.random() * 10
    self.quad_id = math.random( #self.quads )

    self.alpha = math.min( self.z / 5, .65 )
    self.speed = ( math.min( .5 + math.random(), 1 ) ) * self.speed
end

function Cloud:update( dt )
    self.x = self.x + self.speed * dt
    if self.x > SCR_W then
        self.x = -pixel_to_meter( TEXTURE_SIZE * 2 )
    end
end

function Cloud:draw()
    love.graphics.setColor( { 1, 1, 1, self.alpha } )
    love.graphics.draw( self.image, self.quads[self.quad_id], self.x, self.y + math.sin( love.timer.getTime() * 1 / math.min( self.z, 2 ) ) * TEXTURE_SIZE - self.height + SCR_H, 0, 4, 4 )
end